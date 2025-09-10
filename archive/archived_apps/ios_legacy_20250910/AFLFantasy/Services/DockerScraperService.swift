import Combine
import Foundation

// MARK: - DockerScraperService

/// Service that integrates with the running Docker AFL Fantasy scraper
@MainActor
final class DockerScraperService: ObservableObject {
    // MARK: - Published Properties

    @Published var isConnected = false
    @Published var lastUpdate: Date?
    @Published var connectionError: Error?

    // MARK: - Private Properties

    private let session: URLSession
    private let baseURL: URL
    private let decoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()
    private let logger = AFLLogger.Category.network.logger

    // MARK: - Initialization

    init(baseURL: String = DockerScraperConfig.baseURL) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid Docker scraper base URL: \(baseURL)")
        }

        self.baseURL = url

        // Configure URLSession for Docker integration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = DockerScraperConfig.timeout
        config.timeoutIntervalForResource = DockerScraperConfig.timeout * 2
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config)

        // Configure JSON decoder for AFL Fantasy date formats
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Handle multiple date formats from the scraper
            let formatters = [
                ISO8601DateFormatter(),
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                    return formatter
                }(),
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                    return formatter
                }()
            ]

            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date from: \(dateString)"
            )
        }

        startHealthCheck()
    }

    // MARK: - Public API Methods

    /// Fetch all players from Docker scraper
    func fetchAllPlayers() async throws -> [Player] {
        let endpoint = DockerAPIEndpoint.players
        let response: ScraperResponse<PlayerDataResponse> = try await makeRequest(endpoint)

        guard response.success, let playerDataResponse = response.data else {
            throw NetworkError.scraperError(response.error ?? "Failed to fetch players")
        }

        return playerDataResponse.players.compactMap { $0.toPlayer() }
    }

    /// Fetch specific player by ID
    func fetchPlayer(id: String) async throws -> Player {
        let endpoint = DockerAPIEndpoint.playerById(id)
        let response: ScraperResponse<PlayerData> = try await makeRequest(endpoint)

        guard response.success, let playerData = response.data else {
            throw NetworkError.scraperError(response.error ?? "Failed to fetch player")
        }

        guard let player = playerData.toPlayer() else {
            throw NetworkError.decodingError(NSError(domain: "Player conversion failed", code: -1))
        }

        return player
    }

    /// Fetch team data from Docker scraper
    func fetchTeamData(teamId: String) async throws -> TeamData {
        let endpoint = DockerAPIEndpoint.teamData(teamId)
        let response: ScraperResponse<TeamDataResponse> = try await makeRequest(endpoint)

        guard response.success, let teamDataResponse = response.data else {
            throw NetworkError.scraperError(response.error ?? "Failed to fetch team data")
        }

        return TeamData(
            teamId: teamDataResponse.teamId,
            teamName: teamDataResponse.teamName,
            teamValue: teamDataResponse.teamValue,
            totalScore: teamDataResponse.totalScore,
            overallRank: teamDataResponse.rank,
            tradesRemaining: teamDataResponse.trades,
            roundsPlayed: 1, // Would be calculated from current round
            players: teamDataResponse.players.compactMap { $0.toPlayer() },
            lastUpdated: teamDataResponse.lastUpdated
        )
    }

    /// Fetch live scores from Docker scraper
    func fetchLiveScores() async throws -> LiveScores {
        let endpoint = DockerAPIEndpoint.liveScores
        let response: ScraperResponse<LiveDataResponse> = try await makeRequest(endpoint)

        guard response.success, let liveDataResponse = response.data else {
            throw NetworkError.scraperError(response.error ?? "Failed to fetch live scores")
        }

        return LiveScores(
            matches: liveDataResponse.matches.map { matchData in
                Match(
                    id: matchData.id,
                    homeTeam: matchData.homeTeam,
                    awayTeam: matchData.awayTeam,
                    homeScore: matchData.homeScore,
                    awayScore: matchData.awayScore,
                    quarter: matchData.quarter,
                    timeRemaining: matchData.timeRemaining ?? "",
                    isComplete: matchData.isComplete
                )
            },
            lastUpdated: liveDataResponse.lastUpdated,
            isLive: liveDataResponse.isLive
        )
    }

    /// Fetch historical data for AI analysis
    func fetchHistoricalData(playerId: String, seasons: Int = 3) async throws -> HistoricalPerformance {
        let endpoint = DockerAPIEndpoint.historicalData(playerId: playerId, seasons: seasons)
        let response: ScraperResponse<[String: Any]> = try await makeRequest(endpoint)

        guard response.success, let historyData = response.data else {
            throw NetworkError.scraperError(response.error ?? "Failed to fetch historical data")
        }

        guard let performance = HistoricalPerformance.fromScraperData(historyData) else {
            throw NetworkError.decodingError(NSError(domain: "Historical data conversion failed", code: -1))
        }

        return performance
    }

    // MARK: - Health Check

    private func startHealthCheck() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.checkConnection()
                }
            }
            .store(in: &cancellables)

        // Initial connection check
        Task {
            await checkConnection()
        }
    }

    private func checkConnection() async {
        do {
            let healthURL = baseURL.appendingPathComponent("/health")
            let (_, response) = try await session.data(from: healthURL)

            if let httpResponse = response as? HTTPURLResponse,
               200 ... 299 ~= httpResponse.statusCode {
                isConnected = true
                connectionError = nil
                lastUpdate = Date()
                logger.info("Docker scraper connection healthy")
            } else {
                isConnected = false
                connectionError = NetworkError.dockerUnavailable
                logger.warning("Docker scraper health check failed - invalid response")
            }
        } catch {
            isConnected = false
            connectionError = error
            logger.error("Docker scraper health check failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Request Methods

    private func makeRequest<T: Decodable>(_ endpoint: DockerAPIEndpoint) async throws -> ScraperResponse<T> {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // Add headers
        let headers = DockerScraperConfig.defaultHeaders
        request.allHTTPHeaderFields = headers.toDictionary()

        logger.debug("Making Docker scraper request: \(endpoint.method.rawValue) \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidURL
            }

            guard 200 ... 299 ~= httpResponse.statusCode else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NetworkError.httpError(httpResponse.statusCode, errorMessage)
            }

            let scraperResponse = try decoder.decode(ScraperResponse<T>.self, from: data)

            logger.debug("Docker scraper request successful")
            lastUpdate = Date()
            isConnected = true
            connectionError = nil

            return scraperResponse

        } catch let error as URLError where error.code == .timedOut {
            logger.error("Docker scraper request timeout")
            throw NetworkError.timeout
        } catch {
            logger.error("Docker scraper request failed: \(error.localizedDescription)")
            isConnected = false
            connectionError = error
            throw error
        }
    }
}

// MARK: - DockerAPIEndpoint

enum DockerAPIEndpoint {
    case players
    case playerById(String)
    case teamData(String)
    case liveScores
    case fixtures
    case weather
    case historicalData(playerId: String, seasons: Int)

    var path: String {
        switch self {
        case .players:
            "/api/v1/players"
        case let .playerById(id):
            "/api/v1/players/\(id)"
        case let .teamData(teamId):
            "/api/v1/teams/\(teamId)"
        case .liveScores:
            "/api/v1/live"
        case .fixtures:
            "/api/v1/fixtures"
        case .weather:
            "/api/v1/weather"
        case let .historicalData(playerId, seasons):
            "/api/v1/players/\(playerId)/history?seasons=\(seasons)"
        }
    }

    var method: NetworkModels.HTTPMethod {
        switch self {
        case .players, .playerById, .teamData, .liveScores, .fixtures, .weather, .historicalData:
            .GET
        }
    }
}

// MARK: - DockerScraperConfig

enum DockerScraperConfig {
    static let baseURL = "http://localhost:8080" // Default Docker port
    static let timeout: TimeInterval = 30.0
    static let maxRetries = 3
    static let retryDelay: TimeInterval = 2.0

    // Headers for AFL Fantasy scraper
    static var defaultHeaders: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.addUserAgent("AFL-Fantasy-iOS/1.0")
        headers.add(name: "X-API-Version", value: "1.0")
        headers.add(name: "Accept", value: "application/json")
        headers.add(name: "Content-Type", value: "application/json")
        return headers
    }
}

// MARK: - HTTPHeaders

struct HTTPHeaders {
    private var headers: [String: String] = [:]

    init() {}

    mutating func add(name: String, value: String) {
        headers[name] = value
    }

    mutating func addAuthorization(bearer token: String) {
        headers["Authorization"] = "Bearer \(token)"
    }

    mutating func addUserAgent(_ userAgent: String) {
        headers["User-Agent"] = userAgent
    }

    func toDictionary() -> [String: String] {
        headers
    }
}

// MARK: - PlayerData Extension for Player Conversion

extension PlayerData {
    func toPlayer() -> Player? {
        guard let position = Position(rawValue: position.uppercased()) else {
            return nil
        }

        return Player(
            id: id,
            apiId: Int(id) ?? 0,
            name: name,
            position: position,
            teamId: Int(team.hashValue) % 18 + 1, // Convert team name to ID
            teamName: team,
            teamAbbreviation: String(team.prefix(3)).uppercased(),
            currentPrice: price,
            currentScore: lastScore ?? 0,
            averageScore: averageScore,
            totalScore: totalScore,
            breakeven: calculateBreakeven(),
            gamesPlayed: form.count,
            consistency: calculateConsistency(),
            ceiling: form.max() ?? 0,
            floor: form.min() ?? 0,
            volatility: calculateVolatility(),
            ownership: ownership,
            lastScore: lastScore,
            startingPrice: price - (priceChange * 5), // Estimate
            priceChange: priceChange,
            priceChangeProbability: 0.5,
            cashGenerated: max(0, priceChange * 1000),
            valueGain: Double(priceChange) / Double(price) * 100,
            isInjured: isInjured,
            isDoubtful: status.lowercased().contains("test"),
            isSuspended: isSuspended,
            injuryRisk: createInjuryRisk(),
            contractStatus: status.isEmpty ? "Active" : status,
            seasonalTrend: form.map { Double($0) },
            nextRoundProjection: createNextRoundProjection(),
            threeRoundProjection: createThreeRoundProjection(),
            seasonProjection: createSeasonProjection(),
            venuePerformance: [],
            opponentPerformance: [:],
            isCaptainRecommended: averageScore > 100,
            isTradeTarget: priceChange > 0 && averageScore > 80,
            isCashCow: priceChange > 50000 && price < 500_000,
            alertFlags: []
        )
    }

    private func calculateBreakeven() -> Int {
        let avgForm = form.isEmpty ? averageScore : Double(form.reduce(0, +)) / Double(form.count)
        return Int(avgForm * 3.5) // AFL Fantasy breakeven formula approximation
    }

    private func calculateConsistency() -> Double {
        guard !form.isEmpty else { return 50.0 }
        let avg = Double(form.reduce(0, +)) / Double(form.count)
        let variance = form.map { pow(Double($0) - avg, 2) }.reduce(0, +) / Double(form.count)
        let stdDev = sqrt(variance)
        return max(0, 100 - (stdDev / avg * 100))
    }

    private func calculateVolatility() -> Double {
        guard !form.isEmpty else { return 0.0 }
        let avg = Double(form.reduce(0, +)) / Double(form.count)
        let variance = form.map { pow(Double($0) - avg, 2) }.reduce(0, +) / Double(form.count)
        return sqrt(variance)
    }

    private func createNextRoundProjection() -> RoundProjection {
        let baseProjection = form.isEmpty ? averageScore : Double(form.suffix(3).reduce(0, +)) / Double(min(
            3,
            form.count
        ))

        return RoundProjection(
            round: 1, // Would be determined by current round
            projectedScore: baseProjection,
            confidence: calculateConsistency() / 100.0,
            priceChange: Double(priceChange),
            breakeven: Double(calculateBreakeven()),
            opponent: fixtures.first?.opponent ?? "TBD",
            venue: fixtures.first?.venue ?? "TBD",
            conditions: WeatherConditions()
        )
    }

    private func createThreeRoundProjection() -> [RoundProjection] {
        (1 ... 3).map { round in
            RoundProjection(
                round: round,
                projectedScore: averageScore,
                confidence: calculateConsistency() / 100.0,
                priceChange: Double(priceChange) / 3.0,
                breakeven: Double(calculateBreakeven()),
                opponent: fixtures.first?.opponent ?? "TBD",
                venue: fixtures.first?.venue ?? "TBD",
                conditions: WeatherConditions()
            )
        }
    }

    private func createSeasonProjection() -> SeasonProjection {
        SeasonProjection(
            projectedTotalScore: averageScore * 22, // 22 rounds
            projectedAverageScore: averageScore,
            projectedPriceChange: Double(priceChange * 5),
            projectedBreakeven: Double(calculateBreakeven()),
            confidence: calculateConsistency() / 100.0,
            consistency: calculateConsistency()
        )
    }

    private func createInjuryRisk() -> InjuryRisk {
        InjuryRisk(
            riskLevel: isInjured ? .high : .low,
            riskScore: isInjured ? 80.0 : 20.0,
            affectedBodyParts: [],
            estimatedReturn: nil,
            confidenceLevel: 0.8
        )
    }
}

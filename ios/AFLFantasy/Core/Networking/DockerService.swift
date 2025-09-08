import Combine
import Foundation
import OSLog

// MARK: - DockerConfig

public struct DockerConfig {
    public let baseURL: URL
    public let healthEndpoint: String
    public let statsEndpoint: String
    public let playersEndpoint: String
    public let liveUpdatesWebSocketURL: URL

    public static let development = DockerConfig(
        baseURL: URL(string: "http://localhost:5000")!,
        healthEndpoint: "/health",
        statsEndpoint: "/api/stats",
        playersEndpoint: "/api/players",
        liveUpdatesWebSocketURL: URL(string: "ws://localhost:5001/ws")!
    )

    public static let production = DockerConfig(
        baseURL: URL(string: "http://docker.tiation.net:5000")!,
        healthEndpoint: "/health",
        statsEndpoint: "/api/stats",
        playersEndpoint: "/api/players",
        liveUpdatesWebSocketURL: URL(string: "ws://docker.tiation.net:5001/ws")!
    )
}

// MARK: - DockerServiceProtocol

public protocol DockerServiceProtocol {
    func fetchHealthStatus() async throws -> HealthStatus
    func fetchPlayerStats() async throws -> [PlayerStats]
    func fetchLatestStats() async throws -> DashboardStats
    func subscribeLiveUpdates() -> AnyPublisher<LiveUpdate, Error>
}

// MARK: - HealthStatus

public struct HealthStatus: Codable {
    public let status: String
    public let timestamp: Date
    public let services: [ServiceStatus]

    public struct ServiceStatus: Codable {
        public let name: String
        public let status: String
        public let lastCheck: Date
    }
}

// MARK: - DashboardStats

public struct DashboardStats: Codable {
    public let lastUpdated: Date
    public let playersCount: Int
    public let teamsCount: Int
    public let averageScore: Double
    public let topPerformer: PlayerStats?
}

// MARK: - LiveUpdate

public struct LiveUpdate: Codable {
    public let type: UpdateType
    public let playerId: Int?
    public let data: [String: AnyCodable]
    public let timestamp: Date

    public enum UpdateType: String, Codable {
        case playerScore = "player_score"
        case priceChange = "price_change"
        case injury
        case teamChange = "team_change"
    }
}

// MARK: - AnyCodable

// Helper for arbitrary JSON data
public struct AnyCodable: Codable {
    public let value: Any

    public init(_ value: (some Any)?) {
        self.value = value ?? ()
    }
}

public extension AnyCodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            value = ()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - Docker Service Implementation

@MainActor
public class DockerService: DockerServiceProtocol, ObservableObject {
    private let config: DockerConfig
    private let session: URLSession
    private let logger = Logger(subsystem: "AFLFantasy", category: "DockerService")

    // Published properties for SwiftUI
    @Published public var isConnected: Bool = false
    @Published public var lastUpdate: Date?
    @Published public var connectionError: Error?

    // WebSocket for live updates
    private var webSocketTask: URLSessionWebSocketTask?
    private let liveUpdatesSubject = PassthroughSubject<LiveUpdate, Error>()

    public init(config: DockerConfig = .development) {
        self.config = config

        // Configure URL session for Docker containers
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        session = URLSession(configuration: configuration)

        // Start health monitoring
        Task {
            await monitorConnection()
        }
    }

    // MARK: - Health Check

    public func fetchHealthStatus() async throws -> HealthStatus {
        let url = config.baseURL.appendingPathComponent(config.healthEndpoint)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw NetworkError.serverError
        }

        let healthStatus = try JSONDecoder().decode(HealthStatus.self, from: data)
        await MainActor.run {
            self.isConnected = healthStatus.status == "healthy"
            self.lastUpdate = Date()
            self.connectionError = nil
        }

        logger.info("Health check successful: \(healthStatus.status)")
        return healthStatus
    }

    // MARK: - Fetch Player Stats

    public func fetchPlayerStats() async throws -> [PlayerStats] {
        let url = config.baseURL.appendingPathComponent(config.playersEndpoint)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw NetworkError.serverError
        }

        // Custom decoder to handle Docker scraper JSON format
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let playerStats = try decoder.decode([PlayerStats].self, from: data)
        logger.info("Fetched \(playerStats.count) player stats from Docker service")

        return playerStats
    }

    // MARK: - Fetch Latest Stats

    public func fetchLatestStats() async throws -> DashboardStats {
        let url = config.baseURL.appendingPathComponent(config.statsEndpoint)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw NetworkError.serverError
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let dashboardStats = try decoder.decode(DashboardStats.self, from: data)
        await MainActor.run {
            self.lastUpdate = Date()
        }

        logger.info("Fetched latest dashboard stats")
        return dashboardStats
    }

    // MARK: - Live Updates WebSocket

    public func subscribeLiveUpdates() -> AnyPublisher<LiveUpdate, Error> {
        setupWebSocket()
        return liveUpdatesSubject.eraseToAnyPublisher()
    }

    private func setupWebSocket() {
        webSocketTask = session.webSocketTask(with: config.liveUpdatesWebSocketURL)
        webSocketTask?.resume()

        // Listen for messages
        receiveWebSocketMessage()

        logger.info("WebSocket connection established for live updates")
    }

    private func receiveWebSocketMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(message):
                Task { @MainActor in
                    await self.handleWebSocketMessage(message)
                }
                // Continue listening
                receiveWebSocketMessage()

            case let .failure(error):
                logger.error("WebSocket error: \(error.localizedDescription)")
                liveUpdatesSubject.send(completion: .failure(error))

                // Attempt to reconnect after delay
                Task {
                    try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                    self.setupWebSocket()
                }
            }
        }
    }

    @MainActor
    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) async {
        switch message {
        case let .string(text):
            do {
                let data = text.data(using: .utf8) ?? Data()
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let liveUpdate = try decoder.decode(LiveUpdate.self, from: data)
                liveUpdatesSubject.send(liveUpdate)

                logger.info("Received live update: \(liveUpdate.type.rawValue)")
            } catch {
                logger.error("Failed to decode live update: \(error.localizedDescription)")
            }

        case let .data(data):
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let liveUpdate = try decoder.decode(LiveUpdate.self, from: data)
                liveUpdatesSubject.send(liveUpdate)

                logger.info("Received binary live update: \(liveUpdate.type.rawValue)")
            } catch {
                logger.error("Failed to decode binary live update: \(error.localizedDescription)")
            }

        @unknown default:
            logger.warning("Received unknown WebSocket message type")
        }
    }

    // MARK: - Connection Monitoring

    private func monitorConnection() async {
        while true {
            do {
                _ = try await fetchHealthStatus()
                try await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            } catch {
                await MainActor.run {
                    self.isConnected = false
                    self.connectionError = error
                }
                logger.error("Connection monitoring failed: \(error.localizedDescription)")
                try? await Task.sleep(nanoseconds: 60_000_000_000) // 1 minute retry
            }
        }
    }

    deinit {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

// MARK: - Environment Integration

@MainActor
public class AppEnvironment: ObservableObject {
    @Published public var dockerService: DockerService
    @Published public var isProduction: Bool

    public init(isProduction: Bool = false) {
        self.isProduction = isProduction
        dockerService = DockerService(
            config: isProduction ? .production : .development
        )
    }

    public func switchEnvironment() {
        isProduction.toggle()
        dockerService = DockerService(
            config: isProduction ? .production : .development
        )
    }
}

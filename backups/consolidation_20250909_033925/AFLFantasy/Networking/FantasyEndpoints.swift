import Foundation

// MARK: - FantasyEndpoints

enum FantasyEndpoints {
    // Dashboard
    case dashboard(teamId: String)
    case teamStats(teamId: String)

    // Players
    case players
    case playerDetails(id: Int)
    case playerStats(id: Int)
    case playerHistory(id: Int)

    // Trading
    case tradeRecommendations(teamId: String)
    case tradeAnalysis(teamId: String, playersOut: [Int], playersIn: [Int])
    case validateTrade(teamId: String, playersOut: [Int], playersIn: [Int])

    // Captain
    case captainRecommendations(teamId: String, round: Int)
    case captainAnalysis(teamId: String, playerId: Int, round: Int)

    // Cash Cows
    case cashCowAnalysis(teamId: String)
    case priceProjections(playerIds: [Int])

    // Analytics
    case venuePerformance(playerId: Int)
    case teamAnalytics
    case leagueStats(leagueId: String)
}

// MARK: APIEndpoint

extension FantasyEndpoints: APIEndpoint {
    var path: String {
        switch self {
        case let .dashboard(teamId):
            "/teams/\(teamId)/dashboard"
        case let .teamStats(teamId):
            "/teams/\(teamId)/stats"
        case .players:
            "/players"
        case let .playerDetails(id):
            "/players/\(id)"
        case let .playerStats(id):
            "/players/\(id)/stats"
        case let .playerHistory(id):
            "/players/\(id)/history"
        case let .tradeRecommendations(teamId):
            "/teams/\(teamId)/trade-recommendations"
        case .tradeAnalysis:
            "/trades/analyze"
        case .validateTrade:
            "/trades/validate"
        case let .captainRecommendations(teamId, round):
            "/teams/\(teamId)/captain-recommendations/round/\(round)"
        case let .captainAnalysis(teamId, playerId, round):
            "/teams/\(teamId)/captain-analysis/\(playerId)/round/\(round)"
        case let .cashCowAnalysis(teamId):
            "/teams/\(teamId)/cash-cows"
        case .priceProjections:
            "/players/price-projections"
        case let .venuePerformance(playerId):
            "/players/\(playerId)/venue-performance"
        case .teamAnalytics:
            "/analytics/team"
        case let .leagueStats(leagueId):
            "/leagues/\(leagueId)/stats"
        }
    }

    var method: NetworkModels.HTTPMethod {
        switch self {
        case .tradeAnalysis, .validateTrade:
            .post
        default:
            .get
        }
    }

    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.add("Content-Type", value: "application/json")
        if let body {
            headers.add("Content-Length", value: String(body.count))
        }
        return headers
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        if let queryItems {
            for item in queryItems {
                params[item.name] = item.value
            }
        }
        return params.isEmpty ? nil : params
    }

    var requiresAuth: Bool {
        switch self {
        case .players:
            false
        default:
            true
        }
    }

    // Helper for building the parameters
    private var queryItems: [URLQueryItem]? {
        var items = [URLQueryItem]()

        switch self {
        case .players:
            items.append(URLQueryItem(name: "include", value: "stats,fixtures,price_history"))
        case let .priceProjections(playerIds):
            items.append(URLQueryItem(name: "player_ids", value: playerIds.map(String.init).joined(separator: ",")))
        default:
            break
        }

        return items.isEmpty ? nil : items
    }

    var body: Data? {
        switch self {
        case let .tradeAnalysis(teamId, playersOut, playersIn):
            let params = [
                "team_id": teamId,
                "players_out": playersOut,
                "players_in": playersIn
            ] as [String: Any]
            return try? JSONSerialization.data(withJSONObject: params)

        case let .validateTrade(teamId, playersOut, playersIn):
            let params = [
                "team_id": teamId,
                "players_out": playersOut,
                "players_in": playersIn
            ] as [String: Any]
            return try? JSONSerialization.data(withJSONObject: params)

        default:
            return nil
        }
    }

    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .players, .teamAnalytics, .venuePerformance:
            .returnCacheDataElseLoad
        default:
            .useProtocolCachePolicy
        }
    }

    var timeoutInterval: TimeInterval {
        switch self {
        case .tradeAnalysis, .cashCowAnalysis:
            45 // Longer timeout for complex operations
        default:
            30
        }
    }
}

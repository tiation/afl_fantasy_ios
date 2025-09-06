//
//  DashboardService.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import Foundation

#if canImport(OpenAPIClient)
    import OpenAPIClient
#endif

// MARK: - DashboardServiceProtocol

/// Protocol defining the dashboard service interface
public protocol DashboardServiceProtocol {
    /// Fetch dashboard data with caching support
    func getDashboard(forceRefresh: Bool) -> AnyPublisher<DashboardResponse, Error>

    /// Get cached dashboard data if available
    var cachedDashboard: DashboardResponse? { get }

    /// Clear cached data
    func clearCache()
}

// MARK: - DashboardService

/// Service for managing dashboard data with Combine publishers and caching
public class DashboardService: ObservableObject, DashboardServiceProtocol {
    // MARK: - Properties

    private let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()

    // Caching
    private var _cachedDashboard: DashboardResponse?
    private var lastFetchDate: Date?
    private let cacheExpiryInterval: TimeInterval = 300 // 5 minutes

    // Published state
    @Published public var isLoading = false
    @Published public var lastError: Error?
    @Published public var dashboard: DashboardResponse?

    // MARK: - Initialization

    public init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
        configureAPIClient()
    }

    // MARK: - Configuration

    private func configureAPIClient() {
        #if canImport(OpenAPIClient)
            // Configure the generated API client
            OpenAPIClientAPI.basePath = APIConfiguration.basePath
            OpenAPIClientAPI.customHeaders = APIConfiguration.defaultHeaders
        #endif
    }

    // MARK: - Public Methods

    /// Fetch dashboard data with caching support
    public func getDashboard(forceRefresh: Bool = false) -> AnyPublisher<DashboardResponse, Error> {
        // Check if we can use cached data
        if !forceRefresh, let cachedData = getCachedDashboardIfValid() {
            return Just(cachedData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Future<DashboardResponse, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(DashboardServiceError.selfDeallocated))
                return
            }

            isLoading = true
            lastError = nil

            #if canImport(OpenAPIClient)
                DashboardAPI.getDashboard { data, error in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        if let error {
                            let serviceError = DashboardServiceError.apiError(error)
                            self.lastError = serviceError
                            promise(.failure(serviceError))
                            return
                        }

                        guard let response = data else {
                            let serviceError = DashboardServiceError.noData
                            self.lastError = serviceError
                            promise(.failure(serviceError))
                            return
                        }

                        // Cache the response
                        self.cacheDashboard(response)
                        self.dashboard = response
                        promise(.success(response))
                    }
                }
            #else
                // Fallback implementation using URLSession
                fetchDashboardWithURLSession { result in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        switch result {
                        case let .success(response):
                            self.cacheDashboard(response)
                            self.dashboard = response
                            promise(.success(response))
                        case let .failure(error):
                            self.lastError = error
                            promise(.failure(error))
                        }
                    }
                }
            #endif
        }
        .retry(APIConfiguration.maxRetryAttempts)
        .delay(for: .seconds(APIConfiguration.retryDelay), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    /// Get cached dashboard data if available
    public var cachedDashboard: DashboardResponse? {
        getCachedDashboardIfValid()
    }

    /// Clear cached data
    public func clearCache() {
        _cachedDashboard = nil
        lastFetchDate = nil
        dashboard = nil
    }

    // MARK: - Caching Implementation

    private func cacheDashboard(_ dashboard: DashboardResponse) {
        _cachedDashboard = dashboard
        lastFetchDate = Date()
    }

    private func getCachedDashboardIfValid() -> DashboardResponse? {
        guard let cachedDashboard = _cachedDashboard,
              let lastFetch = lastFetchDate,
              Date().timeIntervalSince(lastFetch) < cacheExpiryInterval
        else {
            return nil
        }
        return cachedDashboard
    }

    private func isCacheValid() -> Bool {
        guard let lastFetch = lastFetchDate else { return false }
        return Date().timeIntervalSince(lastFetch) < cacheExpiryInterval
    }

    // MARK: - Convenience Methods

    /// Refresh dashboard data (alias for getDashboard with forceRefresh)
    public func refresh() -> AnyPublisher<DashboardResponse, Error> {
        getDashboard(forceRefresh: true)
    }

    /// Get dashboard data or return cached if available
    public func getDashboardOrCached() -> AnyPublisher<DashboardResponse, Error> {
        getDashboard(forceRefresh: false)
    }
}

// MARK: - URLSession Fallback

extension DashboardService {
    private func fetchDashboardWithURLSession(
        completion: @escaping (Result<DashboardResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(APIConfiguration.basePath)/dashboard") else {
            completion(.failure(DashboardServiceError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = APIConfiguration.requestTimeout

        for (key, value) in APIConfiguration.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(DashboardServiceError.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(DashboardServiceError.invalidResponse))
                return
            }

            guard 200 ... 299 ~= httpResponse.statusCode else {
                completion(.failure(DashboardServiceError.httpError(httpResponse.statusCode)))
                return
            }

            guard let data else {
                completion(.failure(DashboardServiceError.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let dashboardResponse = try decoder.decode(DashboardResponse.self, from: data)
                completion(.success(dashboardResponse))
            } catch {
                completion(.failure(DashboardServiceError.decodingError(error)))
            }
        }.resume()
    }
}

// MARK: - DashboardServiceError

/// Errors specific to dashboard service operations
public enum DashboardServiceError: LocalizedError {
    case selfDeallocated
    case apiError(Error)
    case noData
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case httpError(Int)

    public var errorDescription: String? {
        switch self {
        case .selfDeallocated:
            "Service was deallocated"
        case let .apiError(error):
            "API error: \(error.localizedDescription)"
        case .noData:
            "No data received from server"
        case .invalidURL:
            "Invalid URL configuration"
        case .invalidResponse:
            "Invalid response from server"
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case let .decodingError(error):
            "Failed to decode response: \(error.localizedDescription)"
        case let .httpError(statusCode):
            "HTTP error with status code: \(statusCode)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .networkError:
            "Check your internet connection and try again."
        case let .httpError(statusCode) where statusCode >= 500:
            "Server error. Please try again later."
        case let .httpError(statusCode) where statusCode == 401:
            "Authentication required. Please log in again."
        case .decodingError:
            "Data format error. The server response may have changed."
        default:
            "Please try again. If the problem persists, contact support."
        }
    }
}

// MARK: - Mock Data Types (when OpenAPI not available)

#if !canImport(OpenAPIClient)

    // Mock types to allow compilation without generated API client
    public struct DashboardResponse: Codable {
        public let teamValue: TeamValue
        public let rank: Rank
        public let upcomingMatchups: [Matchup]
        public let topPerformers: [TopPerformer]?
        public let lastUpdated: Date
        public let nextDeadline: Date?

        public init(
            teamValue: TeamValue,
            rank: Rank,
            upcomingMatchups: [Matchup],
            topPerformers: [TopPerformer]? = nil,
            lastUpdated: Date,
            nextDeadline: Date? = nil
        ) {
            self.teamValue = teamValue
            self.rank = rank
            self.upcomingMatchups = upcomingMatchups
            self.topPerformers = topPerformers
            self.lastUpdated = lastUpdated
            self.nextDeadline = nextDeadline
        }
    }

    public struct TeamValue: Codable {
        public let current: Int
        public let bank: Int
        public let total: Int

        public init(current: Int, bank: Int, total: Int) {
            self.current = current
            self.bank = bank
            self.total = total
        }
    }

    public struct Rank: Codable {
        public let overall: Int
        public let league: Int?

        public init(overall: Int, league: Int? = nil) {
            self.overall = overall
            self.league = league
        }
    }

    public struct Matchup: Codable {
        public let homeTeam: String
        public let awayTeam: String
        public let startTime: Date
        public let round: Int

        public init(homeTeam: String, awayTeam: String, startTime: Date, round: Int) {
            self.homeTeam = homeTeam
            self.awayTeam = awayTeam
            self.startTime = startTime
            self.round = round
        }
    }

    public struct TopPerformer: Codable {
        public let name: String
        public let team: String
        public let score: Int
        public let position: String

        public init(name: String, team: String, score: Int, position: String) {
            self.name = name
            self.team = team
            self.score = score
            self.position = position
        }
    }

#endif

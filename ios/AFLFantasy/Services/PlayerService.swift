//
//  PlayerService.swift
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

// MARK: - PlayerServiceProtocol

/// Protocol defining the player service interface
public protocol PlayerServiceProtocol {
    /// Fetch all players with optional filtering
    func getPlayers(
        position: PlayerPosition?,
        season: Int?,
        limit: Int?,
        offset: Int?
    ) -> AnyPublisher<PlayersResponse, Error>

    /// Fetch a specific player by ID
    func getPlayer(id: Int) -> AnyPublisher<SinglePlayerResponse, Error>
}

// MARK: - PlayerPosition

/// Player position enum matching API expectations
public enum PlayerPosition: String, CaseIterable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
}

// MARK: - PlayerService

/// Service for managing player data with Combine publishers
public class PlayerService: ObservableObject, PlayerServiceProtocol {
    // MARK: - Properties

    private let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()

    // Published state
    @Published public var isLoading = false
    @Published public var lastError: Error?

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

    /// Fetch all players with optional filtering
    public func getPlayers(
        position: PlayerPosition? = nil,
        season: Int? = nil,
        limit: Int? = 100,
        offset: Int? = 0
    ) -> AnyPublisher<PlayersResponse, Error> {
        Future<PlayersResponse, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(PlayerServiceError.selfDeallocated))
                return
            }

            isLoading = true
            lastError = nil

            #if canImport(OpenAPIClient)
                let apiPosition = position.map { pos -> PlayersAPI.Position_getPlayers in
                    switch pos {
                    case .defender: return .def
                    case .midfielder: return .mid
                    case .ruck: return .ruc
                    case .forward: return .fwd
                    }
                }

                PlayersAPI.getPlayers(
                    position: apiPosition,
                    season: season,
                    limit: limit,
                    offset: offset
                ) { data, error in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        if let error {
                            let serviceError = PlayerServiceError.apiError(error)
                            self.lastError = serviceError
                            promise(.failure(serviceError))
                            return
                        }

                        guard let response = data else {
                            let serviceError = PlayerServiceError.noData
                            self.lastError = serviceError
                            promise(.failure(serviceError))
                            return
                        }

                        promise(.success(response))
                    }
                }
            #else
                // Fallback implementation using URLSession
                fetchPlayersWithURLSession(
                    position: position,
                    season: season,
                    limit: limit,
                    offset: offset,
                    completion: { result in
                        DispatchQueue.main.async {
                            self.isLoading = false

                            switch result {
                            case let .success(response):
                                promise(.success(response))
                            case let .failure(error):
                                self.lastError = error
                                promise(.failure(error))
                            }
                        }
                    }
                )
            #endif
        }
        .eraseToAnyPublisher()
    }

    /// Fetch a specific player by ID
    public func getPlayer(id: Int) -> AnyPublisher<SinglePlayerResponse, Error> {
        Future<SinglePlayerResponse, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(PlayerServiceError.selfDeallocated))
                return
            }

            isLoading = true
            lastError = nil

            #if canImport(OpenAPIClient)
                PlayersAPI.getPlayerById(playerId: id) { data, error in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        if let error {
                            let serviceError = PlayerServiceError.apiError(error)
                            self.lastError = serviceError
                            promise(.failure(serviceError))
                            return
                        }

                        guard let response = data else {
                            let serviceError = PlayerServiceError.noData
                            self.lastError = serviceError
                            promise(.failure(serviceError))
                            return
                        }

                        promise(.success(response))
                    }
                }
            #else
                // Fallback implementation using URLSession
                fetchPlayerWithURLSession(id: id) { result in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        switch result {
                        case let .success(response):
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
}

// MARK: - URLSession Fallback

extension PlayerService {
    private func fetchPlayersWithURLSession(
        position: PlayerPosition?,
        season: Int?,
        limit: Int?,
        offset: Int?,
        completion: @escaping (Result<PlayersResponse, Error>) -> Void
    ) {
        var components = URLComponents(string: "\(APIConfiguration.basePath)/players")!
        var queryItems: [URLQueryItem] = []

        if let position {
            queryItems.append(URLQueryItem(name: "position", value: position.rawValue))
        }
        if let season {
            queryItems.append(URLQueryItem(name: "season", value: "\(season)"))
        }
        if let limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        if let offset {
            queryItems.append(URLQueryItem(name: "offset", value: "\(offset)"))
        }

        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            completion(.failure(PlayerServiceError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        for (key, value) in APIConfiguration.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                completion(.failure(PlayerServiceError.networkError(error)))
                return
            }

            guard let data else {
                completion(.failure(PlayerServiceError.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let playersResponse = try decoder.decode(PlayersResponse.self, from: data)
                completion(.success(playersResponse))
            } catch {
                completion(.failure(PlayerServiceError.decodingError(error)))
            }
        }.resume()
    }

    private func fetchPlayerWithURLSession(
        id: Int,
        completion: @escaping (Result<SinglePlayerResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(APIConfiguration.basePath)/players/\(id)") else {
            completion(.failure(PlayerServiceError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        for (key, value) in APIConfiguration.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                completion(.failure(PlayerServiceError.networkError(error)))
                return
            }

            guard let data else {
                completion(.failure(PlayerServiceError.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let playerResponse = try decoder.decode(SinglePlayerResponse.self, from: data)
                completion(.success(playerResponse))
            } catch {
                completion(.failure(PlayerServiceError.decodingError(error)))
            }
        }.resume()
    }
}

// MARK: - APIClient Wrapper

/// Wrapper for API client configuration
public class APIClient {
    public static let shared = APIClient()

    private init() {
        configureClient()
    }

    private func configureClient() {
        // Configuration happens in PlayerService and DashboardService
    }
}

// MARK: - PlayerServiceError

/// Errors specific to player service operations
public enum PlayerServiceError: LocalizedError {
    case selfDeallocated
    case apiError(Error)
    case noData
    case invalidURL
    case networkError(Error)
    case decodingError(Error)

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
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case let .decodingError(error):
            "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

// MARK: - Mock Data Types (when OpenAPI not available)

#if !canImport(OpenAPIClient)

    // Mock types to allow compilation without generated API client
    public struct PlayersResponse: Codable {
        public let players: [Player]
        public let total: Int
        public let limit: Int
        public let offset: Int
    }

    public struct SinglePlayerResponse: Codable {
        public let player: Player
    }

    public struct Player: Codable, Identifiable {
        public let id: Int
        public let name: String
        public let team: String
        public let position: String
        public let price: Int
        public let averageScore: Double?
        public let lastScore: Int?
    }

#endif

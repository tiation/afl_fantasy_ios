//
//  NetworkClient.swift
//  AFL Fantasy Intelligence Platform
//
//  Enterprise-grade networking with retry logic and rate limiting
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import os.log

// MARK: - NetworkError

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case unauthorized
    case rateLimited(retryAfter: TimeInterval)
    case serverError(statusCode: Int)
    case decodingError(Error)
    case requestTimeout
    case noInternetConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL provided"
        case .noData:
            "No data received from server"
        case .unauthorized:
            "Unauthorized access - check credentials"
        case let .rateLimited(retryAfter):
            "Rate limited - retry after \(retryAfter) seconds"
        case let .serverError(statusCode):
            "Server error with status code: \(statusCode)"
        case .decodingError:
            "Failed to decode response data"
        case .requestTimeout:
            "Request timed out"
        case .noInternetConnection:
            "No internet connection available"
        case let .unknown(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - NetworkClientProtocol

protocol NetworkClientProtocol {
    func fetch<T: Decodable>(_ type: T.Type, from request: URLRequest) async throws -> T
    func fetchData(from request: URLRequest) async throws -> Data
}

// MARK: - NetworkClient

@MainActor
final class NetworkClient: NetworkClientProtocol {
    static let shared = NetworkClient()

    private let session: URLSession
    private let logger = Logger(subsystem: "AFLFantasy", category: "NetworkClient")
    private let maxRetries = 3
    private let baseRetryDelay: TimeInterval = 1.0

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config)
    }

    func fetch<T: Decodable>(_ type: T.Type, from request: URLRequest) async throws -> T {
        let data = try await fetchData(from: request)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        } catch {
            logger.error("Decoding failed: \(error.localizedDescription, privacy: .public)")
            throw NetworkError.decodingError(error)
        }
    }

    func fetchData(from request: URLRequest) async throws -> Data {
        var lastError: Error?

        for attempt in 1 ... maxRetries {
            do {
                logger.info("Attempt \(attempt): \(request.url?.absoluteString ?? "unknown", privacy: .public)")

                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }

                // Handle HTTP status codes
                switch httpResponse.statusCode {
                case 200 ... 299:
                    logger.info("Success: \(httpResponse.statusCode)")
                    return data
                case 401:
                    throw NetworkError.unauthorized
                case 429:
                    let retryAfter = Double(httpResponse.value(forHTTPHeaderField: "Retry-After") ?? "60") ?? 60.0
                    throw NetworkError.rateLimited(retryAfter: retryAfter)
                case 500 ... 599:
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                default:
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                }
            } catch let error as NetworkError {
                lastError = error

                // Don't retry certain errors
                switch error {
                case .unauthorized, .invalidURL, .decodingError:
                    throw error
                case let .rateLimited(retryAfter):
                    if attempt < maxRetries {
                        logger.info("Rate limited, retrying after \(retryAfter)s")
                        try await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                        continue
                    }
                    throw error
                default:
                    break
                }

                if attempt < maxRetries {
                    let delay = baseRetryDelay * pow(2.0, Double(attempt - 1)) // Exponential backoff
                    logger.info("Retrying in \(delay)s due to: \(error.localizedDescription, privacy: .public)")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            } catch {
                lastError = error

                // Handle URLErrors
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost:
                        throw NetworkError.noInternetConnection
                    case .timedOut:
                        throw NetworkError.requestTimeout
                    default:
                        break
                    }
                }

                if attempt < maxRetries {
                    let delay = baseRetryDelay * pow(2.0, Double(attempt - 1))
                    logger.info("Retrying in \(delay)s due to: \(error.localizedDescription, privacy: .public)")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? NetworkError.unknown(URLError(.unknown))
    }
}

// MARK: - MockNetworkClient

final class MockNetworkClient: NetworkClientProtocol {
    var shouldFail = false
    var mockData: Data?
    var mockError: NetworkError?

    func fetch<T: Decodable>(_ type: T.Type, from request: URLRequest) async throws -> T {
        if shouldFail {
            throw mockError ?? NetworkError.unknown(URLError(.unknown))
        }

        guard let data = mockData else {
            throw NetworkError.noData
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }

    func fetchData(from request: URLRequest) async throws -> Data {
        if shouldFail {
            throw mockError ?? NetworkError.unknown(URLError(.unknown))
        }

        return mockData ?? Data()
    }
}

// MARK: - APIRequestBuilder

struct APIRequestBuilder {
    private let baseURL: String

    init(baseURL: String = "https://fantasy.afl.com.au") {
        self.baseURL = baseURL
    }

    func buildRequest(
        endpoint: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Data? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )

        // Custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

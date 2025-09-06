//
//  APIConfiguration.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation

// MARK: - APIConfiguration

/// Configuration settings for the AFL Fantasy API client
public enum APIConfiguration {
    // MARK: - Properties

    /// Base URL for the API
    public static let baseURL: String = {
        #if DEBUG
            return "http://localhost:3000"
        #else
            return "https://api.aflfantasy.app"
        #endif
    }()

    /// API version
    public static let apiVersion = "v1"

    /// Full base path for API calls
    public static var basePath: String {
        "\(baseURL)/\(apiVersion)"
    }

    /// Request timeout interval
    public static let requestTimeout: TimeInterval = 30.0

    /// Resource timeout interval
    public static let resourceTimeout: TimeInterval = 60.0

    /// Maximum retry attempts
    public static let maxRetryAttempts = 3

    /// Retry delay (seconds)
    public static let retryDelay: TimeInterval = 1.0

    // MARK: - Headers

    /// Default headers for API requests
    public static var defaultHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "AFL Fantasy iOS/\(appVersion)"
        ]
    }

    /// API key header name
    public static let apiKeyHeader = "X-API-Key"

    // MARK: - Private Helpers

    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - APIEnvironment

/// Environment configuration
public enum APIEnvironment {
    case development
    case staging
    case production

    public var baseURL: String {
        switch self {
        case .development:
            "http://localhost:3000"
        case .staging:
            "https://staging-api.aflfantasy.app"
        case .production:
            "https://api.aflfantasy.app"
        }
    }
}

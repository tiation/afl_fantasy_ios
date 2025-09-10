//
//  AFLFantasyError.swift
//  AFL Fantasy Intelligence Platform
//
//  Unified error handling for AFL Fantasy services
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation

// MARK: - AFLFantasyError

enum AFLFantasyError: Error, LocalizedError {
    // Authentication errors
    case notAuthenticated
    case authenticationRequired
    case invalidCredentials
    case sessionExpired

    // Network errors
    case networkError(Error)
    case invalidURL
    case invalidResponse
    case noInternetConnection
    case serverError(String)

    // Data errors
    case decodingError(Error)
    case encodingError(Error)
    case dataCorrupted
    case missingData

    // Service errors
    case serviceUnavailable
    case rateLimited
    case quotaExceeded

    // User errors
    case invalidInput(String)
    case permissionDenied
    case resourceNotFound

    // Internal errors
    case internalError(String)
    case configurationError(String)
    case unknown(Error)

    // MARK: - LocalizedError Conformance

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "You are not authenticated. Please sign in to continue."
        case .authenticationRequired:
            "Authentication is required to access this feature."
        case .invalidCredentials:
            "Invalid credentials. Please check your login details."
        case .sessionExpired:
            "Your session has expired. Please sign in again."
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case .invalidURL:
            "Invalid URL. Please try again."
        case .invalidResponse:
            "Invalid response from server."
        case .noInternetConnection:
            "No internet connection. Please check your network settings."
        case let .serverError(message):
            "Server error: \(message)"
        case let .decodingError(error):
            "Failed to decode data: \(error.localizedDescription)"
        case let .encodingError(error):
            "Failed to encode data: \(error.localizedDescription)"
        case .dataCorrupted:
            "The data appears to be corrupted."
        case .missingData:
            "Required data is missing."
        case .serviceUnavailable:
            "The service is temporarily unavailable. Please try again later."
        case .rateLimited:
            "Too many requests. Please wait and try again."
        case .quotaExceeded:
            "Usage quota has been exceeded."
        case let .invalidInput(message):
            "Invalid input: \(message)"
        case .permissionDenied:
            "Permission denied. You don't have access to this resource."
        case .resourceNotFound:
            "The requested resource was not found."
        case let .internalError(message):
            "Internal error: \(message)"
        case let .configurationError(message):
            "Configuration error: \(message)"
        case let .unknown(error):
            "An unknown error occurred: \(error.localizedDescription)"
        }
    }

    var failureReason: String? {
        switch self {
        case .notAuthenticated, .authenticationRequired:
            "User authentication is missing or invalid."
        case .invalidCredentials:
            "The provided credentials are not valid."
        case .sessionExpired:
            "The authentication session has expired."
        case .networkError:
            "A network communication error occurred."
        case .invalidURL:
            "The URL format is invalid."
        case .invalidResponse:
            "The server response is malformed."
        case .noInternetConnection:
            "Device is not connected to the internet."
        case .serverError:
            "The server encountered an error."
        case .decodingError, .encodingError:
            "Data serialization error."
        case .dataCorrupted:
            "The data integrity has been compromised."
        case .missingData:
            "Expected data is not available."
        case .serviceUnavailable:
            "The requested service is not available."
        case .rateLimited:
            "Request rate limit has been exceeded."
        case .quotaExceeded:
            "Service usage limit has been reached."
        case .invalidInput:
            "Input validation failed."
        case .permissionDenied:
            "Insufficient permissions for this operation."
        case .resourceNotFound:
            "The requested resource does not exist."
        case .internalError:
            "An internal application error occurred."
        case .configurationError:
            "Application configuration is invalid."
        case .unknown:
            "An unexpected error occurred."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notAuthenticated, .authenticationRequired, .invalidCredentials, .sessionExpired:
            "Please sign in with your AFL Fantasy account credentials."
        case .networkError, .noInternetConnection:
            "Check your internet connection and try again."
        case .invalidURL, .invalidResponse:
            "Please try again. If the problem persists, contact support."
        case .serverError:
            "The issue is on our end. Please try again in a few minutes."
        case .decodingError, .encodingError, .dataCorrupted:
            "Please restart the app and try again."
        case .missingData:
            "Refresh the data or restart the app."
        case .serviceUnavailable:
            "Please try again in a few minutes."
        case .rateLimited:
            "Please wait a moment before making another request."
        case .quotaExceeded:
            "Please wait until your quota resets or upgrade your plan."
        case .invalidInput:
            "Please check your input and try again."
        case .permissionDenied:
            "Contact your administrator to request access."
        case .resourceNotFound:
            "Please check the resource identifier and try again."
        case .internalError, .configurationError:
            "Please restart the app. If the problem persists, reinstall the app."
        case .unknown:
            "Please try again. If the problem persists, contact support."
        }
    }
}

// MARK: - Convenience Extensions

extension AFLFantasyError {
    /// Whether this error requires user authentication
    var requiresAuthentication: Bool {
        switch self {
        case .notAuthenticated, .authenticationRequired, .invalidCredentials, .sessionExpired:
            true
        default:
            false
        }
    }

    /// Whether this error is recoverable by the user
    var isRecoverable: Bool {
        switch self {
        case .notAuthenticated, .authenticationRequired, .invalidCredentials, .sessionExpired,
             .networkError, .noInternetConnection, .rateLimited, .invalidInput:
            true
        case .internalError, .configurationError, .dataCorrupted, .unknown:
            false
        default:
            true
        }
    }

    /// Priority level for error reporting
    var severity: ErrorSeverity {
        switch self {
        case .internalError, .configurationError, .unknown:
            .critical
        case .serverError, .serviceUnavailable, .dataCorrupted:
            .high
        case .networkError, .decodingError, .encodingError, .quotaExceeded:
            .medium
        default:
            .low
        }
    }
}

// MARK: - ErrorSeverity

/// Error severity levels for logging and alerting
enum ErrorSeverity: String, CaseIterable, Codable {
    case low
    case medium
    case high
    case critical

    var description: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .critical: "Critical"
        }
    }
}

// MARK: - Bridge from AFLAPIError

extension AFLFantasyError {
    /// Create AFLFantasyError from AFLAPIError for compatibility
    static func from(aflAPIError: AFLFantasyAPIClient.AFLAPIError) -> AFLFantasyError {
        switch aflAPIError {
        case .notAuthenticated:
            .notAuthenticated
        case .missingCredentials:
            .invalidCredentials
        case let .networkError(error):
            .networkError(error)
        case let .dataParsingError(message):
            .decodingError(NSError(domain: "DataParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
        case .invalidResponse:
            .invalidResponse
        case .rateLimited:
            .rateLimited
        }
    }
}

// MARK: - AFLAPIError Compatibility

enum AFLFantasyAPIError: Error, LocalizedError {
    case notAuthenticated
    case missingCredentials
    case networkError(Error)
    case dataParsingError(String)
    case invalidResponse
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "Not authenticated with AFL Fantasy"
        case .missingCredentials:
            "AFL Fantasy credentials are missing"
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case let .dataParsingError(message):
            "Data parsing error: \(message)"
        case .invalidResponse:
            "Invalid response from AFL Fantasy API"
        case .rateLimited:
            "Rate limited by AFL Fantasy API"
        }
    }

    /// Convert to AFLFantasyError
    var asAFLFantasyError: AFLFantasyError {
        switch self {
        case .notAuthenticated:
            .notAuthenticated
        case .missingCredentials:
            .invalidCredentials
        case let .networkError(error):
            .networkError(error)
        case let .dataParsingError(message):
            .decodingError(NSError(domain: "DataParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
        case .invalidResponse:
            .invalidResponse
        case .rateLimited:
            .rateLimited
        }
    }
}

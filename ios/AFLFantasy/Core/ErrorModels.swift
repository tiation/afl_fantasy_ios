//
//  ErrorModels.swift
//  AFL Fantasy Intelligence Platform
//
//  Error-related data structures and models
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - UserFriendlyError

struct UserFriendlyError: Identifiable {
    let id: UUID
    let title: String
    let message: String
    let severity: ErrorSeverity
    let context: ErrorContext
    let timestamp: Date
    let suggestedActions: [SuggestedAction]
    let retryAction: (() -> Void)?
    let technicalDetails: TechnicalErrorDetails

    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        severity: ErrorSeverity,
        context: ErrorContext,
        timestamp: Date = Date(),
        suggestedActions: [SuggestedAction] = [],
        retryAction: (() -> Void)? = nil,
        technicalDetails: TechnicalErrorDetails? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.severity = severity
        self.context = context
        self.timestamp = timestamp
        self.suggestedActions = suggestedActions
        self.retryAction = retryAction
        self.technicalDetails = technicalDetails ?? TechnicalErrorDetails(
            errorCode: "Unknown",
            errorDomain: "General",
            underlyingError: message,
            stackTrace: nil,
            additionalInfo: [:]
        )
    }
}

// MARK: - SuggestedAction

struct SuggestedAction {
    let title: String
    let icon: String
    let action: () -> Void
}

// MARK: - TechnicalErrorDetails

struct TechnicalErrorDetails {
    let errorCode: String
    let errorDomain: String
    let underlyingError: String
    let stackTrace: String?
    let additionalInfo: [String: String]
}

// MARK: - ErrorRecord

struct ErrorRecord: Identifiable {
    let id = UUID()
    let userFriendlyError: UserFriendlyError
    let originalError: Error
    let source: String
    let timestamp: Date
}

// MARK: - ErrorSeverity

enum ErrorSeverity: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .low: .blue
        case .medium: .orange
        case .high: .red
        case .critical: .purple
        }
    }

    var icon: String {
        switch self {
        case .low: "info.circle"
        case .medium: "exclamationmark.triangle"
        case .high: "xmark.circle"
        case .critical: "exclamationmark.octagon"
        }
    }
}

// MARK: - ErrorContext

enum ErrorContext: String, CaseIterable {
    case general = "General"
    case network = "Network"
    case security = "Security"
    case persistence = "Persistence"
    case authentication = "Authentication"
    case sync = "Sync"
    case ui = "UI"
}

// MARK: - NetworkError

struct NetworkError: Error, LocalizedError {
    let statusCode: Int?
    let url: URL?
    let responseHeaders: [String: String]?
    let underlying: Error?

    var errorDescription: String? {
        if let statusCode {
            "Network error with status code: \(statusCode)"
        } else {
            underlying?.localizedDescription ?? "Unknown network error"
        }
    }
}

//
//  ErrorHandlingService.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced error handling with user-friendly presentations and actionable recovery
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import os.log
import SwiftUI

// MARK: - ErrorHandlingService

@MainActor
class ErrorHandlingService: ObservableObject {
    static let shared = ErrorHandlingService()

    @Published var currentError: UserFriendlyError?
    @Published var errorHistory: [ErrorRecord] = []
    @Published var isShowingErrorBanner = false
    @Published var errorBannerDismissTimer: Timer?

    private let logger = Logger(subsystem: "AFLFantasy", category: "ErrorHandlingService")
    private let maxErrorHistoryCount = 50

    private init() {}

    // MARK: - Public Interface

    func handle(_ error: Error, context: ErrorContext = .general, source: String = "Unknown") {
        let userFriendlyError = createUserFriendlyError(from: error, context: context, source: source)

        // Log the error with redacted sensitive information
        let redactedMessage = SecurityService.shared.redactSensitiveData(in: error.localizedDescription)
        logger.error("🚨 Error in \(source): \(redactedMessage)")

        // Record error for analytics and debugging
        recordError(userFriendlyError, originalError: error, source: source)

        // Present to user if appropriate
        presentError(userFriendlyError)
    }

    func handleNetworkError(_ error: NetworkError, context: ErrorContext = .network) {
        let userFriendlyError = createNetworkUserFriendlyError(from: error, context: context)

        logger.error("🌐 Network error: \(error.localizedDescription)")

        recordError(userFriendlyError, originalError: error, source: "NetworkClient")
        presentError(userFriendlyError)
    }

    func handleSecurityError(_ error: SecurityError, context: ErrorContext = .security) {
        let userFriendlyError = createSecurityUserFriendlyError(from: error, context: context)

        logger.error("🔒 Security error: \(error.localizedDescription)")

        recordError(userFriendlyError, originalError: error, source: "SecurityService")
        presentError(userFriendlyError)
    }

    func dismissCurrentError() {
        withAnimation(DesignSystem.Motion.tasteful) {
            currentError = nil
            isShowingErrorBanner = false
        }

        errorBannerDismissTimer?.invalidate()
        errorBannerDismissTimer = nil
    }

    func retryLastAction() {
        guard let currentError else { return }

        logger.info("🔄 Retrying last action for error: \(currentError.id)")

        // Execute the retry action if available
        currentError.retryAction?()

        // Dismiss the current error
        dismissCurrentError()
    }

    func clearErrorHistory() {
        errorHistory.removeAll()
        logger.info("🧹 Error history cleared")
    }

    // MARK: - Private Implementation

    private func createUserFriendlyError(
        from error: Error,
        context: ErrorContext,
        source: String
    ) -> UserFriendlyError {
        let errorId = UUID()
        let timestamp = Date()

        // Determine user-friendly title and message based on error type
        let (title, message, severity, suggestedActions) = processError(error, context: context)

        return UserFriendlyError(
            id: errorId,
            title: title,
            message: message,
            severity: severity,
            context: context,
            timestamp: timestamp,
            suggestedActions: suggestedActions,
            retryAction: createRetryAction(for: error, context: context),
            technicalDetails: createTechnicalDetails(from: error, source: source)
        )
    }

    private func createNetworkUserFriendlyError(from error: NetworkError, context: ErrorContext) -> UserFriendlyError {
        let errorId = UUID()
        let timestamp = Date()

        let (title, message, severity, suggestedActions) = processNetworkError(error)

        return UserFriendlyError(
            id: errorId,
            title: title,
            message: message,
            severity: severity,
            context: context,
            timestamp: timestamp,
            suggestedActions: suggestedActions,
            retryAction: { [weak self] in
                self?.handleNetworkRetry(for: error)
            },
            technicalDetails: TechnicalErrorDetails(
                errorCode: "\(error.statusCode ?? -1)",
                errorDomain: "NetworkError",
                underlyingError: error.localizedDescription,
                stackTrace: nil,
                additionalInfo: [
                    "URL": error.url?.absoluteString ?? "Unknown",
                    "HTTP Status": "\(error.statusCode ?? -1)",
                    "Response Headers": error.responseHeaders?.description ?? "None"
                ]
            )
        )
    }

    private func createSecurityUserFriendlyError(
        from error: SecurityError,
        context: ErrorContext
    ) -> UserFriendlyError {
        let errorId = UUID()
        let timestamp = Date()

        let (title, message, severity, suggestedActions) = processSecurityError(error)

        return UserFriendlyError(
            id: errorId,
            title: title,
            message: message,
            severity: severity,
            context: context,
            timestamp: timestamp,
            suggestedActions: suggestedActions,
            retryAction: nil, // Security errors typically don't have automatic retry
            technicalDetails: TechnicalErrorDetails(
                errorCode: error.localizedDescription,
                errorDomain: "SecurityError",
                underlyingError: error.localizedDescription,
                stackTrace: nil,
                additionalInfo: [:]
            )
        )
    }

    private func processError(
        _ error: Error,
        context: ErrorContext
    ) -> (String, String, ErrorSeverity, [SuggestedAction]) {
        switch error {
        case let urlError as URLError:
            processURLError(urlError)
        case let decodingError as DecodingError:
            processDecodingError(decodingError)
        case is CancellationError:
            ("Request Cancelled", "The operation was cancelled", .low, [])
        default:
            (
                "Something went wrong",
                "An unexpected error occurred. Please try again.",
                .medium,
                [
                    SuggestedAction(
                        title: "Try Again",
                        icon: "arrow.clockwise",
                        action: { [weak self] in self?.retryLastAction() }
                    )
                ]
            )
        }
    }

    private func processURLError(_ error: URLError) -> (String, String, ErrorSeverity, [SuggestedAction]) {
        switch error.code {
        case .notConnectedToInternet:
            (
                "No Internet Connection",
                "Please check your internet connection and try again.",
                .high,
                [
                    SuggestedAction(title: "Check Connection", icon: "wifi", action: { self.openWiFiSettings() }),
                    SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })
                ]
            )
        case .timedOut:
            (
                "Request Timed Out",
                "The server is taking too long to respond. Please try again.",
                .medium,
                [
                    SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })
                ]
            )
        case .cannotFindHost:
            (
                "Server Unavailable",
                "Unable to connect to AFL Fantasy servers. Please try again later.",
                .high,
                [
                    SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })
                ]
            )
        default:
            (
                "Connection Error",
                "Unable to connect to the server. Please check your connection.",
                .medium,
                [
                    SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })
                ]
            )
        }
    }

    private func processDecodingError(_ error: DecodingError) -> (String, String, ErrorSeverity, [SuggestedAction]) {
        (
            "Data Error",
            "Unable to process the server response. The data may be corrupted.",
            .medium,
            [
                SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() }),
                SuggestedAction(title: "Clear Cache", icon: "trash", action: { self.clearCache() })
            ]
        )
    }

    private func processNetworkError(_ error: NetworkError) -> (String, String, ErrorSeverity, [SuggestedAction]) {
        guard let statusCode = error.statusCode else {
            return (
                "Network Error",
                "Unable to connect to the server. Please try again.",
                .medium,
                [SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })]
            )
        }

        switch statusCode {
        case 400:
            return (
                "Invalid Request",
                "The request couldn't be processed. Please try again.",
                .medium,
                [SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })]
            )
        case 401:
            return (
                "Authentication Required",
                "Please sign in to your AFL Fantasy account.",
                .high,
                [
                    SuggestedAction(title: "Sign In", icon: "person.circle", action: { self.showSignIn() }),
                    SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })
                ]
            )
        case 403:
            return (
                "Access Denied",
                "You don't have permission to access this resource.",
                .high,
                []
            )
        case 429:
            return (
                "Too Many Requests",
                "You're making requests too quickly. Please wait a moment and try again.",
                .medium,
                [SuggestedAction(title: "Try Again", icon: "clock", action: { self.retryWithDelay() })]
            )
        case 500 ... 599:
            return (
                "Server Error",
                "The AFL Fantasy servers are experiencing issues. Please try again later.",
                .high,
                [SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })]
            )
        default:
            return (
                "Network Error",
                "Unable to complete the request. Please try again.",
                .medium,
                [SuggestedAction(title: "Try Again", icon: "arrow.clockwise", action: { self.retryLastAction() })]
            )
        }
    }

    private func processSecurityError(_ error: SecurityError) -> (String, String, ErrorSeverity, [SuggestedAction]) {
        switch error {
        case .insecureConnection:
            (
                "Insecure Connection",
                "The connection is not secure. Please check your network settings.",
                .high,
                []
            )
        case let .domainNotAllowed(host):
            (
                "Domain Not Allowed",
                "Access to \(host) is not permitted.",
                .high,
                []
            )
        case .keychainAccessFailed:
            (
                "Security Error",
                "Unable to access secure storage. Please restart the app.",
                .critical,
                [
                    SuggestedAction(title: "Restart App", icon: "arrow.clockwise", action: { self.restartApp() })
                ]
            )
        default:
            (
                "Security Error",
                "A security issue was detected. Please ensure your device is secure.",
                .high,
                []
            )
        }
    }

    private func createRetryAction(for error: Error, context: ErrorContext) -> (() -> Void)? {
        // Return a retry action based on the error type and context
        { [weak self] in
            self?.logger.info("🔄 Executing retry action for error in context: \(context.rawValue)")
            // In a real implementation, this would trigger the specific action that failed
        }
    }

    private func createTechnicalDetails(from error: Error, source: String) -> TechnicalErrorDetails {
        let errorCode: String
        let errorDomain: String
        let underlyingError: String
        var additionalInfo: [String: String] = [:]

        if let nsError = error as NSError? {
            errorCode = "\(nsError.code)"
            errorDomain = nsError.domain
            underlyingError = nsError.localizedDescription
            additionalInfo = nsError.userInfo.compactMapValues { "\($0)" }
        } else {
            errorCode = "Unknown"
            errorDomain = "UnknownDomain"
            underlyingError = error.localizedDescription
        }

        return TechnicalErrorDetails(
            errorCode: errorCode,
            errorDomain: errorDomain,
            underlyingError: underlyingError,
            stackTrace: Thread.callStackSymbols.joined(separator: "\n"),
            additionalInfo: additionalInfo.merging(["Source": source], uniquingKeysWith: { _, new in new })
        )
    }

    private func recordError(_ error: UserFriendlyError, originalError: Error, source: String) {
        let record = ErrorRecord(
            userFriendlyError: error,
            originalError: originalError,
            source: source,
            timestamp: Date()
        )

        errorHistory.append(record)

        // Limit history size
        if errorHistory.count > maxErrorHistoryCount {
            errorHistory.removeFirst(errorHistory.count - maxErrorHistoryCount)
        }
    }

    private func presentError(_ error: UserFriendlyError) {
        currentError = error

        withAnimation(DesignSystem.Motion.tasteful) {
            isShowingErrorBanner = true
        }

        // Auto-dismiss after delay for low severity errors
        if error.severity == .low {
            errorBannerDismissTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                Task { @MainActor in
                    self.dismissCurrentError()
                }
            }
        }
    }

    // MARK: - Action Handlers

    private func openWiFiSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }

    private func clearCache() {
        Task {
            try? await PersistenceManager.shared.clearExpiredCache()
            logger.info("🧹 Cache cleared due to error recovery")
        }
    }

    private func showSignIn() {
        // In a real implementation, this would show the sign-in screen
        logger.info("👤 Showing sign-in screen")
    }

    private func retryWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.retryLastAction()
        }
    }

    private func restartApp() {
        // In a real implementation, this might show instructions for restarting
        logger.info("🔄 App restart requested")
    }

    private func handleNetworkRetry(for error: NetworkError) {
        logger.info("🌐 Retrying network request")
        // In a real implementation, this would retry the specific network request
    }
}

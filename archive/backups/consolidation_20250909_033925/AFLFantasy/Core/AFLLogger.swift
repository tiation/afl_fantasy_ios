//
//  AFLLogger.swift
//  AFL Fantasy Intelligence Platform
//
//  Secure logging with token redaction and privacy protection
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import os.log

// MARK: - AFLLogger

final class AFLLogger {
    static let shared = AFLLogger()

    private let logger = Logger(subsystem: "com.aflai.fantasy", category: "General")
    private let networkLogger = Logger(subsystem: "com.aflai.fantasy", category: "Network")
    private let scraperLogger = Logger(subsystem: "com.aflai.fantasy", category: "Scraper")
    private let persistenceLogger = Logger(subsystem: "com.aflai.fantasy", category: "Persistence")
    private let performanceLogger = Logger(subsystem: "com.aflai.fantasy", category: "Performance")

    private init() {}

    // MARK: - Logging Categories

    enum Category {
        case general
        case network
        case scraper
        case persistence
        case performance
        case ui

        var logger: Logger {
            switch self {
            case .general: AFLLogger.shared.logger
            case .network: AFLLogger.shared.networkLogger
            case .scraper: AFLLogger.shared.scraperLogger
            case .persistence: AFLLogger.shared.persistenceLogger
            case .performance: AFLLogger.shared.performanceLogger
            case .ui: AFLLogger.shared.logger
            }
        }
    }

    // MARK: - Privacy-Aware Logging Methods

    static func info(
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let redactedMessage = redactSensitiveData(message)
        let context = formatContext(file: file, function: function, line: line)
        category.logger.info("\(context, privacy: .public) \(redactedMessage, privacy: .public)")
    }

    static func debug(
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let redactedMessage = redactSensitiveData(message)
        let context = formatContext(file: file, function: function, line: line)
        category.logger.debug("\(context, privacy: .public) \(redactedMessage, privacy: .public)")
    }

    static func warning(
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let redactedMessage = redactSensitiveData(message)
        let context = formatContext(file: file, function: function, line: line)
        category.logger.warning("\(context, privacy: .public) \(redactedMessage, privacy: .public)")
    }

    static func error(
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let redactedMessage = redactSensitiveData(message)
        let context = formatContext(file: file, function: function, line: line)
        category.logger.error("\(context, privacy: .public) \(redactedMessage, privacy: .public)")
    }

    static func fault(
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let redactedMessage = redactSensitiveData(message)
        let context = formatContext(file: file, function: function, line: line)
        category.logger.fault("\(context, privacy: .public) \(redactedMessage, privacy: .public)")
    }

    // MARK: - Performance Logging

    static func logPerformance<T>(operation: String, execute: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try execute()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        performanceLogger
            .info("⏱️ \(operation, privacy: .public) completed in \(timeElapsed * 1000, format: .fixed(precision: 2))ms")

        // Log warning if operation takes longer than expected thresholds
        if timeElapsed > 0.1 { // 100ms threshold
            performanceLogger
                .warning(
                    "🐌 Slow operation: \(operation, privacy: .public) took \(timeElapsed * 1000, format: .fixed(precision: 2))ms"
                )
        }

        return result
    }

    static func logAsyncPerformance<T>(operation: String, execute: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await execute()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        performanceLogger
            .info("⏱️ \(operation, privacy: .public) completed in \(timeElapsed * 1000, format: .fixed(precision: 2))ms")

        if timeElapsed > 0.5 { // 500ms threshold for async operations
            performanceLogger
                .warning(
                    "🐌 Slow async operation: \(operation, privacy: .public) took \(timeElapsed * 1000, format: .fixed(precision: 2))ms"
                )
        }

        return result
    }

    // MARK: - Network Logging

    static func logNetworkRequest(url: String, method: String, statusCode: Int? = nil) {
        let redactedURL = redactSensitiveData(url)
        if let status = statusCode {
            networkLogger.info("🌐 \(method, privacy: .public) \(redactedURL, privacy: .public) → \(status)")
        } else {
            networkLogger.info("🌐 \(method, privacy: .public) \(redactedURL, privacy: .public)")
        }
    }

    static func logNetworkError(url: String, method: String, error: Error) {
        let redactedURL = redactSensitiveData(url)
        networkLogger
            .error(
                "🚨 \(method, privacy: .public) \(redactedURL, privacy: .public) failed: \(error.localizedDescription, privacy: .public)"
            )
    }

    // MARK: - Memory Logging

    static func logMemoryUsage(context: String) {
        let memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let memoryUsageMB = Double(memoryInfo.resident_size) / (1024 * 1024)
            performanceLogger
                .info("📊 Memory usage at \(context, privacy: .public): \(memoryUsageMB, format: .fixed(precision: 1))MB"
                )

            // Warning if memory usage is high
            if memoryUsageMB > 200 {
                performanceLogger
                    .warning(
                        "⚠️ High memory usage at \(context, privacy: .public): \(memoryUsageMB, format: .fixed(precision: 1))MB"
                    )
            }
        }
    }

    // MARK: - Private Methods

    private static func redactSensitiveData(_ message: String) -> String {
        var redacted = message

        // Redact common token patterns
        let tokenPatterns = [
            // API Keys
            ("(?i)api[_-]?key[\"'\\s]*[:=][\"'\\s]*([a-zA-Z0-9]{10,})", "$1[REDACTED]"),
            // Bearer tokens
            ("(?i)bearer\\s+([a-zA-Z0-9_\\-\\.]{10,})", "Bearer [REDACTED]"),
            // Session cookies
            ("(?i)session[_-]?id[\"'\\s]*[:=][\"'\\s]*([a-zA-Z0-9]{10,})", "session_id=[REDACTED]"),
            // AFL Fantasy specific
            ("(?i)team[_-]?id[\"'\\s]*[:=][\"'\\s]*([0-9]{6,})", "team_id=[REDACTED]"),
            // CSRF tokens
            ("(?i)csrf[_-]?token[\"'\\s]*[:=][\"'\\s]*([a-zA-Z0-9]{10,})", "csrf_token=[REDACTED]"),
            // Authorization headers
            ("(?i)authorization[\"'\\s]*:[\"'\\s]*([^\"'\\s,}]+)", "Authorization: [REDACTED]"),
            // Email addresses (partial redaction)
            ("([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})", "***@$2"),
            // Phone numbers
            ("\\b\\d{3}[-.\\s]?\\d{3}[-.\\s]?\\d{4}\\b", "[PHONE-REDACTED]"),
            // Credit card numbers (basic pattern)
            ("\\b\\d{4}[-.\\s]?\\d{4}[-.\\s]?\\d{4}[-.\\s]?\\d{4}\\b", "[CARD-REDACTED]")
        ]

        for (pattern, replacement) in tokenPatterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: redacted.utf16.count)
            redacted = regex?.stringByReplacingMatches(
                in: redacted,
                options: [],
                range: range,
                withTemplate: replacement
            ) ?? redacted
        }

        return redacted
    }

    private static func formatContext(file: String, function: String, line: Int) -> String {
        let filename = (file as NSString).lastPathComponent
        return "[\(filename):\(line)] \(function)"
    }
}

// MARK: - Convenience Extensions

extension Logger {
    func logTimed<T>(_ operation: String, execute: () throws -> T) rethrows -> T {
        try AFLLogger.logPerformance(operation: operation, execute: execute)
    }

    func logTimedAsync<T>(_ operation: String, execute: () async throws -> T) async rethrows -> T {
        try await AFLLogger.logAsyncPerformance(operation: operation, execute: execute)
    }
}

// MARK: - Performance Measurement

struct PerformanceMeasurement {
    let operation: String
    let startTime: CFAbsoluteTime

    init(_ operation: String) {
        self.operation = operation
        startTime = CFAbsoluteTimeGetCurrent()
        AFLLogger.debug("🏁 Starting \(operation)", category: .performance)
    }

    func finish() {
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        AFLLogger.info(
            "✅ \(operation) completed in \(String(format: "%.2f", elapsed * 1000))ms",
            category: .performance
        )
    }

    func finishWithResult<T>(_ result: T) -> T {
        finish()
        return result
    }
}

// MARK: - Debug Only Logging

#if DEBUG
    extension AFLLogger {
        static func debugOnly(
            _ message: String,
            category: Category = .general,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            debug(message, category: category, file: file, function: function, line: line)
        }
    }
#else
    extension AFLLogger {
        static func debugOnly(
            _ message: String,
            category: Category = .general,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            // No-op in release builds
        }
    }
#endif

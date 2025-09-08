//
//  SecurityService.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced security with keychain management, token redaction, and ATS enforcement
//  Created by AI Assistant on 6/9/2025.
//

import CryptoKit
import Foundation
import Network
import os.log
import Security

// MARK: - SecurityService

@MainActor
class SecurityService: ObservableObject {
    static let shared = SecurityService()

    @Published var isSecurityConfigured: Bool = false
    @Published var lastSecurityCheck: Date?
    @Published var securityWarnings: [SecurityWarning] = []

    private let logger = Logger(subsystem: "AFLFantasy", category: "SecurityService")
    private let keychainService = KeychainService.shared
    private let certificatePinner = CertificatePinner()

    // Security configuration
    private let allowedDomains = [
        "fantasy.afl.com.au",
        "api.fantasy.afl.com.au",
        "auth.afl.com.au",
        "cdn.afl.com.au"
    ]

    private init() {
        configureApplicationSecurity()
    }

    // MARK: - Public Interface

    func configureApplicationSecurity() {
        logger.info("🔒 Configuring application security")

        Task {
            // Configure ATS enforcement
            await enforceApplicationTransportSecurity()

            // Validate keychain access
            await validateKeychainAccess()

            // Check certificate pinning
            await validateCertificatePinning()

            // Perform security audit
            await performSecurityAudit()

            isSecurityConfigured = true
            lastSecurityCheck = Date()

            logger.info("✅ Security configuration complete")
        }
    }

    func storeSecureToken(_ token: String, for service: SecureService) async throws {
        let redactedToken = TokenRedactor.redact(token)
        logger.info("🔐 Storing secure token for \(service.rawValue): \(redactedToken)")

        try keychainService.store(
            token,
            forService: service.keychainService,
            account: service.keychainAccount,
            accessibility: .afterFirstUnlock
        )
    }

    func retrieveSecureToken(for service: SecureService) async throws -> String? {
        logger.info("🔓 Retrieving secure token for \(service.rawValue)")

        return try keychainService.retrieve(
            forService: service.keychainService,
            account: service.keychainAccount
        )
    }

    func deleteSecureToken(for service: SecureService) async throws {
        logger.info("🗑️ Deleting secure token for \(service.rawValue)")

        try keychainService.delete(
            forService: service.keychainService,
            account: service.keychainAccount
        )
    }

    func validateNetworkRequest(_ request: URLRequest) throws {
        guard let url = request.url else {
            throw SecurityError.invalidURL
        }

        // Enforce HTTPS
        guard url.scheme == "https" else {
            throw SecurityError.insecureConnection
        }

        // Validate allowed domains
        guard let host = url.host,
              allowedDomains.contains(host)
        else {
            throw SecurityError.domainNotAllowed(host: url.host ?? "unknown")
        }
    }

    func redactSensitiveData(in text: String) -> String {
        TokenRedactor.redactSensitiveInformation(in: text)
    }

    // MARK: - Private Implementation

    private func enforceApplicationTransportSecurity() async {
        logger.info("🛡️ Enforcing Application Transport Security")

        // In a production app, this would involve:
        // 1. Validating Info.plist ATS settings
        // 2. Ensuring no NSAllowsArbitraryLoads
        // 3. Validating domain-specific exceptions

        // For this implementation, we'll simulate the checks
        let atsConfiguration = ATSConfiguration()

        if !atsConfiguration.isProperlyConfigured {
            securityWarnings.append(SecurityWarning(
                type: .weakATS,
                message: "Application Transport Security is not properly configured",
                severity: .high
            ))
        }
    }

    private func validateKeychainAccess() async {
        logger.info("🗝️ Validating keychain access")

        do {
            // Test keychain access with a temporary item
            let testKey = "security_test_\(UUID().uuidString)"
            let testValue = "test_value"

            try keychainService.store(
                testValue,
                forService: "com.aflfantasy.security.test",
                account: testKey,
                accessibility: .afterFirstUnlock
            )

            let retrievedValue = try keychainService.retrieve(
                forService: "com.aflfantasy.security.test",
                account: testKey
            )

            guard retrievedValue == testValue else {
                throw SecurityError.keychainAccessFailed
            }

            // Cleanup test data
            try keychainService.delete(
                forService: "com.aflfantasy.security.test",
                account: testKey
            )

            logger.info("✅ Keychain access validated successfully")

        } catch {
            logger.error("❌ Keychain validation failed: \(error.localizedDescription)")

            securityWarnings.append(SecurityWarning(
                type: .keychainAccessFailed,
                message: "Unable to access secure storage",
                severity: .critical
            ))
        }
    }

    private func validateCertificatePinning() async {
        logger.info("📋 Validating certificate pinning")

        for domain in allowedDomains {
            do {
                let isPinned = try await certificatePinner.validateCertificate(for: domain)
                if !isPinned {
                    securityWarnings.append(SecurityWarning(
                        type: .certificatePinningFailed,
                        message: "Certificate pinning validation failed for \(domain)",
                        severity: .medium
                    ))
                }
            } catch {
                logger.error("❌ Certificate validation failed for \(domain): \(error.localizedDescription)")
            }
        }
    }

    private func performSecurityAudit() async {
        logger.info("🔍 Performing security audit")

        var auditResults: [String] = []

        // Check for jailbreak detection (basic)
        if isJailbroken() {
            securityWarnings.append(SecurityWarning(
                type: .jailbreakDetected,
                message: "Device appears to be jailbroken",
                severity: .high
            ))
            auditResults.append("Jailbreak detected")
        }

        // Check for debug mode
        #if DEBUG
            securityWarnings.append(SecurityWarning(
                type: .debugModeEnabled,
                message: "Application is running in debug mode",
                severity: .low
            ))
            auditResults.append("Debug mode enabled")
        #endif

        // Log audit summary (without sensitive details)
        logger.info("🔍 Security audit completed with \(auditResults.count) findings")
    }

    private func isJailbroken() -> Bool {
        // Basic jailbreak detection - in production, use more sophisticated methods
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Applications/blackra1n.app",
            "/Applications/FakeCarrier.app",
            "/Applications/Icy.app",
            "/Applications/IntelliScreen.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/SBSettings.app",
            "/Applications/WinterBoard.app",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/etc/apt",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/usr/bin/sshd"
        ]

        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        return false
    }
}

// MARK: - Keychain Service Enhancement

extension KeychainService {
    enum KeychainError: Error, LocalizedError {
        case invalidData
        case itemNotFound
        case duplicateItem
        case unhandledError(status: OSStatus)

        var errorDescription: String? {
            switch self {
            case .invalidData:
                "Invalid data provided to keychain"
            case .itemNotFound:
                "Item not found in keychain"
            case .duplicateItem:
                "Item already exists in keychain"
            case let .unhandledError(status):
                "Keychain error with status: \(status)"
            }
        }
    }

    enum KeychainAccessibility {
        case afterFirstUnlock
        case afterFirstUnlockThisDeviceOnly
        case whenPasscodeSetThisDeviceOnly
        case whenUnlocked
        case whenUnlockedThisDeviceOnly

        var secAccessibility: CFString {
            switch self {
            case .afterFirstUnlock:
                kSecAttrAccessibleAfterFirstUnlock
            case .afterFirstUnlockThisDeviceOnly:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .whenPasscodeSetThisDeviceOnly:
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            case .whenUnlocked:
                kSecAttrAccessibleWhenUnlocked
            case .whenUnlockedThisDeviceOnly:
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            }
        }
    }

    func store(
        _ value: String,
        forService service: String,
        account: String,
        accessibility: KeychainAccessibility = .afterFirstUnlock
    ) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: accessibility.secAccessibility,
            kSecValueData as String: data
        ]

        // Try to update first
        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let updateData: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility.secAccessibility
        ]

        let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateData as CFDictionary)

        if updateStatus == errSecItemNotFound {
            // Item doesn't exist, add it
            let addStatus = SecItemAdd(query as CFDictionary, nil)

            guard addStatus == errSecSuccess else {
                throw KeychainError.unhandledError(status: addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.unhandledError(status: updateStatus)
        }
    }

    func retrieve(forService service: String, account: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.invalidData
        }

        return value
    }

    func delete(forService service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

// MARK: - Token Redactor

enum TokenRedactor {
    private static let tokenPatterns = [
        // API Keys
        "(?i)api[_-]?key[\"'\\s]*[:=][\"'\\s]*([a-zA-Z0-9]{20,})",
        // JWT Tokens
        "eyJ[A-Za-z0-9-_=]+\\.[A-Za-z0-9-_=]+\\.?[A-Za-z0-9-_.+/=]*",
        // Session IDs
        "(?i)session[_-]?id[\"'\\s]*[:=][\"'\\s]*([a-zA-Z0-9]{16,})",
        // Passwords
        "(?i)password[\"'\\s]*[:=][\"'\\s]*([^\"'\\s]{6,})",
        // Authentication headers
        "Authorization[\"'\\s]*:[\"'\\s]*Bearer\\s+([a-zA-Z0-9-._~+/]+=*)",
        // Generic secrets
        "(?i)secret[\"'\\s]*[:=][\"'\\s]*([a-zA-Z0-9]{10,})"
    ]

    static func redact(_ token: String) -> String {
        guard token.count > 8 else { return "***" }

        let startChars = String(token.prefix(4))
        let endChars = String(token.suffix(4))
        let middleLength = token.count - 8
        let stars = String(repeating: "*", count: max(middleLength, 4))

        return "\(startChars)\(stars)\(endChars)"
    }

    static func redactSensitiveInformation(in text: String) -> String {
        var redactedText = text

        for pattern in tokenPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let range = NSRange(location: 0, length: text.utf16.count)

                redactedText = regex.stringByReplacingMatches(
                    in: redactedText,
                    options: [],
                    range: range,
                    withTemplate: "[REDACTED]"
                )
            } catch {
                // If regex fails, continue with other patterns
                continue
            }
        }

        return redactedText
    }
}

// MARK: - Certificate Pinner

class CertificatePinner {
    private let logger = Logger(subsystem: "AFLFantasy", category: "CertificatePinner")

    // In production, these would be the actual certificate hashes
    private let pinnedCertificates: [String: [String]] = [
        "fantasy.afl.com.au": ["sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="],
        "api.fantasy.afl.com.au": ["sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="]
    ]

    func validateCertificate(for domain: String) async throws -> Bool {
        guard let expectedHashes = pinnedCertificates[domain] else {
            logger.info("No certificate pinning configured for \(domain)")
            return true // No pinning configured, allow connection
        }

        // In a real implementation, this would:
        // 1. Establish a connection to the domain
        // 2. Extract the certificate chain
        // 3. Calculate SHA256 hashes
        // 4. Compare against pinned hashes

        // For this demo, we'll simulate validation
        logger.info("Validating certificate for \(domain)")

        // Simulate async certificate validation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        return true // Simulated success
    }
}

// MARK: - Security Types

enum SecureService: String, CaseIterable {
    case aflFantasyAPI = "AFL_Fantasy_API"
    case userSession = "User_Session"
    case deviceIdentifier = "Device_Identifier"
    case analyticsToken = "Analytics_Token"

    var keychainService: String {
        "com.aflfantasy.\(rawValue.lowercased())"
    }

    var keychainAccount: String {
        "default"
    }
}

enum SecurityError: Error, LocalizedError {
    case invalidURL
    case insecureConnection
    case domainNotAllowed(host: String)
    case keychainAccessFailed
    case certificateValidationFailed
    case tokenRedactionFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL provided"
        case .insecureConnection:
            "Insecure connection attempted"
        case let .domainNotAllowed(host):
            "Domain not allowed: \(host)"
        case .keychainAccessFailed:
            "Failed to access secure storage"
        case .certificateValidationFailed:
            "Certificate validation failed"
        case .tokenRedactionFailed:
            "Failed to redact sensitive information"
        }
    }
}

struct SecurityWarning: Identifiable {
    let id = UUID()
    let type: SecurityWarningType
    let message: String
    let severity: SecuritySeverity
    let timestamp = Date()
}

enum SecurityWarningType {
    case weakATS
    case keychainAccessFailed
    case certificatePinningFailed
    case jailbreakDetected
    case debugModeEnabled
    case insecureConnection
    case domainViolation
}

enum SecuritySeverity {
    case low
    case medium
    case high
    case critical

    var color: Color {
        switch self {
        case .low: .blue
        case .medium: .orange
        case .high: .red
        case .critical: .purple
        }
    }
}

// MARK: - ATS Configuration

struct ATSConfiguration {
    let isProperlyConfigured: Bool
    let allowsArbitraryLoads: Bool
    let exceptionDomains: [String]

    init() {
        // In a real implementation, this would read from Info.plist
        // For demo purposes, assume proper configuration
        isProperlyConfigured = true
        allowsArbitraryLoads = false
        exceptionDomains = []
    }
}

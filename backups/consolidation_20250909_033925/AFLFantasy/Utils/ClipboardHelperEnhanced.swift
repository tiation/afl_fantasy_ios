//
//  ClipboardHelperEnhanced.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced version with performance, security, and usability improvements
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CookieExtractionResult

/// Result type for cookie extraction with detailed information
struct CookieExtractionResult {
    let cookie: String
    let source: ExtractionSource
    let confidence: Double
    let additionalInfo: [String: String]?

    enum ExtractionSource: String, CaseIterable {
        case rawValue = "Raw Cookie Value"
        case nameValue = "Name=Value Pair"
        case cookieHeader = "HTTP Cookie Header"
        case json = "JSON Format"
        case curlCommand = "cURL Command"
        case postmanExport = "Postman Export"
    }
}

// MARK: - ClipboardHelperEnhanced

/// Enhanced helper class with better performance, security, and user experience
class ClipboardHelperEnhanced {
    // MARK: - Configuration

    private static let supportedCookieNames = ["sessionid", "session_id", "aflsession", "auth_token"]
    private static let minCookieLength = 8
    private static let maxCookieLength = 256
    private static let maxProcessingLength = 50000 // Prevent processing extremely large clipboard content

    // MARK: - Cache for compiled regexes

    private static let regexCache: [String: NSRegularExpression] = {
        var cache: [String: NSRegularExpression] = [:]

        // Pre-compile frequently used regexes
        let patterns = [
            "nameValue": "(?:sessionid|session_id|aflsession|auth_token)\\s*=\\s*([\\w\\-_.=]+)",
            "cookieHeader": "(?:Cookie:\\s*)?.*?(?:sessionid|session_id|aflsession|auth_token)\\s*=\\s*([\\w\\-_.=]+)(?:;|$)",
            "jsonPattern": "\"(?:name|key)\"\\s*:\\s*\"(?:sessionid|session_id|aflsession|auth_token)\".*?\"(?:value|string)\"\\s*:\\s*\"([\\w\\-_.=]+)\"",
            "curlPattern": "curl.*?(?:-H|--header)\\s*[\"']Cookie:\\s*.*?(?:sessionid|session_id|aflsession|auth_token)=([\\w\\-_.=]+)",
            "postmanPattern": "\"key\"\\s*:\\s*\"(?:Cookie|Authorization)\".*?\"value\"\\s*:\\s*\".*?(?:sessionid|session_id|aflsession|auth_token)=([\\w\\-_.=]+)\""
        ]

        for (key, pattern) in patterns {
            if let regex = try? NSRegularExpression(
                pattern: pattern,
                options: [.caseInsensitive, .dotMatchesLineSeparators]
            ) {
                cache[key] = regex
            }
        }

        return cache
    }()

    // MARK: - Public API

    /// Enhanced extraction with detailed result information
    static func extractSessionCookieFromClipboard() -> CookieExtractionResult? {
        guard let clipboardString = UIPasteboard.general.string else {
            return nil
        }

        // Security: Limit processing length to prevent performance issues
        let processableContent = String(clipboardString.prefix(maxProcessingLength))

        // Try extraction methods in order of likelihood and performance
        if let result = extractRawCookie(from: processableContent) {
            return result
        }

        if let result = extractFromNameValue(from: processableContent) {
            return result
        }

        if let result = extractFromCookieHeader(from: processableContent) {
            return result
        }

        if let result = extractFromCurlCommand(from: processableContent) {
            return result
        }

        if let result = extractFromPostmanExport(from: processableContent) {
            return result
        }

        if let result = extractFromJSON(from: processableContent) {
            return result
        }

        return nil
    }

    /// Simple boolean check (maintains backward compatibility)
    static func clipboardContainsPossibleSessionCookie() -> Bool {
        extractSessionCookieFromClipboard() != nil
    }

    /// Get simple cookie value (maintains backward compatibility)
    static func extractSessionCookieFromClipboard() -> String? {
        extractSessionCookieFromClipboard()?.cookie
    }

    // MARK: - Enhanced Extraction Methods

    private static func extractRawCookie(from content: String) -> CookieExtractionResult? {
        let cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidCookieFormat(cleaned) else { return nil }

        // Calculate confidence based on format characteristics
        let confidence = calculateRawCookieConfidence(cleaned)

        return CookieExtractionResult(
            cookie: cleaned,
            source: .rawValue,
            confidence: confidence,
            additionalInfo: ["length": "\(cleaned.count)"]
        )
    }

    private static func extractFromNameValue(from content: String) -> CookieExtractionResult? {
        guard let regex = regexCache["nameValue"] else { return nil }

        let range = NSRange(location: 0, length: content.utf16.count)
        guard let match = regex.firstMatch(in: content, options: [], range: range),
              match.numberOfRanges > 1 else { return nil }

        let valueRange = match.range(at: 1)
        guard let swiftRange = Range(valueRange, in: content) else { return nil }

        let cookieValue = String(content[swiftRange])
        guard isValidCookieFormat(cookieValue) else { return nil }

        return CookieExtractionResult(
            cookie: cookieValue,
            source: .nameValue,
            confidence: 0.95,
            additionalInfo: ["format": "name=value"]
        )
    }

    private static func extractFromCookieHeader(from content: String) -> CookieExtractionResult? {
        guard let regex = regexCache["cookieHeader"] else { return nil }

        let range = NSRange(location: 0, length: content.utf16.count)
        guard let match = regex.firstMatch(in: content, options: [], range: range),
              match.numberOfRanges > 1 else { return nil }

        let valueRange = match.range(at: 1)
        guard let swiftRange = Range(valueRange, in: content) else { return nil }

        let cookieValue = String(content[swiftRange])
        guard isValidCookieFormat(cookieValue) else { return nil }

        // Count other cookies for confidence calculation
        let cookieCount = content.components(separatedBy: ";").count
        let confidence = min(0.98, 0.85 + (Double(cookieCount) * 0.02))

        return CookieExtractionResult(
            cookie: cookieValue,
            source: .cookieHeader,
            confidence: confidence,
            additionalInfo: ["cookieCount": "\(cookieCount)"]
        )
    }

    private static func extractFromCurlCommand(from content: String) -> CookieExtractionResult? {
        guard content.contains("curl") else { return nil }
        guard let regex = regexCache["curlPattern"] else { return nil }

        let range = NSRange(location: 0, length: content.utf16.count)
        guard let match = regex.firstMatch(in: content, options: [], range: range),
              match.numberOfRanges > 1 else { return nil }

        let valueRange = match.range(at: 1)
        guard let swiftRange = Range(valueRange, in: content) else { return nil }

        let cookieValue = String(content[swiftRange])
        guard isValidCookieFormat(cookieValue) else { return nil }

        return CookieExtractionResult(
            cookie: cookieValue,
            source: .curlCommand,
            confidence: 0.92,
            additionalInfo: ["source": "cURL command"]
        )
    }

    private static func extractFromPostmanExport(from content: String) -> CookieExtractionResult? {
        guard content.contains("postman") || (content.contains("key") && content.contains("value")) else { return nil }
        guard let regex = regexCache["postmanPattern"] else { return nil }

        let range = NSRange(location: 0, length: content.utf16.count)
        guard let match = regex.firstMatch(in: content, options: [], range: range),
              match.numberOfRanges > 1 else { return nil }

        let valueRange = match.range(at: 1)
        guard let swiftRange = Range(valueRange, in: content) else { return nil }

        let cookieValue = String(content[swiftRange])
        guard isValidCookieFormat(cookieValue) else { return nil }

        return CookieExtractionResult(
            cookie: cookieValue,
            source: .postmanExport,
            confidence: 0.90,
            additionalInfo: ["source": "Postman export"]
        )
    }

    private static func extractFromJSON(from content: String) -> CookieExtractionResult? {
        guard content.contains("{"), content.contains("}") else { return nil }
        guard let regex = regexCache["jsonPattern"] else { return nil }

        let range = NSRange(location: 0, length: content.utf16.count)
        guard let match = regex.firstMatch(in: content, options: [], range: range),
              match.numberOfRanges > 1 else { return nil }

        let valueRange = match.range(at: 1)
        guard let swiftRange = Range(valueRange, in: content) else { return nil }

        let cookieValue = String(content[swiftRange])
        guard isValidCookieFormat(cookieValue) else { return nil }

        // Try to parse as proper JSON for additional validation
        let isValidJSON = (try? JSONSerialization.jsonObject(with: Data(content.utf8))) != nil
        let confidence = isValidJSON ? 0.88 : 0.75

        return CookieExtractionResult(
            cookie: cookieValue,
            source: .json,
            confidence: confidence,
            additionalInfo: ["validJSON": "\(isValidJSON)"]
        )
    }

    // MARK: - Enhanced Validation

    private static func isValidCookieFormat(_ string: String) -> Bool {
        let cleaned = string.trimmingCharacters(in: .whitespacesAndNewlines)

        // Length check
        guard cleaned.count >= minCookieLength && cleaned.count <= maxCookieLength else {
            return false
        }

        // Character validation - allow common cookie characters
        let allowedChars = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "-_.="))

        guard string.rangeOfCharacter(from: allowedChars.inverted) == nil else {
            return false
        }

        // Pattern-based validation for common cookie formats
        return isHexLikePattern(cleaned) ||
            isBase64LikePattern(cleaned) ||
            isAlphanumericToken(cleaned)
    }

    private static func isHexLikePattern(_ string: String) -> Bool {
        // Check if string looks like hex (optionally with separators)
        let hexPattern = "^[0-9a-fA-F\\-_]+$"
        return string.range(of: hexPattern, options: .regularExpression) != nil
    }

    private static func isBase64LikePattern(_ string: String) -> Bool {
        // Check if string looks like base64
        let base64Pattern = "^[A-Za-z0-9+/=_-]+$"
        return string.range(of: base64Pattern, options: .regularExpression) != nil
    }

    private static func isAlphanumericToken(_ string: String) -> Bool {
        // Check if string is a reasonable alphanumeric token
        let tokenPattern = "^[A-Za-z0-9\\-_.]{8,}$"
        return string.range(of: tokenPattern, options: .regularExpression) != nil
    }

    private static func calculateRawCookieConfidence(_ cookie: String) -> Double {
        var confidence = 0.5

        // Length factors
        if cookie.count >= 24 && cookie.count <= 64 {
            confidence += 0.2
        }

        // Format factors
        if isHexLikePattern(cookie) {
            confidence += 0.2
        }

        if cookie.count == 32 || cookie.count == 40 || cookie.count == 64 {
            confidence += 0.1 // Common hash lengths
        }

        return min(confidence, 0.85) // Cap at 0.85 for raw cookies
    }

    // MARK: - Utility Methods

    /// Get user-friendly description of extraction result
    static func getExtractionDescription(_ result: CookieExtractionResult) -> String {
        let confidencePercent = Int(result.confidence * 100)
        return "Found \(result.source.rawValue) with \(confidencePercent)% confidence"
    }

    /// Validate if clipboard might contain multiple session formats
    static func analyzeClipboardContent() -> [CookieExtractionResult] {
        guard let content = UIPasteboard.general.string else { return [] }

        let processableContent = String(content.prefix(maxProcessingLength))
        var results: [CookieExtractionResult] = []

        // Try all extraction methods
        if let result = extractRawCookie(from: processableContent) {
            results.append(result)
        }

        if let result = extractFromNameValue(from: processableContent) {
            results.append(result)
        }

        if let result = extractFromCookieHeader(from: processableContent) {
            results.append(result)
        }

        if let result = extractFromCurlCommand(from: processableContent) {
            results.append(result)
        }

        if let result = extractFromPostmanExport(from: processableContent) {
            results.append(result)
        }

        if let result = extractFromJSON(from: processableContent) {
            results.append(result)
        }

        // Sort by confidence and remove duplicates
        return results
            .sorted { $0.confidence > $1.confidence }
            .reduce(into: [CookieExtractionResult]()) { unique, result in
                if !unique.contains(where: { $0.cookie == result.cookie }) {
                    unique.append(result)
                }
            }
    }
}

// MARK: - Enhanced Character Extension

extension Character {
    var isHexDigit: Bool {
        isNumber || ("a" ... "f").contains(lowercased()) || ("A" ... "F").contains(lowercased())
    }

    var isCookieChar: Bool {
        isLetter || isNumber || self == "-" || self == "_" || self == "." || self == "="
    }
}

// MARK: - Debug Helper

#if DEBUG
    extension ClipboardHelperEnhanced {
        /// Debug method to test extraction with custom content
        static func debugExtraction(content: String) -> [CookieExtractionResult] {
            let originalClipboard = UIPasteboard.general.string
            UIPasteboard.general.string = content

            let results = analyzeClipboardContent()

            UIPasteboard.general.string = originalClipboard
            return results
        }
    }
#endif

//
//  ClipboardHelper.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import UIKit

/// Helper class to detect and extract AFL Fantasy session cookies from clipboard
class ClipboardHelper {
    
    /// Attempt to extract a session cookie from the clipboard
    /// Returns the extracted cookie string if found, nil otherwise
    static func extractSessionCookieFromClipboard() -> String? {
        guard let clipboardString = UIPasteboard.general.string else {
            return nil
        }
        
        // Try different patterns of possible clipboard contents
        
        // Case 1: Raw sessionid cookie value
        // Example: "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        if isCookieFormat(clipboardString) {
            return clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Case 2: Cookie in Name=Value format
        // Example: "sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        if let sessionCookie = extractCookieFromNameValue(clipboardString) {
            return sessionCookie
        }
        
        // Case 3: Full cookie header with multiple cookies
        // Example: "Cookie: csrftoken=abc123; sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1; other=value"
        if let sessionCookie = extractCookieFromHeader(clipboardString) {
            return sessionCookie
        }
        
        // Case 4: JSON format (from browser dev tools)
        // Example: { "name": "sessionid", "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1" }
        if let sessionCookie = extractCookieFromJSON(clipboardString) {
            return sessionCookie
        }
        
        // No recognized cookie format
        return nil
    }
    
    /// Check if a string looks like a session cookie value (alphanumeric, certain length)
    private static func isCookieFormat(_ string: String) -> Bool {
        // Session cookies are typically hex strings between 20-64 characters
        let cleaned = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let isHexString = cleaned.allSatisfy { $0.isHexDigit || $0 == "-" || $0 == "_" }
        let hasReasonableLength = cleaned.count >= 20 && cleaned.count <= 128
        
        return isHexString && hasReasonableLength
    }
    
    /// Extract cookie from name=value format
    private static func extractCookieFromNameValue(_ string: String) -> String? {
        // Try to match "sessionid=value" pattern
        if let regex = try? NSRegularExpression(pattern: "sessionid\\s*=\\s*([\\w\\-_]+)", options: .caseInsensitive) {
            let range = NSRange(location: 0, length: string.utf16.count)
            if let match = regex.firstMatch(in: string, options: [], range: range) {
                if match.numberOfRanges > 1 {
                    let valueRange = match.range(at: 1)
                    if let swiftRange = Range(valueRange, in: string) {
                        let value = String(string[swiftRange])
                        if isCookieFormat(value) {
                            return value
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// Extract sessionid cookie from a cookie header with multiple cookies
    private static func extractCookieFromHeader(_ string: String) -> String? {
        // Match Cookie: header format or just semicolon-separated cookies
        if let regex = try? NSRegularExpression(pattern: "(?:Cookie:\\s*)?.*?sessionid\\s*=\\s*([\\w\\-_]+)(?:;|$)", options: .caseInsensitive) {
            let range = NSRange(location: 0, length: string.utf16.count)
            if let match = regex.firstMatch(in: string, options: [], range: range) {
                if match.numberOfRanges > 1 {
                    let valueRange = match.range(at: 1)
                    if let swiftRange = Range(valueRange, in: string) {
                        let value = String(string[swiftRange])
                        if isCookieFormat(value) {
                            return value
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// Extract cookie from JSON format (from browser dev tools)
    private static func extractCookieFromJSON(_ string: String) -> String? {
        // Check if looks like JSON
        guard string.contains("{") && string.contains("}") else {
            return nil
        }
        
        // Try to match JSON with sessionid
        if let regex = try? NSRegularExpression(
            pattern: "\"(?:name|key)\"\\s*:\\s*\"sessionid\".*?\"(?:value|string)\"\\s*:\\s*\"([\\w\\-_]+)\"",
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        ) {
            let range = NSRange(location: 0, length: string.utf16.count)
            if let match = regex.firstMatch(in: string, options: [], range: range) {
                if match.numberOfRanges > 1 {
                    let valueRange = match.range(at: 1)
                    if let swiftRange = Range(valueRange, in: string) {
                        let value = String(string[swiftRange])
                        if isCookieFormat(value) {
                            return value
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Detects if clipboard contains something that might be a session cookie
    static func clipboardContainsPossibleSessionCookie() -> Bool {
        return extractSessionCookieFromClipboard() != nil
    }
}

// MARK: - Character Extension

extension Character {
    var isHexDigit: Bool {
        return isNumber || ("a"..."f").contains(lowercased()) || ("A"..."F").contains(lowercased())
    }
}

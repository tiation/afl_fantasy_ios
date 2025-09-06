//
//  ClipboardHelperTests.swift
//  AFLFantasyTests
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import XCTest
@testable import AFLFantasy

final class ClipboardHelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear clipboard before each test
        UIPasteboard.general.string = ""
    }
    
    override func tearDown() {
        // Clean up clipboard after each test
        UIPasteboard.general.string = ""
        super.tearDown()
    }
    
    // MARK: - Raw Cookie Format Tests
    
    func testRawCookieDetection() {
        // Test valid raw session cookie
        UIPasteboard.general.string = "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testLongRawCookie() {
        // Test longer valid cookie
        UIPasteboard.general.string = "a1b2c3d4e5f6789012345678901234567890abcdef1234567890"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "a1b2c3d4e5f6789012345678901234567890abcdef1234567890")
    }
    
    func testRawCookieWithWhitespace() {
        // Test cookie with surrounding whitespace
        UIPasteboard.general.string = "  3f28da7c9a32b7e1b3d5f7a8c6e9d2b1  \n"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testCookieWithDashes() {
        // Test cookie with dashes (common in some implementations)
        UIPasteboard.general.string = "3f28-da7c-9a32-b7e1-b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28-da7c-9a32-b7e1-b3d5f7a8c6e9d2b1")
    }
    
    func testCookieWithUnderscores() {
        // Test cookie with underscores
        UIPasteboard.general.string = "3f28_da7c_9a32_b7e1_b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28_da7c_9a32_b7e1_b3d5f7a8c6e9d2b1")
    }
    
    // MARK: - Name=Value Format Tests
    
    func testNameValueFormat() {
        // Test sessionid=value format
        UIPasteboard.general.string = "sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testNameValueWithSpaces() {
        // Test with spaces around equals
        UIPasteboard.general.string = "sessionid = 3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testNameValueCaseInsensitive() {
        // Test case insensitive matching
        UIPasteboard.general.string = "SessionID=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    // MARK: - Cookie Header Format Tests
    
    func testCookieHeaderSingle() {
        // Test Cookie: header with single cookie
        UIPasteboard.general.string = "Cookie: sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testCookieHeaderMultiple() {
        // Test Cookie header with multiple cookies
        UIPasteboard.general.string = "Cookie: csrftoken=abc123; sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1; other=value"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testSemicolonSeparatedCookies() {
        // Test semicolon-separated cookies without Cookie: prefix
        UIPasteboard.general.string = "csrftoken=abc123; sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1; other=value"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testCookieHeaderCaseInsensitive() {
        // Test case insensitive Cookie header
        UIPasteboard.general.string = "cookie: SessionID=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    // MARK: - JSON Format Tests
    
    func testJSONFormat() {
        // Test JSON from browser dev tools
        let jsonString = """
        {
          "name": "sessionid",
          "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1",
          "domain": ".fantasy.afl.com.au"
        }
        """
        UIPasteboard.general.string = jsonString
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testJSONWithKeyVariation() {
        // Test JSON with "key" instead of "name"
        let jsonString = """
        {
          "key": "sessionid",
          "string": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        }
        """
        UIPasteboard.general.string = jsonString
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testJSONComplexFormat() {
        // Test more complex JSON structure
        let jsonString = """
        {
          "cookies": [
            {
              "name": "csrftoken",
              "value": "abc123"
            },
            {
              "name": "sessionid", 
              "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1",
              "httpOnly": true
            }
          ]
        }
        """
        UIPasteboard.general.string = jsonString
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    // MARK: - Invalid Format Tests
    
    func testEmptyClipboard() {
        UIPasteboard.general.string = ""
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertNil(result)
    }
    
    func testNoClipboardString() {
        UIPasteboard.general.string = nil
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertNil(result)
    }
    
    func testTooShortCookie() {
        // Test cookie that's too short
        UIPasteboard.general.string = "abc123"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertNil(result)
    }
    
    func testTooLongCookie() {
        // Test cookie that's too long (over 128 chars)
        let longCookie = String(repeating: "a", count: 150)
        UIPasteboard.general.string = longCookie
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertNil(result)
    }
    
    func testInvalidCharacters() {
        // Test cookie with invalid characters
        UIPasteboard.general.string = "sessionid=invalid@#$%characters!"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertNil(result)
    }
    
    func testRandomText() {
        // Test with random text that shouldn't match
        UIPasteboard.general.string = "This is just some random text that doesn't contain any session cookie"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertNil(result)
    }
    
    func testWrongCookieName() {
        // Test with different cookie name
        UIPasteboard.general.string = "wrongname=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertNil(result)
    }
    
    // MARK: - Detection Tests
    
    func testClipboardContainsPossibleSessionCookieTrue() {
        UIPasteboard.general.string = "sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        
        let result = ClipboardHelper.clipboardContainsPossibleSessionCookie()
        XCTAssertTrue(result)
    }
    
    func testClipboardContainsPossibleSessionCookieFalse() {
        UIPasteboard.general.string = "This is not a session cookie"
        
        let result = ClipboardHelper.clipboardContainsPossibleSessionCookie()
        XCTAssertFalse(result)
    }
    
    func testClipboardContainsPossibleSessionCookieEmpty() {
        UIPasteboard.general.string = ""
        
        let result = ClipboardHelper.clipboardContainsPossibleSessionCookie()
        XCTAssertFalse(result)
    }
    
    // MARK: - Edge Cases Tests
    
    func testMixedValidAndInvalidContent() {
        // Test content that has both valid and invalid parts
        UIPasteboard.general.string = """
        Some random text here
        sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1
        More random text
        """
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testMultilineJSON() {
        // Test multiline JSON (common when copying from dev tools)
        let jsonString = """
        {
            "name": "sessionid",
            "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1",
            "domain": ".fantasy.afl.com.au",
            "path": "/",
            "expires": "2024-12-31T23:59:59.000Z",
            "httpOnly": true,
            "secure": true
        }
        """
        UIPasteboard.general.string = jsonString
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testSessionIdInMiddleOfCookieHeader() {
        // Test sessionid in the middle of multiple cookies
        UIPasteboard.general.string = "first=value1; second=value2; sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1; third=value3"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1")
    }
    
    func testUppercaseHexCharacters() {
        // Test with uppercase hex characters
        UIPasteboard.general.string = "sessionid=3F28DA7C9A32B7E1B3D5F7A8C6E9D2B1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3F28DA7C9A32B7E1B3D5F7A8C6E9D2B1")
    }
    
    func testMixedCaseHexCharacters() {
        // Test with mixed case hex characters
        UIPasteboard.general.string = "sessionid=3f28DA7c9A32b7E1B3d5F7a8C6e9D2b1"
        
        let result = ClipboardHelper.extractSessionCookieFromClipboard()
        XCTAssertEqual(result, "3f28DA7c9A32b7E1B3d5F7a8C6e9D2b1")
    }
}

// MARK: - Character Extension Tests

final class CharacterExtensionTests: XCTestCase {
    
    func testIsHexDigitNumbers() {
        for char in "0123456789" {
            XCTAssertTrue(char.isHexDigit, "Character \(char) should be hex digit")
        }
    }
    
    func testIsHexDigitLowercaseLetters() {
        for char in "abcdef" {
            XCTAssertTrue(char.isHexDigit, "Character \(char) should be hex digit")
        }
    }
    
    func testIsHexDigitUppercaseLetters() {
        for char in "ABCDEF" {
            XCTAssertTrue(char.isHexDigit, "Character \(char) should be hex digit")
        }
    }
    
    func testIsHexDigitInvalidCharacters() {
        for char in "ghijklmnopqrstuvwxyzGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+" {
            XCTAssertFalse(char.isHexDigit, "Character \(char) should not be hex digit")
        }
    }
}

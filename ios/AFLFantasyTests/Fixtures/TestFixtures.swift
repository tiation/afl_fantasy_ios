//
//  TestFixtures.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation

// MARK: - TestFixtures

/// Test fixtures for unit testing
public enum TestFixtures {
    // MARK: - Dashboard Fixtures

    public static let dashboardJSON = """
    {
        "teamValue": {
            "current": 74000000,
            "bank": 9500000,
            "total": 83500000
        },
        "rank": {
            "overall": 15847,
            "league": null
        },
        "upcomingMatchups": [
            {
                "homeTeam": "Melbourne",
                "awayTeam": "Collingwood",
                "startTime": "2025-08-30T14:20:00Z",
                "round": 24
            },
            {
                "homeTeam": "Carlton", 
                "awayTeam": "Brisbane",
                "startTime": "2025-08-31T14:20:00Z",
                "round": 24
            }
        ],
        "topPerformers": [
            {
                "name": "Max Gawn",
                "team": "Melbourne",
                "score": 145,
                "position": "RUC"
            },
            {
                "name": "Clayton Oliver",
                "team": "Melbourne", 
                "score": 128,
                "position": "MID"
            }
        ],
        "lastUpdated": "2025-09-06T13:13:05.176Z",
        "nextDeadline": "2025-08-29T19:50:00Z"
    }
    """

    // MARK: - Players Fixtures

    public static let playersJSON = """
    {
        "players": [
            {
                "id": 1,
                "name": "Max Gawn",
                "team": "Melbourne", 
                "position": "RUC",
                "price": 800000,
                "averageScore": 105.2,
                "lastScore": 112
            },
            {
                "id": 2,
                "name": "Clayton Oliver",
                "team": "Melbourne",
                "position": "MID", 
                "price": 750000,
                "averageScore": 115.8,
                "lastScore": 128
            },
            {
                "id": 3,
                "name": "Christian Petracca",
                "team": "Melbourne",
                "position": "MID",
                "price": 720000,
                "averageScore": 110.4,
                "lastScore": 94
            }
        ],
        "total": 3,
        "limit": 100,
        "offset": 0
    }
    """

    public static let singlePlayerJSON = """
    {
        "player": {
            "id": 1,
            "name": "Max Gawn",
            "team": "Melbourne",
            "position": "RUC",
            "price": 800000,
            "averageScore": 105.2,
            "lastScore": 112
        }
    }
    """

    // MARK: - Error Fixtures

    public static let errorResponseJSON = """
    {
        "error": {
            "code": "NOT_FOUND",
            "message": "Player not found",
            "details": "The requested player with ID 999 was not found"
        }
    }
    """

    // MARK: - Helper Methods

    /// Get dashboard response data for testing
    public static var dashboardData: Data {
        dashboardJSON.data(using: .utf8) ?? Data()
    }

    /// Get players response data for testing
    public static var playersData: Data {
        playersJSON.data(using: .utf8) ?? Data()
    }

    /// Get single player response data for testing
    public static var singlePlayerData: Data {
        singlePlayerJSON.data(using: .utf8) ?? Data()
    }

    /// Get error response data for testing
    public static var errorData: Data {
        errorResponseJSON.data(using: .utf8) ?? Data()
    }
}

// MARK: - MockURLProtocol

/// Mock URLProtocol for testing network calls
public class MockURLProtocol: URLProtocol {
    // MARK: - Properties

    public static var mockData: Data?
    public static var mockResponse: URLResponse?
    public static var mockError: Error?

    // MARK: - URLProtocol Override

    override public class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override public func startLoading() {
        // Return mock error if set
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        // Return mock response if set
        if let response = MockURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        // Return mock data if set
        if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override public func stopLoading() {
        // No-op
    }

    // MARK: - Test Helpers

    /// Reset all mock data
    public static func reset() {
        mockData = nil
        mockResponse = nil
        mockError = nil
    }

    /// Setup successful response
    public static func setupSuccess(data: Data, statusCode: Int = 200) {
        mockData = data
        mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        mockError = nil
    }

    /// Setup error response
    public static func setupError(_ error: Error) {
        mockError = error
        mockData = nil
        mockResponse = nil
    }
}

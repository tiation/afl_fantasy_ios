import Foundation
import XCTest

// MARK: - MockURLProtocol

/// URLProtocol subclass for stubbing network requests in tests
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let handler = Self.requestHandler else {
            XCTFail("Request handler is not set")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

// MARK: - APIStubHelpers

enum APIStubHelpers {
    static func jsonData<T: Encodable>(from object: T) -> Data? {
        try? JSONEncoder().encode(object)
    }
    
    static func successResponse(for url: URL, statusCode: Int = 200) -> HTTPURLResponse? {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "1.1",
            headerFields: ["Content-Type": "application/json"]
        )
    }
    
    static func errorResponse(for url: URL, statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "1.1",
            headerFields: nil
        )
    }
}

// MARK: - Mock Data Factory

struct MockDataFactory {
    static func mockPlayers() -> [Player] {
        [
            Player(
                id: "1",
                name: "Marcus Bontempelli",
                team: "WB",
                position: .midfielder,
                price: 725000,
                average: 105.2,
                projected: 108.5,
                breakeven: -15
            ),
            Player(
                id: "2",
                name: "Clayton Oliver",
                team: "MEL",
                position: .midfielder,
                price: 680000,
                average: 98.7,
                projected: 102.1,
                breakeven: -8
            ),
            Player(
                id: "3",
                name: "Jordan Dawson",
                team: "ADE",
                position: .defender,
                price: 420000,
                average: 89.2,
                projected: 92.8,
                breakeven: 45
            )
        ]
    }
    
    static func mockCashCows() -> [CashCowAnalysis] {
        [
            CashCowAnalysis(
                playerId: "1",
                playerName: "Jordan Dawson",
                currentPrice: 420000,
                projectedPrice: 480000,
                cashGenerated: 60000,
                recommendation: "HOLD",
                confidence: 0.85,
                fpAverage: 89.2,
                gamesPlayed: 8
            ),
            CashCowAnalysis(
                playerId: "2",
                playerName: "Nick Daicos",
                currentPrice: 380000,
                projectedPrice: 450000,
                cashGenerated: 70000,
                recommendation: "HOLD",
                confidence: 0.75,
                fpAverage: 95.8,
                gamesPlayed: 6
            )
        ]
    }
    
    static func mockHealthResponse() -> APIHealthResponse {
        APIHealthResponse(
            status: "healthy",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            playersLoaded: 603
        )
    }
    
    static func mockStatsResponse() -> APIStatsResponse {
        APIStatsResponse(
            totalPlayers: 603,
            playersWithData: 580,
            cashCowsIdentified: 45,
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            cacheAgeMinutes: 5
        )
    }
}

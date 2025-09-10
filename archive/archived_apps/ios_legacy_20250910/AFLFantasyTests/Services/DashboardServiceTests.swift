//
//  DashboardServiceTests.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

@testable import AFLFantasy
import Combine
import XCTest

// MARK: - DashboardServiceTests

final class DashboardServiceTests: XCTestCase {
    // MARK: - Properties

    private var dashboardService: DashboardService!
    private var cancellables: Set<AnyCancellable>!
    private var mockURLSession: URLSession!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()

        // Configure mock URL session
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockURLSession = URLSession(configuration: configuration)

        // Create dashboard service
        dashboardService = DashboardService()
        cancellables = Set<AnyCancellable>()

        // Reset mock protocol
        MockURLProtocol.reset()
    }

    override func tearDown() {
        dashboardService = nil
        cancellables = nil
        mockURLSession = nil
        MockURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - Test Cases

    func testGetDashboardSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Dashboard fetch success")
        MockURLProtocol.setupSuccess(data: TestFixtures.dashboardData)

        // When
        dashboardService.getDashboard()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        XCTFail("Expected success, got error: \(error)")
                    }
                },
                receiveValue: { response in
                    // Then
                    XCTAssertEqual(response.teamValue.current, 74_000_000)
                    XCTAssertEqual(response.teamValue.bank, 9_500_000)
                    XCTAssertEqual(response.teamValue.total, 83_500_000)
                    XCTAssertEqual(response.rank.overall, 15847)
                    XCTAssertNil(response.rank.league)
                    XCTAssertEqual(response.upcomingMatchups.count, 2)
                    XCTAssertEqual(response.upcomingMatchups.first?.homeTeam, "Melbourne")
                    XCTAssertEqual(response.upcomingMatchups.first?.awayTeam, "Collingwood")
                    XCTAssertEqual(response.topPerformers?.count, 2)
                    XCTAssertEqual(response.topPerformers?.first?.name, "Max Gawn")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetDashboardCaching() {
        // Given
        let firstExpectation = XCTestExpectation(description: "First dashboard fetch")
        let secondExpectation = XCTestExpectation(description: "Second dashboard fetch (cached)")

        MockURLProtocol.setupSuccess(data: TestFixtures.dashboardData)

        // When - First fetch
        dashboardService.getDashboard()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response.teamValue.current, 74_000_000)
                    firstExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [firstExpectation], timeout: 5.0)

        // Setup different data for second call
        let differentData = """
        {
            "teamValue": { "current": 75000000, "bank": 8500000, "total": 83500000 },
            "rank": { "overall": 16000, "league": null },
            "upcomingMatchups": [],
            "topPerformers": [],
            "lastUpdated": "2025-09-06T14:13:05.176Z",
            "nextDeadline": null
        }
        """.data(using: .utf8)!

        MockURLProtocol.setupSuccess(data: differentData)

        // When - Second fetch (should use cache)
        dashboardService.getDashboard(forceRefresh: false)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    // Should still have cached data, not new data
                    XCTAssertEqual(response.teamValue.current, 74_000_000) // Original cached value
                    secondExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [secondExpectation], timeout: 5.0)
    }

    func testGetDashboardForceRefresh() {
        // Given
        let firstExpectation = XCTestExpectation(description: "First dashboard fetch")
        let secondExpectation = XCTestExpectation(description: "Force refresh fetch")

        MockURLProtocol.setupSuccess(data: TestFixtures.dashboardData)

        // First fetch to populate cache
        dashboardService.getDashboard()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response.teamValue.current, 74_000_000)
                    firstExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [firstExpectation], timeout: 5.0)

        // Setup different data for force refresh
        let updatedData = """
        {
            "teamValue": { "current": 75000000, "bank": 8500000, "total": 83500000 },
            "rank": { "overall": 16000, "league": null },
            "upcomingMatchups": [],
            "topPerformers": [],
            "lastUpdated": "2025-09-06T14:13:05.176Z",
            "nextDeadline": null
        }
        """.data(using: .utf8)!

        MockURLProtocol.setupSuccess(data: updatedData)

        // Force refresh should get new data
        dashboardService.getDashboard(forceRefresh: true)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    // Should have new data
                    XCTAssertEqual(response.teamValue.current, 75_000_000) // New value
                    secondExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [secondExpectation], timeout: 5.0)
    }

    func testGetDashboardNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Dashboard fetch network error")
        let networkError = URLError(.networkConnectionLost)
        MockURLProtocol.setupError(networkError)

        // When
        dashboardService.getDashboard()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected error, got success")
                    case let .failure(error):
                        // Then
                        XCTAssertTrue(error is DashboardServiceError)
                        if case let .networkError(underlyingError) = error as? DashboardServiceError {
                            XCTAssertEqual((underlyingError as? URLError)?.code, .networkConnectionLost)
                        } else {
                            XCTFail("Expected network error")
                        }
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected error, got success")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetDashboardHTTPError() {
        // Given
        let expectation = XCTestExpectation(description: "Dashboard fetch HTTP error")
        MockURLProtocol.setupSuccess(data: TestFixtures.errorData, statusCode: 500)

        // When
        dashboardService.getDashboard()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected error, got success")
                    case let .failure(error):
                        // Then
                        XCTAssertTrue(error is DashboardServiceError)
                        if case let .httpError(statusCode) = error as? DashboardServiceError {
                            XCTAssertEqual(statusCode, 500)
                        } else {
                            XCTFail("Expected HTTP error, got: \(error)")
                        }
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected error, got success")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetDashboardDecodingError() {
        // Given
        let expectation = XCTestExpectation(description: "Dashboard fetch decoding error")
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        MockURLProtocol.setupSuccess(data: invalidJSON)

        // When
        dashboardService.getDashboard()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected error, got success")
                    case let .failure(error):
                        // Then
                        XCTAssertTrue(error is DashboardServiceError)
                        if case .decodingError = error as? DashboardServiceError {
                            // Expected
                        } else {
                            XCTFail("Expected decoding error, got: \(error)")
                        }
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected error, got success")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testCachedDashboardProperty() {
        // Given
        let expectation = XCTestExpectation(description: "Cache property test")
        MockURLProtocol.setupSuccess(data: TestFixtures.dashboardData)

        // Initially no cached data
        XCTAssertNil(dashboardService.cachedDashboard)

        // When
        dashboardService.getDashboard()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    // Then
                    XCTAssertNotNil(self.dashboardService.cachedDashboard)
                    XCTAssertEqual(self.dashboardService.cachedDashboard?.teamValue.current, 74_000_000)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testClearCache() {
        // Given
        let expectation = XCTestExpectation(description: "Clear cache test")
        MockURLProtocol.setupSuccess(data: TestFixtures.dashboardData)

        // Populate cache first
        dashboardService.getDashboard()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    // Verify cache is populated
                    XCTAssertNotNil(self.dashboardService.cachedDashboard)
                    XCTAssertNotNil(self.dashboardService.dashboard)

                    // When - Clear cache
                    self.dashboardService.clearCache()

                    // Then - Cache should be empty
                    XCTAssertNil(self.dashboardService.cachedDashboard)
                    XCTAssertNil(self.dashboardService.dashboard)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testRefreshMethod() {
        // Given
        let expectation = XCTestExpectation(description: "Refresh method test")
        MockURLProtocol.setupSuccess(data: TestFixtures.dashboardData)

        // When
        dashboardService.refresh()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        XCTFail("Expected success, got error: \(error)")
                    }
                },
                receiveValue: { response in
                    // Then
                    XCTAssertEqual(response.teamValue.current, 74_000_000)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDashboardServicePublishedProperties() {
        // Given
        let loadingExpectation = XCTestExpectation(description: "Loading state")
        let dashboardExpectation = XCTestExpectation(description: "Dashboard state")

        MockURLProtocol.setupSuccess(data: TestFixtures.dashboardData)

        // When
        dashboardService.$isLoading
            .dropFirst() // Skip initial false value
            .sink { isLoading in
                if isLoading {
                    loadingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        dashboardService.$dashboard
            .compactMap { $0 } // Only non-nil values
            .sink { dashboard in
                XCTAssertEqual(dashboard.teamValue.current, 74_000_000)
                dashboardExpectation.fulfill()
            }
            .store(in: &cancellables)

        dashboardService.getDashboard()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [loadingExpectation, dashboardExpectation], timeout: 5.0)
    }

    func testDashboardServiceErrorDescriptions() {
        // Test error descriptions
        let apiError = DashboardServiceError.apiError(URLError(.networkConnectionLost))
        XCTAssertTrue(apiError.localizedDescription.contains("API error"))

        let noDataError = DashboardServiceError.noData
        XCTAssertEqual(noDataError.localizedDescription, "No data received from server")

        let invalidURLError = DashboardServiceError.invalidURL
        XCTAssertEqual(invalidURLError.localizedDescription, "Invalid URL configuration")

        let networkError = DashboardServiceError.networkError(URLError(.networkConnectionLost))
        XCTAssertTrue(networkError.localizedDescription.contains("Network error"))

        let httpError = DashboardServiceError.httpError(404)
        XCTAssertEqual(httpError.localizedDescription, "HTTP error with status code: 404")

        // Test recovery suggestions
        XCTAssertEqual(networkError.recoverySuggestion, "Check your internet connection and try again.")

        let serverError = DashboardServiceError.httpError(500)
        XCTAssertEqual(serverError.recoverySuggestion, "Server error. Please try again later.")

        let authError = DashboardServiceError.httpError(401)
        XCTAssertEqual(authError.recoverySuggestion, "Authentication required. Please log in again.")

        let decodingError = DashboardServiceError.decodingError(URLError(.badURL))
        XCTAssertEqual(decodingError.recoverySuggestion, "Data format error. The server response may have changed.")
    }

    // MARK: - Performance Tests

    func testGetDashboardPerformance() {
        // Given
        MockURLProtocol.setupSuccess(data: TestFixtures.dashboardData)

        // When/Then
        measure {
            let expectation = XCTestExpectation(description: "Performance test")

            dashboardService.getDashboard()
                .sink(
                    receiveCompletion: { _ in expectation.fulfill() },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            wait(for: [expectation], timeout: 1.0)
        }
    }
}

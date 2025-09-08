//
//  PlayerServiceTests.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

@testable import AFLFantasy
import Combine
import XCTest

// MARK: - PlayerServiceTests

final class PlayerServiceTests: XCTestCase {
    // MARK: - Properties

    private var playerService: PlayerService!
    private var cancellables: Set<AnyCancellable>!
    private var mockURLSession: URLSession!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()

        // Configure mock URL session
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockURLSession = URLSession(configuration: configuration)

        // Create player service
        playerService = PlayerService()
        cancellables = Set<AnyCancellable>()

        // Reset mock protocol
        MockURLProtocol.reset()
    }

    override func tearDown() {
        playerService = nil
        cancellables = nil
        mockURLSession = nil
        MockURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - Test Cases

    func testGetPlayersSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Players fetch success")
        MockURLProtocol.setupSuccess(data: TestFixtures.playersData)

        // When
        playerService.getPlayers()
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
                    XCTAssertEqual(response.total, 3)
                    XCTAssertEqual(response.players.count, 3)
                    XCTAssertEqual(response.players.first?.name, "Max Gawn")
                    XCTAssertEqual(response.players.first?.team, "Melbourne")
                    XCTAssertEqual(response.players.first?.position, "RUC")
                    XCTAssertEqual(response.players.first?.price, 800_000)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetPlayersWithFilters() {
        // Given
        let expectation = XCTestExpectation(description: "Players fetch with filters")
        MockURLProtocol.setupSuccess(data: TestFixtures.playersData)

        // When
        playerService.getPlayers(
            position: .midfielder,
            season: 2025,
            limit: 50,
            offset: 10
        )
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
                XCTAssertEqual(response.total, 3)
                XCTAssertEqual(response.limit, 100) // From fixture
                XCTAssertEqual(response.offset, 0) // From fixture
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetPlayersNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Players fetch network error")
        let networkError = URLError(.networkConnectionLost)
        MockURLProtocol.setupError(networkError)

        // When
        playerService.getPlayers()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected error, got success")
                    case let .failure(error):
                        // Then
                        XCTAssertTrue(error is PlayerServiceError)
                        if case let .networkError(underlyingError) = error as? PlayerServiceError {
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

    func testGetPlayersDecodingError() {
        // Given
        let expectation = XCTestExpectation(description: "Players fetch decoding error")
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        MockURLProtocol.setupSuccess(data: invalidJSON)

        // When
        playerService.getPlayers()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected error, got success")
                    case let .failure(error):
                        // Then
                        XCTAssertTrue(error is PlayerServiceError)
                        if case .decodingError = error as? PlayerServiceError {
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

    func testGetSinglePlayerSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Single player fetch success")
        MockURLProtocol.setupSuccess(data: TestFixtures.singlePlayerData)

        // When
        playerService.getPlayer(id: 1)
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
                    XCTAssertEqual(response.player.id, 1)
                    XCTAssertEqual(response.player.name, "Max Gawn")
                    XCTAssertEqual(response.player.team, "Melbourne")
                    XCTAssertEqual(response.player.position, "RUC")
                    XCTAssertEqual(response.player.price, 800_000)
                    XCTAssertEqual(response.player.averageScore, 105.2)
                    XCTAssertEqual(response.player.lastScore, 112)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetSinglePlayerNotFound() {
        // Given
        let expectation = XCTestExpectation(description: "Single player not found")
        MockURLProtocol.setupSuccess(data: TestFixtures.errorData, statusCode: 404)

        // When
        playerService.getPlayer(id: 999)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected error, got success")
                    case let .failure(error):
                        // Then
                        XCTAssertTrue(error is PlayerServiceError)
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

    func testPlayerServicePublishedProperties() {
        // Given
        let loadingExpectation = XCTestExpectation(description: "Loading state")
        let errorExpectation = XCTestExpectation(description: "Error state")

        MockURLProtocol.setupError(URLError(.networkConnectionLost))

        // When
        playerService.$isLoading
            .dropFirst() // Skip initial false value
            .sink { isLoading in
                if isLoading {
                    loadingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        playerService.$lastError
            .compactMap { $0 } // Only non-nil errors
            .sink { error in
                XCTAssertNotNil(error)
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)

        playerService.getPlayers()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [loadingExpectation, errorExpectation], timeout: 5.0)
    }

    func testPlayerPositionEnum() {
        // Test enum cases
        XCTAssertEqual(PlayerPosition.defender.rawValue, "DEF")
        XCTAssertEqual(PlayerPosition.midfielder.rawValue, "MID")
        XCTAssertEqual(PlayerPosition.ruck.rawValue, "RUC")
        XCTAssertEqual(PlayerPosition.forward.rawValue, "FWD")

        // Test all cases are available
        XCTAssertEqual(PlayerPosition.allCases.count, 4)
    }

    func testPlayerServiceErrorDescriptions() {
        // Test error descriptions
        let apiError = PlayerServiceError.apiError(URLError(.networkConnectionLost))
        XCTAssertTrue(apiError.localizedDescription.contains("API error"))

        let noDataError = PlayerServiceError.noData
        XCTAssertEqual(noDataError.localizedDescription, "No data received from server")

        let invalidURLError = PlayerServiceError.invalidURL
        XCTAssertEqual(invalidURLError.localizedDescription, "Invalid URL configuration")

        let networkError = PlayerServiceError.networkError(URLError(.networkConnectionLost))
        XCTAssertTrue(networkError.localizedDescription.contains("Network error"))

        let decodingError = PlayerServiceError.decodingError(URLError(.badURL))
        XCTAssertTrue(decodingError.localizedDescription.contains("Failed to decode response"))
    }

    // MARK: - Performance Tests

    func testGetPlayersPerformance() {
        // Given
        MockURLProtocol.setupSuccess(data: TestFixtures.playersData)

        // When/Then
        measure {
            let expectation = XCTestExpectation(description: "Performance test")

            playerService.getPlayers()
                .sink(
                    receiveCompletion: { _ in expectation.fulfill() },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            wait(for: [expectation], timeout: 1.0)
        }
    }
}

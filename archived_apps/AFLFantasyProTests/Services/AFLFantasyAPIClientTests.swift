//
//  AFLFantasyAPIClientTests.swift
//  AFL Fantasy Pro Tests - API Client Tests
//
//  Unit tests for AFLFantasyAPIClient with mock implementations
//  and comprehensive error handling scenarios.
//

import XCTest
import Combine
@testable import AFLFantasyPro

final class AFLFantasyAPIClientTests: XCTestCase {
    
    var apiClient: AFLFantasyAPIClient!
    var mockSession: MockURLSession!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        apiClient = AFLFantasyAPIClient(session: mockSession)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        apiClient = nil
        mockSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Authentication Tests
    
    func testSignInSuccess() async throws {
        // Given
        let expectedUser = User(id: "123", username: "testuser", email: "test@example.com")
        let responseData = """
        {
            "success": true,
            "user": {
                "id": "123",
                "username": "testuser",
                "email": "test@example.com"
            },
            "token": "test-token",
            "csrfToken": "csrf-token"
        }
        """.data(using: .utf8)!
        
        mockSession.setMockResponse(data: responseData, statusCode: 200)
        
        // When
        let user = try await apiClient.signIn(username: "testuser", password: "password")
        
        // Then
        XCTAssertEqual(user.id, expectedUser.id)
        XCTAssertEqual(user.username, expectedUser.username)
        XCTAssertEqual(user.email, expectedUser.email)
        XCTAssertTrue(apiClient.isAuthenticated)
    }
    
    func testSignInFailureInvalidCredentials() async {
        // Given
        let responseData = """
        {
            "success": false,
            "error": "Invalid credentials"
        }
        """.data(using: .utf8)!
        
        mockSession.setMockResponse(data: responseData, statusCode: 401)
        
        // When/Then
        do {
            _ = try await apiClient.signIn(username: "invalid", password: "invalid")
            XCTFail("Expected authentication error")
        } catch let error as AFLFantasyAPIError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testSignInFailureNetworkError() async {
        // Given
        mockSession.setMockError(URLError(.notConnectedToInternet))
        
        // When/Then
        do {
            _ = try await apiClient.signIn(username: "testuser", password: "password")
            XCTFail("Expected network error")
        } catch let error as AFLFantasyAPIError {
            XCTAssertEqual(error, .networkError(URLError(.notConnectedToInternet)))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testSignOut() {
        // Given
        apiClient.setAuthenticationToken("test-token")
        XCTAssertTrue(apiClient.isAuthenticated)
        
        // When
        apiClient.signOut()
        
        // Then
        XCTAssertFalse(apiClient.isAuthenticated)
        XCTAssertNil(apiClient.currentUser)
    }
    
    // MARK: - Player Data Tests
    
    func testFetchPlayersSuccess() async throws {
        // Given
        let mockPlayers = [
            createMockPlayer(id: "1", name: "Marcus Bontempelli", position: "MID"),
            createMockPlayer(id: "2", name: "Clayton Oliver", position: "MID")
        ]
        
        let responseData = try JSONEncoder().encode(APIResponse(success: true, players: mockPlayers))
        mockSession.setMockResponse(data: responseData, statusCode: 200)
        
        // When
        let players = try await apiClient.fetchPlayers(for: 1)
        
        // Then
        XCTAssertEqual(players.count, 2)
        XCTAssertEqual(players[0].displayName, "Marcus Bontempelli")
        XCTAssertEqual(players[1].displayName, "Clayton Oliver")
    }
    
    func testFetchPlayersUnauthorized() async {
        // Given
        mockSession.setMockResponse(data: Data(), statusCode: 401)
        
        // When/Then
        do {
            _ = try await apiClient.fetchPlayers(for: 1)
            XCTFail("Expected unauthorized error")
        } catch let error as AFLFantasyAPIError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetchPlayersParsingError() async {
        // Given
        let invalidResponseData = "invalid json".data(using: .utf8)!
        mockSession.setMockResponse(data: invalidResponseData, statusCode: 200)
        
        // When/Then
        do {
            _ = try await apiClient.fetchPlayers(for: 1)
            XCTFail("Expected parsing error")
        } catch let error as AFLFantasyAPIError {
            if case .decodingError = error {
                // Expected
            } else {
                XCTFail("Expected decoding error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Team Data Tests
    
    func testFetchTeamSuccess() async throws {
        // Given
        let mockTeam = createMockTeam(id: "team1", name: "My Team", totalScore: 1500)
        let responseData = try JSONEncoder().encode(APIResponse(success: true, team: mockTeam))
        mockSession.setMockResponse(data: responseData, statusCode: 200)
        
        // When
        let team = try await apiClient.fetchTeam(for: "user123", round: 1)
        
        // Then
        XCTAssertEqual(team.id, "team1")
        XCTAssertEqual(team.name, "My Team")
        XCTAssertEqual(team.totalScore, 1500)
    }
    
    func testUpdateTeamSuccess() async throws {
        // Given
        let mockTeam = createMockTeam(id: "team1", name: "Updated Team", totalScore: 1600)
        let responseData = try JSONEncoder().encode(APIResponse(success: true, team: mockTeam))
        mockSession.setMockResponse(data: responseData, statusCode: 200)
        
        // When
        let updatedTeam = try await apiClient.updateTeam(mockTeam)
        
        // Then
        XCTAssertEqual(updatedTeam.name, "Updated Team")
        XCTAssertEqual(updatedTeam.totalScore, 1600)
    }
    
    // MARK: - Live Match Tests
    
    func testFetchLiveMatchesSuccess() async throws {
        // Given
        let mockMatches = [
            createMockLiveMatch(id: "match1", homeTeam: "Richmond", awayTeam: "Carlton", isLive: true),
            createMockLiveMatch(id: "match2", homeTeam: "Collingwood", awayTeam: "Essendon", isLive: false)
        ]
        
        let responseData = try JSONEncoder().encode(APIResponse(success: true, matches: mockMatches))
        mockSession.setMockResponse(data: responseData, statusCode: 200)
        
        // When
        let matches = try await apiClient.fetchLiveMatches()
        
        // Then
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(matches[0].homeTeamName, "Richmond")
        XCTAssertEqual(matches[0].awayTeamName, "Carlton")
        XCTAssertTrue(matches[0].isLive)
        XCTAssertFalse(matches[1].isLive)
    }
    
    func testFetchLiveMatchesEmpty() async throws {
        // Given
        let responseData = try JSONEncoder().encode(APIResponse<[LiveMatch]>(success: true, data: []))
        mockSession.setMockResponse(data: responseData, statusCode: 200)
        
        // When
        let matches = try await apiClient.fetchLiveMatches()
        
        // Then
        XCTAssertTrue(matches.isEmpty)
    }
    
    // MARK: - Captain Recommendations Tests
    
    func testFetchCaptainRecommendationsSuccess() async throws {
        // Given
        let mockRecommendations = [
            CaptainRecommendation(
                playerId: "1",
                playerName: "Marcus Bontempelli",
                confidence: 0.95,
                reason: "Excellent form",
                projectedScore: 125.0
            )
        ]
        
        let responseData = try JSONEncoder().encode(APIResponse(success: true, captainRecommendations: mockRecommendations))
        mockSession.setMockResponse(data: responseData, statusCode: 200)
        
        // When
        let recommendations = try await apiClient.fetchCaptainRecommendations(for: "user123")
        
        // Then
        XCTAssertEqual(recommendations.count, 1)
        XCTAssertEqual(recommendations[0].playerId, "1")
        XCTAssertEqual(recommendations[0].confidence, 0.95)
    }
    
    // MARK: - Rate Limiting Tests
    
    func testRateLimitHandling() async {
        // Given
        mockSession.setMockResponse(data: Data(), statusCode: 429)
        
        // When/Then
        do {
            _ = try await apiClient.fetchPlayers(for: 1)
            XCTFail("Expected rate limit error")
        } catch let error as AFLFantasyAPIError {
            XCTAssertEqual(error, .rateLimited)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Combine Publishers Tests
    
    func testPlayerUpdatesPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Player updates received")
        var receivedPlayers: [Player] = []
        
        apiClient.playerUpdatesPublisher
            .sink { players in
                receivedPlayers = players
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        let mockPlayers = [createMockPlayer(id: "1", name: "Test Player", position: "MID")]
        apiClient.notifyPlayerUpdates(mockPlayers)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedPlayers.count, 1)
        XCTAssertEqual(receivedPlayers[0].displayName, "Test Player")
    }
    
    func testMatchUpdatesPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Match updates received")
        var receivedMatches: [LiveMatch] = []
        
        apiClient.matchUpdatesPublisher
            .sink { matches in
                receivedMatches = matches
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        let mockMatches = [createMockLiveMatch(id: "1", homeTeam: "Test Home", awayTeam: "Test Away", isLive: true)]
        apiClient.notifyMatchUpdates(mockMatches)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedMatches.count, 1)
        XCTAssertEqual(receivedMatches[0].homeTeamName, "Test Home")
    }
    
    // MARK: - Helper Methods
    
    private func createMockPlayer(id: String, name: String, position: String) -> Player {
        return Player(
            id: id,
            firstName: name.components(separatedBy: " ").first ?? "",
            lastName: name.components(separatedBy: " ").dropFirst().joined(separator: " "),
            displayName: name,
            position: Player.Position(rawValue: position) ?? .midfielder,
            currentPrice: 500000,
            averageScore: 85.0,
            liveScore: 0,
            totalScore: 850,
            captainScore: 0,
            projectedScore: 90.0,
            priceChange: 5000,
            playingStatus: .confirmed,
            injuryStatus: .healthy,
            isAvailable: true,
            isCaptain: false,
            isViceCaptain: false,
            isEmergency: false,
            photoURL: nil
        )
    }
    
    private func createMockTeam(id: String, name: String, totalScore: Int) -> Team {
        return Team(
            id: id,
            userID: "user123",
            name: name,
            fullName: name,
            abbreviation: "MT",
            totalScore: totalScore,
            trades: 20,
            captainID: nil,
            viceCaptainID: nil,
            round: 1,
            logoURL: nil,
            primaryColor: "#000000",
            secondaryColor: "#FFFFFF"
        )
    }
    
    private func createMockLiveMatch(id: String, homeTeam: String, awayTeam: String, isLive: Bool) -> LiveMatch {
        return LiveMatch(
            id: id,
            homeTeamName: homeTeam,
            awayTeamName: awayTeam,
            homeTeamID: "home-\(id)",
            awayTeamID: "away-\(id)",
            homeScore: 85,
            awayScore: 72,
            startTime: Date(),
            status: isLive ? "Live" : "Final",
            quarter: "Q3",
            timeRemaining: isLive ? "12:45" : nil,
            venue: "Test Stadium",
            round: 1,
            isLive: isLive
        )
    }
}

// MARK: - Mock URL Session

class MockURLSession: URLSessionProtocol {
    private var mockData: Data?
    private var mockResponse: URLResponse?
    private var mockError: Error?
    
    func setMockResponse(data: Data, statusCode: Int) {
        self.mockData = data
        self.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.afl.com.au")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        self.mockError = nil
    }
    
    func setMockError(_ error: Error) {
        self.mockData = nil
        self.mockResponse = nil
        self.mockError = error
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.badServerResponse)
        }
        
        return (data, response)
    }
}

// MARK: - Mock API Response

private struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let players: [Player]?
    let team: Team?
    let matches: [LiveMatch]?
    let captainRecommendations: [CaptainRecommendation]?
    let error: String?
    
    init(success: Bool, data: T) {
        self.success = success
        self.data = data
        self.players = nil
        self.team = nil
        self.matches = nil
        self.captainRecommendations = nil
        self.error = nil
    }
    
    init(success: Bool, players: [Player]) {
        self.success = success
        self.data = nil
        self.players = players
        self.team = nil
        self.matches = nil
        self.captainRecommendations = nil
        self.error = nil
    }
    
    init(success: Bool, team: Team) {
        self.success = success
        self.data = nil
        self.players = nil
        self.team = team
        self.matches = nil
        self.captainRecommendations = nil
        self.error = nil
    }
    
    init(success: Bool, matches: [LiveMatch]) {
        self.success = success
        self.data = nil
        self.players = nil
        self.team = nil
        self.matches = matches
        self.captainRecommendations = nil
        self.error = nil
    }
    
    init(success: Bool, captainRecommendations: [CaptainRecommendation]) {
        self.success = success
        self.data = nil
        self.players = nil
        self.team = nil
        self.matches = nil
        self.captainRecommendations = captainRecommendations
        self.error = nil
    }
}

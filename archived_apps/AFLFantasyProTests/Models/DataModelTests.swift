//
//  DataModelTests.swift
//  AFL Fantasy Pro Tests - Data Model Tests
//
//  Unit tests for core data models including Player, Team, LiveMatch
//  with validation, encoding/decoding, and edge case scenarios.
//

import XCTest
@testable import AFLFantasyPro

final class DataModelTests: XCTestCase {
    
    // MARK: - Player Model Tests
    
    func testPlayerInitialization() {
        // Given
        let player = Player(
            id: "123",
            firstName: "Marcus",
            lastName: "Bontempelli",
            displayName: "Marcus Bontempelli",
            position: .midfielder,
            currentPrice: 650000,
            averageScore: 118.5,
            liveScore: 85,
            totalScore: 1420,
            captainScore: 170,
            projectedScore: 120.0,
            priceChange: 15000,
            playingStatus: .confirmed,
            injuryStatus: .healthy,
            isAvailable: true,
            isCaptain: true,
            isViceCaptain: false,
            isEmergency: false,
            photoURL: "https://example.com/photo.jpg"
        )
        
        // Then
        XCTAssertEqual(player.id, "123")
        XCTAssertEqual(player.firstName, "Marcus")
        XCTAssertEqual(player.lastName, "Bontempelli")
        XCTAssertEqual(player.displayName, "Marcus Bontempelli")
        XCTAssertEqual(player.position, .midfielder)
        XCTAssertEqual(player.currentPrice, 650000)
        XCTAssertEqual(player.averageScore, 118.5)
        XCTAssertEqual(player.liveScore, 85)
        XCTAssertEqual(player.totalScore, 1420)
        XCTAssertEqual(player.captainScore, 170)
        XCTAssertEqual(player.projectedScore, 120.0)
        XCTAssertEqual(player.priceChange, 15000)
        XCTAssertEqual(player.playingStatus, .confirmed)
        XCTAssertEqual(player.injuryStatus, .healthy)
        XCTAssertTrue(player.isAvailable)
        XCTAssertTrue(player.isCaptain)
        XCTAssertFalse(player.isViceCaptain)
        XCTAssertFalse(player.isEmergency)
        XCTAssertEqual(player.photoURL, "https://example.com/photo.jpg")
    }
    
    func testPlayerPositions() {
        // Test all position cases
        XCTAssertEqual(Player.Position.defender.rawValue, "DEF")
        XCTAssertEqual(Player.Position.midfielder.rawValue, "MID")
        XCTAssertEqual(Player.Position.ruckman.rawValue, "RUC")
        XCTAssertEqual(Player.Position.forward.rawValue, "FWD")
        
        // Test display names
        XCTAssertEqual(Player.Position.defender.displayName, "Defender")
        XCTAssertEqual(Player.Position.midfielder.displayName, "Midfielder")
        XCTAssertEqual(Player.Position.ruckman.displayName, "Ruckman")
        XCTAssertEqual(Player.Position.forward.displayName, "Forward")
    }
    
    func testPlayerPlayingStatus() {
        // Test all playing status cases
        XCTAssertEqual(Player.PlayingStatus.confirmed.rawValue, "confirmed")
        XCTAssertEqual(Player.PlayingStatus.probable.rawValue, "probable")
        XCTAssertEqual(Player.PlayingStatus.test.rawValue, "test")
        XCTAssertEqual(Player.PlayingStatus.out.rawValue, "out")
        
        // Test display names
        XCTAssertEqual(Player.PlayingStatus.confirmed.displayName, "Confirmed")
        XCTAssertEqual(Player.PlayingStatus.probable.displayName, "Probable")
        XCTAssertEqual(Player.PlayingStatus.test.displayName, "Test")
        XCTAssertEqual(Player.PlayingStatus.out.displayName, "Out")
    }
    
    func testPlayerInjuryStatus() {
        // Test all injury status cases
        XCTAssertEqual(Player.InjuryStatus.healthy.rawValue, "healthy")
        XCTAssertEqual(Player.InjuryStatus.injured.rawValue, "injured")
        XCTAssertEqual(Player.InjuryStatus.suspended.rawValue, "suspended")
        XCTAssertEqual(Player.InjuryStatus.managed.rawValue, "managed")
        
        // Test display names
        XCTAssertEqual(Player.InjuryStatus.healthy.displayName, "Healthy")
        XCTAssertEqual(Player.InjuryStatus.injured.displayName, "Injured")
        XCTAssertEqual(Player.InjuryStatus.suspended.displayName, "Suspended")
        XCTAssertEqual(Player.InjuryStatus.managed.displayName, "Managed")
    }
    
    func testPlayerEquatable() {
        // Given
        let player1 = createSamplePlayer(id: "123", name: "Marcus Bontempelli")
        let player2 = createSamplePlayer(id: "123", name: "Marcus Bontempelli")
        let player3 = createSamplePlayer(id: "456", name: "Clayton Oliver")
        
        // Then
        XCTAssertEqual(player1, player2)
        XCTAssertNotEqual(player1, player3)
    }
    
    func testPlayerHashable() {
        // Given
        let player1 = createSamplePlayer(id: "123", name: "Marcus Bontempelli")
        let player2 = createSamplePlayer(id: "123", name: "Marcus Bontempelli")
        let player3 = createSamplePlayer(id: "456", name: "Clayton Oliver")
        
        // Then
        XCTAssertEqual(player1.hashValue, player2.hashValue)
        XCTAssertNotEqual(player1.hashValue, player3.hashValue)
        
        // Test in Set
        let playerSet: Set<Player> = [player1, player2, player3]
        XCTAssertEqual(playerSet.count, 2) // player1 and player2 should be treated as same
    }
    
    func testPlayerCodable() throws {
        // Given
        let originalPlayer = createSamplePlayer(id: "123", name: "Marcus Bontempelli")
        
        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalPlayer)
        
        // Then - Decode
        let decoder = JSONDecoder()
        let decodedPlayer = try decoder.decode(Player.self, from: data)
        
        // Verify all properties are preserved
        XCTAssertEqual(originalPlayer.id, decodedPlayer.id)
        XCTAssertEqual(originalPlayer.firstName, decodedPlayer.firstName)
        XCTAssertEqual(originalPlayer.lastName, decodedPlayer.lastName)
        XCTAssertEqual(originalPlayer.displayName, decodedPlayer.displayName)
        XCTAssertEqual(originalPlayer.position, decodedPlayer.position)
        XCTAssertEqual(originalPlayer.currentPrice, decodedPlayer.currentPrice)
        XCTAssertEqual(originalPlayer.averageScore, decodedPlayer.averageScore)
        XCTAssertEqual(originalPlayer.liveScore, decodedPlayer.liveScore)
        XCTAssertEqual(originalPlayer.totalScore, decodedPlayer.totalScore)
        XCTAssertEqual(originalPlayer.playingStatus, decodedPlayer.playingStatus)
        XCTAssertEqual(originalPlayer.injuryStatus, decodedPlayer.injuryStatus)
        XCTAssertEqual(originalPlayer.isAvailable, decodedPlayer.isAvailable)
    }
    
    // MARK: - Team Model Tests
    
    func testTeamInitialization() {
        // Given
        let team = Team(
            id: "team123",
            userID: "user456",
            name: "My Fantasy Team",
            fullName: "My Fantasy Team - Round 10",
            abbreviation: "MFT",
            totalScore: 1850,
            trades: 15,
            captainID: "player123",
            viceCaptainID: "player456",
            round: 10,
            logoURL: "https://example.com/logo.png",
            primaryColor: "#FF0000",
            secondaryColor: "#0000FF"
        )
        
        // Then
        XCTAssertEqual(team.id, "team123")
        XCTAssertEqual(team.userID, "user456")
        XCTAssertEqual(team.name, "My Fantasy Team")
        XCTAssertEqual(team.fullName, "My Fantasy Team - Round 10")
        XCTAssertEqual(team.abbreviation, "MFT")
        XCTAssertEqual(team.totalScore, 1850)
        XCTAssertEqual(team.trades, 15)
        XCTAssertEqual(team.captainID, "player123")
        XCTAssertEqual(team.viceCaptainID, "player456")
        XCTAssertEqual(team.round, 10)
        XCTAssertEqual(team.logoURL, "https://example.com/logo.png")
        XCTAssertEqual(team.primaryColor, "#FF0000")
        XCTAssertEqual(team.secondaryColor, "#0000FF")
    }
    
    func testTeamEquatable() {
        // Given
        let team1 = createSampleTeam(id: "team123", name: "My Team")
        let team2 = createSampleTeam(id: "team123", name: "My Team")
        let team3 = createSampleTeam(id: "team456", name: "Other Team")
        
        // Then
        XCTAssertEqual(team1, team2)
        XCTAssertNotEqual(team1, team3)
    }
    
    func testTeamCodable() throws {
        // Given
        let originalTeam = createSampleTeam(id: "team123", name: "My Team")
        
        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTeam)
        
        // Then - Decode
        let decoder = JSONDecoder()
        let decodedTeam = try decoder.decode(Team.self, from: data)
        
        // Verify properties
        XCTAssertEqual(originalTeam.id, decodedTeam.id)
        XCTAssertEqual(originalTeam.userID, decodedTeam.userID)
        XCTAssertEqual(originalTeam.name, decodedTeam.name)
        XCTAssertEqual(originalTeam.totalScore, decodedTeam.totalScore)
        XCTAssertEqual(originalTeam.trades, decodedTeam.trades)
    }
    
    // MARK: - LiveMatch Model Tests
    
    func testLiveMatchInitialization() {
        // Given
        let startTime = Date()
        let liveMatch = LiveMatch(
            id: "match123",
            homeTeamName: "Richmond",
            awayTeamName: "Carlton",
            homeTeamID: "richmond",
            awayTeamID: "carlton",
            homeScore: 85,
            awayScore: 72,
            startTime: startTime,
            status: "Live",
            quarter: "Q3",
            timeRemaining: "12:45",
            venue: "MCG",
            round: 10,
            isLive: true
        )
        
        // Then
        XCTAssertEqual(liveMatch.id, "match123")
        XCTAssertEqual(liveMatch.homeTeamName, "Richmond")
        XCTAssertEqual(liveMatch.awayTeamName, "Carlton")
        XCTAssertEqual(liveMatch.homeTeamID, "richmond")
        XCTAssertEqual(liveMatch.awayTeamID, "carlton")
        XCTAssertEqual(liveMatch.homeScore, 85)
        XCTAssertEqual(liveMatch.awayScore, 72)
        XCTAssertEqual(liveMatch.startTime, startTime)
        XCTAssertEqual(liveMatch.status, "Live")
        XCTAssertEqual(liveMatch.quarter, "Q3")
        XCTAssertEqual(liveMatch.timeRemaining, "12:45")
        XCTAssertEqual(liveMatch.venue, "MCG")
        XCTAssertEqual(liveMatch.round, 10)
        XCTAssertTrue(liveMatch.isLive)
    }
    
    func testLiveMatchEquatable() {
        // Given
        let match1 = createSampleLiveMatch(id: "match123", homeTeam: "Richmond", awayTeam: "Carlton")
        let match2 = createSampleLiveMatch(id: "match123", homeTeam: "Richmond", awayTeam: "Carlton")
        let match3 = createSampleLiveMatch(id: "match456", homeTeam: "Collingwood", awayTeam: "Essendon")
        
        // Then
        XCTAssertEqual(match1, match2)
        XCTAssertNotEqual(match1, match3)
    }
    
    func testLiveMatchCodable() throws {
        // Given
        let originalMatch = createSampleLiveMatch(id: "match123", homeTeam: "Richmond", awayTeam: "Carlton")
        
        // When - Encode
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalMatch)
        
        // Then - Decode
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedMatch = try decoder.decode(LiveMatch.self, from: data)
        
        // Verify properties
        XCTAssertEqual(originalMatch.id, decodedMatch.id)
        XCTAssertEqual(originalMatch.homeTeamName, decodedMatch.homeTeamName)
        XCTAssertEqual(originalMatch.awayTeamName, decodedMatch.awayTeamName)
        XCTAssertEqual(originalMatch.homeScore, decodedMatch.homeScore)
        XCTAssertEqual(originalMatch.awayScore, decodedMatch.awayScore)
        XCTAssertEqual(originalMatch.isLive, decodedMatch.isLive)
    }
    
    // MARK: - User Model Tests
    
    func testUserInitialization() {
        // Given
        let user = User(
            id: "user123",
            username: "testuser",
            email: "test@example.com"
        )
        
        // Then
        XCTAssertEqual(user.id, "user123")
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.email, "test@example.com")
    }
    
    func testUserEquatable() {
        // Given
        let user1 = User(id: "user123", username: "testuser", email: "test@example.com")
        let user2 = User(id: "user123", username: "testuser", email: "test@example.com")
        let user3 = User(id: "user456", username: "otheruser", email: "other@example.com")
        
        // Then
        XCTAssertEqual(user1, user2)
        XCTAssertNotEqual(user1, user3)
    }
    
    func testUserCodable() throws {
        // Given
        let originalUser = User(id: "user123", username: "testuser", email: "test@example.com")
        
        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalUser)
        
        // Then - Decode
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(User.self, from: data)
        
        // Verify properties
        XCTAssertEqual(originalUser.id, decodedUser.id)
        XCTAssertEqual(originalUser.username, decodedUser.username)
        XCTAssertEqual(originalUser.email, decodedUser.email)
    }
    
    // MARK: - CaptainRecommendation Model Tests
    
    func testCaptainRecommendationInitialization() {
        // Given
        let recommendation = CaptainRecommendation(
            playerId: "player123",
            playerName: "Marcus Bontempelli",
            confidence: 0.95,
            reason: "Excellent form against weak opposition",
            projectedScore: 125.5
        )
        
        // Then
        XCTAssertEqual(recommendation.playerId, "player123")
        XCTAssertEqual(recommendation.playerName, "Marcus Bontempelli")
        XCTAssertEqual(recommendation.confidence, 0.95, accuracy: 0.001)
        XCTAssertEqual(recommendation.reason, "Excellent form against weak opposition")
        XCTAssertEqual(recommendation.projectedScore, 125.5, accuracy: 0.001)
    }
    
    func testCaptainRecommendationCodable() throws {
        // Given
        let originalRecommendation = CaptainRecommendation(
            playerId: "player123",
            playerName: "Marcus Bontempelli",
            confidence: 0.95,
            reason: "Excellent form",
            projectedScore: 125.5
        )
        
        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalRecommendation)
        
        // Then - Decode
        let decoder = JSONDecoder()
        let decodedRecommendation = try decoder.decode(CaptainRecommendation.self, from: data)
        
        // Verify properties
        XCTAssertEqual(originalRecommendation.playerId, decodedRecommendation.playerId)
        XCTAssertEqual(originalRecommendation.playerName, decodedRecommendation.playerName)
        XCTAssertEqual(originalRecommendation.confidence, decodedRecommendation.confidence, accuracy: 0.001)
        XCTAssertEqual(originalRecommendation.reason, decodedRecommendation.reason)
        XCTAssertEqual(originalRecommendation.projectedScore, decodedRecommendation.projectedScore, accuracy: 0.001)
    }
    
    // MARK: - Edge Cases and Validation
    
    func testPlayerWithMinimalData() {
        // Test player with only required fields
        let player = Player(
            id: "123",
            firstName: "",
            lastName: "",
            displayName: "Unknown Player",
            position: .midfielder,
            currentPrice: 0,
            averageScore: 0,
            liveScore: 0,
            totalScore: 0,
            captainScore: 0,
            projectedScore: 0,
            priceChange: 0,
            playingStatus: .out,
            injuryStatus: .injured,
            isAvailable: false,
            isCaptain: false,
            isViceCaptain: false,
            isEmergency: false,
            photoURL: nil
        )
        
        XCTAssertEqual(player.id, "123")
        XCTAssertEqual(player.displayName, "Unknown Player")
        XCTAssertFalse(player.isAvailable)
        XCTAssertNil(player.photoURL)
    }
    
    func testLiveMatchWithNilOptionalFields() {
        // Test match with nil optional fields
        let match = LiveMatch(
            id: "match123",
            homeTeamName: "Richmond",
            awayTeamName: "Carlton",
            homeTeamID: "richmond",
            awayTeamID: "carlton",
            homeScore: 85,
            awayScore: 72,
            startTime: Date(),
            status: "Final",
            quarter: "Q4",
            timeRemaining: nil,
            venue: "MCG",
            round: 10,
            isLive: false
        )
        
        XCTAssertEqual(match.id, "match123")
        XCTAssertNil(match.timeRemaining)
        XCTAssertFalse(match.isLive)
    }
    
    // MARK: - Performance Tests
    
    func testLargePlayerArrayPerformance() {
        // Test performance with large array of players
        let players = (1...1000).map { i in
            createSamplePlayer(id: "\(i)", name: "Player \(i)")
        }
        
        measure {
            // Test filtering performance
            let midfielders = players.filter { $0.position == .midfielder }
            let availablePlayers = players.filter { $0.isAvailable }
            
            XCTAssertFalse(midfielders.isEmpty)
            XCTAssertFalse(availablePlayers.isEmpty)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createSamplePlayer(id: String, name: String) -> Player {
        return Player(
            id: id,
            firstName: name.components(separatedBy: " ").first ?? "",
            lastName: name.components(separatedBy: " ").dropFirst().joined(separator: " "),
            displayName: name,
            position: .midfielder,
            currentPrice: 500000,
            averageScore: 85.0,
            liveScore: 72,
            totalScore: 850,
            captainScore: 144,
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
    
    private func createSampleTeam(id: String, name: String) -> Team {
        return Team(
            id: id,
            userID: "user123",
            name: name,
            fullName: name,
            abbreviation: "MT",
            totalScore: 1500,
            trades: 20,
            captainID: nil,
            viceCaptainID: nil,
            round: 1,
            logoURL: nil,
            primaryColor: "#000000",
            secondaryColor: "#FFFFFF"
        )
    }
    
    private func createSampleLiveMatch(id: String, homeTeam: String, awayTeam: String) -> LiveMatch {
        return LiveMatch(
            id: id,
            homeTeamName: homeTeam,
            awayTeamName: awayTeam,
            homeTeamID: homeTeam.lowercased(),
            awayTeamID: awayTeam.lowercased(),
            homeScore: 85,
            awayScore: 72,
            startTime: Date(),
            status: "Live",
            quarter: "Q3",
            timeRemaining: "12:45",
            venue: "Test Stadium",
            round: 1,
            isLive: true
        )
    }
}

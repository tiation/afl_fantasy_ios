//
//  AFLFantasyTests.swift
//  AFL Fantasy Intelligence Platform Tests
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import XCTest
@testable import AFLFantasy

final class AFLFantasyTests: XCTestCase {

    override func setUpWithError() throws {
        // Setup code here
    }

    override func tearDownWithError() throws {
        // Teardown code here
    }

    func testPlayerModel() throws {
        // Test Player model creation and properties
        let player = Player(
            id: "test1",
            name: "Test Player",
            position: .midfielder,
            price: 500000,
            currentScore: 100,
            projectedScore: 105,
            breakeven: 75
        )
        
        XCTAssertEqual(player.name, "Test Player")
        XCTAssertEqual(player.position, .midfielder)
        XCTAssertEqual(player.formattedPrice, "$500k")
        XCTAssertEqual(player.breakeven, 75)
    }
    
    func testAppStateInitialization() throws {
        // Test AppState initializes with mock data
        let appState = AppState()
        
        XCTAssertFalse(appState.players.isEmpty, "AppState should initialize with mock players")
        XCTAssertFalse(appState.captainSuggestions.isEmpty, "AppState should have captain suggestions")
        XCTAssertEqual(appState.selectedTab, .dashboard, "Default tab should be dashboard")
    }
    
    func testCaptainSuggestionModel() throws {
        // Test CaptainSuggestion model
        let player = Player(
            id: "test1",
            name: "Test Captain",
            position: .midfielder,
            price: 800000,
            currentScore: 120,
            projectedScore: 125,
            breakeven: 85
        )
        
        let suggestion = CaptainSuggestion(
            player: player,
            confidence: 90,
            projectedPoints: 250
        )
        
        XCTAssertEqual(suggestion.player.name, "Test Captain")
        XCTAssertEqual(suggestion.confidence, 90)
        XCTAssertEqual(suggestion.projectedPoints, 250)
    }
    
    func testPositionColors() throws {
        // Test position colors are unique
        let positions = Position.allCases
        let colors = positions.map { $0.color }
        
        XCTAssertEqual(positions.count, 4, "Should have 4 positions")
        // Each position should have a distinct color
        XCTAssertEqual(Position.defender.color, .blue)
        XCTAssertEqual(Position.midfielder.color, .green)
        XCTAssertEqual(Position.ruck.color, .purple)
        XCTAssertEqual(Position.forward.color, .red)
    }

    func testPerformanceExample() throws {
        // Test performance of mock data loading
        measure {
            let appState = AppState()
            XCTAssertFalse(appState.players.isEmpty)
        }
    }

}

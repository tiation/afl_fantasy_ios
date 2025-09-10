//
//  AFLFantasyScraperService.swift
//  AFL Fantasy Intelligence Platform
//

import Foundation

// MARK: - ScraperResult

struct ScraperResult {
    let players: [Player]
    let scores: [String: Int]
    let updates: [String]
    let lastUpdated: Date
}

// MARK: - AFLFantasyScraperService

final class AFLFantasyScraperService: AFLFantasyScraperServiceProtocol {
    static let shared = AFLFantasyScraperService()

    private init() {}

    func refreshAllData() async throws -> ScraperResult {
        // Mock implementation for now
        ScraperResult(
            players: [],
            scores: [:],
            updates: [],
            lastUpdated: Date()
        )
    }
}

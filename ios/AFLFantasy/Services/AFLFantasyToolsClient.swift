//
//  AFLFantasyToolsClient.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced analytics and tools integration
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation

// MARK: - ToolCategory

enum ToolCategory: String, CaseIterable {
    case trade
    case cash
    case captain
    case risk
    case price
    case fixture
    case context
    case ai
}

// MARK: - TradeAnalysis

struct TradeAnalysis: Codable, Identifiable {
    let id = UUID()
    let playerOut: String
    let playerIn: String
    let netCost: Int
    let impactScore: Double
    let confidence: Double
    let reasoning: String
    let warnings: [String]?

    private enum CodingKeys: String, CodingKey {
        case playerOut = "player_out"
        case playerIn = "player_in"
        case netCost = "net_cost"
        case impactScore = "impact_score"
        case confidence, reasoning, warnings
    }
}

// MARK: - CaptainSuggestionAnalysis

struct CaptainSuggestionAnalysis: Codable, Identifiable {
    let id = UUID()
    let player: String
    let team: String
    let position: String
    let projectedScore: Double
    let confidence: Double
    let ceiling: Double
    let floor: Double
    let reasoning: String
    let fixture: FixtureAnalysis?

    private enum CodingKeys: String, CodingKey {
        case player, team, position, confidence, ceiling, floor, reasoning, fixture
        case projectedScore = "projected_score"
    }
}

// MARK: - FixtureAnalysis

struct FixtureAnalysis: Codable {
    let opponent: String
    let venue: String
    let difficulty: String
    let defensiveVulnerability: Double?
    let weatherImpact: String?

    private enum CodingKeys: String, CodingKey {
        case opponent, venue, difficulty
        case defensiveVulnerability = "defensive_vulnerability"
        case weatherImpact = "weather_impact"
    }
}

// MARK: - CashGenerationTarget

struct CashGenerationTarget: Codable, Identifiable {
    let id = UUID()
    let player: String
    let currentPrice: Int
    let targetPrice: Int
    let expectedWeeks: Int
    let cashGenerated: Int
    let confidence: Double
    let breakeven: Int
    let riskLevel: String

    private enum CodingKeys: String, CodingKey {
        case player, confidence, breakeven
        case currentPrice = "current_price"
        case targetPrice = "target_price"
        case expectedWeeks = "expected_weeks"
        case cashGenerated = "cash_generated"
        case riskLevel = "risk_level"
    }
}

// MARK: - RiskAssessment

struct RiskAssessment: Codable, Identifiable {
    let id = UUID()
    let player: String
    let injuryRisk: Double
    let formRisk: Double
    let priceRisk: Double
    let fixtureRisk: Double
    let overallRisk: String
    let recommendations: [String]

    private enum CodingKeys: String, CodingKey {
        case player, recommendations
        case injuryRisk = "injury_risk"
        case formRisk = "form_risk"
        case priceRisk = "price_risk"
        case fixtureRisk = "fixture_risk"
        case overallRisk = "overall_risk"
    }
}

// MARK: - PriceMovementPrediction

struct PriceMovementPrediction: Codable, Identifiable {
    let id = UUID()
    let player: String
    let currentPrice: Int
    let predictedChange: Int
    let confidence: Double
    let timeframe: String
    let factors: [String]

    private enum CodingKeys: String, CodingKey {
        case player, confidence, timeframe, factors
        case currentPrice = "current_price"
        case predictedChange = "predicted_change"
    }
}

// MARK: - AIRecommendation

struct AIRecommendation: Codable, Identifiable {
    let id = UUID()
    let type: String
    let priority: String
    let title: String
    let description: String
    let actionRequired: Bool
    let confidence: Double
    let reasoning: String
    let data: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case type, priority, title, description, confidence, reasoning, data
        case actionRequired = "action_required"
    }
}

// MARK: - ToolsResponse

struct ToolsResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
    let timestamp: String
    let executionTime: Double?

    private enum CodingKeys: String, CodingKey {
        case success, data, error, timestamp
        case executionTime = "execution_time"
    }
}

// MARK: - AFLFantasyToolsClient

class AFLFantasyToolsClient: ObservableObject {
    // MARK: - Properties

    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    // MARK: - Published State

    @Published var isExecutingTool: Bool = false
    @Published var lastToolExecution: Date?
    @Published var executionHistory: [String] = []

    // MARK: - Initialization

    init(baseURL: URL = URL(string: "http://localhost:3000")!) {
        self.baseURL = baseURL
        session = URLSession(configuration: .default)
        decoder = JSONDecoder()

        // Configure date decoding
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }

    // MARK: - Captain Analysis Tools

    func getCaptainSuggestions(round: Int? = nil) async -> Result<[CaptainSuggestionAnalysis], AFLFantasyError> {
        await executeTool(
            endpoint: "captain/suggestions",
            parameters: round != nil ? ["round": "\(round!)"] : [:],
            responseType: [CaptainSuggestionAnalysis].self,
            toolName: "Captain Suggestions"
        )
    }

    func analyzeCaptainChoice(
        player: String,
        round: Int? = nil
    ) async -> Result<CaptainSuggestionAnalysis, AFLFantasyError> {
        await executeTool(
            endpoint: "captain/analyze",
            parameters: [
                "player": player,
                "round": round != nil ? "\(round!)" : ""
            ],
            responseType: CaptainSuggestionAnalysis.self,
            toolName: "Captain Analysis"
        )
    }

    // MARK: - Trade Analysis Tools

    func analyzeTradeOpportunity(
        playerOut: String,
        playerIn: String,
        budget: Int? = nil
    ) async -> Result<TradeAnalysis, AFLFantasyError> {
        var params = [
            "player_out": playerOut,
            "player_in": playerIn
        ]
        if let budget {
            params["budget"] = "\(budget)"
        }

        return await executeTool(
            endpoint: "trade/analyze",
            parameters: params,
            responseType: TradeAnalysis.self,
            toolName: "Trade Analysis"
        )
    }

    func getTradeRecommendations(
        budget: Int,
        position: String? = nil
    ) async -> Result<[TradeAnalysis], AFLFantasyError> {
        var params = ["budget": "\(budget)"]
        if let position {
            params["position"] = position
        }

        return await executeTool(
            endpoint: "trade/recommendations",
            parameters: params,
            responseType: [TradeAnalysis].self,
            toolName: "Trade Recommendations"
        )
    }

    // MARK: - Cash Generation Tools

    func getCashGenerationTargets(weeks: Int = 3) async -> Result<[CashGenerationTarget], AFLFantasyError> {
        await executeTool(
            endpoint: "cash/targets",
            parameters: ["weeks": "\(weeks)"],
            responseType: [CashGenerationTarget].self,
            toolName: "Cash Generation Targets"
        )
    }

    func trackCashCowProgress(player: String) async -> Result<CashGenerationTarget, AFLFantasyError> {
        await executeTool(
            endpoint: "cash/track",
            parameters: ["player": player],
            responseType: CashGenerationTarget.self,
            toolName: "Cash Cow Tracking"
        )
    }

    // MARK: - Risk Analysis Tools

    func analyzePlayerRisk(player: String) async -> Result<RiskAssessment, AFLFantasyError> {
        await executeTool(
            endpoint: "risk/player",
            parameters: ["player": player],
            responseType: RiskAssessment.self,
            toolName: "Player Risk Analysis"
        )
    }

    func getTeamRiskAssessment() async -> Result<[RiskAssessment], AFLFantasyError> {
        await executeTool(
            endpoint: "risk/team",
            parameters: [:],
            responseType: [RiskAssessment].self,
            toolName: "Team Risk Assessment"
        )
    }

    // MARK: - Price Prediction Tools

    func predictPriceMovements(timeframe: String = "week") async -> Result<[PriceMovementPrediction], AFLFantasyError> {
        await executeTool(
            endpoint: "price/predict",
            parameters: ["timeframe": timeframe],
            responseType: [PriceMovementPrediction].self,
            toolName: "Price Movement Predictions"
        )
    }

    func trackPriceTargets(player: String) async -> Result<PriceMovementPrediction, AFLFantasyError> {
        await executeTool(
            endpoint: "price/track",
            parameters: ["player": player],
            responseType: PriceMovementPrediction.self,
            toolName: "Price Target Tracking"
        )
    }

    // MARK: - AI-Powered Recommendations

    func getAIRecommendations(category: String? = nil) async -> Result<[AIRecommendation], AFLFantasyError> {
        var params: [String: String] = [:]
        if let category {
            params["category"] = category
        }

        return await executeTool(
            endpoint: "ai/recommendations",
            parameters: params,
            responseType: [AIRecommendation].self,
            toolName: "AI Recommendations"
        )
    }

    func getWeeklyInsights() async -> Result<[AIRecommendation], AFLFantasyError> {
        await executeTool(
            endpoint: "ai/weekly-insights",
            parameters: [:],
            responseType: [AIRecommendation].self,
            toolName: "Weekly AI Insights"
        )
    }

    // MARK: - Generic Tool Execution

    private func executeTool<T: Codable>(
        endpoint: String,
        parameters: [String: String],
        responseType: T.Type,
        toolName: String
    ) async -> Result<T, AFLFantasyError> {
        await MainActor.run {
            isExecutingTool = true
            executionHistory.append("\(Date.now): Executing \(toolName)")
        }

        defer {
            Task { @MainActor in
                isExecutingTool = false
                lastToolExecution = Date()
            }
        }

        do {
            // Construct URL
            var urlComponents = URLComponents(
                url: baseURL.appendingPathComponent("api/tools/\(endpoint)"),
                resolvingAgainstBaseURL: false
            )!

            if !parameters.isEmpty {
                urlComponents.queryItems = parameters.compactMap { key, value in
                    !value.isEmpty ? URLQueryItem(name: key, value: value) : nil
                }
            }

            guard let url = urlComponents.url else {
                return .failure(.invalidURL)
            }

            // Create request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("AFL-Fantasy-iOS/1.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 30.0

            // Execute request
            let (data, response) = try await session.data(for: request)

            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            guard 200 ... 299 ~= httpResponse.statusCode else {
                if httpResponse.statusCode == 401 {
                    return .failure(.authenticationRequired)
                } else if httpResponse.statusCode >= 500 {
                    return .failure(.serverError("Tool execution failed with status \(httpResponse.statusCode)"))
                } else {
                    return .failure(.invalidResponse)
                }
            }

            // Parse response
            let toolResponse = try decoder.decode(ToolsResponse<T>.self, from: data)

            if toolResponse.success, let data = toolResponse.data {
                await MainActor.run {
                    executionHistory.append("\(Date.now): ✅ \(toolName) completed successfully")
                }
                return .success(data)
            } else {
                let errorMessage = toolResponse.error ?? "Unknown tool execution error"
                await MainActor.run {
                    executionHistory.append("\(Date.now): ❌ \(toolName) failed: \(errorMessage)")
                }
                return .failure(.serverError(errorMessage))
            }

        } catch {
            await MainActor.run {
                executionHistory.append("\(Date.now): ❌ \(toolName) error: \(error.localizedDescription)")
            }

            if error is DecodingError {
                return .failure(.decodingError(error))
            } else {
                return .failure(.networkError(error))
            }
        }
    }

    // MARK: - Utility Methods

    func clearExecutionHistory() {
        executionHistory.removeAll()
    }

    var isToolExecutionInProgress: Bool {
        isExecutingTool
    }
}

// MARK: - Extensions for UI Support

extension CaptainSuggestionAnalysis {
    var confidenceLevel: String {
        switch confidence {
        case 0.9...: "Very High"
        case 0.8 ..< 0.9: "High"
        case 0.7 ..< 0.8: "Medium"
        case 0.6 ..< 0.7: "Low"
        default: "Very Low"
        }
    }

    var confidenceColor: String {
        switch confidence {
        case 0.8...: "green"
        case 0.7 ..< 0.8: "yellow"
        case 0.6 ..< 0.7: "orange"
        default: "red"
        }
    }
}

extension TradeAnalysis {
    var impactGrade: String {
        switch impactScore {
        case 8...: "A+"
        case 7 ..< 8: "A"
        case 6 ..< 7: "B"
        case 5 ..< 6: "C"
        default: "D"
        }
    }

    var netCostFormatted: String {
        if netCost > 0 {
            "+$\(netCost / 1000)k"
        } else {
            "-$\(abs(netCost) / 1000)k"
        }
    }
}

extension RiskAssessment {
    var riskColor: String {
        switch overallRisk.lowercased() {
        case "low": "green"
        case "medium": "yellow"
        case "high": "orange"
        default: "red"
        }
    }
}

extension AIRecommendation {
    var priorityColor: String {
        switch priority.lowercased() {
        case "critical": "red"
        case "high": "orange"
        case "medium": "yellow"
        default: "blue"
        }
    }
}

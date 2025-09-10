import Foundation

// MARK: - OpenAIService

/// Service for integrating with OpenAI API for AFL Fantasy insights
@MainActor
final class OpenAIService: ObservableObject {
    
    // MARK: - Properties
    
    private let keychainService = KeychainService.shared
    private let session = URLSession.shared
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    @Published var isConfigured = false
    @Published var isLoading = false
    @Published var lastError: String?
    
    // MARK: - Initialization
    
    init() {
        checkConfiguration()
    }
    
    // MARK: - Configuration
    
    func checkConfiguration() {
        isConfigured = keychainService.hasValidAPIKey()
    }
    
    func validateAndStoreAPIKey(_ apiKey: String) async -> Bool {
        guard !apiKey.isEmpty, apiKey.hasPrefix("sk-") else {
            lastError = "Invalid API key format. OpenAI keys start with 'sk-'"
            return false
        }
        
        // Test the API key with a simple request
        let testSuccessful = await testAPIKey(apiKey)
        
        if testSuccessful {
            do {
                try keychainService.storeAPIKey(apiKey)
                isConfigured = true
                lastError = nil
                return true
            } catch {
                lastError = "Failed to store API key securely: \(error.localizedDescription)"
                return false
            }
        }
        
        return false
    }
    
    private func testAPIKey(_ apiKey: String) async -> Bool {
        let testRequest = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                OpenAIMessage(role: "user", content: "Test message - reply with 'OK'")
            ],
            maxTokens: 10,
            temperature: 0.1
        )
        
        do {
            _ = try await makeRequest(testRequest, apiKey: apiKey)
            return true
        } catch {
            lastError = "API key validation failed: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - AI Analysis Methods
    
    func getCaptainRecommendation(
        for players: [Player],
        venue: String? = nil,
        opponent: String? = nil,
        weather: String? = nil
    ) async throws -> AIRecommendation {
        guard let apiKey = try keychainService.getAPIKey() else {
            throw OpenAIError.noAPIKey
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let playersText = players.prefix(10).map { player in
            "\(player.name) (\(player.position.rawValue), \(player.team)) - Avg: \(player.average), Proj: \(player.projected), Price: $\(player.price)"
        }.joined(separator: "\n")
        
        let venueInfo = venue != nil ? " at \(venue!)" : ""
        let opponentInfo = opponent != nil ? " vs \(opponent!)" : ""
        let weatherInfo = weather != nil ? " with \(weather!) conditions" : ""
        
        let prompt = """
        As an AFL Fantasy expert, recommend the best captain choice from these players\(venueInfo)\(opponentInfo)\(weatherInfo):
        
        \(playersText)
        
        Consider:
        - Recent form vs season average
        - Venue history and opponent matchup
        - Weather conditions impact
        - Captaincy ceiling vs floor
        
        Provide your recommendation in this exact format:
        **Player Name**: [Name]
        **Confidence**: [High/Medium/Low]
        **Reasoning**: [2-3 sentences explaining why this player is the best captain choice]
        **Risk Level**: [Low/Medium/High]
        **Projected Score**: [70-150 range]
        """
        
        let request = OpenAIRequest(
            model: "gpt-4o",
            messages: [
                OpenAIMessage(role: "system", content: "You are an expert AFL Fantasy coach with deep knowledge of player performance, venue effects, and matchup analysis."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            maxTokens: 300,
            temperature: 0.3
        )
        
        let response = try await makeRequest(request, apiKey: apiKey)
        
        return AIRecommendation(
            type: .captainAdvice,
            content: response.choices.first?.message.content ?? "No recommendation available",
            confidence: extractConfidence(from: response.choices.first?.message.content ?? ""),
            timestamp: Date()
        )
    }
    
    func getTradeRecommendation(
        currentTeam: [Player],
        availablePlayers: [Player],
        budget: Int,
        tradesRemaining: Int
    ) async throws -> AIRecommendation {
        guard let apiKey = try keychainService.getAPIKey() else {
            throw OpenAIError.noAPIKey
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let teamText = currentTeam.prefix(15).map { "\($0.name) (\($0.position.rawValue)) - $\($0.price)" }.joined(separator: ", ")
        let topPlayers = availablePlayers.sorted { $0.projected > $1.projected }.prefix(20)
        let availableText = topPlayers.map { "\($0.name) (\($0.position.rawValue)) - $\($0.price), Proj: \($0.projected)" }.joined(separator: "\n")
        
        let prompt = """
        As an AFL Fantasy expert, analyze this team and suggest the best trade:
        
        Current Team: \(teamText)
        Budget: $\(budget)
        Trades Remaining: \(tradesRemaining)
        
        Top Available Players:
        \(availableText)
        
        Consider:
        - Value for money upgrades
        - Upcoming fixture difficulty
        - Player form and potential
        - Team balance and structure
        
        Recommend ONE specific trade in this format:
        **Trade Out**: [Player Name] ($[price])
        **Trade In**: [Player Name] ($[price])
        **Cost**: $[difference]
        **Reasoning**: [Why this trade improves the team]
        **Priority**: [High/Medium/Low]
        """
        
        let request = OpenAIRequest(
            model: "gpt-4o",
            messages: [
                OpenAIMessage(role: "system", content: "You are an AFL Fantasy expert specializing in team optimization and player trading strategies."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            maxTokens: 400,
            temperature: 0.4
        )
        
        let response = try await makeRequest(request, apiKey: apiKey)
        
        return AIRecommendation(
            type: .tradeAdvice,
            content: response.choices.first?.message.content ?? "No recommendation available",
            confidence: extractConfidence(from: response.choices.first?.message.content ?? ""),
            timestamp: Date()
        )
    }
    
    func analyzePriceMovements(
        players: [Player],
        round: Int
    ) async throws -> AIRecommendation {
        guard let apiKey = try keychainService.getAPIKey() else {
            throw OpenAIError.noAPIKey
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let playersText = players.prefix(15).map { 
            "\($0.name) (\($0.position.rawValue)) - Price: $\($0.price), Avg: \($0.average), Proj: \($0.projected), BE: \($0.breakeven)"
        }.joined(separator: "\n")
        
        let prompt = """
        As an AFL Fantasy price movement expert, analyze these players for Round \(round):
        
        \(playersText)
        
        Focus on:
        - Players likely to rise in price (breakeven analysis)
        - Players at risk of price drops
        - Cash generation opportunities
        - Timing for buying/selling
        
        Provide analysis in this format:
        **Price Risers**: [2-3 players with reasons]
        **Price Fallers**: [2-3 players with reasons] 
        **Cash Cows**: [Best value cash generation picks]
        **Timing**: [When to make moves - before/after this round]
        """
        
        let request = OpenAIRequest(
            model: "gpt-4o",
            messages: [
                OpenAIMessage(role: "system", content: "You are an AFL Fantasy expert specializing in player pricing, cash generation, and market timing."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            maxTokens: 450,
            temperature: 0.3
        )
        
        let response = try await makeRequest(request, apiKey: apiKey)
        
        return AIRecommendation(
            type: .priceAnalysis,
            content: response.choices.first?.message.content ?? "No analysis available",
            confidence: extractConfidence(from: response.choices.first?.message.content ?? ""),
            timestamp: Date()
        )
    }
    
    // MARK: - Private Methods
    
    private func makeRequest(_ request: OpenAIRequest, apiKey: String) async throws -> OpenAIResponse {
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAIError.apiError(message)
            }
            throw OpenAIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(OpenAIResponse.self, from: data)
    }
    
    private func extractConfidence(from content: String) -> Double {
        let lowercaseContent = content.lowercased()
        if lowercaseContent.contains("high confidence") || lowercaseContent.contains("confidence**: high") {
            return 0.9
        } else if lowercaseContent.contains("medium confidence") || lowercaseContent.contains("confidence**: medium") {
            return 0.7
        } else if lowercaseContent.contains("low confidence") || lowercaseContent.contains("confidence**: low") {
            return 0.5
        }
        return 0.8 // Default confidence
    }
}

// MARK: - OpenAI Models

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let id: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
    let finishReason: String?
}

struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
}



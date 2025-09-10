# AFL Fantasy iOS - Backend Integration Guide

## Overview
This guide covers how to integrate the AFL Fantasy iOS app with the backend APIs (Python Flask and Node.js Express services).

## Architecture

```
iOS App
    │
    ├── Network Layer (URLSession + Combine)
    │   ├── APIClient.swift
    │   ├── Endpoints.swift
    │   └── NetworkError.swift
    │
    ├── Data Models
    │   ├── Player.swift
    │   ├── Trade.swift
    │   └── Fantasy.swift
    │
    └── Backend APIs
        ├── Node.js API (Primary) → Port 5000 (default) or 3000
        │   ├── /api/health
        │   ├── /api/scraped-players (player data from scrapers)
        │   ├── /api/afl-fantasy/dashboard-data (dashboard data)
        │   ├── /api/trade_score (proxies to Python)
        │   ├── /api/stats (stats and analysis)
        │   ├── /api/afl-data (AFL Fantasy integration)
        │   ├── /api/integration (authenticated AFL Fantasy)
        │   ├── /api/champion-data (Champion Data API)
        │   ├── /api/stats-tools (analysis tools)
        │   ├── /api/algorithms (price predictor & scoring)
        │   └── /api/score-projection (projected score algorithm)
        │
        └── Python API (Specialized) → Port 5000
            ├── /health
            └── /api/trade_score (trade scoring algorithm)
```

## Base Configuration

### Environment Setup
Create a configuration file for different environments:

```swift
// Config/APIConfiguration.swift
import Foundation

enum Environment {
    case development
    case staging
    case production
}

struct APIConfiguration {
    static let current: Environment = {
        #if DEBUG
            return .development
        #elseif STAGING
            return .staging
        #else
            return .production
        #endif
    }()
    
    static var baseURL: String {
        switch current {
        case .development:
            return "http://localhost:3000"  // Node.js configured port
        case .staging:
            return "https://staging-api.yourapp.com"
        case .production:
            return "https://api.yourapp.com"
        }
    }
    
    static var pythonAPIURL: String {
        switch current {
        case .development:
            return "http://localhost:5000"
        case .staging:
            return "https://staging-python-api.yourapp.com"
        case .production:
            return "https://python-api.yourapp.com"
        }
    }
    
    static var timeout: TimeInterval { 30.0 }
    static var retryCount: Int { 3 }
}
```

## Network Layer Implementation

### API Client
Create a centralized API client using modern Swift concurrency:

```swift
// Network/APIClient.swift
import Foundation
import Combine

class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfiguration.timeout
        config.timeoutIntervalForResource = APIConfiguration.timeout * 2
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        
        // Configure date decoding strategy
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
}

// MARK: - Async/Await Methods
extension APIClient {
    func request<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildURLRequest(for: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            try validateResponse(response)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw mapError(error)
        }
    }
    
    func requestWithoutResponse(endpoint: APIEndpoint) async throws {
        let request = try buildURLRequest(for: endpoint)
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
}

// MARK: - Combine Methods
extension APIClient {
    func publisher<T: Codable>(
        for endpoint: APIEndpoint,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        do {
            let request = try buildURLRequest(for: endpoint)
            
            return session.dataTaskPublisher(for: request)
                .tryMap { [weak self] data, response in
                    try self?.validateResponse(response)
                    return data
                }
                .decode(type: T.self, decoder: decoder)
                .mapError { [weak self] error in
                    self?.mapError(error) ?? .unknown
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: mapError(error))
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Private Methods
private extension APIClient {
    func buildURLRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let body = endpoint.body {
            request.httpBody = body
        }
        
        return request
    }
    
    func validateResponse(_ response: URLResponse?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
    
    func mapError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noConnection
            case .timedOut:
                return .timeout
            default:
                return .requestFailed(urlError.localizedDescription)
            }
        }
        
        return .unknown
    }
}
```

### API Endpoints
Define all API endpoints in a structured way:

```swift
// Network/APIEndpoint.swift
import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension APIEndpoint {
    var url: String { baseURL + path }
    
    var headers: [String: String] {
        var defaultHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "AFL-Fantasy-iOS/1.0"
        ]
        
        // Add authentication if available
        if let authToken = UserDefaults.standard.string(forKey: "auth_token") {
            defaultHeaders["Authorization"] = "Bearer \(authToken)"
        }
        
        return defaultHeaders
    }
}

// MARK: - Node.js API Endpoints
enum NodeAPIEndpoint {
    case health
    case players(position: String? = nil)
    case playerDetail(id: Int)
    case dashboard
    case tradeAnalysis(TradeAnalysisRequest)
    case teamManagement
    case statistics(week: Int? = nil)
}

extension NodeAPIEndpoint: APIEndpoint {
    var baseURL: String { APIConfiguration.baseURL }
    
    var path: String {
        switch self {
        case .health:
            return "/api/health"
        case .players(let position):
            var path = "/api/players"
            if let position = position {
                path += "?position=\(position)"
            }
            return path
        case .playerDetail(let id):
            return "/api/players/\(id)"
        case .dashboard:
            return "/api/dashboard"
        case .tradeAnalysis:
            return "/api/trade-analysis"
        case .teamManagement:
            return "/api/team"
        case .statistics(let week):
            var path = "/api/statistics"
            if let week = week {
                path += "?week=\(week)"
            }
            return path
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .health, .players, .playerDetail, .dashboard, .teamManagement, .statistics:
            return .GET
        case .tradeAnalysis:
            return .POST
        }
    }
    
    var body: Data? {
        switch self {
        case .tradeAnalysis(let request):
            return try? JSONEncoder().encode(request)
        default:
            return nil
        }
    }
}

// MARK: - Python API Endpoints
enum PythonAPIEndpoint {
    case health
    case tradeScore(TradeScoreRequest)
}

extension PythonAPIEndpoint: APIEndpoint {
    var baseURL: String { APIConfiguration.pythonAPIURL }
    
    var path: String {
        switch self {
        case .health:
            return "/health"
        case .tradeScore:
            return "/api/trade_score"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .health:
            return .GET
        case .tradeScore:
            return .POST
        }
    }
    
    var body: Data? {
        switch self {
        case .tradeScore(let request):
            return try? JSONEncoder().encode(request)
        default:
            return nil
        }
    }
}
```

### Network Error Handling
Create comprehensive error handling:

```swift
// Network/NetworkError.swift
import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noConnection
    case timeout
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case requestFailed(String)
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Internal server error"
        case .unknown:
            return "Unknown error occurred"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noConnection:
            return "Please check your internet connection and try again."
        case .timeout:
            return "The request took too long. Please try again."
        case .unauthorized:
            return "Please log in again."
        case .serverError:
            return "Please try again later."
        default:
            return "Please try again."
        }
    }
}
```

## Data Models

### Core Models
Define the data models that match your API responses:

```swift
// Models/Player.swift
import Foundation

struct Player: Codable, Identifiable {
    let id: Int
    let name: String
    let team: String
    let position: String
    let price: Double
    let averageScore: Double
    let lastThreeAverage: Double
    let form: String
    let injuryStatus: String?
    let ownership: Double
    let nextFixture: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case team
        case position
        case price
        case averageScore = "average_score"
        case lastThreeAverage = "last_three_average"
        case form
        case injuryStatus = "injury_status"
        case ownership
        case nextFixture = "next_fixture"
        case imageURL = "image_url"
    }
}

struct PlayersResponse: Codable {
    let players: [Player]
    let totalCount: Int
    let page: Int
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case players
        case totalCount = "total_count"
        case page
        case hasMore = "has_more"
    }
}
```

```swift
// Models/Trade.swift
import Foundation

struct TradeAnalysisRequest: Codable {
    let playerIn: Int
    let playerOut: Int
    let budget: Double
    let teamValue: Double
    
    enum CodingKeys: String, CodingKey {
        case playerIn = "player_in"
        case playerOut = "player_out"
        case budget
        case teamValue = "team_value"
    }
}

struct TradeAnalysisResponse: Codable {
    let recommendation: String
    let score: Double
    let reasoning: [String]
    let impact: TradeImpact
    let alternatives: [Alternative]
}

struct TradeImpact: Codable {
    let pointsChange: Double
    let budgetChange: Double
    let riskLevel: String
    
    enum CodingKeys: String, CodingKey {
        case pointsChange = "points_change"
        case budgetChange = "budget_change"
        case riskLevel = "risk_level"
    }
}

struct Alternative: Codable {
    let playerIn: Player
    let score: Double
    let reasoning: String
    
    enum CodingKeys: String, CodingKey {
        case playerIn = "player_in"
        case score
        case reasoning
    }
}
```

```swift
// Models/TradeScore.swift
import Foundation

struct TradeScoreRequest: Codable {
    let playerInId: Int
    let playerOutId: Int
    let budget: Double
    let currentTeam: [Int]
    
    enum CodingKeys: String, CodingKey {
        case playerInId = "player_in_id"
        case playerOutId = "player_out_id"
        case budget
        case currentTeam = "current_team"
    }
}

struct TradeScoreResponse: Codable {
    let score: Double
    let confidence: Double
    let factors: TradeFactors
    let recommendation: String
}

struct TradeFactors: Codable {
    let formFactor: Double
    let priceFactor: Double
    let fixtureFactor: Double
    let ownershipFactor: Double
    let injuryRisk: Double
    
    enum CodingKeys: String, CodingKey {
        case formFactor = "form_factor"
        case priceFactor = "price_factor"
        case fixtureFactor = "fixture_factor"
        case ownershipFactor = "ownership_factor"
        case injuryRisk = "injury_risk"
    }
}
```

## Service Layer

### API Service
Create service classes for each domain:

```swift
// Services/PlayerService.swift
import Foundation
import Combine

class PlayerService: ObservableObject {
    private let apiClient = APIClient.shared
    
    @Published var players: [Player] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPlayers(position: String? = nil) async {
        await MainActor.run { isLoading = true }
        
        do {
            let response: PlayersResponse = try await apiClient.request(
                endpoint: NodeAPIEndpoint.players(position: position),
                responseType: PlayersResponse.self
            )
            
            await MainActor.run {
                self.players = response.players
                self.isLoading = false
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.error = error as? NetworkError ?? .unknown
                self.isLoading = false
            }
        }
    }
    
    func fetchPlayerDetail(id: Int) async -> Player? {
        do {
            return try await apiClient.request(
                endpoint: NodeAPIEndpoint.playerDetail(id: id),
                responseType: Player.self
            )
        } catch {
            await MainActor.run {
                self.error = error as? NetworkError ?? .unknown
            }
            return nil
        }
    }
}
```

```swift
// Services/TradeService.swift
import Foundation
import Combine

class TradeService: ObservableObject {
    private let apiClient = APIClient.shared
    
    @Published var isAnalyzing = false
    @Published var error: NetworkError?
    
    func analyzeTradeWithNode(request: TradeAnalysisRequest) async -> TradeAnalysisResponse? {
        await MainActor.run { isAnalyzing = true }
        
        do {
            let response: TradeAnalysisResponse = try await apiClient.request(
                endpoint: NodeAPIEndpoint.tradeAnalysis(request),
                responseType: TradeAnalysisResponse.self
            )
            
            await MainActor.run {
                self.isAnalyzing = false
                self.error = nil
            }
            
            return response
        } catch {
            await MainActor.run {
                self.error = error as? NetworkError ?? .unknown
                self.isAnalyzing = false
            }
            return nil
        }
    }
    
    func getTradeScoreFromPython(request: TradeScoreRequest) async -> TradeScoreResponse? {
        do {
            return try await apiClient.request(
                endpoint: PythonAPIEndpoint.tradeScore(request),
                responseType: TradeScoreResponse.self
            )
        } catch {
            await MainActor.run {
                self.error = error as? NetworkError ?? .unknown
            }
            return nil
        }
    }
    
    func getComprehensiveTradeAnalysis(
        playerInId: Int,
        playerOutId: Int,
        budget: Double,
        teamValue: Double,
        currentTeam: [Int]
    ) async -> (nodeAnalysis: TradeAnalysisResponse?, pythonScore: TradeScoreResponse?) {
        
        // Prepare requests
        let nodeRequest = TradeAnalysisRequest(
            playerIn: playerInId,
            playerOut: playerOutId,
            budget: budget,
            teamValue: teamValue
        )
        
        let pythonRequest = TradeScoreRequest(
            playerInId: playerInId,
            playerOutId: playerOutId,
            budget: budget,
            currentTeam: currentTeam
        )
        
        // Execute both requests concurrently
        async let nodeAnalysis = analyzeTradeWithNode(request: nodeRequest)
        async let pythonScore = getTradeScoreFromPython(request: pythonRequest)
        
        return await (nodeAnalysis, pythonScore)
    }
}
```

## SwiftUI Integration

### Player List View
Example of how to use the services in SwiftUI views:

```swift
// Views/PlayersView.swift
import SwiftUI

struct PlayersView: View {
    @StateObject private var playerService = PlayerService()
    @State private var selectedPosition: String? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                // Position filter
                PositionFilterView(selectedPosition: $selectedPosition)
                
                // Players list
                if playerService.isLoading {
                    ProgressView("Loading players...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if playerService.players.isEmpty {
                    EmptyStateView(message: "No players found")
                } else {
                    List(playerService.players) { player in
                        PlayerRowView(player: player)
                    }
                }
            }
            .navigationTitle("Players")
            .refreshable {
                await playerService.fetchPlayers(position: selectedPosition)
            }
            .task {
                await playerService.fetchPlayers(position: selectedPosition)
            }
            .onChange(of: selectedPosition) { _ in
                Task {
                    await playerService.fetchPlayers(position: selectedPosition)
                }
            }
            .alert("Error", isPresented: .constant(playerService.error != nil)) {
                Button("OK") {
                    playerService.error = nil
                }
            } message: {
                Text(playerService.error?.localizedDescription ?? "Unknown error")
            }
        }
    }
}

struct PlayerRowView: View {
    let player: Player
    
    var body: some View {
        HStack {
            // Player image
            AsyncImage(url: URL(string: player.imageURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                
                HStack {
                    Text(player.position)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(player.team)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(player.price, specifier: "%.1f")")
                    .font(.headline)
                
                Text("\(player.averageScore, specifier: "%.1f") avg")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
```

### Trade Analysis View
```swift
// Views/TradeAnalysisView.swift
import SwiftUI

struct TradeAnalysisView: View {
    @StateObject private var tradeService = TradeService()
    @State private var playerIn: Player?
    @State private var playerOut: Player?
    @State private var showingPlayerPicker = false
    @State private var isPickingPlayerIn = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Player selection
                VStack(spacing: 16) {
                    PlayerSelectionRow(
                        title: "Player In",
                        player: playerIn,
                        onTap: {
                            isPickingPlayerIn = true
                            showingPlayerPicker = true
                        }
                    )
                    
                    PlayerSelectionRow(
                        title: "Player Out",
                        player: playerOut,
                        onTap: {
                            isPickingPlayerIn = false
                            showingPlayerPicker = true
                        }
                    )
                }
                
                // Analyze button
                Button("Analyze Trade") {
                    analyzeTradeAction()
                }
                .buttonStyle(.borderedProminent)
                .disabled(playerIn == nil || playerOut == nil || tradeService.isAnalyzing)
                
                if tradeService.isAnalyzing {
                    ProgressView("Analyzing trade...")
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Trade Analysis")
            .sheet(isPresented: $showingPlayerPicker) {
                PlayerPickerView(
                    selectedPlayer: isPickingPlayerIn ? $playerIn : $playerOut
                )
            }
            .alert("Error", isPresented: .constant(tradeService.error != nil)) {
                Button("OK") {
                    tradeService.error = nil
                }
            } message: {
                Text(tradeService.error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    private func analyzeTradeAction() {
        guard let playerIn = playerIn, let playerOut = playerOut else { return }
        
        Task {
            let (nodeAnalysis, pythonScore) = await tradeService.getComprehensiveTradeAnalysis(
                playerInId: playerIn.id,
                playerOutId: playerOut.id,
                budget: 1000000, // Get from user's team
                teamValue: 83000000, // Get from user's team
                currentTeam: [] // Get from user's team
            )
            
            // Handle results - show in new view or update UI
            await MainActor.run {
                // Update UI with analysis results
            }
        }
    }
}
```

## Error Handling & Retry Logic

### Retry Mechanism
Implement automatic retry for transient failures:

```swift
// Network/RetryableAPIClient.swift
extension APIClient {
    func requestWithRetry<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        maxRetries: Int = APIConfiguration.retryCount
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                return try await request(endpoint: endpoint, responseType: responseType)
            } catch {
                lastError = error
                
                // Don't retry on client errors (4xx)
                if let networkError = error as? NetworkError,
                   case .httpError(let code) = networkError,
                   400...499 ~= code {
                    throw error
                }
                
                // Don't retry on last attempt
                if attempt == maxRetries {
                    break
                }
                
                // Exponential backoff
                let delay = pow(2.0, Double(attempt)) * 0.5
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        throw lastError ?? NetworkError.unknown
    }
}
```

## Local Data Persistence

### Core Data Integration
For offline support and caching:

```swift
// Persistence/PersistenceController.swift
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AFLFantasy")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
```

## Testing

### Unit Tests for API Client
```swift
// Tests/APIClientTests.swift
import XCTest
@testable import AFLFantasy

class APIClientTests: XCTestCase {
    var apiClient: APIClient!
    
    override func setUp() {
        super.setUp()
        // Use a test configuration with mock URLs
        apiClient = APIClient.shared
    }
    
    func testHealthEndpoint() async throws {
        // Test the health endpoint
        let response = try await apiClient.request(
            endpoint: NodeAPIEndpoint.health,
            responseType: HealthResponse.self
        )
        
        XCTAssertEqual(response.status, "healthy")
    }
    
    func testPlayersEndpoint() async throws {
        let response = try await apiClient.request(
            endpoint: NodeAPIEndpoint.players(),
            responseType: PlayersResponse.self
        )
        
        XCTAssertFalse(response.players.isEmpty)
    }
}
```

### Mock API Client for Testing
```swift
// Tests/Mocks/MockAPIClient.swift
class MockAPIClient: APIClient {
    var mockResponses: [String: Any] = [:]
    var shouldFail = false
    var failureError: NetworkError = .unknown
    
    override func request<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        if shouldFail {
            throw failureError
        }
        
        guard let mockResponse = mockResponses[endpoint.path] as? T else {
            throw NetworkError.decodingError(NSError(domain: "Mock", code: 1))
        }
        
        return mockResponse
    }
}
```

## Performance Optimization

### Image Caching
For player images and other assets:

```swift
// Utils/ImageCache.swift
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure cache limits
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func image(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
}
```

### Request Debouncing
For search and real-time features:

```swift
// Utils/Debouncer.swift
import Foundation

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem { action() }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}
```

## Security Considerations

### API Key Management
Never hardcode API keys in the app:

```swift
// Config/Secrets.swift
enum Secrets {
    static var apiKey: String? {
        // Load from Keychain, environment variable, or secure storage
        return KeychainHelper.shared.getValue(for: "api_key")
    }
}
```

### SSL Pinning (Optional)
For additional security in production:

```swift
// Network/SSLPinningDelegate.swift
import Foundation
import CommonCrypto

class SSLPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Implement SSL pinning logic here
        // This is a simplified example - use a proper implementation in production
        completionHandler(.performDefaultHandling, nil)
    }
}
```

## Monitoring & Analytics

### Error Tracking
Integrate with crash reporting services:

```swift
// Analytics/ErrorTracker.swift
import Foundation

class ErrorTracker {
    static func trackError(_ error: Error, context: [String: Any] = [:]) {
        // Send to your analytics service (Firebase, Bugsnag, etc.)
        print("Error tracked: \(error)")
    }
    
    static func trackAPICall(endpoint: String, duration: TimeInterval, success: Bool) {
        // Track API performance metrics
        print("API Call: \(endpoint), Duration: \(duration)s, Success: \(success)")
    }
}
```

## Next Steps

1. **Implementation Priority:**
   - Start with the basic API client and network layer
   - Implement core models and player service
   - Add trade analysis functionality
   - Integrate with UI

2. **Testing Strategy:**
   - Unit tests for API client and services
   - UI tests for critical user flows
   - Integration tests with mock backend

3. **Performance Monitoring:**
   - Monitor API response times
   - Track error rates
   - Optimize for slow network conditions

4. **Security Audit:**
   - Review data transmission security
   - Implement proper authentication
   - Add input validation

---

*For more detailed backend information, see README.md and DEPLOYMENT.md*

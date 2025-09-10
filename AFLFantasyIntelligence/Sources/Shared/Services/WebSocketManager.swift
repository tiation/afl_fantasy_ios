import Foundation
import Combine

/// WebSocket manager for real-time updates integrated with AlertManager
@MainActor
final class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()
    
    // MARK: - Published Properties
    
    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var liveScores: [String: Int] = [:]
    
    // MARK: - Private Properties
    
    private var webSocket: URLSessionWebSocketTask?
    private var reconnectTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // WebSocket configuration
    private var serverURL = "ws://localhost:4000/ws" // Update with your server URL
    private let reconnectInterval: TimeInterval = 5.0
    private let pingInterval: TimeInterval = 30.0
    
    // Alert integration
    private var alertManager: AlertManager?
    
    // MARK: - Connection State
    
    enum ConnectionState {
        case connecting
        case connected
        case disconnected
        case error(String)
        
        var isConnected: Bool {
            if case .connected = self { return true }
            return false
        }
    }
    
    // MARK: - Init
    
    init() {
        setupReconnectTimer()
    }
    
    // MARK: - Public Methods
    
    func setAlertManager(_ manager: AlertManager) {
        self.alertManager = manager
        print("🔗 WebSocket connected to AlertManager")
    }
    
    func configure(serverURL: String) {
        self.serverURL = serverURL
        print("🌐 WebSocket server URL updated to: \(serverURL)")
        
        // Reconnect with new URL if currently connected
        if connectionState.isConnected {
            disconnect()
            connect()
        }
    }
    
    func connect() {
        guard connectionState != .connecting && connectionState != .connected else {
            print("🌐 WebSocket already connecting or connected")
            return
        }
        
        guard let url = URL(string: serverURL) else {
            connectionState = .error("Invalid server URL")
            return
        }
        
        print("🌐 Connecting to WebSocket: \(serverURL)")
        connectionState = .connecting
        
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
        // Start message receiving
        receiveMessage()
        
        // Setup ping/pong
        schedulePing()
        
        // Subscribe to channels after connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.subscribeToChannels()
        }
    }
    
    func disconnect() {
        print("🌐 Disconnecting WebSocket")
        
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        connectionState = .disconnected
        
        // Cancel timers
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    // MARK: - Private Methods
    
    private func subscribeToChannels() {
        guard connectionState.isConnected else { return }
        
        let subscribeMessage = WebSocketOutgoingMessage(
            type: "subscribe",
            channels: ["alerts", "live_scores", "price_updates", "breaking_news"]
        )
        
        sendMessage(subscribeMessage)
        print("📡 Subscribed to WebSocket channels")
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let message):
                    self.handleWebSocketMessage(message)
                    
                    // Continue receiving if still connected
                    if self.connectionState.isConnected {
                        self.receiveMessage()
                    }
                    
                case .failure(let error):
                    print("🌐 WebSocket receive error: \(error)")
                    self.handleConnectionError(error)
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
        var textData: String?
        
        switch message {
        case .string(let text):
            textData = text
        case .data(let data):
            textData = String(data: data, encoding: .utf8)
        @unknown default:
            print("🌐 Unknown WebSocket message type")
            return
        }
        
        guard let text = textData,
              let data = text.data(using: .utf8) else {
            print("🌐 Failed to parse WebSocket message")
            return
        }
        
        do {
            let response = try JSONDecoder().decode(WebSocketIncomingMessage.self, from: data)
            handleServerMessage(response)
        } catch {
            print("🌐 Failed to decode WebSocket message: \(error)")
            // Try to parse as connection confirmation
            if text.contains("connected") || text.contains("subscribed") {
                connectionState = .connected
                print("🌐 WebSocket connected successfully")
            }
        }
    }
    
    private func handleServerMessage(_ message: WebSocketIncomingMessage) {
        switch message.type {
        case "connection_confirmed":
            connectionState = .connected
            print("🌐 WebSocket connection confirmed")
            
        case "alert":
            handleAlertMessage(message)
            
        case "live_scores":
            handleLiveScoresMessage(message)
            
        case "price_update":
            handlePriceUpdate(message)
            
        case "pong":
            // Pong received, connection is healthy
            break
            
        default:
            print("🌐 Unknown server message type: \(message.type)")
        }
    }
    
    private func handleAlertMessage(_ message: WebSocketIncomingMessage) {
        guard let alertData = message.alert else {
            print("🚨 Alert message missing alert data")
            return
        }
        
        // Convert server alert format to our AlertUpdate
        let alertUpdate = AlertUpdate(
            id: alertData.id ?? UUID().uuidString,
            type: parseAlertType(alertData.type),
            title: alertData.title,
            message: alertData.message,
            timestamp: parseTimestamp(alertData.timestamp) ?? Date(),
            playerId: alertData.playerId,
            data: alertData.data
        )
        
        // Forward to AlertManager
        alertManager?.handleIncomingAlert(alertUpdate)
        
        print("🚨 Received alert: \(alertUpdate.title)")
    }
    
    private func handleLiveScoresMessage(_ message: WebSocketIncomingMessage) {
        if let scores = message.liveScores {
            liveScores = scores
            print("⚽ Updated live scores: \(scores.count) players")
        }
    }
    
    private func handlePriceUpdate(_ message: WebSocketIncomingMessage) {
        // Create price change alert if significant
        guard let priceData = message.priceUpdate,
              let playerId = priceData.playerId,
              let playerName = priceData.playerName,
              let oldPrice = priceData.oldPrice,
              let newPrice = priceData.newPrice else {
            return
        }
        
        let priceChange = newPrice - oldPrice
        guard abs(priceChange) >= 5000 else { return } // Only alert for changes >= $5k
        
        let direction = priceChange > 0 ? "increased" : "decreased"
        let alertUpdate = AlertUpdate(
            type: .priceChange,
            title: "Price \(direction.capitalized)",
            message: "\(playerName) has \(direction) by $\(abs(priceChange) / 1000)k (now $\(newPrice / 1000)k)",
            playerId: playerId,
            data: [
                "oldPrice": "\\(oldPrice)",
                "newPrice": "\\(newPrice)",
                "change": "\\(priceChange)"
            ]
        )
        
        alertManager?.handleIncomingAlert(alertUpdate)
    }
    
    private func sendMessage<T: Codable>(_ message: T) {
        guard let data = try? JSONEncoder().encode(message),
              let text = String(data: data, encoding: .utf8) else {
            print("🌐 Failed to encode WebSocket message")
            return
        }
        
        webSocket?.send(.string(text)) { [weak self] error in
            if let error = error {
                print("🌐 WebSocket send error: \(error)")
                self?.handleConnectionError(error)
            }
        }
    }
    
    private func schedulePing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + pingInterval) { [weak self] in
            guard let self = self, self.connectionState.isConnected else { return }
            
            self.webSocket?.sendPing { error in
                if let error = error {
                    print("🌐 WebSocket ping error: \(error)")
                    Task { @MainActor in
                        self.handleConnectionError(error)
                    }
                } else {
                    Task { @MainActor in
                        self.schedulePing()
                    }
                }
            }
        }
    }
    
    private func handleConnectionError(_ error: Error) {
        print("🌐 WebSocket connection error: \(error)")
        connectionState = .error(error.localizedDescription)
        
        // Attempt reconnection if not manually disconnected
        if webSocket != nil {
            scheduleReconnect()
        }
    }
    
    private func scheduleReconnect() {
        guard reconnectTimer == nil else { return }
        
        print("🌐 Scheduling WebSocket reconnect in \(reconnectInterval)s")
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectInterval, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.reconnectTimer = nil
                self?.connect()
            }
        }
    }
    
    private func setupReconnectTimer() {
        // Auto-connect on initialization
        Task { @MainActor in
            self.connect()
        }
    }
    
    // MARK: - Parsing Helpers
    
    private func parseAlertType(_ serverType: String) -> AlertType {
        switch serverType.lowercased() {
        case "price_change", "pricechange":
            return .priceChange
        case "injury", "injury_update":
            return .injury
        case "late_out", "lateout":
            return .lateOut
        case "role_change", "rolechange":
            return .roleChange
        case "trade_deadline", "tradedeadline":
            return .tradeDeadline
        case "captain_reminder", "captainreminder":
            return .captainReminder
        case "breaking_news", "breakingnews":
            return .breakingNews
        case "milestone", "milestone_reached":
            return .milestoneReached
        case "price_threshold", "pricethreshold":
            return .priceThreshold
        case "form_alert", "formalert":
            return .formAlert
        case "fixture_change", "fixturechange":
            return .fixtureChange
        case "ai_recommendation", "airecommendation":
            return .aiRecommendation
        case "system":
            return .system
        default:
            print("🌐 Unknown alert type from server: \(serverType), defaulting to system")
            return .system
        }
    }
    
    private func parseTimestamp(_ timestampString: String?) -> Date? {
        guard let timestampString = timestampString else { return nil }
        
        // Try parsing ISO 8601 format
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestampString) {
            return date
        }
        
        // Try parsing Unix timestamp
        if let timestamp = Double(timestampString) {
            return Date(timeIntervalSince1970: timestamp)
        }
        
        return nil
    }
}

// MARK: - WebSocket Message Types

private struct WebSocketOutgoingMessage: Codable {
    let type: String
    let channels: [String]?
    let data: [String: String]?
    
    init(type: String, channels: [String]? = nil, data: [String: String]? = nil) {
        self.type = type
        self.channels = channels
        self.data = data
    }
}

private struct WebSocketIncomingMessage: Codable {
    let type: String
    let alert: ServerAlert?
    let liveScores: [String: Int]?
    let priceUpdate: PriceUpdate?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case alert
        case liveScores = "live_scores"
        case priceUpdate = "price_update"
    }
}

private struct ServerAlert: Codable {
    let id: String?
    let type: String
    let title: String
    let message: String
    let timestamp: String?
    let playerId: String?
    let data: [String: String]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case message
        case timestamp
        case playerId = "player_id"
        case data
    }
}

private struct PriceUpdate: Codable {
    let playerId: String?
    let playerName: String?
    let oldPrice: Int?
    let newPrice: Int?
    
    private enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case playerName = "player_name"
        case oldPrice = "old_price"
        case newPrice = "new_price"
    }
}

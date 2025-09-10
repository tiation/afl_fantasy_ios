import Foundation
import Network
import Combine

/// Manager for WebSocket connections and real-time data updates
@MainActor
final class WebSocketManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isConnected = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastUpdateTime: Date?
    @Published var errorMessage: String?
    
    // MARK: - Publishers for Real-time Data
    
    let priceUpdatesPublisher = PassthroughSubject<PriceUpdate, Never>()
    let scoreUpdatesPublisher = PassthroughSubject<ScoreUpdate, Never>()
    let matchUpdatesPublisher = PassthroughSubject<MatchUpdate, Never>()
    let alertsPublisher = PassthroughSubject<AlertNotification, Never>()
    
    // MARK: - Private Properties
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let baseURL: URL
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var reconnectTimer: Timer?
    private var heartbeatTimer: Timer?
    
    // MARK: - Initialization
    
    override init() {
        self.baseURL = URL(string: "wss://localhost:8080/ws")! // Default WebSocket URL
        super.init()
        
        setupURLSession()
    }
    
    init(baseURL: URL) {
        self.baseURL = baseURL
        super.init()
        
        setupURLSession()
    }
    
    // MARK: - Connection Management
    
    /// Connect to the WebSocket server
    func connect() {
        guard !isConnected else { return }
        
        connectionStatus = .connecting
        
        webSocketTask = urlSession?.webSocketTask(with: baseURL)
        webSocketTask?.delegate = self
        webSocketTask?.resume()
        
        // Start listening for messages
        receiveMessage()
        
        // Start heartbeat timer
        startHeartbeat()
        
        print("📡 Connecting to WebSocket: \(baseURL)")
    }
    
    /// Disconnect from the WebSocket server
    func disconnect() {
        connectionStatus = .disconnecting
        
        stopHeartbeat()
        stopReconnectTimer()
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        isConnected = false
        connectionStatus = .disconnected
        
        print("📡 Disconnected from WebSocket")
    }
    
    /// Send a message through the WebSocket
    func sendMessage(_ message: WebSocketMessage) {
        guard isConnected else {
            print("⚠️ Cannot send message - WebSocket not connected")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(message)
            let string = String(data: data, encoding: .utf8) ?? ""
            
            webSocketTask?.send(.string(string)) { [weak self] error in
                if let error = error {
                    print("❌ Failed to send WebSocket message: \(error)")
                    self?.handleConnectionError(error)
                }
            }
        } catch {
            print("❌ Failed to encode WebSocket message: \(error)")
        }
    }
    
    /// Subscribe to specific data types
    func subscribe(to dataTypes: [WebSocketDataType]) {
        let subscriptionMessage = WebSocketMessage(
            type: .subscribe,
            payload: ["dataTypes": dataTypes.map { $0.rawValue }]
        )
        sendMessage(subscriptionMessage)
    }
    
    /// Unsubscribe from specific data types
    func unsubscribe(from dataTypes: [WebSocketDataType]) {
        let unsubscriptionMessage = WebSocketMessage(
            type: .unsubscribe,
            payload: ["dataTypes": dataTypes.map { $0.rawValue }]
        )
        sendMessage(unsubscriptionMessage)
    }
    
    // MARK: - Private Methods
    
    private func setupURLSession() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage() // Continue listening
                
            case .failure(let error):
                print("❌ WebSocket receive error: \(error)")
                self?.handleConnectionError(error)
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        DispatchQueue.main.async {
            self.lastUpdateTime = Date()
            
            switch message {
            case .string(let text):
                self.processTextMessage(text)
            case .data(let data):
                self.processDataMessage(data)
            @unknown default:
                print("⚠️ Unknown WebSocket message type")
            }
        }
    }
    
    private func processTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        processDataMessage(data)
    }
    
    private func processDataMessage(_ data: Data) {
        do {
            let message = try JSONDecoder().decode(WebSocketResponse.self, from: data)
            handleWebSocketResponse(message)
        } catch {
            print("❌ Failed to decode WebSocket message: \(error)")
        }
    }
    
    private func handleWebSocketResponse(_ response: WebSocketResponse) {
        switch response.type {
        case .priceUpdate:
            if let priceUpdate = parsePriceUpdate(from: response.payload) {
                priceUpdatesPublisher.send(priceUpdate)
            }
            
        case .scoreUpdate:
            if let scoreUpdate = parseScoreUpdate(from: response.payload) {
                scoreUpdatesPublisher.send(scoreUpdate)
            }
            
        case .matchUpdate:
            if let matchUpdate = parseMatchUpdate(from: response.payload) {
                matchUpdatesPublisher.send(matchUpdate)
            }
            
        case .alert:
            if let alert = parseAlert(from: response.payload) {
                alertsPublisher.send(alert)
            }
            
        case .heartbeat:
            // Received heartbeat response - connection is healthy
            break
            
        case .error:
            if let errorMsg = response.payload["message"] as? String {
                errorMessage = errorMsg
            }
        }
    }
    
    private func parsePriceUpdate(from payload: [String: Any]) -> PriceUpdate? {
        guard let playerId = payload["playerId"] as? String,
              let oldPrice = payload["oldPrice"] as? Int,
              let newPrice = payload["newPrice"] as? Int else { return nil }
        
        return PriceUpdate(
            playerId: playerId,
            oldPrice: oldPrice,
            newPrice: newPrice,
            timestamp: Date()
        )
    }
    
    private func parseScoreUpdate(from payload: [String: Any]) -> ScoreUpdate? {
        guard let playerId = payload["playerId"] as? String,
              let score = payload["score"] as? Double else { return nil }
        
        return ScoreUpdate(
            playerId: playerId,
            score: score,
            timestamp: Date()
        )
    }
    
    private func parseMatchUpdate(from payload: [String: Any]) -> MatchUpdate? {
        guard let matchId = payload["matchId"] as? String,
              let status = payload["status"] as? String else { return nil }
        
        return MatchUpdate(
            matchId: matchId,
            status: status,
            homeScore: payload["homeScore"] as? Int,
            awayScore: payload["awayScore"] as? Int,
            timestamp: Date()
        )
    }
    
    private func parseAlert(from payload: [String: Any]) -> AlertNotification? {
        guard let id = payload["id"] as? String,
              let typeString = payload["type"] as? String,
              let type = AlertType(rawValue: typeString),
              let title = payload["title"] as? String,
              let message = payload["message"] as? String,
              let priorityString = payload["priority"] as? String,
              let priority = AlertPriority(rawValue: priorityString) else { return nil }
        
        return AlertNotification(
            id: id,
            type: type,
            title: title,
            message: message,
            priority: priority,
            createdAt: Date(),
            isRead: false,
            actionURL: payload["actionURL"] as? String,
            metadata: payload["metadata"] as? [String: Any] ?? [:]
        )
    }
    
    private func handleConnectionError(_ error: Error) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionStatus = .disconnected
            self.errorMessage = error.localizedDescription
            
            // Attempt to reconnect if not manually disconnected
            if self.reconnectAttempts < self.maxReconnectAttempts {
                self.scheduleReconnect()
            }
        }
    }
    
    private func scheduleReconnect() {
        guard reconnectTimer == nil else { return }
        
        let delay = min(pow(2.0, Double(reconnectAttempts)), 30.0) // Exponential backoff, max 30s
        reconnectAttempts += 1
        
        print("📡 Scheduling reconnect attempt \(reconnectAttempts) in \(delay)s")
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.reconnectTimer = nil
            self?.connect()
        }
    }
    
    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        reconnectAttempts = 0
    }
    
    private func startHeartbeat() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.sendHeartbeat()
        }
    }
    
    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    private func sendHeartbeat() {
        let heartbeatMessage = WebSocketMessage(
            type: .heartbeat,
            payload: ["timestamp": Date().timeIntervalSince1970]
        )
        sendMessage(heartbeatMessage)
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketManager: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.isConnected = true
            self.connectionStatus = .connected
            self.reconnectAttempts = 0
            self.stopReconnectTimer()
            self.errorMessage = nil
            
            print("📡 WebSocket connected successfully")
            
            // Subscribe to default data types
            self.subscribe(to: [.priceUpdates, .scoreUpdates, .alerts])
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionStatus = .disconnected
            
            let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "No reason"
            print("📡 WebSocket closed with code: \(closeCode), reason: \(reasonString)")
            
            // Only attempt reconnect for unexpected disconnections
            if closeCode != .goingAway && self.reconnectAttempts < self.maxReconnectAttempts {
                self.scheduleReconnect()
            }
        }
    }
}

// MARK: - URLSessionDelegate

extension WebSocketManager: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionStatus = .disconnected
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("❌ WebSocket session became invalid: \(error)")
            }
        }
    }
}

// MARK: - Supporting Types

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case reconnecting
}

enum WebSocketDataType: String, CaseIterable {
    case priceUpdates = "price_updates"
    case scoreUpdates = "score_updates"
    case matchUpdates = "match_updates"
    case alerts = "alerts"
    case teamNews = "team_news"
}

struct WebSocketMessage: Codable {
    let type: MessageType
    let payload: [String: Any]
    
    enum MessageType: String, Codable {
        case subscribe
        case unsubscribe
        case heartbeat
        case message
    }
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        let data = try JSONSerialization.data(withJSONObject: payload)
        let jsonString = String(data: data, encoding: .utf8) ?? "{}"
        try container.encode(jsonString, forKey: .payload)
    }
}

struct WebSocketResponse: Codable {
    let type: ResponseType
    let payload: [String: Any]
    
    enum ResponseType: String, Codable {
        case priceUpdate = "price_update"
        case scoreUpdate = "score_update"
        case matchUpdate = "match_update"
        case alert = "alert"
        case heartbeat = "heartbeat"
        case error = "error"
    }
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(ResponseType.self, forKey: .type)
        
        let payloadString = try container.decode(String.self, forKey: .payload)
        let payloadData = payloadString.data(using: .utf8) ?? Data()
        payload = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] ?? [:]
    }
}

struct PriceUpdate {
    let playerId: String
    let oldPrice: Int
    let newPrice: Int
    let timestamp: Date
}

struct ScoreUpdate {
    let playerId: String
    let score: Double
    let timestamp: Date
}

struct MatchUpdate {
    let matchId: String
    let status: String
    let homeScore: Int?
    let awayScore: Int?
    let timestamp: Date
}

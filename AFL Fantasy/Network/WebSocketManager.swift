import Foundation
import UserNotifications

/// WebSocket manager for real-time updates
class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()
    
    private var webSocket: URLSessionWebSocketTask?
    private let baseURL = "ws://localhost:4000/ws"
    
    // State publishers
    @Published var isConnected = false
    @Published var alerts: [Alert] = []
    @Published var liveScores: [String: Int] = [:]
    
    init() {
        connect()
    }
    
    func connect() {
        guard let url = URL(string: baseURL) else { return }
        
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
        // Start listening for messages
        receiveMessage()
        ping()
        
        // Subscribe to channels
        subscribe(to: ["alerts", "scores", "prices"])
    }
    
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        isConnected = false
    }
    
    func subscribe(to channels: [String]) {
        let message = WebSocketMessage(
            type: "subscribe",
            channels: channels
        )
        send(message)
    }
    
    func unsubscribe(from channels: [String]) {
        let message = WebSocketMessage(
            type: "unsubscribe",
            channels: channels
        )
        send(message)
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // Continue receiving messages
                self.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error:", error)
                self.reconnect()
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(WSResponse.self, from: data) else {
            return
        }
        
        DispatchQueue.main.async {
            switch message.type {
            case "alert":
                if let alert = message.alert {
                    self.alerts.insert(alert, at: 0)
                    if self.alerts.count > 100 {
                        self.alerts.removeLast()
                    }
                    
                    // Post notification for system alert if critical
                    if alert.severity == .critical {
                        self.postSystemNotification(for: alert)
                    }
                }
                
            case "live_scores":
                if let scores = message.scores {
                    self.liveScores = scores
                }
                
            case "subscribed", "unsubscribed":
                break
                
            default:
                print("Unknown message type:", message.type)
            }
        }
    }
    
    private func send(_ message: WebSocketMessage) {
        guard let data = try? JSONEncoder().encode(message),
              let text = String(data: data, encoding: .utf8) else {
            return
        }
        
        webSocket?.send(.string(text)) { error in
            if let error = error {
                print("WebSocket send error:", error)
                self.reconnect()
            }
        }
    }
    
    private func ping() {
        let workItem = DispatchWorkItem { [weak self] in
            self?.webSocket?.sendPing { error in
                if let error = error {
                    print("WebSocket ping error:", error)
                    self?.reconnect()
                }
            }
            self?.ping()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 30, execute: workItem)
    }
    
    private func reconnect() {
        disconnect()
        
        // Wait 1 second before reconnecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.connect()
        }
    }
    
    private func postSystemNotification(for alert: Alert) {
        let content = UNMutableNotificationContent()
        content.title = alert.type.title
        content.body = alert.message
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Supporting Types

private struct WebSocketMessage: Codable {
    let type: String
    let channels: [String]
}

private struct WSResponse: Codable {
    let type: String
    let alert: Alert?
    let scores: [String: Int]?
}

private extension AlertType {
    var title: String {
        switch self {
        case .priceChange:
            return "Price Alert"
        case .injuryUpdate, .injury:
            return "Injury Update"
        case .lateOut:
            return "Late Out"
        case .roleChange:
            return "Role Change"
        case .breakingNews:
            return "Breaking News"
        case .tradeDeadline:
            return "Trade Deadline"
        case .captainReminder:
            return "Captain Reminder"
        case .selection:
            return "Selection Alert"
        case .milestone:
            return "Milestone"
        case .system:
            return "System Alert"
        }
    }
}

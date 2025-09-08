//
//  ReachabilityService.swift
//  AFL Fantasy Intelligence Platform
//
//  Network reachability detection and monitoring
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import Network
import os.log
import SwiftUI

// MARK: - ReachabilityService

@MainActor
class ReachabilityService: ObservableObject {
    @Published var connectionStatus: NetworkStatus = .unknown
    @Published var isReachable: Bool = true
    @Published var connectionType: ConnectionType = .unknown
    @Published var lastConnectedTime: Date?
    @Published var offlineDuration: TimeInterval = 0

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ReachabilityService", qos: .background)
    private let logger = Logger(subsystem: "AFLFantasy", category: "ReachabilityService")
    private var offlineTimer: Timer?

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    func startMonitoring() {
        logger.info("🌐 Starting network reachability monitoring")

        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                await self?.updateConnectionStatus(path)
            }
        }

        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        logger.info("🌐 Stopping network reachability monitoring")
        monitor.cancel()
        offlineTimer?.invalidate()
        offlineTimer = nil
    }

    func forceRefresh() async -> Bool {
        guard isReachable else {
            logger.warning("⚠️ Cannot refresh - device is offline")
            return false
        }

        logger.info("🔄 Force refresh requested")

        // Simulate network check with timeout
        return await withCheckedContinuation { continuation in
            let timeoutTask = Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 second timeout
                continuation.resume(returning: false)
            }

            Task {
                do {
                    // Test connectivity to AFL Fantasy servers
                    guard let url = URL(string: "https://fantasy.afl.com.au/api/classic") else {
                        timeoutTask.cancel()
                        logger.error("❌ Invalid connectivity test URL")
                        continuation.resume(returning: false)
                        return
                    }
                    let (_, response) = try await URLSession.shared.data(from: url)

                    timeoutTask.cancel()

                    if let httpResponse = response as? HTTPURLResponse {
                        let isReachable = httpResponse.statusCode == 200 || httpResponse.statusCode == 404
                        logger.info("🌐 Connectivity test result: \(isReachable ? "✅" : "❌")")
                        continuation.resume(returning: isReachable)
                    } else {
                        continuation.resume(returning: false)
                    }
                } catch {
                    timeoutTask.cancel()
                    logger.error("🌐 Connectivity test failed: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func updateConnectionStatus(_ path: NWPath) {
        let newStatus: NetworkStatus
        let newConnectionType: ConnectionType
        let wasReachable = isReachable
        let newIsReachable = path.status == .satisfied

        // Determine connection status
        switch path.status {
        case .satisfied:
            newStatus = .connected
        case .unsatisfied:
            newStatus = .disconnected
        case .requiresConnection:
            newStatus = .connecting
        @unknown default:
            newStatus = .unknown
        }

        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            newConnectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            newConnectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            newConnectionType = .ethernet
        } else {
            newConnectionType = .unknown
        }

        // Update published properties
        connectionStatus = newStatus
        connectionType = newConnectionType
        isReachable = newIsReachable

        // Handle connection state changes
        if newIsReachable, !wasReachable {
            handleConnectionRestored()
        } else if !newIsReachable, wasReachable {
            handleConnectionLost()
        }

        logger.info("🌐 Network status: \(newStatus.rawValue) via \(newConnectionType.rawValue)")
    }

    private func handleConnectionRestored() {
        lastConnectedTime = Date()
        offlineTimer?.invalidate()
        offlineTimer = nil
        offlineDuration = 0

        logger.info("✅ Network connection restored")

        // Notify other services that connectivity is restored
        NotificationCenter.default.post(name: .networkConnectivityRestored, object: nil)
    }

    private func handleConnectionLost() {
        logger.warning("❌ Network connection lost")

        // Start offline duration timer
        offlineTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.offlineDuration += 1.0
            }
        }

        // Notify other services that connectivity is lost
        NotificationCenter.default.post(name: .networkConnectivityLost, object: nil)
    }
}

// MARK: - NetworkStatus

public enum NetworkStatus: String, CaseIterable {
    case unknown = "Unknown"
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"

    var systemImage: String {
        switch self {
        case .unknown: "questionmark.circle"
        case .disconnected: "wifi.slash"
        case .connecting: "wifi.exclamationmark"
        case .connected: "wifi"
        }
    }

    var color: Color {
        switch self {
        case .unknown: .gray
        case .disconnected: .red
        case .connecting: .orange
        case .connected: .green
        }
    }
}

// MARK: - ConnectionType

enum ConnectionType: String, CaseIterable {
    case unknown = "Unknown"
    case wifi = "WiFi"
    case cellular = "Cellular"
    case ethernet = "Ethernet"

    var systemImage: String {
        switch self {
        case .unknown: "questionmark.circle"
        case .wifi: "wifi"
        case .cellular: "antenna.radiowaves.left.and.right"
        case .ethernet: "cable.connector"
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let networkConnectivityRestored = Notification.Name("NetworkConnectivityRestored")
    static let networkConnectivityLost = Notification.Name("NetworkConnectivityLost")
}

// MARK: - Reachability Status View Modifier

struct ReachabilityStatusModifier: ViewModifier {
    @StateObject private var reachability = ReachabilityService()
    @State private var showOfflineBanner = false

    func body(content: Content) -> some View {
        content
            .environmentObject(reachability)
            .overlay(alignment: .top) {
                if showOfflineBanner, !reachability.isReachable {
                    OfflineStatusBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(999)
                }
            }
            .onChange(of: reachability.isReachable) { _, isReachable in
                withAnimation(.easeInOut(duration: 0.3)) {
                    showOfflineBanner = !isReachable
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .networkConnectivityRestored)) { _ in
                withAnimation(.easeInOut(duration: 0.5).delay(2.0)) {
                    showOfflineBanner = false
                }
            }
    }
}

extension View {
    func reachabilityStatus() -> some View {
        modifier(ReachabilityStatusModifier())
    }
}

// MARK: - Offline Status Banner

struct OfflineStatusBanner: View {
    @EnvironmentObject var reachability: ReachabilityService

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.m.value) {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
                .font(.system(size: DesignSystem.IconSize.medium.value))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs.value) {
                Text("You're offline")
                    .typography(.bodySecondary)
                    .foregroundColor(.white)

                if let lastConnected = reachability.lastConnectedTime {
                    Text("Last connected \(lastConnected, format: .relative(presentation: .named))")
                        .typography(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("Check your internet connection")
                        .typography(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            Spacer()

            if reachability.offlineDuration > 0 {
                Text(formatDuration(reachability.offlineDuration))
                    .typography(.caption1)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, DesignSystem.Spacing.s.value)
                    .padding(.vertical, DesignSystem.Spacing.xs.value)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                            .fill(.white.opacity(0.2))
                    )
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(.red.gradient)
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 0)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

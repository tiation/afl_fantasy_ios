//
//  ConnectionStatusBarCore.swift
//  AFL Fantasy Intelligence Platform
//
//  Simple ConnectionStatusBar implementation
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - ConnectionStatusBar

struct ConnectionStatusBar: View {
    @State private var connectionStatus: ConnectionStatus = .live
    @State private var animateConnection = false
    
    var body: some View {
        HStack {
            Image(systemName: connectionStatus.systemImage)
                .foregroundColor(connectionStatus.color)
                .scaleEffect(animateConnection ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: animateConnection)
            
            Text(connectionStatus.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(connectionStatus.color)
            
            Spacer()
            
            Text("Last updated: now")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(connectionStatus.color.opacity(0.1))
        )
        .onAppear {
            animateConnection = connectionStatus == .live
        }
    }
}

// MARK: - ConnectionStatus

enum ConnectionStatus: String, CaseIterable {
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"
    case live = "Live"
    case error = "Error"

    var color: Color {
        switch self {
        case .disconnected: .gray
        case .connecting: .orange
        case .connected: .green
        case .live: .red
        case .error: .red
        }
    }

    var systemImage: String {
        switch self {
        case .disconnected: "wifi.slash"
        case .connecting: "wifi.exclamationmark"
        case .connected: "wifi"
        case .live: "dot.radiowaves.left.and.right"
        case .error: "exclamationmark.triangle"
        }
    }
}

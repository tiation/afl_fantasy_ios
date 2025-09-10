import SwiftUI

struct AlertDetailView: View {
    let alert: AlertNotification
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: alert.type.iconName)
                                .font(.title2)
                                .foregroundColor(alert.type.color)
                                .frame(width: 32, height: 32)
                                .background(alert.type.color.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(alert.type.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(alert.timestamp.formatted(.dateTime.weekday(.wide).month(.wide).day().hour().minute()))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            DSStatusBadge(
                                text: alert.type.priority.displayName,
                                style: badgeStyle(for: alert.type.priority)
                            )
                        }
                    }
                    
                    Divider()
                    
                    // Message Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                        
                        Text(alert.message)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    // Player Information (if available)
                    if let playerName = alert.playerName {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Player")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text(playerName)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Alert Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func badgeStyle(for priority: AlertPriority) -> DSStatusBadge.Style {
        switch priority {
        case .critical: return .error
        case .high: return .warning
        case .medium: return .info
        case .low: return .success
        }
    }
}

// MARK: - Extensions for Alert Detail

extension AlertType {
    var iconName: String {
        switch self {
        case .priceChange: return "dollarsign.circle"
        case .injury: return "bandage"
        case .teamSelection: return "person.2"
        case .breakeven: return "chart.line.uptrend.xyaxis"
        case .trade: return "arrow.swap.horizontal"
        case .captain: return "star"
        }
    }
    
    var displayName: String {
        return rawValue
    }
}

extension AlertPriority {
    var displayName: String {
        switch self {
        case .critical: return "CRITICAL"
        case .high: return "HIGH"
        case .medium: return "MEDIUM"
        case .low: return "LOW"
        }
    }
}

// Alert extension methods moved to Models/Alert.swift to avoid conflicts

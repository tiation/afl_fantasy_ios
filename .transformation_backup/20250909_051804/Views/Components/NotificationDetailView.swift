import SwiftUI

struct NotificationDetailView: View {
    let notification: AlertNotification
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: typeIcon)
                                .foregroundColor(typeColor)
                                .font(.title2)
                            
                            Text(notification.type.displayName)
                                .font(.headline)
                                .foregroundColor(typeColor)
                            
                            Spacer()
                            
                            Text(formattedTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(notification.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    // Message content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                        
                        Text(notification.message)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    
                    // Additional data if available
                    if let data = notification.data, !data.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Additional Information")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(Array(data.keys.sorted()), id: \.self) { key in
                                    DataRow(key: key, value: data[key] ?? "")
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Notification")
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
    
    private var typeIcon: String {
        switch notification.type {
        case .injury, .injuryUpdate:
            return "bandage.fill"
        case .selection:
            return "person.fill.checkmark"
        case .priceChange:
            return "dollarsign.circle.fill"
        case .milestone:
            return "trophy.fill"
        case .system:
            return "gear"
        case .lateOut:
            return "exclamationmark.triangle.fill"
        case .roleChange:
            return "arrow.left.arrow.right"
        case .breakingNews:
            return "newspaper.fill"
        case .tradeDeadline:
            return "clock.fill"
        case .captainReminder:
            return "star.fill"
        }
    }
    
    private var typeColor: Color {
        switch notification.type {
        case .injury, .injuryUpdate, .lateOut:
            return .red
        case .selection, .milestone:
            return .green
        case .priceChange:
            return .blue
        case .system, .captainReminder:
            return .orange
        case .roleChange, .breakingNews, .tradeDeadline:
            return .purple
        }
    }
    
    private var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: notification.timestamp, relativeTo: Date())
    }
}

struct DataRow: View {
    let key: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

struct NotificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationDetailView(
            notification: AlertNotification(
                id: "1",
                title: "Price Drop Alert",
                message: "Marcus Bontempelli has dropped $50k in price. Consider selling to maximize cash generation.",
                type: .priceChange,
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false,
                playerId: "123",
                data: [
                    "oldPrice": "$650k",
                    "newPrice": "$600k",
                    "change": "-$50k",
                    "team": "Western Bulldogs"
                ]
            )
        )
    }
}

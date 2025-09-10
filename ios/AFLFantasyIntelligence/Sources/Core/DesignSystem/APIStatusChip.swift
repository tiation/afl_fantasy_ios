import SwiftUI

// MARK: - APIStatusChip

struct APIStatusChip: View {
    @EnvironmentObject var apiService: APIService
    
    var body: some View {
        HStack(spacing: DS.Spacing.xs) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .animation(.easeInOut(duration: 0.3), value: apiService.isHealthy)
            
            Text(statusText)
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.onSurfaceSecondary)
        }
        .padding(.horizontal, DS.Spacing.s)
        .padding(.vertical, DS.Spacing.xs)
        .background(
            Capsule()
                .fill(DS.Colors.surfaceVariant)
        )
        .dsAccessibility(
            label: "API Status: \(statusText)",
            hint: apiService.isHealthy ? "API is connected and working" : "API is not responding"
        )
    }
    
    private var statusColor: Color {
        apiService.isHealthy ? DS.Colors.success : DS.Colors.error
    }
    
    private var statusText: String {
        apiService.isHealthy ? "Connected" : "Offline"
    }
}

// MARK: - Preview

#if DEBUG
struct APIStatusChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DS.Spacing.l) {
            APIStatusChip()
                .environmentObject(APIService.mock)
                .previewDisplayName("Connected")
            
            APIStatusChip()
                .environmentObject({
                    let service = APIService.mock
                    service.isHealthy = false
                    return service
                }())
                .previewDisplayName("Offline")
        }
        .padding()
    }
}
#endif

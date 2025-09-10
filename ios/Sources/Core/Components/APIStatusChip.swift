import SwiftUI

// MARK: - APIStatusChip

struct APIStatusChip: View {
    @EnvironmentObject var apiService: APIService
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text("API")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("API Status: \(statusText)")
        .accessibilityHint("Tap for details")
        .sheet(isPresented: $showingDetails) {
            APIStatusDetailView()
                .environmentObject(apiService)
        }
    }
    
    private var statusColor: Color {
        if apiService.isHealthy {
            return DS.Colors.success
        } else {
            return DS.Colors.error
        }
    }
    
    private var statusText: String {
        apiService.isHealthy ? "Connected" : "Disconnected"
    }
}

// MARK: - APIStatusDetailView

struct APIStatusDetailView: View {
    @EnvironmentObject var apiService: APIService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: DS.Spacing.l) {
                DSCard {
                    VStack(alignment: .leading, spacing: DS.Spacing.m) {
                        HStack {
                            Image(systemName: apiService.isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .font(.title2)
                                .foregroundColor(apiService.isHealthy ? DS.Colors.success : DS.Colors.error)
                            
                            Text("API Connection")
                                .font(DS.Typography.headline)
                                .foregroundColor(DS.Colors.onSurface)
                            
                            Spacer()
                        }
                        
                        Text(apiService.isHealthy ? "Connected and operational" : "Connection issues detected")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        if let lastCheck = apiService.lastHealthCheck {
                            Text("Last checked: \(lastCheck.formatted(date: .omitted, time: .shortened))")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }
                        
                        if !apiService.isHealthy {
                            Text("Some features may be unavailable. Try refreshing or check your connection.")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.error)
                                .padding(.top, DS.Spacing.s)
                        }
                    }
                }
                
                DSButton("Refresh Connection", style: .primary) {
                    Task {
                        await apiService.checkHealth()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("System Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Previews

#if DEBUG
    struct APIStatusChip_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 20) {
                APIStatusChip()
                    .environmentObject(APIService.mock)
                
                APIStatusChip()
                    .environmentObject({
                        let service = APIService()
                        // Mock unhealthy state
                        return service
                    }())
            }
            .padding()
        }
    }
#endif

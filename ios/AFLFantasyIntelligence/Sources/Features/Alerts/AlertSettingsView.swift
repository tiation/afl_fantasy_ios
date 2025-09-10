import SwiftUI

struct AlertSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var alertsViewModel = AlertsViewModel()
    @State private var settings = AlertSettings()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Alert Types") {
                    Toggle("Price Changes", isOn: $settings.priceChangeEnabled)
                    Toggle("Injuries", isOn: $settings.injuryEnabled)
                    Toggle("Team Selections", isOn: $settings.teamSelectionEnabled)
                    Toggle("Breakeven Alerts", isOn: $settings.breakevenEnabled)
                    Toggle("Trade Recommendations", isOn: $settings.tradeEnabled)
                    Toggle("Captain Recommendations", isOn: $settings.captainEnabled)
                }
                
                Section("Price Change Settings") {
                    HStack {
                        Text("Minimum Change")
                        Spacer()
                        Text("$\(settings.minimumPriceChange)")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(settings.minimumPriceChange) },
                            set: { settings.minimumPriceChange = Int($0) }
                        ),
                        in: 1000...20000,
                        step: 1000
                    )
                }
                
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $settings.pushNotificationsEnabled)
                    Toggle("Sound", isOn: $settings.soundEnabled)
                }
            }
            .navigationTitle("Alert Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        alertsViewModel.updateSettings(settings)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            settings = alertsViewModel.getCurrentSettings()
        }
    }
}

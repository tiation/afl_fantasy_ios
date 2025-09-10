import SwiftUI

// MARK: - AISettingsView

struct AISettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var openAIService = OpenAIService()
    
    @State private var apiKey = ""
    @State private var isSecureTextEntry = true
    @State private var showingApiKeyInfo = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    apiKeySection
                } header: {
                    Text("OpenAI Configuration")
                } footer: {
                    Text("Your API key is stored securely in the device keychain and never shared.")
                }
                
                Section {
                    statusSection
                } header: {
                    Text("Status")
                }
                
                Section {
                    infoSection
                } header: {
                    Text("Information")
                }
            }
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAPIKey()
                    }
                    .disabled(apiKey.isEmpty || isSaving)
                }
            }
        }
        .onAppear {
            loadCurrentAPIKey()
        }
        .alert("API Key Information", isPresented: $showingApiKeyInfo) {
            Button("Get API Key") {
                if let url = URL(string: "https://platform.openai.com/api-keys") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You need an OpenAI API key to use AI features. Visit platform.openai.com to create one.")
        }
    }
    
    // MARK: - API Key Section
    
    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            HStack {
                if isSecureTextEntry {
                    SecureField("sk-...", text: $apiKey)
                        .textContentType(.password)
                } else {
                    TextField("sk-...", text: $apiKey)
                        .textContentType(.password)
                }
                
                Button(action: { isSecureTextEntry.toggle() }) {
                    Image(systemName: isSecureTextEntry ? "eye" : "eye.slash")
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
            }
            
            HStack {
                Button("How to get API Key") {
                    showingApiKeyInfo = true
                }
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.primary)
                
                Spacer()
                
                if openAIService.isConfigured {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DS.Colors.success)
                        Text("Configured")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.success)
                    }
                }
            }
            
            if let error = openAIService.lastError {
                Text(error)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.error)
            }
        }
    }
    
    // MARK: - Status Section
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            StatusRow(
                title: "API Connection",
                status: openAIService.isConfigured ? .connected : .disconnected,
                icon: openAIService.isConfigured ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            
            StatusRow(
                title: "AI Features",
                status: openAIService.isConfigured ? .enabled : .disabled,
                icon: openAIService.isConfigured ? "brain.head.profile" : "brain.head.profile"
            )
            
            if openAIService.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Validating API key...")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
            }
        }
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            InfoRow(
                title: "Captain Recommendations",
                description: "Get AI-powered captain suggestions based on form, fixtures, and weather",
                icon: "star.fill"
            )
            
            InfoRow(
                title: "Trade Analysis",
                description: "Receive intelligent trade recommendations considering team balance and value",
                icon: "arrow.triangle.swap"
            )
            
            InfoRow(
                title: "Price Predictions",
                description: "Analyze price movements and cash generation opportunities",
                icon: "chart.line.uptrend.xyaxis"
            )
            
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text("Cost Information")
                    .font(DS.Typography.subheadline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text("AI features use your OpenAI API credits. Typical cost is $0.01-0.03 per analysis.")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadCurrentAPIKey() {
        // Don't load the actual key for security reasons
        // Just check if one exists
        openAIService.checkConfiguration()
    }
    
    private func saveAPIKey() {
        guard !apiKey.isEmpty else { return }
        
        isSaving = true
        
        Task {
            let success = await openAIService.validateAndStoreAPIKey(apiKey)
            
            await MainActor.run {
                isSaving = false
                
                if success {
                    // Clear the text field for security
                    apiKey = ""
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatusRow: View {
    let title: String
    let status: ConnectionStatus
    let icon: String
    
    enum ConnectionStatus {
        case connected, disconnected, enabled, disabled
        
        var color: Color {
            switch self {
            case .connected, .enabled:
                return DS.Colors.success
            case .disconnected, .disabled:
                return DS.Colors.error
            }
        }
        
        var text: String {
            switch self {
            case .connected: return "Connected"
            case .disconnected: return "Not Connected"
            case .enabled: return "Enabled"
            case .disabled: return "Disabled"
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(status.color)
                .frame(width: 20)
            
            Text(title)
                .font(DS.Typography.body)
                .foregroundColor(DS.Colors.onSurface)
            
            Spacer()
            
            Text(status.text)
                .font(DS.Typography.caption)
                .foregroundColor(status.color)
        }
    }
}

struct InfoRow: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.m) {
            Image(systemName: icon)
                .foregroundColor(DS.Colors.primary)
                .frame(width: 20)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(title)
                    .font(DS.Typography.subheadline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text(description)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AISettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AISettingsView()
    }
}
#endif

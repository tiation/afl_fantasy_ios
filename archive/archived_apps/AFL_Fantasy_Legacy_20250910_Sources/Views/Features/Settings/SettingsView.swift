import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingProfile = false
    @State private var showingAFLFantasyImport = false
    private let keychainManager = KeychainManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Theme.Colors.background
                    .ignoresSafeArea()
                
                // Content
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    List {
                        // Profile Section
                        Section {
                            Button {
                                showingProfile = true
                            } label: {
                                HStack(spacing: 16) {
                                    // Avatar placeholder
                                    Circle()
                                        .fill(.blue.gradient)
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Text(viewModel.userInitials)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(viewModel.username.isEmpty ? "User" : viewModel.username)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("View and edit profile")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // AFL Fantasy Section
                        Section("AFL Fantasy Team") {
                            if keychainManager.hasAFLCredentials() {
                                // Team is connected - show sync options
                                Button {
                                    // TODO: Quick refresh team data
                                } label: {
                                    SettingsRow(
                                        icon: "arrow.clockwise",
                                        title: "Refresh Team Data",
                                        value: "Last synced: Today"
                                    )
                                }
                                
                                Button {
                                    showingAFLFantasyImport = true
                                } label: {
                                    SettingsRow(
                                        icon: "gearshape.fill",
                                        title: "Team Import Settings",
                                        value: "Connected"
                                    )
                                }
                                .foregroundColor(.primary)
                            } else {
                                // Team not connected - show import option
                                Button {
                                    showingAFLFantasyImport = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "sportscourt.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Import AFL Fantasy Team")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text("Connect your actual roster and data")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "square.and.arrow.down.fill")
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // General Section
                        Section("General") {
                            // Username
                            NavigationLink {
                                SettingsDetailView(
                                    title: "Username",
                                    value: viewModel.username,
                                    placeholder: "Enter username",
                                    onSave: viewModel.updateUsername
                                )
                            } label: {
                                SettingsRow(
                                    icon: "person.fill",
                                    title: "Username",
                                    value: viewModel.username
                                )
                            }
                            
                            // Team Name
                            NavigationLink {
                                SettingsDetailView(
                                    title: "Team Name",
                                    value: viewModel.teamName,
                                    placeholder: "Enter team name",
                                    onSave: viewModel.updateTeamName
                                )
                            } label: {
                                SettingsRow(
                                    icon: "flag.fill",
                                    title: "Team Name",
                                    value: viewModel.teamName
                                )
                            }
                        }
                        
                        // Features Section
                        Section("Features") {
                            // AI Recommendations
                            Toggle(isOn: $viewModel.isAIEnabled) {
                                SettingsRow(
                                    icon: "wand.and.stars",
                                    title: "AI Recommendations",
                                    value: viewModel.isAIEnabled ? "Enabled" : "Disabled"
                                )
                            }
                            
                            // Live Scoring
                            Toggle(isOn: $viewModel.isLiveScoringEnabled) {
                                SettingsRow(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Live Scoring",
                                    value: viewModel.isLiveScoringEnabled ? "Enabled" : "Disabled"
                                )
                            }
                            
                            // Price Change Alerts
                            Toggle(isOn: $viewModel.isPriceAlertsEnabled) {
                                SettingsRow(
                                    icon: "bell.fill",
                                    title: "Price Change Alerts",
                                    value: viewModel.isPriceAlertsEnabled ? "Enabled" : "Disabled"
                                )
                            }
                        }
                        
                        // Display Section
                        Section("Display") {
                            // Theme
                            Picker("Theme", selection: $viewModel.selectedTheme) {
                                ForEach(ThemeOption.allCases, id: \.self) { theme in
                                    Text(theme.name).tag(theme)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            // Score Format
                            Picker("Score Format", selection: $viewModel.selectedScoreFormat) {
                                ForEach(ScoreFormat.allCases, id: \.self) { format in
                                    Text(format.name).tag(format)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // Privacy Section
                        Section("Privacy") {
                            // Analytics
                            Toggle(isOn: $viewModel.isAnalyticsEnabled) {
                                SettingsRow(
                                    icon: "chart.bar.fill",
                                    title: "Analytics",
                                    value: viewModel.isAnalyticsEnabled ? "Enabled" : "Disabled"
                                )
                            }
                            
                            // League Privacy
                            NavigationLink {
                                SettingsDetailView(
                                    title: "League Privacy",
                                    value: viewModel.leaguePrivacy.rawValue,
                                    options: LeaguePrivacy.allCases.map(\.rawValue),
                                    onSave: { viewModel.updateLeaguePrivacy(LeaguePrivacy(rawValue: $0) ?? .public) }
                                )
                            } label: {
                                SettingsRow(
                                    icon: "lock.fill",
                                    title: "League Privacy",
                                    value: viewModel.leaguePrivacy.rawValue
                                )
                            }
                        }
                        
                        // Data Management Section
                        Section("Data Management") {
                            // Cache Size
                            HStack {
                                SettingsRow(
                                    icon: "internaldrive.fill",
                                    title: "Cache Size",
                                    value: viewModel.cacheSize
                                )
                                
                                Spacer()
                                
                                Button("Clear") {
                                    viewModel.clearCache()
                                }
                                .foregroundColor(Theme.Colors.error)
                            }
                            
                            // Export Data
                            Button {
                                viewModel.exportData()
                            } label: {
                                SettingsRow(
                                    icon: "square.and.arrow.up.fill",
                                    title: "Export Data",
                                    value: ""
                                )
                            }
                        }
                        
                        // About Section
                        Section("About") {
                            // Version
                            SettingsRow(
                                icon: "info.circle.fill",
                                title: "Version",
                                value: viewModel.appVersion
                            )
                            
                            // Support
                            Button {
                                viewModel.openSupport()
                            } label: {
                                SettingsRow(
                                    icon: "questionmark.circle.fill",
                                    title: "Support",
                                    value: ""
                                )
                            }
                        }
                        
                        // Sign Out
                        Section {
                            Button {
                                viewModel.signOut()
                            } label: {
                                Text("Sign Out")
                                    .foregroundColor(Theme.Colors.error)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(Theme.Font.title3)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK") {}
            } message: {
                Text(viewModel.successMessage)
            }
            .onAppear {
                viewModel.loadSettings()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }
}

// MARK: - Supporting Views

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 28)
            
            // Title
            Text(title)
                .font(Theme.Font.body)
                .foregroundColor(Theme.Colors.textPrimary)
            
            if !value.isEmpty {
                Spacer()
                
                // Value
                Text(value)
                    .font(Theme.Font.body)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
}

struct SettingsDetailView: View {
    let title: String
    let value: String
    let placeholder: String
    let options: [String]?
    let onSave: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var editedValue: String
    
    init(
        title: String,
        value: String,
        placeholder: String = "",
        options: [String]? = nil,
        onSave: @escaping (String) -> Void
    ) {
        self.title = title
        self.value = value
        self.placeholder = placeholder
        self.options = options
        self.onSave = onSave
        _editedValue = State(initialValue: value)
    }
    
    var body: some View {
        List {
            if let options = options {
                // Picker for predefined options
                Picker(title, selection: $editedValue) {
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.inline)
            } else {
                // Text input for custom value
                TextField(placeholder, text: $editedValue)
                    .font(Theme.Font.body)
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, Theme.Spacing.xs)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave(editedValue)
                    dismiss()
                }
                .disabled(editedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}


// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

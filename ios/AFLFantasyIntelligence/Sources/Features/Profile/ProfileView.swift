import SwiftUI
import LocalAuthentication

// MARK: - ProfileView

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var teamManager: TeamManager
    
    @State private var showingBiometricSettings = false
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                if let user = authService.currentUser {
                    Section {
                        ProfileHeader(user: user)
                    }
                }
                
                // Teams Summary
                Section("Fantasy Teams") {
                    HStack {
                        Image(systemName: "person.2.badge.plus")
                            .foregroundColor(DS.Colors.primary)
                        
                        VStack(alignment: .leading) {
                            Text("My Teams")
                                .font(DS.Typography.body)
                            Text("\(teamManager.teams.count) teams")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }
                        
                        Spacer()
                        
                        if let activeTeam = teamManager.activeTeam {
                            VStack(alignment: .trailing) {
                                Text("Active Team")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                                Text(activeTeam.name)
                                    .font(DS.Typography.body)
                            }
                        }
                    }
                }
                
                // Security Settings
                Section("Security") {
                    // Biometric Authentication
                    if authService.biometricType != .none {
                        HStack {
                            Image(systemName: biometricIcon)
                                .foregroundColor(DS.Colors.primary)
                            
                            VStack(alignment: .leading) {
                                Text(biometricText)
                                    .font(DS.Typography.body)
                                Text(authService.isBiometricEnabled ? "Enabled" : "Disabled")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: biometricToggleBinding)
                                .labelsHidden()
                        }
                    }
                }
                
                // App Settings
                Section("Settings") {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(DS.Colors.primary)
                        
                        Text("Notifications")
                            .font(DS.Typography.body)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                    
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(DS.Colors.primary)
                        
                        Text("Appearance")
                            .font(DS.Typography.body)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                    
                    // API Endpoint setting
                    APIEndpointSettingRow()
                }
                
                // Support
                Section("Support") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(DS.Colors.primary)
                        
                        Text("Help & Support")
                            .font(DS.Typography.body)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                    
                    HStack {
                        Image(systemName: "star")
                            .foregroundColor(DS.Colors.primary)
                        
                        Text("Rate App")
                            .font(DS.Typography.body)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
                
                // Logout Section
                Section {
                    Button {
                        showingLogoutConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            
                            Text("Sign Out")
                                .font(DS.Typography.body)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .dsFloatingTabBarPadding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .confirmationDialog("Sign Out", isPresented: $showingLogoutConfirmation) {
            Button("Sign Out", role: .destructive) {
                authService.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    // MARK: - Computed Properties
    
    private var biometricIcon: String {
        switch authService.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
        }
    }
    
    private var biometricText: String {
        switch authService.biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometrics"
        }
    }
    
    private var biometricToggleBinding: Binding<Bool> {
        Binding(
            get: { authService.isBiometricEnabled },
            set: { isEnabled in
                if isEnabled {
                    Task {
                        await authService.enableBiometricAuth()
                    }
                } else {
                    authService.disableBiometricAuth()
                }
            }
        )
    }
}

// MARK: - ProfileHeader

struct ProfileHeader: View {
    let user: User
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            // Profile Image
            Circle()
                .fill(DS.Colors.primary.gradient)
                .frame(width: 60, height: 60)
                .overlay {
                    Text(String(user.name.prefix(1)).uppercased())
                        .font(DS.Typography.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            
            // User Info
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(user.name)
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text(user.email)
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                
                Text("Member since \(formattedDate(user.createdAt))")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, DS.Spacing.s)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationService())
            .environmentObject(TeamManager.mock)
    }
}
#endif

// MARK: - APIEndpointSettingRow

struct APIEndpointSettingRow: View {
    @EnvironmentObject var apiService: APIService
    @StateObject private var prefs = UserPreferencesService.shared
    @State private var urlString: String = ""
    @State private var saved: Bool = false
    @State private var reconnecting: Bool = false
    @State private var reconnectResult: Bool? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack(alignment: .center, spacing: DS.Spacing.m) {
                Image(systemName: "network")
                    .foregroundColor(DS.Colors.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("API Endpoint")
                        .font(DS.Typography.body)
                    Text("Base URL for the backend API")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: DS.Spacing.s) {
                TextField("http://localhost:8080", text: $urlString)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
                    .font(DS.Typography.body)
                    .padding(8)
                    .background(DS.Colors.surfaceSecondary)
                    .cornerRadius(8)
                
                Button("Save") {
                    saveURL()
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    Task {
                        await reconnect()
                    }
                } label: {
                    if reconnecting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Apply & Reconnect")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(reconnecting)
            }
            
            if let result = reconnectResult {
                HStack(spacing: DS.Spacing.s) {
                    Image(systemName: result ? "checkmark.circle" : "xmark.circle")
                        .foregroundColor(result ? DS.Colors.success : DS.Colors.error)
                    Text(result ? "Connected to new endpoint." : "Failed to connect. Check URL.")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
            } else if saved {
                Text("Saved. Will apply on next launch.")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
            }
        }
        .onAppear {
            urlString = prefs.apiBaseURL
        }
    }
    
    private func saveURL() {
        // Basic validation
        if URL(string: urlString) != nil {
            prefs.apiBaseURL = urlString
            saved = true
        }
    }
    
    private func reconnect() async {
        guard URL(string: urlString) != nil else { return }
        reconnecting = true
        reconnectResult = nil
        let ok = await apiService.switchEndpoint(urlString)
        reconnectResult = ok
        reconnecting = false
    }
}

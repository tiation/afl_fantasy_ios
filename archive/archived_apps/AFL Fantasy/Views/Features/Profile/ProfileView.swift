import SwiftUI
import PhotosUI

// MARK: - ProfileView

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var avatarLoader = AvatarLoader.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditProfile = false
    @State private var showingImagePicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with avatar and basic info
                    profileHeader
                    
                    // Quick stats cards
                    quickStatsSection
                    
                    // Profile sections
                    personalInfoSection
                    
                    preferencesSection
                    
                    Spacer(minLength: 32)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { _, newPhoto in
                if let newPhoto = newPhoto {
                    Task {
                        await viewModel.updateAvatar(from: newPhoto)
                    }
                }
            }
            .onAppear {
                viewModel.loadProfile()
            }
        }
    }
    
    // MARK: - Profile Header
    
    @ViewBuilder
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            Button {
                showingImagePicker = true
            } label: {
                ZStack {
                    if let avatarImage = avatarLoader.currentAvatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(uiImage: avatarLoader.getPlaceholderImage(for: viewModel.userInitials))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    }
                    
                    // Edit overlay
                    Circle()
                        .fill(.black.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                }
            }
            .accessibilityLabel("Change profile photo")
            
            VStack(spacing: 8) {
                Text(viewModel.username)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let bio = viewModel.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                if let favoriteTeam = viewModel.favoriteTeam {
                    teamBadge(for: favoriteTeam)
                }
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private func teamBadge(for team: AFLTeam) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: team.primaryColor) ?? .blue)
                .frame(width: 12, height: 12)
            
            Text(team.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.quaternary, in: Capsule())
    }
    
    // MARK: - Quick Stats Section
    
    @ViewBuilder
    private var quickStatsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                icon: "calendar",
                title: "Member Since",
                value: "2024",
                color: .blue
            )
            
            StatCard(
                icon: "trophy.fill",
                title: "Best Rank",
                value: "#1,234",
                color: .orange
            )
            
            StatCard(
                icon: "star.fill",
                title: "Total Points",
                value: "2,456",
                color: .green
            )
        }
    }
    
    // MARK: - Personal Info Section
    
    @ViewBuilder
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Personal Information", icon: "person.fill")
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "person",
                    title: "Username",
                    value: viewModel.username
                )
                
                InfoRow(
                    icon: "envelope",
                    title: "Email",
                    value: "user@example.com"
                )
                
                InfoRow(
                    icon: "flag.fill",
                    title: "Team Name",
                    value: "My AFL Team"
                )
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Preferences Section
    
    @ViewBuilder
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Preferences", icon: "gearshape.fill")
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "paintbrush.fill",
                    title: "Theme",
                    value: viewModel.themePreference?.style.displayName ?? "System"
                )
                
                InfoRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    value: viewModel.notificationCount
                )
                
                if let aiSettings = viewModel.aiSettings {
                    InfoRow(
                        icon: "brain.head.profile",
                        title: "AI Risk Level",
                        value: aiSettings.riskTolerance.displayName
                    )
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ProfileViewModel

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var username = ""
    @Published var bio: String?
    @Published var favoriteTeam: AFLTeam?
    @Published var themePreference: ThemePreference?
    @Published var notificationPrefs: DetailedNotificationPreferences?
    @Published var aiSettings: AIPersonalizationSettings?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let userService: UserServiceProtocol
    private let keychainManager = KeychainManager()
    
    // MARK: - Computed Properties
    
    var userInitials: String {
        let components = username.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1))
        } else {
            return String(username.prefix(2))
        }
    }
    
    var notificationCount: String {
        guard let prefs = notificationPrefs else { return "Default" }
        
        let enabledCount = [
            prefs.priceAlerts,
            prefs.injuryNews,
            prefs.tradeDeadlines,
            prefs.captainReminders,
            prefs.teamNews,
            prefs.milestones,
            prefs.weeklyReports,
            prefs.aiRecommendations
        ].filter { $0 }.count
        
        return "\(enabledCount) of 8 enabled"
    }
    
    // MARK: - Init
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    // MARK: - Public Methods
    
    func loadProfile() {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }
                
                let profile = try await userService.getEnhancedProfile()
                
                username = profile.username
                bio = profile.bio
                favoriteTeam = profile.favoriteTeam
                themePreference = profile.themePreference
                notificationPrefs = profile.notificationPrefs
                aiSettings = keychainManager.getAIPersonalizationSettings()
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func updateAvatar(from photoItem: PhotosPickerItem) async {
        guard let data = try? await photoItem.loadTransferable(type: Data.self) else {
            handleError(ProfileError.avatarLoadFailed)
            return
        }
        
        do {
            _ = try await userService.uploadAvatar(data: data)
        } catch {
            handleError(error)
        }
    }
    
    func updateUsername(_ newUsername: String) async {
        do {
            try await userService.updateUsername(newUsername)
            username = newUsername
        } catch {
            handleError(error)
        }
    }
    
    func updateBio(_ newBio: String) async {
        do {
            try await userService.updateBio(newBio)
            bio = newBio
        } catch {
            handleError(error)
        }
    }
    
    func updateFavoriteTeam(_ team: AFLTeam) async {
        do {
            try await userService.updateFavoriteTeam(team.id)
            favoriteTeam = team
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - ProfileError

enum ProfileError: LocalizedError {
    case avatarLoadFailed
    
    var errorDescription: String? {
        switch self {
        case .avatarLoadFailed:
            return "Failed to load avatar image"
        }
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

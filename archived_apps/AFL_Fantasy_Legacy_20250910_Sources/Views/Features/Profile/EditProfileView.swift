import SwiftUI

// MARK: - EditProfileView

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedUsername = ""
    @State private var editedBio = ""
    @State private var selectedTeam: AFLTeam?
    @State private var selectedTheme: ThemePreference.ThemeStyle = .system
    @State private var useTeamColors = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                // Personal Information Section
                Section {
                    TextField("Username", text: $editedUsername)
                        .textInputAutocapitalization(.words)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $editedBio)
                            .frame(minHeight: 80)
                        
                        if editedBio.isEmpty {
                            Text("Tell us about yourself...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
                } header: {
                    Text("Personal Information")
                }
                
                // Favorite Team Section
                Section {
                    TeamSelectionView(selectedTeam: $selectedTeam)
                } header: {
                    Text("Favorite Team")
                } footer: {
                    Text("Your favorite team affects AI recommendations and theme colors when enabled.")
                }
                
                // Theme Section
                Section {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(ThemePreference.ThemeStyle.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Use team colors", isOn: $useTeamColors)
                        .disabled(selectedTeam == nil)
                    
                    if useTeamColors && selectedTeam != nil {
                        HStack {
                            Text("Preview")
                            Spacer()
                            teamColorPreview
                        }
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Team colors will be used for accent colors throughout the app when enabled.")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadCurrentValues()
            }
            .disabled(isLoading)
        }
    }
    
    @ViewBuilder
    private var teamColorPreview: some View {
        HStack(spacing: 8) {
            if let team = selectedTeam {
                Circle()
                    .fill(Color(hex: team.primaryColor) ?? .blue)
                    .frame(width: 16, height: 16)
                
                Circle()
                    .fill(Color(hex: team.secondaryColor) ?? .gray)
                    .frame(width: 16, height: 16)
            }
        }
    }
    
    private func loadCurrentValues() {
        editedUsername = viewModel.username
        editedBio = viewModel.bio ?? ""
        selectedTeam = viewModel.favoriteTeam
        selectedTheme = viewModel.themePreference?.style ?? .system
        useTeamColors = viewModel.themePreference?.useTeamColors ?? false
    }
    
    private func saveChanges() {
        isLoading = true
        
        Task {
            do {
                // Save username if changed
                if editedUsername != viewModel.username {
                    await viewModel.updateUsername(editedUsername)
                }
                
                // Save bio if changed
                if editedBio != (viewModel.bio ?? "") {
                    await viewModel.updateBio(editedBio)
                }
                
                // Save favorite team if changed
                if selectedTeam != viewModel.favoriteTeam, let team = selectedTeam {
                    await viewModel.updateFavoriteTeam(team)
                }
                
                // Save theme preference if changed
                let newThemePreference = ThemePreference(
                    style: selectedTheme,
                    useTeamColors: useTeamColors,
                    accentColor: useTeamColors ? selectedTeam?.primaryColor : nil
                )
                
                if newThemePreference.style != viewModel.themePreference?.style ||
                   newThemePreference.useTeamColors != viewModel.themePreference?.useTeamColors {
                    try await UserService().updateThemePreference(newThemePreference)
                    viewModel.themePreference = newThemePreference
                }
                
                isLoading = false
                dismiss()
                
            } catch {
                isLoading = false
                viewModel.errorMessage = error.localizedDescription
                viewModel.showError = true
            }
        }
    }
}

// MARK: - TeamSelectionView

struct TeamSelectionView: View {
    @Binding var selectedTeam: AFLTeam?
    
    private let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(AFLTeam.allTeams) { team in
                TeamSelectionCard(
                    team: team,
                    isSelected: selectedTeam?.id == team.id
                ) {
                    selectedTeam = team
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct TeamSelectionCard: View {
    let team: AFLTeam
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Team colors
            HStack(spacing: 4) {
                Rectangle()
                    .fill(Color(hex: team.primaryColor) ?? .blue)
                    .frame(height: 6)
                
                Rectangle()
                    .fill(Color(hex: team.secondaryColor) ?? .gray)
                    .frame(height: 6)
            }
            .frame(width: 60)
            .cornerRadius(3)
            
            Text(team.shortName)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isSelected ? Color.accentColor : Color.clear,
                    lineWidth: 2
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(viewModel: ProfileViewModel())
    }
}

import SwiftUI

// MARK: - ActiveTeamCard

struct ActiveTeamCard: View {
    let team: FantasyTeam
    let teamManager: TeamManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Active Team")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                    
                    Text(team.name)
                        .font(DS.Typography.largeTitle)
                        .foregroundColor(DS.Colors.onSurface)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                    Text("\(team.league)")
                        .font(DS.Typography.caption)
                        .padding(.horizontal, DS.Spacing.s)
                        .padding(.vertical, DS.Spacing.xs)
                        .background(DS.Colors.primary.opacity(0.1))
                        .foregroundColor(DS.Colors.primary)
                        .cornerRadius(8)
                    
                    if let rank = team.rank {
                        Text("Rank: #\(rank)")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
            }
            
            if let points = team.points {
                HStack {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Total Points")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                        
                        Text("\(points)")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                        Text("Players")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                        
                        Text("\(team.players.count)")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                    }
                }
            }
        }
        .padding(DS.Spacing.l)
        .background(DS.Colors.surface)
        .cornerRadius(DS.CornerRadius.large)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - AddTeamSection

struct AddTeamSection: View {
    let onScanTapped: () -> Void
    let onManualTapped: () -> Void
    
    var body: some View {
        VStack(spacing: DS.Spacing.m) {
            Text("Add New Team")
                .font(DS.Typography.headline)
                .foregroundColor(DS.Colors.onSurface)
            
            HStack(spacing: DS.Spacing.m) {
                // Scan Barcode Button
                Button(action: onScanTapped) {
                    VStack(spacing: DS.Spacing.s) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.largeTitle)
                            .foregroundColor(DS.Colors.primary)
                        
                        Text("Scan Code")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        Text("Use camera to scan team barcode or QR code")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(DS.Spacing.l)
                    .background(DS.Colors.surface)
                    .cornerRadius(DS.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                            .stroke(DS.Colors.primary, lineWidth: 1)
                    )
                }
                
                // Manual Entry Button
                Button(action: onManualTapped) {
                    VStack(spacing: DS.Spacing.s) {
                        Image(systemName: "keyboard")
                            .font(.largeTitle)
                            .foregroundColor(DS.Colors.secondary)
                        
                        Text("Enter Manually")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        Text("Type team code and details manually")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(DS.Spacing.l)
                    .background(DS.Colors.surface)
                    .cornerRadius(DS.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                            .stroke(DS.Colors.outline, lineWidth: 1)
                    )
                }
            }
        }
        .padding(DS.Spacing.m)
        .background(DS.Colors.background)
        .cornerRadius(DS.CornerRadius.large)
    }
}

// MARK: - TeamsListSection

struct TeamsListSection: View {
    let teams: [FantasyTeam]
    let activeTeam: FantasyTeam?
    let onTeamTapped: (FantasyTeam) -> Void
    let onActiveTeamChanged: (FantasyTeam) -> Void
    let onTeamDeleted: (FantasyTeam) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("All Teams (\(teams.count))")
                .font(DS.Typography.headline)
                .foregroundColor(DS.Colors.onSurface)
            
            LazyVStack(spacing: DS.Spacing.s) {
                ForEach(teams) { team in
                    TeamRowView(
                        team: team,
                        isActive: team.id == activeTeam?.id,
                        onTapped: { onTeamTapped(team) },
                        onSetActive: { onActiveTeamChanged(team) },
                        onDelete: { onTeamDeleted(team) }
                    )
                }
            }
        }
    }
}

// MARK: - TeamRowView

struct TeamRowView: View {
    let team: FantasyTeam
    let isActive: Bool
    let onTapped: () -> Void
    let onSetActive: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Button(action: onTapped) {
            HStack(spacing: DS.Spacing.m) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    HStack {
                        Text(team.name)
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        if isActive {
                            Text("ACTIVE")
                                .font(DS.Typography.caption)
                                .padding(.horizontal, DS.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(DS.Colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("Code: \(team.code) • \(team.league)")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                    
                    if let rank = team.rank, let points = team.points {
                        Text("Rank: #\(rank) • \(points) pts")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
                
                Spacer()
                
                Menu {
                    if !isActive {
                        Button("Set as Active") {
                            onSetActive()
                        }
                    }
                    
                    Button("Delete", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                        .padding(DS.Spacing.s)
                }
            }
            .padding(DS.Spacing.m)
            .background(DS.Colors.surface)
            .cornerRadius(DS.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("Delete Team", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete \"\(team.name)\"? This action cannot be undone.")
        }
    }
}

// MARK: - AddTeamManuallyView

struct AddTeamManuallyView: View {
    let onTeamAdded: (String, String, String) -> Void
    
    @State private var teamName = ""
    @State private var teamCode = ""
    @State private var selectedLeague = "Classic"
    @Environment(\.presentationMode) var presentationMode
    
    private let leagues = ["Classic", "Draft", "H2H"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Team Details") {
                    TextField("Team Name", text: $teamName)
                    TextField("Team Code", text: $teamCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }
                
                Section("League") {
                    Picker("League Type", selection: $selectedLeague) {
                        ForEach(leagues, id: \.self) { league in
                            Text(league).tag(league)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Add Team") {
                        onTeamAdded(teamName, teamCode, selectedLeague)
                    }
                    .disabled(teamName.isEmpty || teamCode.isEmpty)
                }
            }
            .navigationTitle("Add Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - TeamDetailsView

struct TeamDetailsView: View {
    let team: FantasyTeam
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    // Team Info
                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        Text(team.name)
                            .font(DS.Typography.largeTitle)
                        
                        Text("Code: \(team.code)")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                        
                        Text("League: \(team.league)")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                    
                    // Stats
                    if let rank = team.rank, let points = team.points {
                        VStack(alignment: .leading, spacing: DS.Spacing.s) {
                            Text("Statistics")
                                .font(DS.Typography.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Rank")
                                        .font(DS.Typography.caption)
                                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                                    Text("#\(rank)")
                                        .font(DS.Typography.title2)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Points")
                                        .font(DS.Typography.caption)
                                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                                    Text("\(points)")
                                        .font(DS.Typography.title2)
                                }
                            }
                        }
                        .padding(DS.Spacing.m)
                        .background(DS.Colors.surface)
                        .cornerRadius(DS.CornerRadius.medium)
                    }
                    
                    // Players
                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        Text("Players (\(team.players.count))")
                            .font(DS.Typography.headline)
                        
                        Text("Player management coming soon...")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                            .italic()
                    }
                    .padding(DS.Spacing.m)
                    .background(DS.Colors.surface)
                    .cornerRadius(DS.CornerRadius.medium)
                }
                .padding(DS.Spacing.m)
            }
            .navigationTitle("Team Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

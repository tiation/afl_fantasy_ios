import SwiftUI

// MARK: - TeamsView

struct TeamsView: View {
    @StateObject private var teamManager = TeamManager()
    @State private var showingScanner = false
    @State private var showingAddTeam = false
    @State private var showingTeamDetails: FantasyTeam?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.l) {
                    // Active Team Section
                    if let activeTeam = teamManager.activeTeam {
                        ActiveTeamCard(team: activeTeam, teamManager: teamManager)
                    }
                    
                    // Add Team Section
                    AddTeamSection(
                        onScanTapped: { showingScanner = true },
                        onManualTapped: { showingAddTeam = true }
                    )
                    
                    // All Teams Section
                    if !teamManager.teams.isEmpty {
                        TeamsListSection(
                            teams: teamManager.teams,
                            activeTeam: teamManager.activeTeam,
                            onTeamTapped: { team in
                                showingTeamDetails = team
                            },
                            onActiveTeamChanged: { team in
                                teamManager.setActiveTeam(team)
                            },
                            onTeamDeleted: { team in
                                teamManager.removeTeam(team)
                            }
                        )
                    }
                    
                    // Loading State
                    if teamManager.isLoading {
                        ProgressView("Loading...")
                            .padding(DS.Spacing.xl)
                    }
                }
                .padding(DS.Spacing.m)
                .dsFloatingTabBarPadding()
            }
            .navigationTitle("My Teams")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingScanner = true }) {
                            Label("Scan Barcode", systemImage: "qrcode.viewfinder")
                        }
                        
                        Button(action: { showingAddTeam = true }) {
                            Label("Add Manually", systemImage: "plus")
                        }
                        
                        Button(action: {
                            Task {
                                await teamManager.refreshTeams()
                            }
                        }) {
                            Label("Refresh Teams", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .refreshable {
                await teamManager.refreshTeams()
            }
            .alert("Team Error", isPresented: .constant(teamManager.error != nil)) {
                Button("OK") {
                    teamManager.error = nil
                }
            } message: {
                if let error = teamManager.error {
                    Text(error.localizedDescription)
                }
            }
        }
        .fullScreenCover(isPresented: $showingScanner) {
            BarcodeScannerView { code, type in
                showingScanner = false
                Task {
                    await teamManager.addTeam(code: code, barcodeType: type.rawValue)
                }
            }
        }
        .sheet(isPresented: $showingAddTeam) {
            AddTeamManuallyView { name, code, league in
                teamManager.addTeam(name: name, code: code, league: league)
                showingAddTeam = false
            }
        }
        .sheet(item: $showingTeamDetails) { team in
            TeamDetailsView(team: team)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}
#endif

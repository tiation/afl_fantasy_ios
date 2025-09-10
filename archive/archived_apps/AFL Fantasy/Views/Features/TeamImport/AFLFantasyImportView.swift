import SwiftUI

// MARK: - AFL Fantasy Team Import View

struct AFLFantasyImportView: View {
    @StateObject private var viewModel = AFLFantasyImportViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Main content based on state
                        switch viewModel.importState {
                        case .initial:
                            credentialInputSection
                        case .importing:
                            importingProgressSection
                        case .success:
                            successSection
                        case .error:
                            errorSection
                        }
                        
                        Spacer(minLength: 32)
                    }
                    .padding()
                }
            }
            .navigationTitle("Import Your Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.importState == .success {
                        Button("Done") {
                            dismiss()
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Import Error", isPresented: $viewModel.showError) {
                Button("Try Again") {
                    viewModel.resetToInitial()
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - Header Section
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            // AFL Fantasy logo/icon
            Image(systemName: "sportscourt.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("Connect Your AFL Fantasy Team")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Import your actual roster, players, scores, and rankings from the official AFL Fantasy website")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Credential Input Section
    
    @ViewBuilder
    private var credentialInputSection: some View {
        VStack(spacing: 20) {
            // Credential form
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AFL Fantasy Email")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your AFL Fantasy email", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("AFL Fantasy Password")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    SecureField("Enter your password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Security notice
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                    Text("Your credentials are encrypted and stored securely on your device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.blue)
                    Text("Credentials never leave your device - all scraping happens locally")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "trash.slash.fill")
                        .foregroundColor(.orange)
                    Text("You can delete stored credentials anytime in Settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            
            // Import button
            Button {
                viewModel.startImport()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.title3)
                    
                    Text("Import My AFL Fantasy Team")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty)
            
            // Help text
            Text("Can't find your credentials? Check the AFL Fantasy app or website settings.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Importing Progress Section
    
    @ViewBuilder
    private var importingProgressSection: some View {
        VStack(spacing: 24) {
            // Progress indicator
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text(viewModel.progressMessage)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.progressDetail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Progress steps
            VStack(spacing: 12) {
                ForEach(ImportStep.allCases, id: \.self) { step in
                    ImportStepRow(
                        step: step,
                        isCompleted: viewModel.completedSteps.contains(step),
                        isCurrent: viewModel.currentStep == step
                    )
                }
            }
            .padding()
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Success Section
    
    @ViewBuilder
    private var successSection: some View {
        VStack(spacing: 24) {
            // Success header
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Team Imported Successfully!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Your AFL Fantasy team is now connected and ready to use")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Team summary
            if let teamData = viewModel.importedTeamData {
                VStack(spacing: 16) {
                    Text("Team Summary")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        TeamSummaryCard(
                            title: "Players",
                            value: "\(teamData.totalPlayers)",
                            icon: "person.3.fill",
                            color: .blue
                        )
                        
                        TeamSummaryCard(
                            title: "Team Value",
                            value: "$\(teamData.teamValue / 1000)K",
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )
                        
                        TeamSummaryCard(
                            title: "Current Score",
                            value: "\(teamData.currentScore)",
                            icon: "chart.bar.fill",
                            color: .orange
                        )
                        
                        TeamSummaryCard(
                            title: "Rank",
                            value: "#\(teamData.overallRank)",
                            icon: "trophy.fill",
                            color: .purple
                        )
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Next steps
            VStack(spacing: 12) {
                Text("What's Next?")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    NextStepRow(
                        icon: "wand.and.stars",
                        title: "Get AI Recommendations",
                        description: "Personalized trade and captain suggestions"
                    )
                    
                    NextStepRow(
                        icon: "bell.fill",
                        title: "Enable Notifications",
                        description: "Price changes, injury news, and more"
                    )
                    
                    NextStepRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Auto-Sync",
                        description: "Keep your team data updated automatically"
                    )
                }
            }
            .padding()
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            
            // Sync options
            HStack(spacing: 16) {
                Button {
                    viewModel.enableAutoSync()
                } label: {
                    Text("Enable Auto-Sync")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
                
                Button {
                    viewModel.refreshTeamData()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Now")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
    
    // MARK: - Error Section
    
    @ViewBuilder
    private var errorSection: some View {
        VStack(spacing: 24) {
            // Error header
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Import Failed")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(viewModel.errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Common solutions
            VStack(spacing: 12) {
                Text("Try These Solutions:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    SolutionRow(
                        icon: "key.fill",
                        title: "Double-check your credentials",
                        description: "Make sure email and password are correct"
                    )
                    
                    SolutionRow(
                        icon: "wifi",
                        title: "Check your internet connection",
                        description: "Ensure you have a stable connection"
                    )
                    
                    SolutionRow(
                        icon: "globe",
                        title: "Try the AFL Fantasy website",
                        description: "Make sure you can log in at fantasy.afl.com.au"
                    )
                    
                    SolutionRow(
                        icon: "clock.fill",
                        title: "Wait and try again",
                        description: "AFL Fantasy servers might be temporarily down"
                    )
                }
            }
            .padding()
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            
            // Action buttons
            VStack(spacing: 12) {
                Button {
                    viewModel.resetToInitial()
                } label: {
                    Text("Try Again")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    viewModel.openSupportEmail()
                } label: {
                    Text("Contact Support")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct TeamSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ImportStepRow: View {
    let step: ImportStep
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCompleted ? .green : (isCurrent ? .blue : .secondary))
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else if isCurrent {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isCurrent ? .primary : .secondary)
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct NextStepRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SolutionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

struct AFLFantasyImportView_Previews: PreviewProvider {
    static var previews: some View {
        AFLFantasyImportView()
    }
}

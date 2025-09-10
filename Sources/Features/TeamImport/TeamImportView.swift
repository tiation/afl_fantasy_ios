//
//  TeamImportView.swift
//
//  A simplified team import view with username/password input and a QR option to scan AFL Fantasy team URL.
//  Now connected to the real AFL Fantasy API.

import SwiftUI

@available(iOS 16.0, *)
struct TeamImportView: View {
    @StateObject private var viewModel = TeamImportViewModel()
    @State private var showingQRScanner = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("AFL Fantasy Credentials")) {
                    TextField("Email", text: $viewModel.username)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $viewModel.password)
                }

                Section {
                    Button {
                        viewModel.startImport()
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text("Import My Team")
                        }
                    }
                    .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                }

                Section(header: Text("Or")) {
                    Button {
                        showingQRScanner = true
                    } label: {
                        Label("Scan QR Code for Team URL", systemImage: "qrcode.viewfinder")
                    }
                    .disabled(viewModel.isLoading)
                    .sheet(isPresented: $showingQRScanner) {
                        QRScannerView { content in
                            viewModel.processQRCode(content)
                        }
                    }

                    if let scannedTeamId = viewModel.scannedTeamId {
                        HStack {
                            Text("Detected Team ID")
                            Spacer()
                            Text(scannedTeamId)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if let summary = viewModel.teamSummary {
                    Section(header: Text("Team Summary")) {
                        HStack { Text("Players"); Spacer(); Text("\(summary.totalPlayers)") }
                        HStack { Text("Team Value"); Spacer(); Text("$\(summary.teamValue / 1000)K") }
                        HStack { Text("Current Score"); Spacer(); Text("\(summary.currentScore)") }
                        HStack { Text("Rank"); Spacer(); Text("#\(summary.overallRank)") }
                        HStack {
                            Text("Last Updated")
                            Spacer()
                            Text(summary.lastUpdated, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let health = viewModel.apiHealth {
                    Section(header: Text("API Status")) {
                        HStack {
                            Text("Status")
                            Spacer()
                            Text(health.status)
                                .foregroundColor(health.status == "healthy" ? .green : .red)
                        }
                        HStack {
                            Text("Players Cached")
                            Spacer()
                            Text("\(health.playersCache ?? 0)")
                                .foregroundColor(.secondary)
                        }
                        
                        Button {
                            viewModel.checkAPIHealth()
                        } label: {
                            Label("Refresh API Status", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
            .navigationTitle("Import Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Import Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                viewModel.checkAPIHealth()
            }
        }
    }
}

@available(iOS 16.0, *)
@MainActor
final class TeamImportViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    @Published var scannedTeamId: String?
    @Published var teamSummary: ImportedTeamData?
    @Published var apiHealth: APIHealthResponse?

    private let keychainManager = KeychainManager()
    private let apiClient = AFLFantasyAPIClient.shared
    
    init() {
        // Pre-populate with stored credentials if they exist
        if let storedUsername = keychainManager.getAFLUsername() {
            username = storedUsername
        }
    }

    func startImport() {
        guard !username.isEmpty && !password.isEmpty else { return }
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                // Store credentials
                keychainManager.storeAFLUsername(username)
                keychainManager.storeAFLPassword(password)
                
                // Import team from API
                let importedData = try await apiClient.importTeam(username: username, password: password)
                self.teamSummary = importedData
                
            } catch {
                if let aflError = error as? AFLFantasyError {
                    self.errorMessage = aflError.errorDescription ?? "Unknown error occurred"
                } else {
                    self.errorMessage = error.localizedDescription
                }
                self.showError = true
            }
        }
    }

    func processQRCode(_ content: String) {
        if let teamId = extractTeamId(from: content) {
            scannedTeamId = teamId
            keychainManager.storeAFLTeamId(teamId)
            
            // Import team by URL
            isLoading = true
            Task {
                defer { isLoading = false }
                
                do {
                    let importedData = try await apiClient.importTeamByUrl(content)
                    self.teamSummary = importedData
                } catch {
                    if let aflError = error as? AFLFantasyError {
                        self.errorMessage = aflError.errorDescription ?? "Unknown error occurred"
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    self.showError = true
                }
            }
        } else {
            errorMessage = "Could not extract team ID from scanned QR code."
            showError = true
        }
    }
    
    func checkAPIHealth() {
        Task {
            do {
                let health = try await apiClient.healthCheck()
                self.apiHealth = health
            } catch {
                print("Failed to check API health: \(error)")
                // Don't show error for health check, just log it
            }
        }
    }

    private func extractTeamId(from content: String) -> String? {
        if content.allSatisfy({ $0.isNumber }) { return content }
        let patterns = [
            #"fantasy\.afl\.com\.au/team/(\d+)"#,
            #"/team/(\d+)"#
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: content.utf16.count)
                if let match = regex.firstMatch(in: content, options: [], range: range), match.numberOfRanges > 1,
                   let swiftRange = Range(match.range(at: 1), in: content) {
                    return String(content[swiftRange])
                }
            }
        }
        return nil
    }
}

#Preview {
    TeamImportView()
}

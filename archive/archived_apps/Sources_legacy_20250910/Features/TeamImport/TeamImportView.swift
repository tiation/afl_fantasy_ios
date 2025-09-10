//
//  TeamImportView.swift
//
//  A simplified team import view with username/password input and a QR option to scan AFL Fantasy team URL.
//

import SwiftUI

struct TeamImportView: View {
    @StateObject private var viewModel = TeamImportViewModel()
    @State private var showingQRScanner = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("AFL Fantasy Credentials")) {
                    TextField("Email", text: $viewModel.username)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $viewModel.password)
                }

                Section {
                    Button {
                        viewModel.startImport()
                    } label: {
                        HStack {
                            if viewModel.isLoading { ProgressView() }
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
                    }
                }
            }
            .navigationTitle("Import Team")
            .alert("Import Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

final class TeamImportViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    @Published var scannedTeamId: String?
    @Published var teamSummary: ImportedTeamData?

    private let keychainManager = KeychainManager()

    func startImport() {
        guard !username.isEmpty && !password.isEmpty else { return }
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            // Store credentials
            keychainManager.storeAFLUsername(username)
            keychainManager.storeAFLPassword(password)
            // TODO: Integrate real import logic; for now set mock
            self.teamSummary = ImportedTeamData()
        }
    }

    func processQRCode(_ content: String) {
        if let teamId = extractTeamId(from: content) {
            scannedTeamId = teamId
            keychainManager.storeAFLTeamId(teamId)
        } else {
            errorMessage = "Could not extract team ID from scanned QR code."
            showError = true
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


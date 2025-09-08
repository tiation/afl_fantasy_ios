//
//  LoginView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - LoginView

struct LoginView: View {
    // MARK: - Environment

    @EnvironmentObject private var dataService: AFLFantasyDataService
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var teamId: String = ""
    @State private var sessionCookie: String = ""
    @State private var apiToken: String = ""
    @State private var showingHelp: Bool = false
    @State private var showingError: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    credentialsForm
                    actionButtons
                    helpSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK") {
                dataService.clearError()
            }
        } message: {
            Text(dataService.errorMessage ?? "Unknown error occurred")
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "sportscourt.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Text("AFL Fantasy Intelligence")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Sign in with your AFL Fantasy credentials to access advanced analytics and insights")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Credentials Form

    private var credentialsForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Team ID")
                    .font(.headline)

                TextField("Enter your AFL Fantasy Team ID", text: $teamId)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                Text("Found in your AFL Fantasy team URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Session Cookie")
                    .font(.headline)

                TextField("Enter your session cookie", text: $sessionCookie, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2 ... 4)

                Text("Obtained from browser developer tools")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("API Token (Optional)")
                    .font(.headline)

                TextField("Enter API token if available", text: $apiToken, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2 ... 4)

                Text("Additional authentication if required")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: authenticateUser) {
                HStack {
                    if dataService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }

                    Text(dataService.isLoading ? "Signing In..." : "Sign In")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(dataService.isLoading || !isFormValid)

            Button("Need Help?") {
                showingHelp = true
            }
            .foregroundColor(.accentColor)
        }
    }

    // MARK: - Help Section

    private var helpSection: some View {
        VStack(spacing: 12) {
            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Security Note")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(
                    "Your credentials are stored securely in your device's keychain and never shared with third parties."
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !teamId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !sessionCookie.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    private func authenticateUser() {
        let cleanTeamId = teamId.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSessionCookie = sessionCookie.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanApiToken = apiToken.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            let result = await dataService.authenticate(
                teamId: cleanTeamId,
                sessionCookie: cleanSessionCookie,
                apiToken: cleanApiToken.isEmpty ? nil : cleanApiToken
            )

            switch result {
            case .success:
                dismiss()
            case .failure:
                showingError = true
            }
        }
    }
}

// MARK: - HelpView

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    helpSection(
                        title: "Finding Your Team ID",
                        content: "1. Log into AFL Fantasy on your browser\n2. Go to your team page\n3. Look at the URL - your Team ID is the number at the end\n4. Example: fantasy.afl.com.au/classic/team/123456"
                    )

                    helpSection(
                        title: "Getting Your Session Cookie",
                        content: "1. Open AFL Fantasy in your browser and log in\n2. Press F12 (or Cmd+Option+I on Mac) to open Developer Tools\n3. Go to the 'Application' or 'Storage' tab\n4. Find 'Cookies' in the sidebar\n5. Look for session-related cookies\n6. Copy the entire cookie value"
                    )

                    helpSection(
                        title: "API Token (Optional)",
                        content: "This is typically not required for basic functionality. Only provide if you have been given a specific API token for enhanced access."
                    )

                    securitySection
                }
                .padding()
            }
            .navigationTitle("How to Sign In")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func helpSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Your Privacy Matters", systemImage: "lock.shield.fill")
                .font(.headline)
                .foregroundColor(.green)

            Text(
                "• Your credentials are encrypted and stored only on your device\n• We never transmit your credentials to our servers\n• All data requests are made directly to AFL Fantasy\n• You can log out and clear credentials anytime"
            )
            .font(.body)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environmentObject(AFLFantasyDataService())
}

#Preview("Help") {
    HelpView()
}

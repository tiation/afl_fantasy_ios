//
//  DashboardView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    // MARK: - Environment

    @EnvironmentObject private var dataService: AFLFantasyDataService

    // MARK: - State

    @State private var showingLogin = false
    @State private var showingSettings = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if dataService.authenticated {
                        authenticatedContent
                    } else {
                        unauthenticatedContent
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("AFL Fantasy")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshButton
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if dataService.authenticated {
                            Button("Settings") {
                                showingSettings = true
                            }

                            Button("Sign Out", role: .destructive) {
                                dataService.logout()
                            }
                        } else {
                            Button("Sign In") {
                                showingLogin = true
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .refreshable {
            await refreshData()
        }
    }

    // MARK: - Authenticated Content

    private var authenticatedContent: some View {
        VStack(spacing: 16) {
            // Status Card
            StatusCard()

            // Key Metrics
            if let dashboardData = dataService.currentDashboardData {
                MetricsGrid(dashboardData: dashboardData)
            }

            // Captain Information
            if let captain = dataService.currentCaptain {
                CaptainCard(captain: captain)
            }

            // Update Information
            UpdateInfoCard()

            // Error Display
            if dataService.hasError {
                ErrorCard()
            }
        }
    }

    // MARK: - Unauthenticated Content

    private var unauthenticatedContent: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)

                Text("Welcome to AFL Fantasy Intelligence")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Sign in to access your team data, advanced analytics, and intelligent insights")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Sign In") {
                showingLogin = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding()
    }

    // MARK: - Refresh Button

    private var refreshButton: some View {
        Button(action: {
            Task {
                await refreshData()
            }
        }) {
            Image(systemName: dataService.loading ? "arrow.clockwise" : "arrow.clockwise")
                .rotationEffect(dataService.loading ? .degrees(360) : .degrees(0))
                .animation(
                    dataService.loading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                    value: dataService.loading
                )
        }
        .disabled(dataService.loading)
    }

    // MARK: - Helper Methods

    private func refreshData() async {
        guard dataService.authenticated else { return }
        _ = await dataService.refreshDashboardData()
    }
}

// MARK: - StatusCard

struct StatusCard: View {
    @EnvironmentObject private var dataService: AFLFantasyDataService

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Status")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(dataService.authenticated ? "Connected" : "Disconnected")
                        .font(.subheadline)
                        .foregroundColor(dataService.authenticated ? .green : .red)
                }

                Spacer()

                Image(systemName: dataService.authenticated ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(dataService.authenticated ? .green : .red)
            }

            if dataService.loading {
                ProgressView("Loading...")
                    .progressViewStyle(.linear)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - MetricsGrid

struct MetricsGrid: View {
    let dashboardData: DashboardData

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            MetricCard(
                title: "Team Value",
                value: String(format: "$%.1fM", dashboardData.teamValue.teamValue / 1_000_000),
                subtitle: "Total value",
                color: .blue
            )

            MetricCard(
                title: "Total Score",
                value: "\(dashboardData.teamScore.totalScore)",
                subtitle: "This round",
                color: .green
            )

            MetricCard(
                title: "Rank",
                value: "#\(dashboardData.rank.rank)",
                subtitle: "Overall",
                color: .orange
            )

            MetricCard(
                title: "Captain",
                value: dashboardData.captain.captain?.name ?? "None",
                subtitle: "Current selection",
                color: .purple
            )
        }
    }
}

// MARK: - MetricCard

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - CaptainCard

struct CaptainCard: View {
    let captain: CaptainData.Captain

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Captain")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(captain.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                if let team = captain.team {
                    Text(team)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let position = captain.position {
                    Text(position)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - UpdateInfoCard

struct UpdateInfoCard: View {
    @EnvironmentObject private var dataService: AFLFantasyDataService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Last Updated")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if dataService.isCacheFresh {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                }
            }

            Text(dataService.lastUpdateDisplayString)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if !dataService.isCacheFresh {
                Text("Data may be stale - pull to refresh")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - ErrorCard

struct ErrorCard: View {
    @EnvironmentObject private var dataService: AFLFantasyDataService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)

                Text("Error")
                    .font(.headline)
                    .foregroundColor(.red)

                Spacer()

                Button("Dismiss") {
                    dataService.clearError()
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }

            Text(dataService.errorMessage ?? "An unknown error occurred")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataService: AFLFantasyDataService

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(dataService.authenticated ? "Connected" : "Disconnected")
                            .foregroundColor(dataService.authenticated ? .green : .red)
                    }

                    HStack {
                        Text("Last Updated")
                        Spacer()
                        Text(dataService.lastUpdateDisplayString)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Account")
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        dataService.logout()
                        dismiss()
                    }
                } footer: {
                    Text("Signing out will clear your stored credentials from this device.")
                }
            }
            .navigationTitle("Settings")
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
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environmentObject(AFLFantasyDataService())
}

#Preview("Settings") {
    SettingsView()
        .environmentObject(AFLFantasyDataService())
}

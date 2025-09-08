//
//  PlayersListDemoView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - PlayersListDemoView

/// Demo SwiftUI view for players list integration
struct PlayersListDemoView: View {
    // MARK: - Properties

    @StateObject private var playerService = PlayerService()
    @State private var selectedPosition: PlayerPosition?
    @State private var showingError = false
    @State private var players: [Player] = []

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Section
                filterSection

                // Players List
                if playerService.isLoading {
                    loadingView
                } else if players.isEmpty {
                    emptyStateView
                } else {
                    playersList
                }
            }
            .navigationTitle("AFL Players")
            .refreshable {
                await refreshPlayers()
            }
            .alert("Error", isPresented: $showingError) {
                Button("Retry") {
                    Task {
                        await refreshPlayers()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let error = playerService.lastError {
                    Text(error.localizedDescription)
                } else {
                    Text("An unknown error occurred")
                }
            }
        }
        .task {
            await refreshPlayers()
        }
        .onChange(of: playerService.lastError) { error in
            showingError = error != nil
        }
    }

    // MARK: - View Components

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedPosition == nil
                ) {
                    selectedPosition = nil
                    Task { await refreshPlayers() }
                }

                ForEach(PlayerPosition.allCases, id: \.self) { position in
                    FilterChip(
                        title: position.displayName,
                        isSelected: selectedPosition == position
                    ) {
                        selectedPosition = position
                        Task { await refreshPlayers() }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Players...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Players Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Pull to refresh or adjust your filters to load player data.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }

    private var playersList: some View {
        List(players) { player in
            PlayerRow(player: player)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .background(Color(.systemBackground))
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Private Methods

    @MainActor
    private func refreshPlayers() async {
        do {
            let response = try await playerService.getPlayers(
                position: selectedPosition,
                season: 2025,
                limit: 100,
                offset: 0
            ).singleOutput()

            players = response.players
        } catch {
            print("Players refresh failed: \(error)")
        }
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.accentColor : Color(.systemGray5)
                )
                .foregroundColor(
                    isSelected ? .white : .primary
                )
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PlayerRow

struct PlayerRow: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.headline)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(player.team)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Text(player.position)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(positionColor(player.position))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatPrice(player.price))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    if let averageScore = player.averageScore {
                        Text("Avg: \(String(format: "%.1f", averageScore))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack {
                if let lastScore = player.lastScore {
                    ScoreChip(
                        title: "Last",
                        value: "\(lastScore)",
                        color: scoreColor(lastScore)
                    )
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("45.8%") // Mock ownership percentage
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Helper Methods

    private func formatPrice(_ price: Int) -> String {
        let priceInMillions = Double(price) / 1_000_000
        return String(format: "$%.1fM", priceInMillions)
    }

    private func positionColor(_ position: String) -> Color {
        switch position {
        case "DEF": Color.blue
        case "MID": Color.green
        case "RUC": Color.orange
        case "FWD": Color.red
        default: Color.gray
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0 ..< 60: Color.red
        case 60 ..< 80: Color.orange
        case 80 ..< 100: Color.blue
        default: Color.green
        }
    }
}

// MARK: - ScoreChip

struct ScoreChip: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

// MARK: - PlayerPosition Extension

extension PlayerPosition {
    var displayName: String {
        switch self {
        case .defender: "DEF"
        case .midfielder: "MID"
        case .ruck: "RUC"
        case .forward: "FWD"
        }
    }
}

// MARK: - Combine Extension

extension Publisher {
    /// Convert publisher to async single output
    func singleOutput() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = self
                .first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}

// MARK: - Preview

struct PlayersListDemoView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersListDemoView()
    }
}

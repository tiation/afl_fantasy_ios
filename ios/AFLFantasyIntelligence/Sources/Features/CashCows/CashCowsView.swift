import SwiftUI

// MARK: - CashCowsView

struct CashCowsView: View {
    @EnvironmentObject var apiService: APIService
    @StateObject private var viewModel = CashCowsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.l) {
                    // Summary Section
                    summarySection

                    // Cash Cows List
                    cashCowsList
                }
                .padding(.horizontal, DS.Spacing.l)
            }
            .navigationTitle("Cash Cows")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadCashCows(apiService: apiService)
            }
        }
        .task {
            await viewModel.loadCashCows(apiService: apiService)
        }
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Cash Generation Summary")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DS.Spacing.m) {
                    VStack {
                        Text("\(viewModel.cashCows.count)")
                            .font(DS.Typography.statNumber)
                            .foregroundColor(DS.Colors.success)
                        Text("Active Cash Cows")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }

                    VStack {
                        Text("$\(totalCashGenerated.formatted())")
                            .font(DS.Typography.statNumber)
                            .foregroundColor(DS.Colors.primary)
                        Text("Potential Cash")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Cash Cows List

    private var cashCowsList: some View {
        LazyVStack(spacing: DS.Spacing.m) {
            if viewModel.isLoading {
                ProgressView("Loading cash cows...")
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if viewModel.cashCows.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.cashCows.sorted { $0.confidence > $1.confidence }) { cashCow in
                    CashCowRowView(cashCow: cashCow)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        DSCard {
            VStack(spacing: DS.Spacing.l) {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 48))
                    .foregroundColor(DS.Colors.onSurfaceVariant)

                Text("No Cash Cows Found")
                    .font(DS.Typography.title3)
                    .foregroundColor(DS.Colors.onSurface)

                Text("No current cash generation opportunities identified")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .multilineTextAlignment(.center)

                DSButton("Refresh Analysis", style: .outline) {
                    Task {
                        await viewModel.loadCashCows(apiService: apiService)
                    }
                }
            }
            .padding(DS.Spacing.l)
        }
    }

    // MARK: - Computed Properties

    private var totalCashGenerated: Int {
        viewModel.cashCows.reduce(0) { $0 + $1.cashGenerated }
    }
}

// MARK: - CashCowRowView

struct CashCowRowView: View {
    let cashCow: CashCowAnalysis

    private var accessibilityLabel: String {
        let playerInfo = "\(cashCow.playerName)"
        let priceInfo = "current price \(cashCow.currentPrice), projected \(cashCow.projectedPrice)"
        let analysisInfo = "cash generation \(cashCow.cashGenerated), recommendation \(cashCow.recommendation)"
        return "\(playerInfo), \(priceInfo), \(analysisInfo)"
    }

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                // Header with name and confidence
                HStack {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text(cashCow.playerName)
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)

                        Text("Confidence: \(Int(cashCow.confidence * 100))%")
                            .font(DS.Typography.caption)
                            .foregroundColor(confidenceColor)
                    }

                    Spacer()

                    Text(cashCow.recommendation)
                        .font(DS.Typography.caption)
                        .padding(.horizontal, DS.Spacing.s)
                        .padding(.vertical, DS.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(recommendationColor.opacity(0.2))
                        )
                        .foregroundColor(recommendationColor)
                }

                // Stats Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: DS.Spacing.s) {
                    statView(title: "Current", value: "$\(cashCow.currentPrice.formatted())")
                    statView(title: "Projected", value: "$\(cashCow.projectedPrice.formatted())")
                    statView(title: "Cash Gen", value: "$\(cashCow.cashGenerated.formatted())")
                    statView(title: "Avg Score", value: String(format: "%.1f", cashCow.fpAverage))
                }

                // Performance indicator
                if cashCow.cashGenerated > 0 {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(DS.Colors.success)

                        Text("Potential gain: $\(cashCow.cashGenerated.formatted())")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.success)
                    }
                }
            }
        }
        .dsAccessibility(
            label: accessibilityLabel,
            traits: .isButton
        )
    }

    private func statView(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.onSurface)
            Text(title)
                .font(.system(size: 8))
                .foregroundColor(DS.Colors.onSurfaceSecondary)
        }
    }

    private var confidenceColor: Color {
        if cashCow.confidence >= 0.8 {
            DS.Colors.success
        } else if cashCow.confidence >= 0.6 {
            DS.Colors.warning
        } else {
            DS.Colors.error
        }
    }

    private var recommendationColor: Color {
        switch cashCow.recommendation {
        case "HOLD":
            DS.Colors.success
        case "SELL":
            DS.Colors.error
        default:
            DS.Colors.neutral
        }
    }
}

// MARK: - CashCowsViewModel

@MainActor
final class CashCowsViewModel: ObservableObject {
    @Published var cashCows: [CashCowAnalysis] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCashCows(apiService: APIService) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let fetchedCashCows = try await apiService.fetchCashCows()
            cashCows = fetchedCashCows
            print("✅ Loaded \(fetchedCashCows.count) cash cows from API")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load cash cows: \(error)")
            
            // Try to fallback to mock data only if API is completely unreachable
            if cashCows.isEmpty {
                cashCows = CashCowAnalysis.mockCashCows
                print("🔄 Using mock cash cows data fallback")
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
    struct CashCowsView_Previews: PreviewProvider {
        static var previews: some View {
            CashCowsView()
                .environmentObject(APIService.mock)
        }
    }

    struct CashCowRowView_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                CashCowRowView(cashCow: CashCowAnalysis.mockCashCows[0])
                CashCowRowView(cashCow: CashCowAnalysis.mockCashCows[1])
            }
            .padding()
        }
    }
#endif

import SwiftUI

struct CashCowAnalyzerView: View {
    @StateObject private var viewModel = CashCowAnalyzerViewModel()
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Theme.Colors.groupedBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.l) {
                        // Header section
                        headerSection
                        
                        // Segment control
                        segmentedControl
                        
                        // Content based on selected segment
                        if selectedSegment == 0 {
                            cashCowsList
                        } else {
                            potentialPicksList
                        }
                        
                        // Bottom padding
                        Color.clear.frame(height: Theme.Spacing.l)
                    }
                    .padding(.horizontal, Theme.Spacing.m)
                }
            }
            .navigationTitle("Cash Cows")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.success)
                
                Text("Cash Generation Analysis")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
            }
            
            Text("Track players generating cash through price increases and identify potential breakeven points.")
                .font(Theme.Font.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(Theme.Spacing.m)
        .cardStyle(.subtle)
    }
    
    @ViewBuilder
    private var segmentedControl: some View {
        Picker("View Mode", selection: $selectedSegment) {
            Text("Current Cows").tag(0)
            Text("Potential Picks").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, Theme.Spacing.s)
    }
    
    @ViewBuilder
    private var cashCowsList: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            SectionHeader("Active Cash Cows", subtitle: "Players generating value")
            
            if viewModel.isLoading {
                ForEach(0..<3, id: \.self) { _ in
                    CashCowRowPlaceholder()
                }
            } else if viewModel.cashCows.isEmpty {
                EmptyStateView(
                    icon: "dollarsign.circle",
                    title: "No Active Cash Cows",
                    subtitle: "Players generating value will appear here"
                )
            } else {
                ForEach(viewModel.cashCows, id: \.playerId) { cow in
                    CashCowRow(cashCow: cow)
                }
            }
        }
    }
    
    @ViewBuilder
    private var potentialPicksList: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            SectionHeader("Potential Cash Cows", subtitle: "Undervalued players with growth potential")
            
            if viewModel.isLoading {
                ForEach(0..<3, id: \.self) { _ in
                    CashCowRowPlaceholder()
                }
            } else if viewModel.potentialCows.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass.circle",
                    title: "No Potential Picks Found",
                    subtitle: "Check back regularly for new opportunities"
                )
            } else {
                ForEach(viewModel.potentialCows, id: \.playerId) { cow in
                    CashCowRow(cashCow: cow)
                }
            }
        }
    }
}

// MARK: - Components

struct CashCowRow: View {
    let cashCow: CashCowData
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(cashCow.playerName)
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("$\(cashCow.currentPrice / 1000)k → $\(cashCow.projectedPrice / 1000)k")
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                    Text(cashCow.recommendation)
                        .font(Theme.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(recommendationColor)
                        .padding(.horizontal, Theme.Spacing.s)
                        .padding(.vertical, Theme.Spacing.xxs)
                        .background(recommendationColor.opacity(0.1))
                        .cornerRadius(Theme.Radius.small)
                    
                    Text("$\(cashCow.cashGenerated / 1000)k")
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(Theme.Colors.success)
                }
            }
        }
        .padding(Theme.Spacing.m)
        .cardStyle(.standard)
    }
    
    private var recommendationColor: Color {
        switch cashCow.recommendation.uppercased() {
        case "BUY": return Theme.Colors.success
        case "HOLD": return Theme.Colors.warning
        case "SELL": return Theme.Colors.error
        default: return Theme.Colors.textSecondary
        }
    }
}

struct CashCowRowPlaceholder: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Rectangle()
                        .fill(Theme.Colors.textSecondary.opacity(0.3))
                        .frame(width: 120, height: 16)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Theme.Colors.textSecondary.opacity(0.2))
                        .frame(width: 80, height: 12)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                    Rectangle()
                        .fill(Theme.Colors.textSecondary.opacity(0.3))
                        .frame(width: 60, height: 16)
                        .cornerRadius(8)
                    
                    Rectangle()
                        .fill(Theme.Colors.textSecondary.opacity(0.2))
                        .frame(width: 40, height: 12)
                        .cornerRadius(4)
                }
            }
        }
        .padding(Theme.Spacing.m)
        .cardStyle(.standard)
        .redacted(reason: .placeholder)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            
            Text(title)
                .font(Theme.Font.title3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(subtitle)
                .font(Theme.Font.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.xl)
        .cardStyle(.subtle)
    }
}

// MARK: - Preview

struct CashCowAnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        CashCowAnalyzerView()
    }
}

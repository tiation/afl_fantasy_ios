//
//  SimpleContentView.swift
//  AFL Fantasy Intelligence Platform
//
//  Simple ContentView to get the build working
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - SimpleContentView

struct SimpleContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            SimpleTradeCalculatorView()
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Trades")
                }
                .tag(TabItem.trades)

            SimpleDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(TabItem.dashboard)

            SimpleCaptainView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Captain")
                }
                .tag(TabItem.captain)

            SimpleCashCowView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Cash Cow")
                }
                .tag(TabItem.cashCow)

            SimpleSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(TabItem.settings)
        }
        .accentColor(.orange)
    }
}

// MARK: - SimpleDashboardView

struct SimpleDashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var cashGenerated = 120000

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header with trophy
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.orange)
                            
                            Text("Dashboard")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)

                    // Players List
                    ForEach(Array(appState.players.enumerated()), id: \.offset) { index, player in
                        EnhancedPlayerCard(
                            player: player, 
                            showCashGenerated: player.position == .defender && player.name.contains("Young")
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("🏆 Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - EnhancedPlayerCard

struct EnhancedPlayerCard: View {
    let player: EnhancedPlayer
    let showCashGenerated: Bool
    
    private var positionColor: Color {
        switch player.position {
        case .defender: return .blue
        case .midfielder: return .green  
        case .ruck: return .purple
        case .forward: return .red
        }
    }
    
    private var consistencyGrade: String {
        // Mock data - would be calculated from actual form
        return ["A", "A", "B", "A"].randomElement() ?? "A"
    }
    
    private var averageScore: Int {
        // Mock data - would be calculated from season stats
        return Int.random(in: 85...115)
    }
    
    private var priceChange: Int {
        // Mock data - would come from actual price tracking
        let changes = [-15, 20, 30, 35, -10]
        return changes.randomElement() ?? 0
    }
    
    private var projectedScore: Int {
        // Mock data - would be AI prediction
        return Int.random(in: 88...118)
    }
    
    private var breakEven: Int {
        // Mock data - would be calculated
        return player.position == .defender ? (showCashGenerated ? 45 : 90) : Int.random(in: 75...95)
    }
    
    private var riskLevel: String {
        // Mock data - would be calculated from injury/form data
        return ["Low", "Moderate", "High"].randomElement() ?? "Low"
    }
    
    private var riskColor: Color {
        switch riskLevel {
        case "Low": return .green
        case "Moderate": return .orange
        case "High": return .red
        default: return .gray
        }
    }
    
    private var leftBorderColor: Color {
        switch riskLevel {
        case "Low": return .green
        case "Moderate": return .purple  // Purple for moderate like in screenshot
        case "High": return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            VStack(spacing: 12) {
                // Top row with name, price, and current score
                HStack(alignment: .top, spacing: 12) {
                    // Left border indicator (colored strip)
                    Rectangle()
                        .fill(leftBorderColor)
                        .frame(width: 4)
                        .cornerRadius(2, corners: .topLeft)
                        .cornerRadius(2, corners: .bottomLeft)
                    
                    VStack(spacing: 8) {
                        // Name and position row
                        HStack {
                            Text(player.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Current score - large and prominent
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(player.currentScore)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.orange)
                                
                                if showCashGenerated {
                                    Text("BE: \(breakEven)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("BE: \(breakEven)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Position, price, and risk level
                        HStack {
                            Text(player.position.rawValue.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(positionColor)
                                .cornerRadius(4)
                            
                            Text(player.formattedPrice)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(riskColor)
                                Text(riskLevel)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(riskColor)
                            }
                            
                            Spacer()
                        }
                        
                        // Stats row
                        HStack(spacing: 20) {
                            // Consistency
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Consistency")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(consistencyGrade)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            
                            // Average
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Average")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("\(averageScore)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            
                            // Price Change
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Price Δ")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(priceChange >= 0 ? "+\(priceChange)k" : "\(priceChange)k")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(priceChange >= 0 ? .green : .red)
                            }
                            
                            // Projected
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Projected")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("\(projectedScore)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                        }
                        
                        // Cash generated indicator (only for specific players)
                        if showCashGenerated {
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Cash Generated: $120k")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.green)
                                }
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// Extension to handle corner radius for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - SimpleCaptainView

struct SimpleCaptainView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 28))
                                .foregroundColor(.orange)
                            
                            Text("AI Captain Advisor")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Text("Based on venue, form, and opponent analysis")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)

                    ForEach(Array(appState.captainSuggestions.enumerated()), id: \.offset) { index, suggestion in
                        EnhancedCaptainCard(suggestion: suggestion, rank: index + 1, isTopPick: index == 0)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("⭐ Captain")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - EnhancedCaptainCard

struct EnhancedCaptainCard: View {
    let suggestion: CaptainSuggestion
    let rank: Int
    let isTopPick: Bool
    
    private var confidenceColor: Color {
        switch suggestion.confidence {
        case 90...100: return .green
        case 80..<90: return Color.green.opacity(0.8)
        case 70..<80: return .blue
        default: return .orange
        }
    }
    
    private var formFactorIcon: String {
        // Placeholder - would be based on actual form data
        return "arrow.right.circle.fill"
    }
    
    private var venueBias: String {
        // Placeholder - would calculate actual venue advantage
        return "+\(Int.random(in: 1...10)).\(Int.random(in: 0...9))"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            VStack(spacing: 12) {
                // Top row with rank, name, and projected points
                HStack(alignment: .top, spacing: 12) {
                    // Rank circle
                    ZStack {
                        Circle()
                            .fill(isTopPick ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                        
                        Text("\(rank)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isTopPick ? .white : .primary)
                    }
                    
                    // Player info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(suggestion.player.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if isTopPick {
                                HStack(spacing: 4) {
                                    Text("🔥")
                                    Text("Top Pick")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(suggestion.player.position.rawValue.uppercased())
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(suggestion.player.position.color)
                                .cornerRadius(4)
                            
                            Text("vs \(suggestion.player.opponent)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("@ \(suggestion.player.venue)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    
                    // Projected points - large and prominent
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(suggestion.projectedPoints)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("proj. pts")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Stats row
                HStack(spacing: 24) {
                    // AI Confidence
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Confidence")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(suggestion.confidence)%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(confidenceColor)
                    }
                    
                    // Form Factor
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Form Factor")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Image(systemName: formFactorIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    // Venue Bias
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Venue Bias")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(venueBias)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    // Weather
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weather")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("☀️")
                            .font(.system(size: 16))
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isTopPick ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - SimpleTradeCalculatorView

struct SimpleTradeCalculatorView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("🔄 Trade Calculator")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("🔄 Trades")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimpleCashCowView

struct SimpleCashCowView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("💰 Cash Cow Tracker")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("💰 Cash Cow")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimpleSettingsView

struct SimpleSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("⚙️ Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("⚙️ Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - TabItem

enum TabItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case captain = "Captain"
    case trades = "Trades"
    case cashCow = "Cash Cow"
    case settings = "Settings"

    var systemImage: String {
        switch self {
        case .dashboard: "house.fill"
        case .captain: "star.fill"
        case .trades: "arrow.triangle.2.circlepath"
        case .cashCow: "dollarsign.circle.fill"
        case .settings: "gearshape.fill"
        }
    }
}

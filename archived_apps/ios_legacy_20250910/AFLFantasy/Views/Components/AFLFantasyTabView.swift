//
//  AFLFantasyTabView.swift
//  AFL Fantasy Intelligence Platform
//

import SwiftUI

struct AFLFantasyTabView: View {
    enum TabItem {
        case dashboard
        case trades
        case alerts
        case analysis

        var title: String {
            switch self {
            case .dashboard: "Dashboard"
            case .trades: "Trades"
            case .alerts: "Alerts"
            case .analysis: "Analysis"
            }
        }

        var systemImage: String {
            switch self {
            case .dashboard: "square.grid.2x2"
            case .trades: "arrow.2.squarepath"
            case .alerts: "bell"
            case .analysis: "chart.bar"
            }
        }
    }

    @State private var selectedTab: TabItem = .dashboard
    @EnvironmentObject var hapticsManager: AFLHapticsManager

    var body: some View {
        TabView(selection: $selectedTab) {
            UnifiedDashboardView()
                .tabItem {
                    Label(
                        TabItem.dashboard.title,
                        systemImage: TabItem.dashboard.systemImage
                    )
                }
                .tag(TabItem.dashboard)

            TradeAnalyzerView()
                .tabItem {
                    Label(
                        TabItem.trades.title,
                        systemImage: TabItem.trades.systemImage
                    )
                }
                .tag(TabItem.trades)

            AlertCenterView()
                .tabItem {
                    Label(
                        TabItem.alerts.title,
                        systemImage: TabItem.alerts.systemImage
                    )
                }
                .tag(TabItem.alerts)

            AnalysisCenterView()
                .tabItem {
                    Label(
                        TabItem.analysis.title,
                        systemImage: TabItem.analysis.systemImage
                    )
                }
                .tag(TabItem.analysis)
        }
        .tint(.aflOrange)
        .onChange(of: selectedTab) { _, _ in
            hapticsManager.onPositionSelect()
        }
    }
}

#Preview {
    AFLFantasyTabView()
        .environmentObject(AFLHapticsManager.shared)
}

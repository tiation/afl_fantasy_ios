import SwiftUI

// MARK: - AFLFantasyApp Main App Entry Point

@main
struct AFLFantasyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var toolsClient = AFLFantasyToolsClient()
    @StateObject private var hapticsManager = AFLHapticsManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(toolsClient)
                .environmentObject(hapticsManager)
                .preferredColorScheme(.dark)
        }
    }
}

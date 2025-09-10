import SwiftUI

@main
struct AFLFantasyApp: App {
    @StateObject private var alertManager = AlertManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alertManager)
        }
    }
}


import SwiftUI

struct CaptainAIView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient

    var body: some View {
        NavigationView {
            ScrollView {
                Text("Captain AI View")
                    .font(.title)
                    .padding()
            }
            .navigationTitle("Captain AI")
        }
    }
}

#Preview {
    CaptainAIView()
        .environmentObject(AppState())
        .environmentObject(AFLFantasyToolsClient())
}

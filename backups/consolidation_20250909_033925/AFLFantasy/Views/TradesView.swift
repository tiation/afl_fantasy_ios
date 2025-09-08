import SwiftUI

struct TradesView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient

    var body: some View {
        NavigationView {
            ScrollView {
                Text("Trades View")
                    .font(.title)
                    .padding()
            }
            .navigationTitle("Trades")
        }
    }
}

#Preview {
    TradesView()
        .environmentObject(AppState())
        .environmentObject(AFLFantasyToolsClient())
}

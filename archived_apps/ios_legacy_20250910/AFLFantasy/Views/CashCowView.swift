import SwiftUI

struct CashCowView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient

    var body: some View {
        NavigationView {
            ScrollView {
                Text("Cash Cows View")
                    .font(.title)
                    .padding()
            }
            .navigationTitle("Cash Cows")
        }
    }
}

#Preview {
    CashCowView()
        .environmentObject(AppState())
        .environmentObject(AFLFantasyToolsClient())
}

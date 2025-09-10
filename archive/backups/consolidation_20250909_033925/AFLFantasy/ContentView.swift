import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("AFL Fantasy Intelligence")
                    .font(.largeTitle)
                    .padding()

                Text("Your smart fantasy companion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 20) {
                    NavigationLink("Dashboard") {
                        DashboardView()
                    }
                    .buttonStyle(.bordered)

                    NavigationLink("Players") {
                        PlayerListView()
                    }
                    .buttonStyle(.bordered)

                    NavigationLink("Trades") {
                        TradeView()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding()
        }
    }
}

// Note: DashboardView, PlayerListView, and TradeView are implemented
// in their dedicated files in the Views directory

#Preview {
    ContentView()
}

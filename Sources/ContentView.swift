import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("AFL Fantasy Intelligence")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Welcome to your AFL Fantasy Intelligence platform!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Get Started") {
                    // Navigate to dashboard when ready
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
            .navigationTitle("AFL Fantasy")
        }
    }
}

#Preview {
    ContentView()
}

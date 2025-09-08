import SwiftUI

struct PerformanceChart: View {
    let games: [GameStats]
    let projectedScore: Double
    
    var body: some View {
        VStack {
            Text("Performance Chart")
                .font(.headline)
            
            if !games.isEmpty {
                Text("Games: \(games.count)")
                    .font(.subheadline)
            }
            
            Text("Projected: \(Int(projectedScore))")
                .font(.subheadline)
        }
        .padding()
    }
}

#Preview {
    PerformanceChart(games: [], projectedScore: 85.5)
}

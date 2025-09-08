import SwiftUI

struct TeamStructureChart: View {
    let structure: TeamStructure
    let showDetails: Bool
    
    init(structure: TeamStructure, showDetails: Bool = true) {
        self.structure = structure
        self.showDetails = showDetails
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Team Structure")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("$\(structure.totalValue / 1000)k Total")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            // Position breakdown
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: Theme.Spacing.m) {
                ForEach(Array(structure.positionBalance.keys), id: \.self) { position in
                    if let count = structure.positionBalance[position] {
                        StatBox(
                            title: position.shortName,
                            value: "\(count)"
                        )
                    }
                }
                
                StatBox(
                    title: "Bank",
                    value: "$\(structure.bankBalance / 1000)k"
                )
                
                StatBox(
                    title: "Premiums",
                    value: "\(structure.premiumCount)"
                )
            }
            
            if showDetails {
                // Additional details
                HStack(spacing: Theme.Spacing.m) {
                    StatBox(
                        title: "Mid-Price",
                        value: "\(structure.midPriceCount)"
                    )
                    
                    StatBox(
                        title: "Rookies",
                        value: "\(structure.rookieCount)"
                    )
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    TeamStructureChart(
        structure: TeamStructure(
            totalValue: 12500000,
            bankBalance: 250000,
            positionBalance: [
                .defender: 6,
                .midfielder: 8,
                .ruck: 2,
                .forward: 6
            ],
            premiumCount: 8,
            midPriceCount: 10,
            rookieCount: 4
        ),
        showDetails: true
    )
}

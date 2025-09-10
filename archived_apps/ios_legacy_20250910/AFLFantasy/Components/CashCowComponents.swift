import SwiftUI

// MARK: - CashCowListItem

struct CashCowListItem: View {
    let target: CashGenerationTarget
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(target.player)
                        .font(.headline)
                    Text("$\(target.currentPrice / 1000)k → $\(target.targetPrice / 1000)k")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("+$\(target.cashGenerated / 1000)k")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("\(target.expectedWeeks) weeks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - CashCowInsightCard

struct CashCowInsightCard: View {
    let title: String
    let content: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(accentColor)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - RiskIndicator

struct RiskIndicator: View {
    let level: String
    let score: Double

    var color: Color {
        switch level.lowercased() {
        case "low": .green
        case "moderate": .orange
        case "high": .red
        default: .gray
        }
    }

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(level)
                .font(.subheadline)
                .foregroundColor(color)
            Text(String(format: "%.1f%%", score))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - CashCowDetailView

struct CashCowDetailView: View {
    let target: CashGenerationTarget
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(target.player)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Expected return: +$\(target.cashGenerated / 1000)k")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Price Details
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Current")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(target.currentPrice / 1000)k")
                            .font(.title3)
                    }
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading) {
                        Text("Target")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(target.targetPrice / 1000)k")
                            .font(.title3)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Stats & Timeline
                HStack(spacing: 12) {
                    StatBox(title: "Weeks Left", value: "\(target.expectedWeeks)")
                    StatBox(title: "Breakeven", value: "\(target.breakeven)")
                    StatBox(title: "Confidence", value: "\(Int(target.confidence))%")
                }

                // Risk Level
                VStack(alignment: .leading, spacing: 8) {
                    Text("Risk Assessment")
                        .font(.headline)
                    RiskIndicator(level: target.riskLevel, score: target.confidence)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Action buttons
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

// MARK: - StatBox

private struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

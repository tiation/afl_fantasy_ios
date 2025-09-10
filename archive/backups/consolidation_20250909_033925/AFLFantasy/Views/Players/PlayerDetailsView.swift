import Charts
import SwiftUI

// MARK: - PlayerDetailsView

struct PlayerDetailsView: View {
    let player: EnhancedPlayer
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            // Header
            Section {
                PlayerHeaderView(player: player)
            }

            // Next round projection
            Section("Next Round") {
                ProjectionView(
                    projection: player.nextRoundProjection,
                    conditions: player.nextRoundProjection.conditions
                )
            }

            // Performance metrics
            Section("Performance") {
                MetricsGridView(player: player)
            }

            // Venue performance
            if !player.venuePerformance.isEmpty {
                Section("Venue Performance") {
                    VenuePerformanceChart(performances: player.venuePerformance)
                }
            }

            // Risk assessment
            Section("Risk Assessment") {
                RiskAssessmentView(risk: player.injuryRisk)
            }

            // Alerts
            if !player.alertFlags.isEmpty {
                Section("Alerts") {
                    ForEach(player.alertFlags) { flag in
                        AlertRow(flag: flag)
                    }
                }
            }
        }
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}

// MARK: - PlayerHeaderView

struct PlayerHeaderView: View {
    let player: EnhancedPlayer

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(player.position.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(player.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)

                    if player.priceChange != 0 {
                        HStack(spacing: 2) {
                            Image(systemName: player.priceChange > 0 ? "arrow.up" : "arrow.down")
                            Text("$\(abs(player.priceChange / 1000))k")
                        }
                        .font(.subheadline)
                        .foregroundColor(player.priceChange > 0 ? .green : .red)
                    }
                }
            }

            // Status indicators
            HStack {
                if player.isCashCow {
                    StatusBadge(text: "Cash Cow", icon: "dollarsign.circle.fill", color: .green)
                }

                if player.isDoubtful {
                    StatusBadge(text: "Doubtful", icon: "exclamationmark.triangle.fill", color: .orange)
                }

                if player.isSuspended {
                    StatusBadge(text: "Suspended", icon: "xmark.circle.fill", color: .red)
                }
            }
        }
    }
}

// MARK: - StatusBadge

struct StatusBadge: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color)
        .cornerRadius(8)
    }
}

// MARK: - ProjectionView

struct ProjectionView: View {
    let projection: RoundProjection
    let conditions: WeatherConditions

    var body: some View {
        VStack(spacing: 12) {
            // Score projection
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Projected Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(String(format: "%.1f", projection.projectedScore))
                        .font(.title)
                        .fontWeight(.bold)
                }

                Spacer()

                ConfidenceLabel(confidence: projection.confidence)
            }

            Divider()

            // Match details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(projection.opponent, systemImage: "person.2.fill")
                    Label(projection.venue, systemImage: "mappin.circle.fill")
                }
                .font(.subheadline)

                Spacer()

                // Weather conditions
                WeatherView(conditions: conditions)
            }
        }
    }
}

// MARK: - ConfidenceLabel

struct ConfidenceLabel: View {
    let confidence: Double

    var body: some View {
        Text("\(Int(confidence * 100))% Confidence")
            .font(.subheadline)
            .foregroundColor(confidenceColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(confidenceColor.opacity(0.1))
            .cornerRadius(8)
    }

    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: .green
        case 0.6...: .blue
        default: .orange
        }
    }
}

// MARK: - WeatherView

struct WeatherView: View {
    let conditions: WeatherConditions

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(Int(conditions.temperature))°C")
                .font(.subheadline)

            if conditions.rainProbability > 0.2 {
                Text("\(Int(conditions.rainProbability * 100))% Rain")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - MetricsGridView

struct MetricsGridView: View {
    let player: EnhancedPlayer

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Average",
                value: String(format: "%.1f", player.averageScore),
                trend: String(format: "%.1f", player.seasonProjection.projectedAverage)
            )

            MetricCard(
                title: "Breakeven",
                value: "\(player.breakeven)",
                trend: nil
            )

            MetricCard(
                title: "Consistency",
                value: "\(Int(player.consistency))%",
                trend: nil
            )

            MetricCard(
                title: "Cash Generated",
                value: "$\(player.cashGenerated / 1000)k",
                trend: player.cashGenerated > 0 ? "Profit" : nil,
                trendColor: .green
            )
        }
    }
}

// MARK: - MetricCard

struct MetricCard: View {
    let title: String
    let value: String
    let trend: String?
    var trendColor: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            if let trend {
                Text(trend)
                    .font(.caption)
                    .foregroundColor(trendColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - VenuePerformanceChart

struct VenuePerformanceChart: View {
    let performances: [VenuePerformance]

    var body: some View {
        Chart {
            ForEach(performances, id: \.venue) { venue in
                BarMark(
                    x: .value("Score", venue.averageScore),
                    y: .value("Venue", venue.venue)
                )
                .foregroundStyle(by: .value("Games", venue.gamesPlayed))
                .annotation(position: .trailing) {
                    Text("\(venue.gamesPlayed) games")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: CGFloat(performances.count) * 40 + 40)
    }
}

// MARK: - RiskAssessmentView

struct RiskAssessmentView: View {
    let risk: InjuryRisk

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(
                    "Risk Level: \(risk.riskLevel.rawValue)",
                    systemImage: riskIcon
                )
                .foregroundColor(riskColor)

                Spacer()

                Text("\(Int(risk.riskScore * 100))%")
                    .font(.headline)
                    .foregroundColor(riskColor)
            }

            if !risk.riskFactors.isEmpty {
                ForEach(risk.riskFactors, id: \.self) { factor in
                    Text("• \(factor)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var riskIcon: String {
        switch risk.riskLevel {
        case .low: "checkmark.circle.fill"
        case .medium: "exclamationmark.triangle.fill"
        case .high: "xmark.circle.fill"
        }
    }

    private var riskColor: Color {
        switch risk.riskLevel {
        case .low: .green
        case .medium: .orange
        case .high: .red
        }
    }
}

// MARK: - AlertRow

struct AlertRow: View {
    let flag: AlertFlag

    var body: some View {
        HStack {
            Image(systemName: alertIcon)
                .foregroundColor(alertColor)

            Text(flag.message)
                .font(.subheadline)

            Spacer()

            Text(flag.priority.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var alertIcon: String {
        switch flag.type {
        case .cashCowSell: "dollarsign.circle.fill"
        case .premiumBreakout: "star.fill"
        case .breakoutCandidate: "arrow.up.circle.fill"
        }
    }

    private var alertColor: Color {
        switch flag.priority {
        case .low: .blue
        case .medium: .orange
        case .high: .red
        }
    }
}

// MARK: - Preview

#Preview {
    let samplePlayer = Player(
        id: "1",
        apiId: 12346,
        name: "Marcus Bontempelli",
        position: .midfielder,
        teamId: 3,
        teamName: "Western Bulldogs",
        teamAbbreviation: "WBD",
        currentPrice: 850_000,
        currentScore: 108,
        averageScore: 105.5,
        totalScore: 2310,
        breakeven: 85,
        gamesPlayed: 22,
        consistency: 85.0,
        ceiling: 145,
        floor: 85,
        volatility: 0.22,
        ownership: 55.2,
        lastScore: 115,
        startingPrice: 825_000,
        priceChange: 25000,
        priceChangeProbability: 0.78,
        cashGenerated: 150_000,
        valueGain: 3.03,
        isInjured: false,
        isDoubtful: false,
        isSuspended: false,
        injuryRisk: InjuryRisk(
            riskScore: 0.15,
            severity: .low,
            details: "Minor soreness"
        ),
        contractStatus: "Signed until 2027",
        seasonalTrend: [98.0, 108.0, 115.0, 110.0, 105.0],
        nextRoundProjection: RoundProjection(
            predictedScore: 110.0,
            confidence: 0.85,
            upside: 135.0,
            downside: 88.0,
            venue: "Marvel Stadium",
            opponent: "GWS"
        ),
        threeRoundProjection: [
            RoundProjection(predictedScore: 110.0, confidence: 0.85, upside: 135.0, downside: 88.0, venue: "Marvel Stadium", opponent: "GWS"),
            RoundProjection(predictedScore: 105.0, confidence: 0.80, upside: 128.0, downside: 82.0, venue: "MCG", opponent: "Collingwood"),
            RoundProjection(predictedScore: 112.0, confidence: 0.82, upside: 140.0, downside: 85.0, venue: "Marvel Stadium", opponent: "St Kilda")
        ],
        seasonProjection: SeasonProjection(
            projectedAverage: 105.0,
            projectedTotal: 2310.0,
            breakEvenRounds: 2,
            peakRounds: [16, 20, 23]
        ),
        venuePerformance: [
            VenuePerformance(venue: "Marvel Stadium", averageScore: 108.5, gamesPlayed: 12),
            VenuePerformance(venue: "MCG", averageScore: 102.5, gamesPlayed: 8)
        ],
        opponentPerformance: ["GWS": 125.2, "Collingwood": 98.5, "St Kilda": 115.8],
        isCaptainRecommended: true,
        isTradeTarget: false,
        isCashCow: false,
        alertFlags: [
            AlertFlag(
                type: .premiumBreakout,
                priority: .high,
                message: "Scoring trend indicates premium breakout"
            )
        ]
    )
    
    NavigationView {
        PlayerDetailsView(player: EnhancedPlayer(
            player: samplePlayer,
            premiumPotential: 0.95,
            tradeInScore: 0.8,
            tradeOutScore: 0.2,
            captainScore: 0.88,
            riskScore: 0.15,
            valueScore: 0.85
        ))
    }
}

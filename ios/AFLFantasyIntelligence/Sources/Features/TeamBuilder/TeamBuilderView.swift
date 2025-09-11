import SwiftUI

struct TeamBuilderView: View {
    @StateObject private var teamManager = TeamManager()
    @StateObject private var teamBuilder: TeamBuilderService
    @State private var selectedStrategy: OptimizationStrategy = .balanced
    @State private var showingOptimizer = false
    @State private var showingValidationAlert = false
    
    init() {
        let manager = TeamManager()
        _teamManager = StateObject(wrappedValue: manager)
        _teamBuilder = StateObject(wrappedValue: TeamBuilderService(teamManager: manager))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.l) {
                // Strategy selector
                strategyPicker
                
                // Team validation issues
                if !teamBuilder.validationIssues.isEmpty {
                    validationSection
                }
                
                // Team metrics
                if let metrics = teamBuilder.currentTeamMetrics {
                    teamMetricsSection(metrics)
                }
                
                // Team composition
                teamCompositionSection
                
                // Optimization button
                Button {
                    Task {
                        await optimizeTeam()
                    }
                } label: {
                    if teamBuilder.isOptimizing {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Optimize Team")
                            .font(.headline)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(teamBuilder.isOptimizing || !teamBuilder.validationIssues.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Team Builder")
        .sheet(isPresented: $showingOptimizer) {
            OptimizerResultsView(suggestions: teamBuilder.suggestions)
        }
        .alert("Validation Issues", isPresented: $showingValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(teamBuilder.validationIssues.map(\.description).joined(separator: "\n"))
        }
    }
    
    private var strategyPicker: some View {
        VStack(alignment: .leading) {
            Text("Optimization Strategy")
                .font(.headline)
                .padding(.bottom, 4)
            
            Picker("Strategy", selection: $selectedStrategy) {
                ForEach(OptimizationStrategy.allCases, id: \.self) { strategy in
                    Text(strategy.rawValue)
                        .tag(strategy)
                }
            }
            .pickerStyle(.segmented)
            
            Text(selectedStrategy.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
    
    private var validationSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Validation Issues")
                .font(.headline)
            
            ForEach(teamBuilder.validationIssues) { issue in
                HStack {
                    Circle()
                        .fill(severityColor(for: issue.severity))
                        .frame(width: 8, height: 8)
                    
                    Text(issue.description)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    private func teamMetricsSection(_ metrics: TeamMetrics) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Team Metrics")
                .font(.headline)
            
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: DS.Spacing.m) {
                MetricCard(title: "Consistency", value: "\(Int(metrics.consistencyScore))")
                MetricCard(title: "Value Potential", value: "$\(Int(metrics.valueGenerationPotential / 1000))k")
                MetricCard(title: "Injury Risk", value: "\(Int(metrics.injuryRiskScore))")
                MetricCard(title: "Uniqueness", value: "\(Int(metrics.uniquenessScore))%")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    private var teamCompositionSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Team Composition")
                .font(.headline)
            
            ForEach(Position.allCases, id: \.self) { position in
                HStack {
                    Text(position.rawValue)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(teamManager.playersByPosition(position).count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    private func optimizeTeam() async {
        if teamBuilder.validationIssues.isEmpty {
            await teamBuilder.optimizeTeam(using: selectedStrategy)
            showingOptimizer = true
        } else {
            showingValidationAlert = true
        }
    }
    
    private func severityColor(for severity: OptimizerSuggestion.ImpactLevel) -> Color {
        switch severity {
        case .critical:
            return .red
        case .high:
            return .orange
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#if DEBUG
struct TeamBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamBuilderView()
        }
    }
}
#endif

import SwiftUI

// MARK: - AdvancedFiltersView

struct AdvancedFiltersView: View {
    @StateObject private var filterService = AdvancedFilteringService()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCriteria = Set<FilterCriteria>()
    @State private var selectedPreset: FilterPreset?
    @State private var priceRange = 0.0...800.0
    @State private var selectedTeams = Set<String>()
    @State private var selectedPositions = Set<Position>()
    @State private var performanceThresholds = PerformanceFilters()
    @State private var showWatchlistOnly = false
    @State private var showActivePlayersOnly = true
    @State private var showInjuryRisk = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Create custom filters to find players that match your specific criteria. Combine multiple filters for precise results.")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                } header: {
                    Text("Advanced Player Filtering")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                }
                
                // Filter Presets
                Section("Quick Presets") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.Spacing.s) {
                        ForEach(FilterPreset.allCases, id: \.self) { preset in
                            PresetChip(
                                preset: preset,
                                isSelected: selectedPreset == preset
                            ) {
                                selectPreset(preset)
                            }
                        }
                    }
                }
                
                // Position Selection
                Section("Positions") {
                    FlowLayout(spacing: DS.Spacing.s) {
                        ForEach(Position.allCases, id: \.self) { position in
                            SelectableChip(
                                title: position.displayName,
                                isSelected: selectedPositions.contains(position),
                                color: DS.Colors.positionColor(for: position)
                            ) {
                                togglePosition(position)
                            }
                        }
                    }
                }
                
                // Team Selection
                Section("Teams") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DS.Spacing.s) {
                        ForEach(AFLTeam.allTeams, id: \.self) { team in
                            SelectableChip(
                                title: team,
                                isSelected: selectedTeams.contains(team),
                                color: DS.Colors.secondary
                            ) {
                                toggleTeam(team)
                            }
                        }
                    }
                }
                
                // Price Range
                Section("Price Range") {
                    VStack(alignment: .leading, spacing: DS.Spacing.m) {
                        HStack {
                            Text("$\(Int(priceRange.lowerBound))K")
                                .font(DS.Typography.subheadline)
                                .foregroundColor(DS.Colors.onSurface)
                            
                            Spacer()
                            
                            Text("$\(Int(priceRange.upperBound))K")
                                .font(DS.Typography.subheadline)
                                .foregroundColor(DS.Colors.onSurface)
                        }
                        
                        RangeSlider(
                            range: $priceRange,
                            bounds: 150.0...800.0,
                            step: 10.0
                        )
                        .tint(DS.Colors.primary)
                    }
                }
                
                // Performance Thresholds
                Section("Performance") {
                    VStack(spacing: DS.Spacing.l) {
                        PerformanceSlider(
                            title: "Min Average",
                            value: $performanceThresholds.minAverage,
                            range: 40.0...120.0,
                            step: 1.0,
                            unit: ""
                        )
                        
                        PerformanceSlider(
                            title: "Min Projected", 
                            value: $performanceThresholds.minProjected,
                            range: 40.0...120.0,
                            step: 1.0,
                            unit: ""
                        )
                        
                        PerformanceSlider(
                            title: "Max Breakeven",
                            value: $performanceThresholds.maxBreakeven,
                            range: -50.0...100.0,
                            step: 1.0,
                            unit: ""
                        )
                    }
                }
                
                // Advanced Toggles
                Section("Advanced Options") {
                    Toggle("Watchlist Only", isOn: $showWatchlistOnly)
                        .toggleStyle(DSToggleStyle())
                    
                    Toggle("Active Players Only", isOn: $showActivePlayersOnly)
                        .toggleStyle(DSToggleStyle())
                    
                    Toggle("Show Injury Risk", isOn: $showInjuryRisk)
                        .toggleStyle(DSToggleStyle())
                }
                
                // Active Filters Summary
                if !selectedCriteria.isEmpty || selectedPreset != nil {
                    Section("Active Filters") {
                        ForEach(Array(selectedCriteria), id: \.self) { criteria in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(DS.Colors.success)
                                    .font(.caption)
                                
                                Text(criteria.displayName)
                                    .font(DS.Typography.body)
                                    .foregroundColor(DS.Colors.onSurface)
                                
                                Spacer()
                                
                                Button("Remove") {
                                    selectedCriteria.remove(criteria)
                                }
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.error)
                            }
                        }
                        
                        if let preset = selectedPreset {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(DS.Colors.accent)
                                    .font(.caption)
                                
                                Text("Preset: \(preset.displayName)")
                                    .font(DS.Typography.body)
                                    .foregroundColor(DS.Colors.onSurface)
                                
                                Spacer()
                                
                                Button("Clear") {
                                    selectedPreset = nil
                                }
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.error)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Advanced Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedCriteria.isEmpty && selectedPreset == nil)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Clear All") {
                        clearAllFilters()
                    }
                    .foregroundColor(DS.Colors.error)
                    
                    Spacer()
                    
                    Text("\(filteredPlayerCount) players match")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredPlayerCount: Int {
        // Mock calculation - in real app would filter actual player list
        let baseCount = 600
        let reductionFactor = Double(selectedCriteria.count + (selectedPreset != nil ? 2 : 0)) * 0.3
        return max(50, Int(Double(baseCount) * (1.0 - reductionFactor)))
    }
    
    // MARK: - Actions
    
    private func selectPreset(_ preset: FilterPreset) {
        selectedPreset = selectedPreset == preset ? nil : preset
        
        // Apply preset configurations
        if selectedPreset == preset {
            applyPresetConfiguration(preset)
        }
    }
    
    private func applyPresetConfiguration(_ preset: FilterPreset) {
        switch preset {
        case .premiums:
            priceRange = 550.0...800.0
            performanceThresholds.minAverage = 90.0
            selectedCriteria.insert(.highOwnership)
            
        case .rookies:
            priceRange = 150.0...350.0
            performanceThresholds.minProjected = 60.0
            selectedCriteria.insert(.priceRising)
            
        case .captainOptions:
            priceRange = 400.0...800.0
            performanceThresholds.minAverage = 95.0
            selectedCriteria.insert(.consistentScorer)
            
        case .cashCows:
            priceRange = 150.0...400.0
            performanceThresholds.minProjected = 70.0
            selectedCriteria.insert(.priceRising)
            selectedCriteria.insert(.outperformingBreakeven)
            
        case .differentials:
            priceRange = 300.0...600.0
            selectedCriteria.insert(.lowOwnership)
            selectedCriteria.insert(.goodFixtures)
            
        case .keepers:
            performanceThresholds.minAverage = 85.0
            selectedCriteria.insert(.consistentScorer)
            selectedCriteria.insert(.lowInjuryRisk)
        }
    }
    
    private func togglePosition(_ position: Position) {
        if selectedPositions.contains(position) {
            selectedPositions.remove(position)
        } else {
            selectedPositions.insert(position)
        }
    }
    
    private func toggleTeam(_ team: String) {
        if selectedTeams.contains(team) {
            selectedTeams.remove(team)
        } else {
            selectedTeams.insert(team)
        }
    }
    
    private func applyFilters() {
        let filters = PlayerFilterRequest(
            positions: Array(selectedPositions),
            teams: Array(selectedTeams),
            priceRange: Int(priceRange.lowerBound * 1000)...Int(priceRange.upperBound * 1000),
            minAverage: performanceThresholds.minAverage,
            minProjected: performanceThresholds.minProjected,
            maxBreakeven: Int(performanceThresholds.maxBreakeven),
            criteria: Array(selectedCriteria),
            preset: selectedPreset,
            watchlistOnly: showWatchlistOnly,
            activeOnly: showActivePlayersOnly,
            includeInjuryRisk: showInjuryRisk
        )
        
        Task {
            try await filterService.applyFilters(filters)
        }
    }
    
    private func clearAllFilters() {
        withAnimation(DS.Motion.spring) {
            selectedCriteria.removeAll()
            selectedPreset = nil
            selectedTeams.removeAll()
            selectedPositions.removeAll()
            priceRange = 0.0...800.0
            performanceThresholds = PerformanceFilters()
            showWatchlistOnly = false
            showActivePlayersOnly = true
            showInjuryRisk = false
        }
    }
}

// MARK: - Supporting Views

struct PresetChip: View {
    let preset: FilterPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: preset.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : DS.Colors.primary)
                
                Text(preset.displayName)
                    .font(DS.Typography.caption)
                    .foregroundColor(isSelected ? .white : DS.Colors.onSurface)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                    .fill(isSelected ? DS.Colors.primary : DS.Colors.surfaceSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                    .stroke(isSelected ? DS.Colors.primary : DS.Colors.outline.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DS.Typography.caption)
                .foregroundColor(isSelected ? .white : color)
                .fontWeight(.medium)
                .padding(.horizontal, DS.Spacing.m)
                .padding(.vertical, DS.Spacing.s)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if rowWidth + subviewSize.width + spacing > maxWidth, rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = subviewSize.width
                rowHeight = subviewSize.height
            } else {
                if rowWidth > 0 {
                    rowWidth += spacing
                }
                rowWidth += subviewSize.width
                rowHeight = max(rowHeight, subviewSize.height)
            }
        }
        
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if x + subviewSize.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(subviewSize))
            x += subviewSize.width + spacing
            rowHeight = max(rowHeight, subviewSize.height)
        }
    }
}

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        // Simplified range slider - in production would use custom implementation
        VStack {
            HStack {
                Slider(value: .init(
                    get: { range.lowerBound },
                    set: { range = $0...range.upperBound }
                ), in: bounds, step: step)
                
                Slider(value: .init(
                    get: { range.upperBound },
                    set: { range = range.lowerBound...$0 }
                ), in: bounds, step: step)
            }
        }
    }
}

// These components are now available from Core/DesignSystem/DSExtensions.swift

// MARK: - Supporting Types
// (Using PerformanceFilters and AFLTeam from Core)

// MARK: - Previews

#if DEBUG
struct AdvancedFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedFiltersView()
    }
}
#endif

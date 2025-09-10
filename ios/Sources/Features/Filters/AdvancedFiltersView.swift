import SwiftUI

@available(iOS 14.0, *)
struct AdvancedFiltersView: View {
    @StateObject private var filterService = PlayerFilteringService()
    @StateObject private var preferences = UserPreferencesService.shared
    @Binding var criteria: PlayerFilterCriteria
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section("Position & Team") {
                    PositionPicker(selection: $criteria.position)
                    TeamPicker(selection: $criteria.team)
                }
                
                Section("Price Range") {
                    PriceRangeSlider(
                        minPrice: $criteria.minPrice,
                        maxPrice: $criteria.maxPrice
                    )
                }
                
                Section("Performance") {
                    PerformanceFilters(criteria: $criteria)
                }
                
                Section("Quick Presets") {
                    PresetButtons(criteria: $criteria)
                }
                
                Section("Advanced") {
                    AdvancedOptions(criteria: $criteria)
                }
            }
            .navigationTitle("Advanced Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        criteria = PlayerFilterCriteria()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct PositionPicker: View {
    @Binding var selection: Position?
    
    var body: some View {
        HStack {
            Text("Position")
            Spacer()
            Menu(selection?.rawValue ?? "All") {
                Button("All") { selection = nil }
                ForEach(Position.allCases, id: \.self) { position in
                    Button(position.rawValue) { selection = position }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct TeamPicker: View {
    @Binding var selection: String?
    
    private let teams = ["ADE", "BRI", "CAR", "COL", "ESS", "FRE", "GEE", "GCS", "GWS", 
                        "HAW", "MEL", "NOR", "POR", "RIC", "STK", "SYD", "WBD", "WCE"]
    
    var body: some View {
        HStack {
            Text("Team")
            Spacer()
            Menu(selection ?? "All") {
                Button("All") { selection = nil }
                ForEach(teams, id: \.self) { team in
                    Button(team) { selection = team }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct PriceRangeSlider: View {
    @Binding var minPrice: Int?
    @Binding var maxPrice: Int?
    @State private var range: ClosedRange<Double> = 200_000...1_500_000
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Price Range")
            HStack {
                Text("$\(Int(range.lowerBound).formatted(.number.notation(.compactName)))")
                    .font(.caption)
                Spacer()
                Text("$\(Int(range.upperBound).formatted(.number.notation(.compactName)))")
                    .font(.caption)
            }
            // Note: RangeSlider would need custom implementation or third-party library
            Text("Range slider would go here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onChange(of: range) { newRange in
            minPrice = Int(newRange.lowerBound)
            maxPrice = Int(newRange.upperBound)
        }
    }
}

@available(iOS 14.0, *)
private struct PerformanceFilters: View {
    @Binding var criteria: PlayerFilterCriteria
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Min Average")
                Spacer()
                TextField("0", value: $criteria.minAverage, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Min Projected")
                Spacer()
                TextField("0", value: $criteria.minProjected, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Breakeven Below")
                Spacer()
                TextField("150", value: $criteria.breakevenBelow, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
        }
    }
}

@available(iOS 14.0, *)
private struct PresetButtons: View {
    @Binding var criteria: PlayerFilterCriteria
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(PlayerFilterPreset.allCases, id: \.self) { preset in
                Button(action: { criteria = preset.criteria() }) {
                    HStack {
                        Text(preset.rawValue)
                        Spacer()
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

@available(iOS 14.0, *)
private struct AdvancedOptions: View {
    @Binding var criteria: PlayerFilterCriteria
    
    var body: some View {
        VStack(spacing: 8) {
            Toggle("Watchlist Only", isOn: $criteria.watchlistOnly)
            
            HStack {
                Text("Injury Status")
                Spacer()
                Menu(criteria.injuryStatusIncluded.rawValue.capitalized) {
                    ForEach(InjuryStatusFilter.allCases, id: \.self) { status in
                        Button(status.rawValue.capitalized) {
                            criteria.injuryStatusIncluded = status
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

@available(iOS 14.0, *)
struct AdvancedFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedFiltersView(
            criteria: .constant(PlayerFilterCriteria()),
            isPresented: .constant(true)
        )
    }
}

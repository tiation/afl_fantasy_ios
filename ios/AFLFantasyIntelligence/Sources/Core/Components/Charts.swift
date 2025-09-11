import SwiftUI
import Charts

// MARK: - DSLineChart

@available(iOS 16.0, *)
struct DSLineChart: View {
    let data: [ChartDataPoint]
    let title: String
    let color: Color
    let showGradient: Bool
    
    @State private var isVisible = false
    @State private var selectedPoint: ChartDataPoint?
    
    init(
        data: [ChartDataPoint], 
        title: String, 
        color: Color = DS.Colors.primary,
        showGradient: Bool = true
    ) {
        self.data = data
        self.title = title
        self.color = color
        self.showGradient = showGradient
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            HStack {
                Text(title)
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Spacer()
                
                if let selectedPoint {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(selectedPoint.value, specifier: "%.1f")")
                            .font(DS.Typography.statNumber)
                            .foregroundColor(color)
                        
                        Text(selectedPoint.label)
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
            }
            
            Chart(data, id: \.id) { point in
                LineMark(
                    x: .value("Period", point.x),
                    y: .value("Value", isVisible ? point.value : 0)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.catmullRom)
                
                if showGradient {
                    AreaMark(
                        x: .value("Period", point.x),
                        y: .value("Value", isVisible ? point.value : 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                
                // Selection point
                if let selectedPoint, point.id == selectedPoint.id {
                    PointMark(
                        x: .value("Period", point.x),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(color)
                    .symbolSize(64)
                }
            }
            .frame(height: 180)
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(DS.Colors.outline.opacity(0.3))
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(DS.Colors.onSurfaceSecondary)
                }
            }
            .chartBackground { proxy in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        updateSelectedPoint(at: location, proxy: proxy)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateSelectedPoint(at: value.location, proxy: proxy)
                            }
                    )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    isVisible = true
                }
            }
        }
    }
    
    private func updateSelectedPoint(at location: CGPoint, proxy: ChartProxy) {
        let x = proxy.value(atX: location.x, as: Double.self) ?? 0
        let closestPoint = data.min(by: { abs($0.x - x) < abs($1.x - x) })
        
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPoint = closestPoint
        }
    }
}

// MARK: - DSBarChart

@available(iOS 16.0, *)
struct DSBarChart: View {
    let data: [ChartDataPoint]
    let title: String
    let color: Color
    
    @State private var isVisible = false
    
    init(
        data: [ChartDataPoint],
        title: String,
        color: Color = DS.Colors.primary
    ) {
        self.data = data
        self.title = title
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text(title)
                .font(DS.Typography.headline)
                .foregroundColor(DS.Colors.onSurface)
            
            Chart(data, id: \.id) { point in
                BarMark(
                    x: .value("Category", point.label),
                    y: .value("Value", isVisible ? point.value : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(DS.CornerRadius.small)
            }
            .frame(height: 160)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(DS.Colors.outline.opacity(0.3))
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(DS.Colors.onSurfaceSecondary)
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(DS.Colors.onSurfaceSecondary)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    isVisible = true
                }
            }
        }
    }
}

// MARK: - DSPieChart

@available(iOS 16.0, *)
struct DSPieChart: View {
    let data: [ChartDataPoint]
    let title: String
    
    @State private var isVisible = false
    @State private var selectedSegment: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text(title)
                .font(DS.Typography.headline)
                .foregroundColor(DS.Colors.onSurface)
            
            HStack(spacing: DS.Spacing.l) {
                // Pie chart
                Chart(data, id: \.id) { point in
                    SectorMark(
                        angle: .value("Value", isVisible ? point.value : 0),
                        innerRadius: .ratio(0.4),
                        angularInset: 1.5
                    )
                    .foregroundStyle(colorFor(index: data.firstIndex(where: { $0.id == point.id }) ?? 0))
                    .cornerRadius(4)
                }
                .frame(width: 120, height: 120)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        isVisible = true
                    }
                }
                
                // Legend
                VStack(alignment: .leading, spacing: DS.Spacing.s) {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                        HStack(spacing: DS.Spacing.s) {
                            Circle()
                                .fill(colorFor(index: index))
                                .frame(width: 8, height: 8)
                            
                            Text(point.label)
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.onSurface)
                            
                            Spacer()
                            
                            Text("\(point.value, specifier: "%.0f")")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }
                    }
                }
            }
        }
    }
    
    private func colorFor(index: Int) -> Color {
        let colors = [DS.Colors.primary, DS.Colors.accent, DS.Colors.success, DS.Colors.warning]
        return colors[index % colors.count]
    }
}

// MARK: - DSProgressChart

@available(iOS 16.0, *)
struct DSProgressChart: View {
    let progress: Double
    let target: Double
    let title: String
    let subtitle: String?
    
    @State private var animatedProgress: Double = 0
    
    var progressColor: Color {
        let ratio = progress / target
        if ratio >= 1.0 { return DS.Colors.success }
        if ratio >= 0.8 { return DS.Colors.warning }
        return DS.Colors.primary
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: DS.Spacing.m) {
            VStack(spacing: DS.Spacing.xs) {
                Text(title)
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                if let subtitle {
                    Text(subtitle)
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
            }
            
            ZStack {
                // Background ring
                Circle()
                    .stroke(DS.Colors.outline.opacity(0.3), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: animatedProgress / target)
                    .stroke(
                        LinearGradient(
                            colors: [progressColor, progressColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                // Center content
                VStack(spacing: 2) {
                    Text("\(Int(animatedProgress))")
                        .font(DS.Typography.statNumber)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Text("of \(Int(target))")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    animatedProgress = progress
                }
            }
        }
    }
}

// MARK: - ChartDataPoint

struct ChartDataPoint: Identifiable, Hashable {
    let id = UUID()
    let x: Double
    let value: Double
    let label: String
    
    init(x: Double, value: Double, label: String) {
        self.x = x
        self.value = value
        self.label = label
    }
    
    // Mock data generators
    static func mockFormData() -> [ChartDataPoint] {
        let games = ["R10", "R11", "R12", "R13", "R14", "R15"]
        let scores = [85.2, 92.1, 78.5, 105.3, 88.7, 95.4]
        
        return zip(games.enumerated(), scores).map { (index, score) in
            ChartDataPoint(x: Double(index.0), value: score, label: index.1)
        }
    }
    
    static func mockPriceData() -> [ChartDataPoint] {
        let rounds = ["R10", "R11", "R12", "R13", "R14", "R15"]
        let prices = [420.0, 425.0, 430.0, 435.0, 445.0, 450.0]
        
        return zip(rounds.enumerated(), prices).map { (index, price) in
            ChartDataPoint(x: Double(index.0), value: price, label: index.1)
        }
    }
    
    static func mockPositionBreakdown() -> [ChartDataPoint] {
        return [
            ChartDataPoint(x: 0, value: 6, label: "DEF"),
            ChartDataPoint(x: 1, value: 8, label: "MID"),
            ChartDataPoint(x: 2, value: 2, label: "RUC"),
            ChartDataPoint(x: 3, value: 6, label: "FWD")
        ]
    }
    
    static func mockVenueData() -> [ChartDataPoint] {
        return [
            ChartDataPoint(x: 0, value: 95.2, label: "MCG"),
            ChartDataPoint(x: 1, value: 87.8, label: "Marvel"),
            ChartDataPoint(x: 2, value: 102.4, label: "AO"),
            ChartDataPoint(x: 3, value: 78.9, label: "Gabba")
        ]
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, *)
struct Charts_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.l) {
                DSCard {
                    DSLineChart(
                        data: ChartDataPoint.mockFormData(),
                        title: "Recent Form",
                        color: DS.Colors.primary
                    )
                }
                
                DSCard {
                    DSBarChart(
                        data: ChartDataPoint.mockVenueData(),
                        title: "Venue Averages",
                        color: DS.Colors.success
                    )
                }
                
                DSCard {
                    DSPieChart(
                        data: ChartDataPoint.mockPositionBreakdown(),
                        title: "Team Structure"
                    )
                }
                
                DSCard {
                    DSProgressChart(
                        progress: 1247,
                        target: 1500,
                        title: "Round Score",
                        subtitle: "Target: 1500"
                    )
                }
            }
            .padding()
        }
    }
}
#endif

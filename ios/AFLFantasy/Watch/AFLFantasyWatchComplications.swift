import Foundation
import ClockKit
import SwiftUI
import WidgetKit

// MARK: - Watch Complication Provider
@available(watchOS 7.0, *)
struct AFLFantasyComplicationProvider: TimelineProvider {
    typealias Entry = AFLFantasyComplicationEntry
    
    // Placeholder data for when the complication hasn't loaded yet
    func placeholder(in context: Context) -> AFLFantasyComplicationEntry {
        AFLFantasyComplicationEntry(
            date: Date(),
            teamScore: 1250,
            ranking: 15420,
            captain: "P. Dangerfield",
            captainScore: 89,
            roundNumber: 1,
            status: .active
        )
    }
    
    // Current snapshot of the complication
    func getSnapshot(in context: Context, completion: @escaping (AFLFantasyComplicationEntry) -> ()) {
        Task {
            let entry = await getCurrentFantasyData()
            completion(entry)
        }
    }
    
    // Timeline of entries for the complication
    func getTimeline(in context: Context, completion: @escaping (Timeline<AFLFantasyComplicationEntry>) -> ()) {
        Task {
            let entries = await generateComplicationTimeline()
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func getCurrentFantasyData() async -> AFLFantasyComplicationEntry {
        // Fetch current data from MasterDataService or Watch Connectivity
        return AFLFantasyComplicationEntry(
            date: Date(),
            teamScore: 1250,
            ranking: 15420,
            captain: "P. Dangerfield",
            captainScore: 89,
            roundNumber: 1,
            status: .active
        )
    }
    
    private func generateComplicationTimeline() async -> [AFLFantasyComplicationEntry] {
        let now = Date()
        var entries: [AFLFantasyComplicationEntry] = []
        
        // Generate entries for the next 24 hours, updating every hour
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: now)!
            let entry = await getCurrentFantasyData()
            entry.date = entryDate
            entries.append(entry)
        }
        
        return entries
    }
}

// MARK: - Complication Entry Model
class AFLFantasyComplicationEntry: TimelineEntry, ObservableObject {
    var date: Date
    let teamScore: Int
    let ranking: Int
    let captain: String
    let captainScore: Int
    let roundNumber: Int
    let status: FantasyStatus
    
    init(date: Date, teamScore: Int, ranking: Int, captain: String, captainScore: Int, roundNumber: Int, status: FantasyStatus) {
        self.date = date
        self.teamScore = teamScore
        self.ranking = ranking
        self.captain = captain
        self.captainScore = captainScore
        self.roundNumber = roundNumber
        self.status = status
    }
}

enum FantasyStatus {
    case active
    case gameDay
    case tradeWindow
    case locked
}

// MARK: - Watch Complication Views
@available(watchOS 7.0, *)
struct AFLFantasyComplicationView: View {
    let entry: AFLFantasyComplicationEntry
    @Environment(\.complicationRenderingMode) var renderingMode
    
    var body: some View {
        switch renderingMode {
        case .accented:
            AccentedComplicationView(entry: entry)
        case .fullColor:
            FullColorComplicationView(entry: entry)
        case .vibrant:
            VibrantComplicationView(entry: entry)
        @unknown default:
            DefaultComplicationView(entry: entry)
        }
    }
}

// MARK: - Accented Complication View
@available(watchOS 7.0, *)
struct AccentedComplicationView: View {
    let entry: AFLFantasyComplicationEntry
    
    var body: some View {
        VStack(spacing: 1) {
            Text("AFL")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.accentColor)
            
            Text("\(entry.teamScore)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
        }
        .accessibilityLabel("AFL Fantasy team score: \(entry.teamScore) points")
    }
}

// MARK: - Full Color Complication View
@available(watchOS 7.0, *)
struct FullColorComplicationView: View {
    let entry: AFLFantasyComplicationEntry
    
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Image(systemName: statusIcon(for: entry.status))
                    .font(.system(size: 8))
                    .foregroundColor(statusColor(for: entry.status))
                
                Text("R\(entry.roundNumber)")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text("\(entry.teamScore)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
            
            Text("#\(formattedRanking(entry.ranking))")
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(.orange)
        }
        .accessibilityLabel("Round \(entry.roundNumber), team score \(entry.teamScore), ranked \(entry.ranking)")
    }
    
    private func statusIcon(for status: FantasyStatus) -> String {
        switch status {
        case .active:
            return "play.circle.fill"
        case .gameDay:
            return "sportscourt.fill"
        case .tradeWindow:
            return "arrow.triangle.2.circlepath"
        case .locked:
            return "lock.fill"
        }
    }
    
    private func statusColor(for status: FantasyStatus) -> Color {
        switch status {
        case .active:
            return .green
        case .gameDay:
            return .blue
        case .tradeWindow:
            return .orange
        case .locked:
            return .red
        }
    }
    
    private func formattedRanking(_ ranking: Int) -> String {
        if ranking < 1000 {
            return "\(ranking)"
        } else if ranking < 10000 {
            return "\(ranking / 1000).\(ranking % 1000 / 100)K"
        } else {
            return "\(ranking / 1000)K"
        }
    }
}

// MARK: - Vibrant Complication View
@available(watchOS 7.0, *)
struct VibrantComplicationView: View {
    let entry: AFLFantasyComplicationEntry
    
    var body: some View {
        VStack(spacing: 1) {
            Text("AFL")
                .font(.system(size: 9, weight: .semibold))
            
            Text("\(entry.teamScore)")
                .font(.system(size: 15, weight: .bold))
        }
    }
}

// MARK: - Default Complication View
@available(watchOS 7.0, *)
struct DefaultComplicationView: View {
    let entry: AFLFantasyComplicationEntry
    
    var body: some View {
        Text("\(entry.teamScore)")
            .font(.system(size: 16, weight: .bold))
            .accessibilityLabel("Fantasy score: \(entry.teamScore)")
    }
}

// MARK: - Circular Complication View
@available(watchOS 7.0, *)
struct CircularComplicationView: View {
    let entry: AFLFantasyComplicationEntry
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor, lineWidth: 2)
            
            VStack(spacing: -2) {
                Text("AFL")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("\(entry.teamScore)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .frame(width: 32, height: 32)
    }
}

// MARK: - Rectangular Complication View
@available(watchOS 7.0, *)
struct RectangularComplicationView: View {
    let entry: AFLFantasyComplicationEntry
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text("AFL Fantasy")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.accentColor)
                
                HStack {
                    Text("\(entry.teamScore)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("pts")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 1) {
                Text("Rank")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("#\(formattedRanking(entry.ranking))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 4)
        .accessibilityLabel("AFL Fantasy: \(entry.teamScore) points, ranked \(entry.ranking)")
    }
    
    private func formattedRanking(_ ranking: Int) -> String {
        if ranking < 1000 {
            return "\(ranking)"
        } else {
            return "\(ranking / 1000)K"
        }
    }
}

// MARK: - Captain Performance Complication
@available(watchOS 7.0, *)
struct CaptainComplicationView: View {
    let entry: AFLFantasyComplicationEntry
    
    var body: some View {
        VStack(spacing: 1) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.yellow)
                
                Text(captainInitials(entry.captain))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text("\(entry.captainScore)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.accentColor)
        }
        .accessibilityLabel("Captain \(entry.captain) scored \(entry.captainScore) points")
    }
    
    private func captainInitials(_ name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1))
        } else {
            return String(name.prefix(2))
        }
    }
}

// MARK: - Watch Complication Widget
@available(watchOS 7.0, *)
struct AFLFantasyComplication: Widget {
    let kind: String = "AFLFantasyComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AFLFantasyComplicationProvider()) { entry in
            AFLFantasyComplicationView(entry: entry)
        }
        .configurationDisplayName("AFL Fantasy")
        .description("Shows your AFL Fantasy team score and ranking")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

// MARK: - Widget Family Support
@available(watchOS 7.0, *)
extension AFLFantasyComplicationView {
    @ViewBuilder
    func familySpecificView() -> some View {
        switch Environment(\.widgetFamily).wrappedValue {
        case .accessoryCircular:
            CircularComplicationView(entry: entry)
        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)
        case .accessoryCorner:
            AccentedComplicationView(entry: entry)
        case .accessoryInline:
            Text("AFL: \(entry.teamScore)pts #\(entry.ranking)")
                .font(.system(size: 12, weight: .medium))
        default:
            DefaultComplicationView(entry: entry)
        }
    }
}

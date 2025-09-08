import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Design System

public enum DS {
    
    // MARK: - Spacing
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let s: CGFloat = 8
        public static let m: CGFloat = 12
        public static let l: CGFloat = 16
        public static let xl: CGFloat = 20
        public static let xxl: CGFloat = 24
        public static let xxxl: CGFloat = 32
        public static let huge: CGFloat = 40
    }
    
    // MARK: - Radius
    public enum Radius {
        public static let button: CGFloat = 8
        public static let card: CGFloat = 12
        public static let sheet: CGFloat = 16
        public static let dialog: CGFloat = 20
    }
    
    // MARK: - Shadow
    public enum Shadow {
        public static let low = (y: 2, blur: 8, opacity: 0.12)
        public static let mid = (y: 6, blur: 16, opacity: 0.16)
        public static let high = (y: 12, blur: 32, opacity: 0.2)
    }
    
    // MARK: - Motion
    public enum Motion {
        public static let short: TimeInterval = 0.12
        public static let standard: TimeInterval = 0.2
        public static let long: TimeInterval = 0.25
        
        public static var tasteful: Animation {
            #if canImport(UIKit)
            return UIAccessibility.isReduceMotionEnabled ? 
                .linear(duration: 0.01) : 
                .easeInOut(duration: standard)
            #else
            return .easeInOut(duration: standard)
            #endif
        }
    }
    
    // MARK: - Hit Targets
    public enum HitTarget {
        public static let minimum: CGFloat = 44
        public static let comfortable: CGFloat = 48
    }
}

// MARK: - Typography Extensions

@available(iOS 15.0, *)
public extension Font {
    static var aflLargeTitle: Font { .largeTitle.weight(.bold) }
    static var aflTitle: Font { .title.weight(.semibold) }
    @available(iOS 15.0, *)
    static var aflTitle2: Font { .title2.weight(.semibold) }
    static var aflHeadline: Font { .headline }
    static var aflSubheadline: Font { .subheadline }
    static var aflBody: Font { .body }
    static var aflCallout: Font { .callout }
    static var aflCaption: Font { .caption }
    @available(iOS 15.0, *)
    static var aflCaption2: Font { .caption2 }
}

// MARK: - Color Extensions

public extension Color {
    // AFL Brand Colors
    static let aflPrimary = Color("AFLPrimary")
    static let aflSecondary = Color("AFLSecondary") 
    static let aflAccent = Color("AFLAccent")
    
    // Semantic Colors
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    static let info = Color.blue
    
    // Surface Colors (HIG compliant)
    #if canImport(UIKit)
    static let surface = Color(UIColor.systemBackground)
    static let surfaceSecondary = Color(UIColor.secondarySystemBackground)
    static let surfaceTertiary = Color(UIColor.tertiarySystemBackground)
    
    // Text Colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    #else
    // Fallback colors for non-iOS platforms
    static let surface = Color.primary
    static let surfaceSecondary = Color.secondary
    static let surfaceTertiary = Color.secondary.opacity(0.5)
    
    // Text Colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color.secondary.opacity(0.6)
    #endif
}

// MARK: - Reusable Components

// MARK: - Primary Button
public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    
    public init(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.s) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                }
                
                Text(title)
                    .font(.aflHeadline)
                    .opacity(isLoading ? 0.6 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: DS.HitTarget.minimum)
            .padding(.horizontal, DS.Spacing.l)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isDisabled || isLoading)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
        .accessibilityLabel(Text(title))
        .accessibilityHint(isLoading ? Text("Loading") : Text(""))
    }
}

// MARK: - Card Component
public struct Card<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    public init(
        padding: CGFloat = DS.Spacing.l,
        cornerRadius: CGFloat = DS.Radius.card,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.surfaceSecondary)
                    .shadow(
                        color: .black.opacity(DS.Shadow.low.opacity),
                        radius: CGFloat(DS.Shadow.low.blur) / 2,
                        y: CGFloat(DS.Shadow.low.y)
                    )
            }
    }
}

// MARK: - Stat Chip
public struct StatChip: View {
    let title: String
    let value: String
    let trend: TrendDirection?
    
    public enum TrendDirection {
        case up, down, neutral
        
        var color: Color {
            switch self {
            case .up: return .success
            case .down: return .danger
            case .neutral: return .textSecondary
            }
        }
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }
    }
    
    public init(title: String, value: String, trend: TrendDirection? = nil) {
        self.title = title
        self.value = value
        self.trend = trend
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(title)
                .font(.aflCaption)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: DS.Spacing.xs) {
                Text(value)
                    .font(.aflSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                if let trend = trend {
                    Image(systemName: trend.icon)
                        .font(.caption2)
                        .foregroundColor(trend.color)
                }
            }
        }
        .padding(DS.Spacing.s)
        .background {
            RoundedRectangle(cornerRadius: DS.Radius.button)
                .fill(Color.surfaceTertiary)
        }
    }
}

// MARK: - Player Row Component
public struct PlayerRow: View {
    let player: AFLPlayer
    let showDetail: Bool
    let onTap: (() -> Void)?
    
    public init(player: AFLPlayer, showDetail: Bool = false, onTap: (() -> Void)? = nil) {
        self.player = player
        self.showDetail = showDetail
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: DS.Spacing.m) {
                // Player avatar placeholder
                Circle()
                    .fill(Color.surfaceTertiary)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(String(player.name.prefix(1)))
                            .font(.aflHeadline)
                            .foregroundColor(.textPrimary)
                    }
                
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(player.name)
                        .font(.aflSubheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: DS.Spacing.s) {
                        Text(player.team)
                            .font(.aflCaption)
                            .foregroundColor(.textSecondary)
                        
                        Text("•")
                            .font(.aflCaption)
                            .foregroundColor(.textSecondary)
                        
                        Text(player.position)
                            .font(.aflCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                    Text("$\(Int(player.price / 1000))k")
                        .font(.aflSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    if showDetail {
                        Text("\(Int(player.averageScore)) avg")
                            .font(.aflCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(.vertical, DS.Spacing.s)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

// MARK: - Loading View
public struct LoadingView: View {
    let message: String?
    
    public init(message: String? = "Loading...") {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: DS.Spacing.l) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.aflPrimary)
            
            if let message = message {
                Text(message)
                    .font(.aflCallout)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
    }
}

// MARK: - Error View
public struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    public init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: DS.Spacing.l) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.warning)
            
            Text("Something went wrong")
                .font(.aflTitle2)
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.aflBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.l)
            
            if let retryAction = retryAction {
                PrimaryButton(title: "Try Again") {
                    retryAction()
                }
                .padding(.horizontal, DS.Spacing.l)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
    }
}

import SwiftUI
import UIKit

// MARK: - Design System

/// AFL Fantasy Intelligence Design System following HIG guidelines
enum DS {
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xs: CGFloat = 4      // 4pt
        static let s: CGFloat = 8       // 8pt
        static let m: CGFloat = 12      // 12pt
        static let l: CGFloat = 16      // 16pt
        static let xl: CGFloat = 20     // 20pt
        static let xxl: CGFloat = 24    // 24pt
        static let xxxl: CGFloat = 32   // 32pt
        static let huge: CGFloat = 40   // 40pt
    }
    
    // MARK: - Typography
    
    enum Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
        
        // Custom styles
        static let heroNumber = Font.system(size: 48, weight: .bold, design: .rounded)
        static let statNumber = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let smallStat = Font.system(size: 16, weight: .medium, design: .rounded)
    }
    
    // MARK: - Colors
    
    enum Colors {
        // Primary colors
        static let primary = Color.blue
        static let primaryVariant = Color.blue.opacity(0.8)
        
        // Surface colors
        static let surface = Color(.systemBackground)
        static let surfaceSecondary = Color(.secondarySystemBackground)
        static let surfaceVariant = Color(.tertiarySystemBackground)
        
        // Content colors
        static let onSurface = Color(.label)
        static let onSurfaceSecondary = Color(.secondaryLabel)
        static let onSurfaceVariant = Color(.tertiaryLabel)
        
        // Semantic colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // AFL specific colors
        static let gain = Color.green
        static let loss = Color.red
        static let neutral = Color(.systemGray)
        
        // Position colors (for data visualization)
        static let defender = Color.blue
        static let midfielder = Color.purple
        static let ruck = Color.orange
        static let forward = Color.red
        
        static func positionColor(for position: Position) -> Color {
            switch position {
            case .defender: return defender
            case .midfielder: return midfielder
            case .ruck: return ruck
            case .forward: return forward
            }
        }
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 20
        static let round: CGFloat = 50  // For circular elements
    }
    
    // MARK: - Shadows
    
    enum Shadow {
        static let small = (
            color: Color.black.opacity(0.12),
            radius: 8.0,
            x: 0.0,
            y: 2.0
        )
        
        static let medium = (
            color: Color.black.opacity(0.16),
            radius: 16.0,
            x: 0.0,
            y: 6.0
        )
        
        static let large = (
            color: Color.black.opacity(0.2),
            radius: 32.0,
            x: 0.0,
            y: 12.0
        )
    }
    
    // MARK: - Motion
    
    enum Motion {
        static let fast = Animation.easeInOut(duration: 0.2)
        static let standard = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.5)
        
        // Respects accessibility settings
        static var accessible: Animation {
            UIAccessibility.isReduceMotionEnabled ? .linear(duration: 0.01) : standard
        }
    }
    
    // MARK: - Hit Targets
    
    enum HitTarget {
        static let minimum: CGFloat = 44  // HIG minimum
        static let comfortable: CGFloat = 48
        static let large: CGFloat = 56
    }
}

// MARK: - Design System Components

struct DSCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    
    init(padding: CGFloat = DS.Spacing.l, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(DS.Colors.surface)
            .cornerRadius(DS.CornerRadius.medium)
            .shadow(
                color: DS.Shadow.small.color,
                radius: DS.Shadow.small.radius,
                x: DS.Shadow.small.x,
                y: DS.Shadow.small.y
            )
    }
}

struct DSButton: View {
    enum Style {
        case primary
        case secondary
        case outline
        case ghost
    }
    
    let title: String
    let style: Style
    let action: () -> Void
    
    init(_ title: String, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DS.Typography.headline)
                .foregroundColor(foregroundColor)
                .frame(minHeight: DS.HitTarget.minimum)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DS.Spacing.l)
                .background(backgroundColor)
                .cornerRadius(DS.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.CornerRadius.small)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DS.Colors.primary
        case .secondary:
            return DS.Colors.surfaceSecondary
        case .outline, .ghost:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return DS.Colors.onSurface
        case .outline, .ghost:
            return DS.Colors.primary
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .outline:
            return DS.Colors.primary
        default:
            return Color.clear
        }
    }
    
    private var strokeWidth: CGFloat {
        style == .outline ? 1 : 0
    }
}

struct DSStatCard: View {
    let title: String
    let value: String
    let trend: Trend?
    let icon: String?
    
    enum Trend {
        case up(String)
        case down(String)
        case neutral
        
        var color: Color {
            switch self {
            case .up: return DS.Colors.success
            case .down: return DS.Colors.error
            case .neutral: return DS.Colors.neutral
            }
        }
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var text: String {
            switch self {
            case .up(let value): return value
            case .down(let value): return value
            case .neutral: return ""
            }
        }
    }
    
    var body: some View {
        DSCard {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    HStack {
                        if let icon = icon {
                            Image(systemName: icon)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }
                        Text(title)
                            .font(DS.Typography.subheadline)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                    
                    Text(value)
                        .font(DS.Typography.statNumber)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    if let trend = trend, !trend.text.isEmpty {
                        HStack(spacing: DS.Spacing.xs) {
                            Image(systemName: trend.icon)
                                .font(.caption)
                            Text(trend.text)
                                .font(DS.Typography.caption)
                        }
                        .foregroundColor(trend.color)
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Accessibility Helpers

extension View {
    func dsAccessibility(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    func dsMinimumHitTarget() -> some View {
        self.frame(minWidth: DS.HitTarget.minimum, minHeight: DS.HitTarget.minimum)
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct DSPreviewCard: View {
    var body: some View {
        VStack(spacing: DS.Spacing.l) {
            DSStatCard(
                title: "Current Score",
                value: "1,247",
                trend: .up("+12.3%"),
                icon: "chart.line.uptrend.xyaxis"
            )
            
            DSButton("Primary Button") { }
            DSButton("Secondary Button", style: .secondary) { }
            DSButton("Outline Button", style: .outline) { }
        }
        .padding()
    }
}

struct DesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        DSPreviewCard()
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        
        DSPreviewCard()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
}
#endif

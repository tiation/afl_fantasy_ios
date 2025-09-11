import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - DesignSystem

/// AFL Fantasy Intelligence Design System following HIG guidelines
enum DesignSystem {
    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 2 // 2pt
        static let xs: CGFloat = 4 // 4pt
        static let small: CGFloat = 8 // 8pt
        static let medium: CGFloat = 12 // 12pt
        static let large: CGFloat = 16 // 16pt
        static let xl: CGFloat = 20 // 20pt
        static let xxl: CGFloat = 24 // 24pt
        static let xxxl: CGFloat = 32 // 32pt
        static let huge: CGFloat = 40 // 40pt

        // Legacy compatibility
        static let s: CGFloat = small
        static let m: CGFloat = medium
        static let l: CGFloat = large
    }

    // MARK: - Typography

    enum Typography {
        // System typography - Enhanced
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
        static let overline = Font.system(size: 10, weight: .medium).uppercaseSmallCaps()

        // Custom styles - Premium design
        static let heroNumber = Font.system(size: 56, weight: .black, design: .rounded)
        static let largeNumber = Font.system(size: 32, weight: .bold, design: .rounded)
        static let statNumber = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let smallStat = Font.system(size: 16, weight: .medium, design: .rounded)
        static let microStat = Font.system(size: 12, weight: .medium, design: .rounded)
        
        // Brand specific typography
        static let brandTitle = Font.custom("SF Pro Display", size: 28).weight(.bold)
        static let brandHeadline = Font.custom("SF Pro Display", size: 20).weight(.semibold)
        static let brandBody = Font.custom("SF Pro Text", size: 16).weight(.regular)
        
        // Specialized typography
        static let alertTitle = Font.system(size: 16, weight: .semibold, design: .default)
        static let alertBody = Font.system(size: 14, weight: .regular, design: .default)
        static let badge = Font.system(size: 10, weight: .bold, design: .rounded).uppercaseSmallCaps()
        static let price = Font.system(size: 18, weight: .medium, design: .monospaced)
    }

    // MARK: - Colors

    enum Colors {
        // AFL Fantasy Brand Colors - Premium palette
        static let aflRed = Color(red: 0.86, green: 0.15, blue: 0.26) // #DC263E - AFL Red
        static let aflBlue = Color(red: 0.02, green: 0.32, blue: 0.64) // #0551A3 - AFL Blue
        static let aflGold = Color(red: 1.0, green: 0.71, blue: 0.06) // #FFB50F - AFL Gold
        
        // Primary colors - Enhanced with gradients
        static let primary = aflBlue
        static let primaryVariant = Color(red: 0.05, green: 0.4, blue: 0.75)
        static let primaryLight = Color(red: 0.4, green: 0.6, blue: 0.9)
        static let secondary = Color(.systemGray)
        static let secondaryVariant = Color(.systemGray2)
        static let accent = aflGold
        static let accentSecondary = aflRed
        
        // Gradient definitions
        static let primaryGradient = LinearGradient(
            colors: [primary, primaryVariant],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let accentGradient = LinearGradient(
            colors: [accent, Color(red: 1.0, green: 0.8, blue: 0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let redGradient = LinearGradient(
            colors: [aflRed, Color(red: 1.0, green: 0.3, blue: 0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Surface colors - Enhanced hierarchy
        static let surface = Color(.systemBackground)
        static let surfaceSecondary = Color(.secondarySystemBackground)
        static let surfaceVariant = Color(.tertiarySystemBackground)
        static let surfaceElevated = Color(.systemBackground)
        static let background = Color(.systemBackground)

        // Content colors - Better contrast
        static let onSurface = Color(.label)
        static let onSurfaceSecondary = Color(.secondaryLabel)
        static let onSurfaceVariant = Color(.tertiaryLabel)
        static let onPrimary = Color.white
        static let onAccent = Color.black
        
        // Border colors - More subtle
        static let outline = Color(.separator)
        static let outlineVariant = Color(.separator).opacity(0.3)

        // Semantic colors - More vibrant and accessible
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35) // #34C759
        static let successLight = Color(red: 0.4, green: 0.9, blue: 0.5)
        static let warning = Color(red: 1.0, green: 0.58, blue: 0.0) // #FF9500  
        static let warningLight = Color(red: 1.0, green: 0.8, blue: 0.4)
        static let error = Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30
        static let errorLight = Color(red: 1.0, green: 0.5, blue: 0.5)
        static let info = primary
        static let infoLight = primaryLight

        // AFL specific colors - Enhanced with variations
        static let gain = success
        static let gainLight = successLight
        static let loss = error
        static let lossLight = errorLight
        static let neutral = Color(.systemGray)
        static let neutralLight = Color(.systemGray2)

        // Position colors - More distinct and vibrant
        static let defender = Color(red: 0.20, green: 0.60, blue: 1.0) // Bright Blue
        static let midfielder = Color(red: 0.70, green: 0.30, blue: 1.0) // Purple
        static let ruck = Color(red: 1.0, green: 0.65, blue: 0.0) // Orange
        static let forward = Color(red: 1.0, green: 0.30, blue: 0.30) // Red
        
        // Position gradients
        static func positionGradient(for position: Position) -> LinearGradient {
            switch position {
            case .defender:
                return LinearGradient(
                    colors: [defender, Color(red: 0.4, green: 0.7, blue: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .midfielder:
                return LinearGradient(
                    colors: [midfielder, Color(red: 0.8, green: 0.5, blue: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .ruck:
                return LinearGradient(
                    colors: [ruck, Color(red: 1.0, green: 0.8, blue: 0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .forward:
                return LinearGradient(
                    colors: [forward, Color(red: 1.0, green: 0.5, blue: 0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }

        static func positionColor(for position: Position) -> Color {
            switch position {
            case .defender: defender
            case .midfielder: midfielder
            case .ruck: ruck
            case .forward: forward
            }
        }
        
        // Status colors for alerts and notifications
        static let critical = Color(red: 0.9, green: 0.1, blue: 0.1)
        static let high = warning
        static let medium = Color(red: 0.2, green: 0.5, blue: 1.0)
        static let low = neutral
        
        // Shadow color
        static let shadow = Color.black
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 20
        static let round: CGFloat = 50 // For circular elements
    }

    // MARK: - Shadows

    enum Shadow {
        // Subtle elevation shadows
        static let none = (
            color: Color.clear,
            radius: 0.0,
            x: 0.0,
            y: 0.0
        )
        
        static let small = (
            color: Color.black.opacity(0.08),
            radius: 4.0,
            x: 0.0,
            y: 2.0
        )

        static let medium = (
            color: Color.black.opacity(0.12),
            radius: 8.0,
            x: 0.0,
            y: 4.0
        )
        
        static let large = (
            color: Color.black.opacity(0.16),
            radius: 16.0,
            x: 0.0,
            y: 8.0
        )

        static let xlarge = (
            color: Color.black.opacity(0.2),
            radius: 32.0,
            x: 0.0,
            y: 16.0
        )
        
        // Colored shadows for premium effects
        static let primaryGlow = (
            color: Colors.aflBlue.opacity(0.3),
            radius: 12.0,
            x: 0.0,
            y: 4.0
        )
        
        static let accentGlow = (
            color: Colors.aflGold.opacity(0.4),
            radius: 8.0,
            x: 0.0,
            y: 2.0
        )
        
        static let errorGlow = (
            color: Color.red.opacity(0.3),
            radius: 8.0,
            x: 0.0,
            y: 2.0
        )
    }

// MARK: - Motion

    enum Motion {
        // Premium spring animations for modern iOS feel
        static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let springFast = Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let springSlow = Animation.spring(response: 0.8, dampingFraction: 0.9)
        
        // Standard easing animations
        static let fast = Animation.easeInOut(duration: 0.2)
        static let standard = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.5)
        
        // Specialized animations
        static let bounce = Animation.interpolatingSpring(mass: 1.0, stiffness: 100, damping: 10)
        static let gentle = Animation.easeOut(duration: 0.4)
        static let snappy = Animation.easeInOut(duration: 0.15)

        // Respects accessibility settings
        @MainActor
        static var accessible: Animation {
            UIAccessibility.isReduceMotionEnabled ? .linear(duration: 0.01) : spring
        }
        
        @MainActor
        static var accessibleFast: Animation {
            UIAccessibility.isReduceMotionEnabled ? .linear(duration: 0.01) : springFast
        }
    }

    // MARK: - Hit Targets

    enum HitTarget {
        static let minimum: CGFloat = 44 // HIG minimum
        static let comfortable: CGFloat = 48
        static let large: CGFloat = 56
    }
}

// MARK: - DSCard

struct DSCard<Content: View>: View {
    enum Style {
        case standard
        case elevated
        case gradient(LinearGradient)
        case bordered
        case glass
    }
    
    let content: Content
    let padding: CGFloat
    let style: Style

    init(padding: CGFloat = DS.Spacing.l, style: Style = .standard, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundView)
            .cornerRadius(DS.CornerRadius.medium)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowX,
                y: shadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .standard:
            DS.Colors.surface
        case .elevated:
            DS.Colors.surface
        case .gradient(let gradient):
            gradient
        case .bordered:
            DS.Colors.surface
        case .glass:
            DS.Colors.surface.opacity(0.8)
                .background(.ultraThinMaterial)
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .standard:
            DS.Shadow.small.color
        case .elevated:
            DS.Shadow.medium.color
        case .gradient:
            DS.Shadow.medium.color
        case .bordered:
            DS.Shadow.none.color
        case .glass:
            DS.Shadow.small.color
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .standard:
            DS.Shadow.small.radius
        case .elevated:
            DS.Shadow.medium.radius
        case .gradient:
            DS.Shadow.medium.radius
        case .bordered:
            DS.Shadow.none.radius
        case .glass:
            DS.Shadow.small.radius
        }
    }
    
    private var shadowX: CGFloat {
        switch style {
        case .standard:
            DS.Shadow.small.x
        case .elevated:
            DS.Shadow.medium.x
        case .gradient:
            DS.Shadow.medium.x
        case .bordered:
            DS.Shadow.none.x
        case .glass:
            DS.Shadow.small.x
        }
    }
    
    private var shadowY: CGFloat {
        switch style {
        case .standard:
            DS.Shadow.small.y
        case .elevated:
            DS.Shadow.medium.y
        case .gradient:
            DS.Shadow.medium.y
        case .bordered:
            DS.Shadow.none.y
        case .glass:
            DS.Shadow.small.y
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .bordered:
            DS.Colors.outline
        default:
            Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .bordered:
            1
        default:
            0
        }
    }
}

// MARK: - DSGradientCard

struct DSGradientCard<Content: View>: View {
    let content: Content
    let gradient: LinearGradient
    let padding: CGFloat

    init(gradient: LinearGradient, padding: CGFloat = DS.Spacing.l, @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(gradient)
            .cornerRadius(DS.CornerRadius.medium)
            .shadow(
                color: DS.Shadow.medium.color,
                radius: DS.Shadow.medium.radius,
                x: DS.Shadow.medium.x,
                y: DS.Shadow.medium.y
            )
    }
}

// MARK: - DSProgressRing

struct DSProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    let backgroundColor: Color
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, 
         size: CGFloat = 60, 
         lineWidth: CGFloat = 6,
         color: Color = DS.Colors.primary,
         backgroundColor: Color = DS.Colors.outline.opacity(0.3)) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.2), value: animatedProgress)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - DSAnimatedCounter

struct DSAnimatedCounter: View {
    let value: Double
    let font: Font
    let color: Color
    
    @State private var displayValue: Double = 0
    
    init(
        value: Double,
        font: Font = DS.Typography.statNumber,
        color: Color = DS.Colors.onSurface
    ) {
        self.value = value
        self.font = font
        self.color = color
    }
    
    // Convenience init for Int values
    init(
        value: Int,
        font: Font = DS.Typography.statNumber,
        color: Color = DS.Colors.onSurface
    ) {
        self.value = Double(value)
        self.font = font
        self.color = color
    }
    
    var body: some View {
        Text("\(Int(displayValue))")
            .font(font)
            .foregroundColor(color)
            .accessibilityValue(Text("\(Int(displayValue))"))
            .onAppear {
                animateCounter()
            }
            .onChange(of: value) { _, _ in
                animateCounter()
            }
    }
    
    private func animateCounter() {
        // Respect accessibility preference for reduced motion
        if UIAccessibility.isReduceMotionEnabled {
            displayValue = value
            return
        }
        
        let duration = 1.2
        let startValue = displayValue
        let endValue = value
        
        withAnimation(.easeOut(duration: duration)) {
            displayValue = endValue
        }
        
        // Use Timer for smooth incremental updates
        let steps = 60
        let stepDuration = duration / Double(steps)
        let increment = (endValue - startValue) / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                if i == steps {
                    displayValue = endValue
                } else {
                    displayValue = startValue + increment * Double(i)
                }
            }
        }
    }
}

// MARK: - DSStatusBadge

struct DSStatusBadge: View {
    enum Style {
        case success
        case warning
        case error
        case info
        case neutral
        case custom(Color)
    }
    
    let text: String
    let style: Style
    
    var body: some View {
        Text(text)
            .font(DS.Typography.badge)
            .foregroundColor(.white)
            .padding(.horizontal, DS.Spacing.s)
            .padding(.vertical, DS.Spacing.xs)
            .background(backgroundColor)
            .cornerRadius(DS.CornerRadius.small)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .success:
            return DS.Colors.success
        case .warning:
            return DS.Colors.warning
        case .error:
            return DS.Colors.error
        case .info:
            return DS.Colors.info
        case .neutral:
            return DS.Colors.neutral
        case .custom(let color):
            return color
        }
    }
}

// MARK: - DSButton

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
            DS.Colors.primary
        case .secondary:
            DS.Colors.surfaceSecondary
        case .outline, .ghost:
            Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            .white
        case .secondary:
            DS.Colors.onSurface
        case .outline, .ghost:
            DS.Colors.primary
        }
    }

    private var strokeColor: Color {
        switch style {
        case .outline:
            DS.Colors.primary
        default:
            Color.clear
        }
    }

    private var strokeWidth: CGFloat {
        style == .outline ? 1 : 0
    }
}

// MARK: - DSStatCard

struct DSStatCard: View {
    enum Style {
        case standard
        case gradient
        case minimal
        case prominent
    }
    
    let title: String
    let value: String
    let trend: Trend?
    let icon: String?
    let style: Style
    let animated: Bool

    enum Trend {
        case up(String)
        case down(String)
        case neutral

        var color: Color {
            switch self {
            case .up: DS.Colors.success
            case .down: DS.Colors.error
            case .neutral: DS.Colors.neutral
            }
        }
        
        var lightColor: Color {
            switch self {
            case .up: DS.Colors.successLight
            case .down: DS.Colors.errorLight
            case .neutral: DS.Colors.neutralLight
            }
        }

        var icon: String {
            switch self {
            case .up: "arrow.up.right"
            case .down: "arrow.down.right"
            case .neutral: "minus"
            }
        }

        var text: String {
            switch self {
            case let .up(value): value
            case let .down(value): value
            case .neutral: ""
            }
        }
    }
    
    init(title: String,
         value: String,
         trend: Trend? = nil,
         icon: String? = nil,
         style: Style = .standard,
         animated: Bool = true) {
        self.title = title
        self.value = value
        self.trend = trend
        self.icon = icon
        self.style = style
        self.animated = animated
    }

    var body: some View {
        Group {
            switch style {
            case .standard:
                standardCard
            case .gradient:
                gradientCard
            case .minimal:
                minimalCard
            case .prominent:
                prominentCard
            }
        }
    }
    
    private var standardCard: some View {
        DSCard {
            cardContent
        }
    }
    
    private var gradientCard: some View {
        DSCard(style: .gradient(trendGradient ?? DS.Colors.primaryGradient)) {
            cardContent
                .foregroundColor(.white)
        }
    }
    
    private var minimalCard: some View {
        DSCard(style: .bordered) {
            cardContent
        }
    }
    
    private var prominentCard: some View {
        DSCard(style: .elevated) {
            cardContent
        }
        .shadow(
            color: DS.Shadow.primaryGlow.color,
            radius: DS.Shadow.primaryGlow.radius,
            x: DS.Shadow.primaryGlow.x,
            y: DS.Shadow.primaryGlow.y
        )
    }
    
    private var cardContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                // Title and Icon
                HStack(spacing: DS.Spacing.xs) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(iconColor)
                    }
                    Text(title)
                        .font(DS.Typography.subheadline)
                        .foregroundColor(titleColor)
                }

                // Value with animation
                if animated, let numericValue = Int(value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) {
                    DSAnimatedCounter(value: numericValue, font: DS.Typography.statNumber, color: valueColor)
                } else {
                    Text(value)
                        .font(DS.Typography.statNumber)
                        .foregroundColor(valueColor)
                }

                // Trend indicator
                if let trend, !trend.text.isEmpty {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: trend.icon)
                            .font(.caption2)
                            .fontWeight(.semibold)
                        Text(trend.text)
                            .font(DS.Typography.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(style == .gradient ? .white.opacity(0.9) : trend.color)
                    .padding(.horizontal, DS.Spacing.xs)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(style == .gradient ? .white.opacity(0.2) : trend.lightColor)
                    )
                }
            }

            Spacer()
            
            // Optional progress indicator
            if let trend = trend, trend.text.contains("%") {
                let progress = extractPercentage(from: trend.text)
                DSProgressRing(
                    progress: progress,
                    size: 40,
                    lineWidth: 4,
                    color: style == .gradient ? .white : trend.color
                )
            }
        }
    }
    
    private var trendGradient: LinearGradient? {
        guard let trend = trend else { return nil }
        
        switch trend {
        case .up:
            return LinearGradient(
                colors: [DS.Colors.success, DS.Colors.successLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .down:
            return LinearGradient(
                colors: [DS.Colors.error, DS.Colors.errorLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .neutral:
            return DS.Colors.primaryGradient
        }
    }
    
    private var iconColor: Color {
        style == .gradient ? .white.opacity(0.8) : DS.Colors.onSurfaceSecondary
    }
    
    private var titleColor: Color {
        style == .gradient ? .white.opacity(0.9) : DS.Colors.onSurfaceSecondary
    }
    
    private var valueColor: Color {
        style == .gradient ? .white : DS.Colors.onSurface
    }
    
    private func extractPercentage(from text: String) -> Double {
        let numbers = text.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return (Double(numbers) ?? 0) / 100.0
    }
}

// MARK: - Accessibility Helpers

extension View {
    func dsAccessibility(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }

    func dsMinimumHitTarget() -> some View {
        frame(minWidth: DS.HitTarget.minimum, minHeight: DS.HitTarget.minimum)
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

                DSButton("Primary Button") {}
                DSButton("Secondary Button", style: .secondary) {}
                DSButton("Outline Button", style: .outline) {}
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

// MARK: - Backward Compatibility

/// Legacy typealias for backward compatibility
typealias DS = DesignSystem

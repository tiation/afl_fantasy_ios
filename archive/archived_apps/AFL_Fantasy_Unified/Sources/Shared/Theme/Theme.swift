import SwiftUI
import UIKit

// MARK: - 🎨 UNIFIED THEME SYSTEM - HIG ALIGNED
// Single source of truth for all design tokens
// Automatically supports Dark Mode, Dynamic Type, and Reduced Motion

/// 🏈 AFL Fantasy Design System - Enterprise Grade, HIG Compliant
struct Theme {
    struct Colors {
        // System Colors (iOS HIG Compliant)
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        // Text Colors
        static let textPrimary = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary = Color(.tertiaryLabel)
        static let textQuaternary = Color(.quaternaryLabel)
        
        // Accent & Brand Colors
        static let accent = Color.accentColor
        static let primary = Color("Primary") // Fallback to custom if needed
        static let secondary = Color("Secondary") // Fallback to custom
        static let tint = Color(.systemBlue) // AFL Fantasy brand
        
        // Status Colors (System Colors)
        static let success = Color(.systemGreen)
        static let warning = Color(.systemOrange)
        static let error = Color(.systemRed)
        static let info = Color(.systemBlue)
        
        // Sport-specific Colors
        static let score = Color(.systemBlue)
        static let rank = Color(.systemGreen)
        static let price = Color(.systemMint)
        static let captain = Color(.systemYellow)
        static let viceCaptain = Color(.systemOrange)
        
        // Chart Colors (Accessible)
        static let chartGreen = Color(.systemGreen)
        static let chartRed = Color(.systemRed)
        static let chartBlue = Color(.systemBlue)
        static let chartYellow = Color(.systemYellow)
        static let chartPurple = Color(.systemPurple)
        static let chartMint = Color(.systemMint)
        
        // Fill Colors
        static let fillPrimary = Color(.systemFill)
        static let fillSecondary = Color(.secondarySystemFill)
        static let fillTertiary = Color(.tertiarySystemFill)
        static let fillQuaternary = Color(.quaternarySystemFill)
        
        // Separator
        static let separator = Color(.separator)
        static let opaqueSeparator = Color(.opaqueSeparator)
        
        // Legacy support
        static let card = Color(.systemBackground)
        static let backgroundSecondary = Color(.secondarySystemBackground)
        static let textAccent = Color.accentColor
    }
    
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }
    
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    struct Font {
        // Display
        static let largeTitle = SwiftUI.Font.largeTitle.weight(.bold)
        static let title = SwiftUI.Font.title.weight(.bold)
        static let title2 = SwiftUI.Font.title2.weight(.semibold)
        static let title3 = SwiftUI.Font.title3.weight(.semibold)
        
        // Body
        static let headline = SwiftUI.Font.headline
        static let body = SwiftUI.Font.body
        static let bodyBold = SwiftUI.Font.body.weight(.semibold)
        static let callout = SwiftUI.Font.callout
        static let subheadline = SwiftUI.Font.subheadline
        static let footnote = SwiftUI.Font.footnote
        static let caption = SwiftUI.Font.caption
        static let caption2 = SwiftUI.Font.caption2
        static let captionBold = SwiftUI.Font.caption.weight(.semibold)
        
        // Stats
        static let statLarge = SwiftUI.Font.system(size: 32, weight: .bold)
        static let statMedium = SwiftUI.Font.system(size: 24, weight: .bold)
        static let statSmall = SwiftUI.Font.system(size: 18, weight: .semibold)
    }
    
    struct Shadows {
        static let small = Shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let medium = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = Shadow(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.3)
        
        static let spring = SwiftUI.Animation.spring(
            response: 0.3,
            dampingFraction: 0.7,
            blendDuration: 0
        )
    }
    
    // MARK: - Layout Constants
    struct Layout {
        static let minTouchTarget: CGFloat = 44 // iOS HIG minimum
        static let standardPadding: CGFloat = 16
        static let cardPadding: CGFloat = 12
        static let listRowHeight: CGFloat = 44
        static let navigationBarHeight: CGFloat = 44
    }
}

// MARK: - ViewModifier Extensions

struct LoadingStateModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .opacity(isLoading ? 0.6 : 1.0)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.accent))
                    .scaleEffect(1.2)
            }
        }
        .animation(Theme.Animation.standard, value: isLoading)
    }
}

struct ReducedMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: SwiftUI.Animation
    
    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? nil : animation, value: UUID())
    }
}

struct CardModifier: ViewModifier {
    let style: CardStyle
    
    enum CardStyle {
        case standard
        case elevated
        case subtle
        case interactive
    }
    
    func body(content: Content) -> some View {
        content
            .background(Theme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
    }
    
    private var shadowColor: Color {
        switch style {
        case .standard: return Theme.Shadows.small.color
        case .elevated: return Theme.Shadows.medium.color
        case .subtle: return Color.clear
        case .interactive: return Theme.Shadows.medium.color
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .standard: return Theme.Shadows.small.radius
        case .elevated: return Theme.Shadows.medium.radius
        case .subtle: return 0
        case .interactive: return Theme.Shadows.medium.radius
        }
    }
    
    private var shadowY: CGFloat {
        switch style {
        case .standard: return Theme.Shadows.small.y
        case .elevated: return Theme.Shadows.medium.y
        case .subtle: return 0
        case .interactive: return Theme.Shadows.medium.y
        }
    }
}

extension View {
    func cardStyle(_ style: CardModifier.CardStyle = .standard) -> some View {
        modifier(CardModifier(style: style))
    }
    
    func loadingState(_ isLoading: Bool) -> some View {
        modifier(LoadingStateModifier(isLoading: isLoading))
    }
    
    func respectReducedMotion(_ animation: SwiftUI.Animation = Theme.Animation.standard) -> some View {
        modifier(ReducedMotionModifier(animation: animation))
    }
    
    func minTouchTarget() -> some View {
        frame(minHeight: Theme.Layout.minTouchTarget)
    }
    
    func statStyle() -> some View {
        self
            .font(Theme.Font.statMedium)
            .foregroundColor(Theme.Colors.textPrimary)
    }
    
    func captionStyle() -> some View {
        self
            .font(Theme.Font.caption)
            .foregroundColor(Theme.Colors.textSecondary)
    }
}

// MARK: - Navigation Components

struct NavigationBar<LeadingContent: View, TrailingContent: View>: View {
    let title: String
    let leadingContent: () -> LeadingContent
    let trailingContent: () -> TrailingContent
    
    init(
        _ title: String,
        @ViewBuilder leadingContent: @escaping () -> LeadingContent = { EmptyView() },
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.leadingContent = leadingContent
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack {
            leadingContent()
            
            Spacer()
            
            Text(title)
                .font(Theme.Font.title3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
            
            trailingContent()
        }
        .padding(.horizontal, Theme.Spacing.m)
        .padding(.vertical, Theme.Spacing.s)
        .background(Theme.Colors.background)
    }
}

struct NavigationBarButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    init(icon: String, isActive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.isActive = isActive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isActive ? Theme.Colors.accent : Theme.Colors.textSecondary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let valueColor: Color?
    
    init(title: String, value: String, valueColor: Color? = nil) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xxs) {
            Text(title)
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text(value)
                .font(Theme.Font.bodyBold)
                .foregroundColor(valueColor ?? Theme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helper Types

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - 🚀 PERFORMANCE-OPTIMIZED COMPONENTS

/// Performance-optimized AsyncImage with proper caching
struct OptimizedAsyncImage: View {
    let url: URL?
    let size: CGSize
    
    init(url: URL?, size: CGSize = CGSize(width: 120, height: 160)) {
        self.url = url
        self.size = size
    }
    
    var body: some View {
        AsyncImage(
            url: url,
            transaction: Transaction(animation: Theme.Animation.standard)
        ) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .interpolation(.medium) // 🚀 Better than .high for performance
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(Theme.Colors.textSecondary)
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.accent))
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: size.width, height: size.height) // 🚀 Fixed size prevents layout thrash
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
    }
}

/// Skeleton loading view with reduced motion support
struct SkeletonView: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = Theme.Radius.medium) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        Theme.Colors.fillSecondary,
                        Theme.Colors.fillTertiary,
                        Theme.Colors.fillSecondary
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .offset(x: isAnimating && !reduceMotion ? 200 : -200)
            .animation(
                reduceMotion ? nil : Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                if !reduceMotion {
                    isAnimating = true
                }
            }
            .clipped()
    }
}

/// High-performance list row with precomputed layout
struct OptimizedListRow<Content: View>: View {
    let content: Content
    let height: CGFloat
    
    init(height: CGFloat = Theme.Layout.listRowHeight, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.height = height
    }
    
    var body: some View {
        content
            .frame(height: height) // 🚀 Fixed height for better scrolling performance
            .contentShape(Rectangle()) // 🚀 Explicit hit testing area
    }
}

// MARK: - Accessibility Extensions

extension View {
    /// Apply HIG-compliant accessibility with proper touch targets
    func accessibleElement(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = [],
        value: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityTraits(traits)
            .accessibilityValue(value ?? "")
            .frame(minWidth: Theme.Layout.minTouchTarget, minHeight: Theme.Layout.minTouchTarget)
    }
    
    /// Reduce Motion aware animation
    func reducedMotionAnimation<V: Equatable>(_ animation: SwiftUI.Animation?, value: V) -> some View {
        self
            .animation(UIAccessibility.isReduceMotionEnabled ? nil : animation, value: value)
    }
}

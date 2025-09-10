import SwiftUI

// MARK: - DS Extensions for Advanced Filters

extension DS {
    struct Motion {
        static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.2)
        static let springFast = Animation.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0.1)
    }
    
    struct CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xl: CGFloat = 16
    }
    
    struct Shadow {
        static let large = ShadowStyle(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - DS Extensions for Position Colors

extension DS.Colors {
    static func positionColor(for position: Position) -> Color {
        switch position {
        case .defender: return .blue
        case .midfielder: return .green
        case .ruck: return .orange
        case .forward: return .red
        }
    }
    
    static var info: Color { .blue }
    static var surfaceSecondary: Color { Color(UIColor.secondarySystemBackground) }
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static var accent: Color { .orange }
}

// MARK: - DSToggleStyle

struct DSToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? DS.Colors.primary : Color(UIColor.systemGray4))
                .frame(width: 44, height: 24)
                .overlay(
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .offset(x: configuration.isOn ? 8 : -8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

// MARK: - PerformanceSlider

struct PerformanceSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack {
                Text(title)
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurface)
                
                Spacer()
                
                Text(String(format: "%.1f", value))
                    .font(DS.Typography.body)
                    .foregroundColor(color)
                    .fontWeight(.medium)
            }
            
            Slider(value: $value, in: range)
                .tint(color)
        }
    }
}

// MARK: - DSAccessibility

extension View {
    func dsAccessibility(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}

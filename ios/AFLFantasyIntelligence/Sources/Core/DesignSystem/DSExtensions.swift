import SwiftUI

// MARK: - Design System Extensions

// MARK: - Position Colors
extension Position {
    var color: Color {
        switch self {
        case .defender: return .blue
        case .midfielder: return .green
        case .ruck: return .purple
        case .forward: return .red
        }
    }
}

// MARK: - Enhanced Toggle Style
struct DSToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Button(action: { configuration.isOn.toggle() }) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? DS.Colors.primary : DS.Colors.surface)
                    .frame(width: 44, height: 24)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 20, height: 20)
                            .offset(x: configuration.isOn ? 8 : -8)
                            .animation(.spring(response: 0.3), value: configuration.isOn)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Performance Slider
struct PerformanceSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack {
                Text(title)
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurface)
                Spacer()
                Text("\(Int(value))\(unit)")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .padding(.horizontal, DS.Spacing.xs)
                    .padding(.vertical, DS.Spacing.xxs)
                    .background(DS.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(DS.Colors.primary)
        }
    }
}

// MARK: - Chip View
struct ChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DS.Typography.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : DS.Colors.onSurface)
                .padding(.horizontal, DS.Spacing.m)
                .padding(.vertical, DS.Spacing.s)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? DS.Colors.primary : DS.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(DS.Colors.outline, lineWidth: isSelected ? 0 : 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Loading States
struct LoadingDots: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(DS.Colors.primary)
                    .frame(width: 6, height: 6)
                    .scaleEffect(animating ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - View Extensions
extension View {
    func dsCardShadow() -> some View {
        self.shadow(
            color: DS.Colors.shadow.opacity(0.1),
            radius: 8,
            x: 0,
            y: 2
        )
    }
    
    func dsButtonPress(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    /// Adds proper padding for the floating tab bar at the bottom
    /// Use this for ScrollView content that needs to be scrollable above the floating tab bar
    func dsFloatingTabBarPadding() -> some View {
        self.padding(.bottom, 104) // 80pt tab bar height + 8pt bottom padding + 16pt extra spacing
    }
}

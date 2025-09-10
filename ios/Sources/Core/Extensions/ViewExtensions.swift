import SwiftUI

// MARK: - View Extensions

@available(iOS 14.0, *)
extension View {
    /// Ensures minimum hit target size for accessibility
    func dsMinimumHitTarget() -> some View {
        frame(minWidth: 44, minHeight: 44)
    }
    
    /// Accessibility helper with label, hint, and traits
    func dsAccessibility(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Apply shimmer loading effect for placeholder states
    func shimmerEffect() -> some View {
        self.overlay(
            Rectangle()
                .foregroundColor(Color.clear)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(-15))
        )
        .clipped()
    }
}

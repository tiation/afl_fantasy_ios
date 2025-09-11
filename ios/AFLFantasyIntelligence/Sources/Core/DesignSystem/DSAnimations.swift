import SwiftUI
import UIKit

// MARK: - Animation System

public struct DSAnimations {
    
    // MARK: - Standard Durations
    
    public enum Duration {
        public static let instant: TimeInterval = 0.0
        public static let fast: TimeInterval = 0.15
        public static let standard: TimeInterval = 0.25
        public static let medium: TimeInterval = 0.4
        public static let slow: TimeInterval = 0.6
        public static let xSlow: TimeInterval = 1.0
    }
    
    // MARK: - Easing Curves
    
    public enum Easing {
        public static let easeIn = Animation.easeIn(duration: Duration.standard)
        public static let easeOut = Animation.easeOut(duration: Duration.standard)
        public static let easeInOut = Animation.easeInOut(duration: Duration.standard)
        public static let linear = Animation.linear(duration: Duration.standard)
        
        // Spring animations
        public static let spring = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1)
        public static let springBouncy = Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.1)
        public static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.05)
        
        // Interpolating springs for smooth UI
        public static let interactiveSpring = Animation.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.1)
    }
    
    // MARK: - Common Transitions
    
    public enum Transition {
        @MainActor public static let fade: AnyTransition = .opacity
        @MainActor public static let scale: AnyTransition = .scale(scale: 0.8)
        @MainActor public static let slide: AnyTransition = .slide
        @MainActor public static let move: AnyTransition = .move(edge: .trailing)
        
        // Combined transitions
        @MainActor public static let fadeScale: AnyTransition = .opacity.combined(with: .scale(scale: 0.9))
        @MainActor public static let slideUp: AnyTransition = .move(edge: .bottom).combined(with: .opacity)
        @MainActor public static let slideDown: AnyTransition = .move(edge: .top).combined(with: .opacity)
        
        // Card-like transitions
        @MainActor public static let cardEntry: AnyTransition = .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)).animation(Easing.springSnappy),
            removal: .opacity.combined(with: .scale(scale: 0.8)).animation(Easing.easeOut)
        )
        
        // List item transitions with staggered delay
        @MainActor public static func listItem(delay: Double = 0.0) -> AnyTransition {
            return .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .leading))
                    .animation(Easing.springSnappy.delay(delay)),
                removal: .opacity.combined(with: .scale(scale: 0.8))
                    .animation(Easing.easeOut)
            )
        }
    }
    
    // MARK: - Interactive Effects
    
    public struct InteractiveEffects {
        
        // Button press animation
        public static func buttonPress<Content: View>(
            content: Content,
            isPressed: Bool,
            pressScale: CGFloat = 0.95
        ) -> some View {
            content
                .scaleEffect(isPressed ? pressScale : 1.0)
                .opacity(isPressed ? 0.8 : 1.0)
                .animation(Easing.interactiveSpring, value: isPressed)
        }
        
        // Card hover/tap effect
        public static func cardHover<Content: View>(
            content: Content,
            isHovered: Bool,
            hoverScale: CGFloat = 1.02,
            shadowRadius: CGFloat = 8
        ) -> some View {
            content
                .scaleEffect(isHovered ? hoverScale : 1.0)
                .shadow(
                    color: DS.Colors.shadow.opacity(isHovered ? 0.15 : 0.08),
                    radius: isHovered ? shadowRadius : shadowRadius * 0.5,
                    y: isHovered ? 4 : 2
                )
                .animation(Easing.easeInOut, value: isHovered)
        }
        
        // Loading pulse effect
        public static func loadingPulse<Content: View>(
            content: Content,
            isLoading: Bool
        ) -> some View {
            content
                .opacity(isLoading ? 0.6 : 1.0)
                .scaleEffect(isLoading ? 0.98 : 1.0)
                .animation(
                    isLoading ? 
                        Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                        Easing.easeOut,
                    value: isLoading
                )
        }
    }
    
    // MARK: - Loading States
    
    public struct LoadingAnimations {
        
        // Shimmer effect for skeleton loading
        public static func shimmer<Content: View>(
            content: Content,
            isActive: Bool = true
        ) -> some View {
            content
                .redacted(reason: isActive ? .placeholder : [])
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .rotationEffect(.degrees(30))
                        .offset(x: isActive ? 300 : -300)
                        .animation(
                            isActive ? 
                                Animation.linear(duration: 1.5).repeatForever(autoreverses: false) :
                                .default,
                            value: isActive
                        )
                        .clipped()
                        .opacity(isActive ? 1 : 0)
                )
        }
        
        // Skeleton placeholder
        public static func skeleton(
            width: CGFloat? = nil,
            height: CGFloat = 20,
            cornerRadius: CGFloat = 4
        ) -> some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(DS.Colors.surface)
                .frame(width: width, height: height)
                .redacted(reason: .placeholder)
        }
        
        // Dots loading indicator
        public static func dotsLoading(isActive: Bool = true) -> some View {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(DS.Colors.primary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isActive ? 1.2 : 0.8)
                        .animation(
                            isActive ?
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.15) :
                                .default,
                            value: isActive
                        )
                }
            }
        }
    }
    
    // MARK: - Success/Error Feedback
    
    public struct FeedbackAnimations {
        
        // Success checkmark animation
        public static func successCheckmark(isVisible: Bool = true) -> some View {
            ZStack {
                Circle()
                    .fill(DS.Colors.success)
                    .frame(width: 44, height: 44)
                    .scaleEffect(isVisible ? 1.0 : 0.1)
                    .opacity(isVisible ? 1.0 : 0.0)
                
                Image(systemName: "checkmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .scaleEffect(isVisible ? 1.0 : 0.1)
                    .opacity(isVisible ? 1.0 : 0.0)
            }
            .animation(
                Easing.springBouncy.delay(isVisible ? 0.1 : 0),
                value: isVisible
            )
        }
        
        // Error shake animation
        public static func errorShake<Content: View>(
            content: Content,
            isShaking: Bool
        ) -> some View {
            content
                .offset(x: isShaking ? 5 : 0)
                .animation(
                    isShaking ?
                        Animation.easeInOut(duration: 0.1)
                            .repeatCount(6, autoreverses: true) :
                        .default,
                    value: isShaking
                )
        }
        
        // Progress celebration
        public static func celebrationPop<Content: View>(
            content: Content,
            isTriggered: Bool
        ) -> some View {
            content
                .scaleEffect(isTriggered ? 1.15 : 1.0)
                .animation(
                    isTriggered ?
                        Animation.spring(response: 0.3, dampingFraction: 0.4) :
                        Easing.easeOut,
                    value: isTriggered
                )
        }
    }
    
    // MARK: - Page Transitions
    
    public struct PageTransitions {
        
        // Tab switching animation
        public static func tabSwitch<Content: View>(
            content: Content,
            selectedTab: Int,
            tabIndex: Int
        ) -> some View {
            content
                .opacity(selectedTab == tabIndex ? 1.0 : 0.0)
                .scaleEffect(selectedTab == tabIndex ? 1.0 : 0.95)
                .offset(y: selectedTab == tabIndex ? 0 : 20)
                .animation(Easing.easeInOut, value: selectedTab)
        }
        
        // Modal presentation
        public static func modalPresentation<Content: View>(
            content: Content,
            isPresented: Bool
        ) -> some View {
            content
                .scaleEffect(isPresented ? 1.0 : 0.9)
                .opacity(isPresented ? 1.0 : 0.0)
                .animation(Easing.springSnappy, value: isPresented)
        }
    }
}

// MARK: - View Extensions

extension View {
    
    // Convenience modifiers for common animations
    
    public func dsButtonPress(isPressed: Bool, scale: CGFloat = 0.95) -> some View {
        DSAnimations.InteractiveEffects.buttonPress(
            content: self,
            isPressed: isPressed,
            pressScale: scale
        )
    }
    
    public func dsCardHover(isHovered: Bool, scale: CGFloat = 1.02) -> some View {
        DSAnimations.InteractiveEffects.cardHover(
            content: self,
            isHovered: isHovered,
            hoverScale: scale
        )
    }
    
    public func dsLoadingPulse(isLoading: Bool) -> some View {
        DSAnimations.LoadingAnimations.shimmer(content: self, isActive: isLoading)
    }
    
    public func dsErrorShake(isShaking: Bool) -> some View {
        DSAnimations.FeedbackAnimations.errorShake(content: self, isShaking: isShaking)
    }
    
    public func dsCelebrationPop(isTriggered: Bool) -> some View {
        DSAnimations.FeedbackAnimations.celebrationPop(content: self, isTriggered: isTriggered)
    }
    
    // Staggered list animations
    public func dsStaggeredEntry(delay: Double) -> some View {
        self
            .transition(DSAnimations.Transition.listItem(delay: delay))
    }
    
    // Page transition helper
    public func dsTabContent(selectedTab: Int, tabIndex: Int) -> some View {
        DSAnimations.PageTransitions.tabSwitch(
            content: self,
            selectedTab: selectedTab,
            tabIndex: tabIndex
        )
    }
}

// MARK: - Haptic Feedback Integration

public struct DSHaptics {
    
    @MainActor
    public static func light() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    @MainActor
    public static func medium() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    @MainActor
    public static func heavy() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
    
    @MainActor
    public static func success() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    @MainActor
    public static func warning() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.warning)
    }
    
    @MainActor
    public static func error() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.error)
    }
    
    @MainActor
    public static func selection() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
}

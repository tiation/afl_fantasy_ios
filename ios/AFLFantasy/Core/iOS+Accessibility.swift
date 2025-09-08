//
//  iOS+Accessibility.swift
//  AFL Fantasy Intelligence Platform
//
//  ♿ iOS Accessibility and Human Interface Guidelines compliance helpers
//  VoiceOver, Dynamic Type, Reduce Motion, and 44pt touch target support
//  Created by AI Assistant on 8/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UIKit

// MARK: - Accessibility Helpers

extension View {
    
    /// Apply HIG-compliant accessibility label and traits
    /// - Parameters:
    ///   - label: Descriptive label for VoiceOver
    ///   - hint: Optional usage hint
    ///   - traits: Accessibility traits (button, header, etc.)
    ///   - value: Current value for controls
    func accessibleElement(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits? = nil,
        value: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityTraits(traits ?? [])
            .accessibilityValue(value ?? "")
    }
    
    /// Ensure minimum 44pt touch target (HIG requirement)
    func minimumTouchTarget() -> some View {
        self
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }
    
    /// Apply Dynamic Type scaling with custom limits
    func dynamicTypeSize(_ range: ClosedRange<DynamicTypeSize> = .large....xxxLarge) -> some View {
        self
            .dynamicTypeSize(range)
    }
    
    /// Reduce motion aware animation
    func reducedMotionAnimation<V: Equatable>(_ animation: Animation?, value: V) -> some View {
        self
            .animation(UIAccessibility.isReduceMotionEnabled ? nil : animation, value: value)
    }
    
    /// High contrast aware styling
    func contrastAware(
        normalColor: Color,
        highContrastColor: Color
    ) -> some View {
        self
            .foregroundColor(UIAccessibility.isDarkerSystemColorsEnabled ? highContrastColor : normalColor)
    }
    
    /// VoiceOver navigation grouping
    func voiceOverGroup(_ label: String) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel(label)
    }
    
    /// Add to VoiceOver rotor for easy navigation
    func addToRotor<ID: Hashable>(
        _ entry: AccessibilityRotorEntry<ID>,
        in rotor: AccessibilityRotor<ID>
    ) -> some View {
        self
            .accessibilityRotorEntry(entry, for: rotor)
    }
}

// MARK: - Dynamic Type Support

enum AFLDynamicType {
    /// Get current content size category
    static var current: UIContentSizeCategory {
        UIApplication.shared.preferredContentSizeCategory
    }
    
    /// Check if accessibility sizes are enabled
    static var isAccessibilitySize: Bool {
        current.isAccessibilityCategory
    }
    
    /// Get scaling factor for current size
    static var scaleFactor: CGFloat {
        switch current {
        case .extraSmall: return 0.8
        case .small: return 0.85
        case .medium: return 0.9
        case .large: return 1.0
        case .extraLarge: return 1.1
        case .extraExtraLarge: return 1.2
        case .extraExtraExtraLarge: return 1.3
        case .accessibilityMedium: return 1.4
        case .accessibilityLarge: return 1.5
        case .accessibilityExtraLarge: return 1.6
        case .accessibilityExtraExtraLarge: return 1.7
        case .accessibilityExtraExtraExtraLarge: return 1.8
        default: return 1.0
        }
    }
    
    /// Responsive font size based on Dynamic Type
    static func responsiveSize(base: CGFloat) -> CGFloat {
        base * scaleFactor
    }
}

// MARK: - AFLAccessibleCard

/// Pre-built accessible card component following AFL Fantasy design system
struct AFLAccessibleCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let accessibilityLabel: String?
    let action: (() -> Void)?
    let content: Content
    
    init(
        title: String,
        subtitle: String? = nil,
        accessibilityLabel: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accessibilityLabel = accessibilityLabel
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .accessibleElement(
            label: accessibilityLabel ?? "\(title)\(subtitle.map { ", \($0)" } ?? "")",
            traits: action != nil ? [.button] : []
        )
        .onTapGesture {
            action?()
        }
        .minimumTouchTarget()
    }
}

// MARK: - AFLAccessibleButton

/// Pre-built accessible button with HIG compliance
struct AFLAccessibleButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void
    let style: ButtonStyle
    let isDestructive: Bool
    
    enum ButtonStyle {
        case primary, secondary, tertiary, destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .accentColor
            case .secondary: return .secondary.opacity(0.2)
            case .tertiary: return .clear
            case .destructive: return .red
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive: return .white
            case .secondary, .tertiary: return .primary
            }
        }
    }
    
    init(
        title: String,
        systemImage: String? = nil,
        style: ButtonStyle = .primary,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
        self.style = isDestructive ? .destructive : style
        self.isDestructive = isDestructive
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.body)
                }
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(style.backgroundColor)
            )
            .foregroundColor(style.foregroundColor)
        }
        .minimumTouchTarget()
        .accessibleElement(
            label: title,
            traits: isDestructive ? [.button, .selected] : [.button]
        )
    }
}

// MARK: - AFLLoadingAnimation with Accessibility

/// Accessible loading animation with reduced motion support
struct AFLLoadingAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: 24, height: 24)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .reducedMotionAnimation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
            .onDisappear {
                isAnimating = false
            }
            .accessibilityLabel("Loading")
            .accessibilityValue(isAnimating ? "In progress" : "Complete")
    }
}

// MARK: - Accessibility Testing Helper

#if DEBUG
/// Debug overlay showing accessibility information
struct AccessibilityDebugOverlay: View {
    @State private var showingDebugInfo = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("A11y Debug") {
                    showingDebugInfo.toggle()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.blue)
                .cornerRadius(4)
            }
            
            if showingDebugInfo {
                VStack(alignment: .leading, spacing: 8) {
                    debugInfo
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .allowsHitTesting(showingDebugInfo)
    }
    
    private var debugInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Accessibility Debug")
                .font(.headline)
            
            Group {
                debugRow("VoiceOver", UIAccessibility.isVoiceOverRunning ? "ON" : "OFF")
                debugRow("Switch Control", UIAccessibility.isSwitchControlRunning ? "ON" : "OFF")
                debugRow("Reduce Motion", UIAccessibility.isReduceMotionEnabled ? "ON" : "OFF")
                debugRow("Bold Text", UIAccessibility.isBoldTextEnabled ? "ON" : "OFF")
                debugRow("High Contrast", UIAccessibility.isDarkerSystemColorsEnabled ? "ON" : "OFF")
                debugRow("Text Size", AFLDynamicType.current.rawValue)
                debugRow("Accessibility Size", AFLDynamicType.isAccessibilitySize ? "YES" : "NO")
            }
            .font(.caption)
        }
    }
    
    private func debugRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label + ":")
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

/// View modifier to add accessibility debug overlay
extension View {
    func accessibilityDebug() -> some View {
        self.overlay(AccessibilityDebugOverlay(), alignment: .topTrailing)
    }
}
#endif

// MARK: - Accessibility Audit Helper

enum AccessibilityAudit {
    /// Audit results for view accessibility
    struct AuditResult {
        let hasAccessibilityLabel: Bool
        let hasSufficientTouchTarget: Bool
        let hasSufficientContrast: Bool
        let supportsDynamicType: Bool
        let supportsReduceMotion: Bool
        
        var isFullyAccessible: Bool {
            hasAccessibilityLabel &&
            hasSufficientTouchTarget &&
            hasSufficientContrast &&
            supportsDynamicType &&
            supportsReduceMotion
        }
        
        var score: Double {
            let checks = [hasAccessibilityLabel, hasSufficientTouchTarget, hasSufficientContrast, supportsDynamicType, supportsReduceMotion]
            return Double(checks.filter { $0 }.count) / Double(checks.count)
        }
    }
    
    /// Performance accessibility quick check
    static func quickAudit() -> String {
        var issues: [String] = []
        
        if !UIAccessibility.isVoiceOverRunning && ProcessInfo.processInfo.environment["TESTING"] == nil {
            issues.append("VoiceOver not running - test with VoiceOver enabled")
        }
        
        if AFLDynamicType.current == .large {
            issues.append("Test with larger text sizes (Settings > Display & Brightness > Text Size)")
        }
        
        if !UIAccessibility.isReduceMotionEnabled {
            issues.append("Test with Reduce Motion enabled (Settings > Accessibility > Motion)")
        }
        
        return issues.isEmpty ? 
            "✅ Accessibility environment looks good" : 
            "⚠️ Issues found:\n" + issues.map { "• \($0)" }.joined(separator: "\n")
    }
}

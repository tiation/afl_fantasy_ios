import SwiftUI

// MARK: - Design System Extensions

extension DS {
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    enum Typography {
        static let brandTitle = Font.largeTitle.bold()
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let headline = Font.headline
        static let body = Font.body
        static let caption = Font.caption
    }
    
    // Colors are defined in main DesignSystem.swift
}

// MARK: - DSGradientCard

struct DSGradientCard<Content: View>: View {
    let gradient: LinearGradient?
    let content: Content
    
    init(gradient: LinearGradient? = nil, @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(gradient ?? LinearGradient(
                        colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
    }
}

// MARK: - DSStatCard

struct DSStatCard: View {
    let title: String
    let value: String
    let trend: Trend?
    let icon: String
    let style: Style
    let useAnimatedCounter: Bool
    
    enum Style {
        case minimal, standard, prominent, gradient
    }
    
    enum Trend {
        case up(String), down(String), neutral
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Spacer()
                if let trend = trend {
                    trendView(trend)
                }
            }
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(valueColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(DS.Spacing.m)
        .background(backgroundView)
    }
    
    private var iconColor: Color {
        switch style {
        case .minimal: return .secondary
        case .standard: return DS.Colors.primary
        case .prominent: return .white
        case .gradient: return .white
        }
    }
    
    private var valueColor: Color {
        switch style {
        case .minimal, .standard: return .primary
        case .prominent, .gradient: return .white
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .minimal:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        case .standard:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor.separator), lineWidth: 1)
                )
        case .prominent:
            RoundedRectangle(cornerRadius: 12)
                .fill(DS.Colors.primary)
        case .gradient:
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [DS.Colors.primary, DS.Colors.secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
    }
    
    @ViewBuilder
    private func trendView(_ trend: Trend) -> some View {
        switch trend {
        case .up(let text):
            HStack(spacing: 2) {
                Image(systemName: "arrow.up")
                    .font(.caption2)
                Text(text)
                    .font(.caption2)
            }
            .foregroundColor(.green)
        case .down(let text):
            HStack(spacing: 2) {
                Image(systemName: "arrow.down")
                    .font(.caption2)
                Text(text)
                    .font(.caption2)
            }
            .foregroundColor(.red)
        case .neutral:
            HStack(spacing: 2) {
                Image(systemName: "minus")
                    .font(.caption2)
                Text("Neutral")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - DSCard

struct DSCard<Content: View>: View {
    let style: Style
    let content: Content
    
    enum Style {
        case standard, elevated, bordered, gradient
    }
    
    init(style: Style = .standard, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        content
            .background(backgroundView)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .standard:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
        case .elevated:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        case .bordered:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor.separator), lineWidth: 1)
                )
        case .gradient:
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
    }
}

// MARK: - DSProgressRing

struct DSProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    
    var body: some View {
        Circle()
            .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
            .overlay(
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        DS.Colors.primary,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            )
    }
}

// MARK: - DSStatusBadge

struct DSStatusBadge: View {
    let text: String
    let style: Style
    
    enum Style {
        case info, warning, error, success
    }
    
    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .info: return DS.Colors.primary
        case .warning: return DS.Colors.warning
        case .error: return DS.Colors.error
        case .success: return DS.Colors.success
        }
    }
}

import SwiftUI

// MARK: - DSButton

struct DSButton: View {
    enum Style {
        case primary
        case secondary
        case outline
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
                .font(.headline)
                .foregroundColor(foregroundColor)
                .frame(minHeight: 44) // HIG minimum hit target
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.blue
        case .secondary:
            return Color(.secondarySystemBackground)
        case .outline:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return Color(.label)
        case .outline:
            return .blue
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .outline:
            return .blue
        default:
            return Color.clear
        }
    }
    
    private var strokeWidth: CGFloat {
        style == .outline ? 1 : 0
    }
}

// MARK: - Preview

#if DEBUG
struct DSButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            DSButton("Primary Button") {}
            DSButton("Secondary Button", style: .secondary) {}
            DSButton("Outline Button", style: .outline) {}
        }
        .padding()
    }
}
#endif

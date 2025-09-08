import SwiftUI

/// Design System tokens for the AFL Fantasy app
struct Theme {
    struct Colors {
        // Primary Brand Colors
        static let primary = Color("Primary")
        static let secondary = Color("Secondary")
        static let accent = Color("Accent")
        
        // Text Colors
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let textAccent = Color("TextAccent")
        
        // Background Colors
        static let background = Color("Background")
        static let backgroundSecondary = Color("BackgroundSecondary")
        static let card = Color("Card")
        
        // Status Colors
        static let success = Color("Success")
        static let warning = Color("Warning")
        static let error = Color("Error")
        static let info = Color("Info")
        
        // Chart Colors
        static let chartGreen = Color("ChartGreen")
        static let chartRed = Color("ChartRed")
        static let chartBlue = Color("ChartBlue")
        static let chartYellow = Color("ChartYellow")
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
        static let body = SwiftUI.Font.body
        static let bodyBold = SwiftUI.Font.body.weight(.semibold)
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
}

// MARK: - ViewModifier Extensions

extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.card)
            .cornerRadius(Theme.Radius.medium)
            .shadow(
                color: Theme.Shadows.small.color,
                radius: Theme.Shadows.small.radius,
                x: Theme.Shadows.small.x,
                y: Theme.Shadows.small.y
            )
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

// MARK: - Helper Types

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

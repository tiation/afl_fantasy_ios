import SwiftUI

// MARK: - TabItem Model
struct TabItem: Identifiable {
    let id: Int
    let title: String
    let icon: String
    let activeIcon: String
    let color: Color
    let badgeCount: Int?
    
    init(id: Int, title: String, icon: String, activeIcon: String, color: Color, badgeCount: Int? = nil) {
        self.id = id
        self.title = title
        self.icon = icon
        self.activeIcon = activeIcon
        self.color = color
        self.badgeCount = badgeCount
    }
}

// MARK: - Enhanced Floating Tab Bar
struct EnhancedFloatingTabBar: View {
    @Binding var selectedTab: Int
    let previousTab: Int
    let tabs: [TabItem]
    
    @State private var tabOffsets: [CGFloat] = []
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    @State private var selectionFeedback = UISelectionFeedbackGenerator()
    
    private let tabBarHeight: CGFloat = 80
    private let tabBarCornerRadius: CGFloat = 20
    private let indicatorHeight: CGFloat = 3
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                tabButton(for: tab)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: tabBarHeight)
        .background(
            // Glassmorphic background
            RoundedRectangle(cornerRadius: tabBarCornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: tabBarCornerRadius)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .overlay(
            // Active indicator
            activeIndicator
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
        .onAppear {
            setupHaptics()
        }
    }
    
    private func tabButton(for tab: TabItem) -> some View {
        Button {
            selectTab(tab)
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    // Tab icon
                    Image(systemName: selectedTab == tab.id ? tab.activeIcon : tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab.id ? .semibold : .medium))
                        .foregroundColor(selectedTab == tab.id ? tab.color : Color.secondary)
                        .scaleEffect(selectedTab == tab.id ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: selectedTab)
                    
                    // Badge
                    if let badgeCount = tab.badgeCount, badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(
                                Circle()
                                    .fill(DS.Colors.error)
                            )
                            .offset(x: 12, y: -8)
                            .scaleEffect(selectedTab == tab.id ? 1.1 : 0.9)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    }
                }
                
                // Tab title
                Text(tab.title)
                    .font(.system(size: 11, weight: selectedTab == tab.id ? .semibold : .medium))
                    .foregroundColor(selectedTab == tab.id ? tab.color : Color.secondary)
                    .opacity(selectedTab == tab.id ? 1.0 : 0.7)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(TabButtonStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selectedTab == tab.id ? .isSelected : [])
    }
    
    private var activeIndicator: some View {
        GeometryReader { geometry in
            let tabWidth = geometry.size.width / CGFloat(tabs.count)
            let indicatorOffset = tabWidth * CGFloat(selectedTab)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            tabs.first(where: { $0.id == selectedTab })?.color ?? DS.Colors.primary,
                            tabs.first(where: { $0.id == selectedTab })?.color.opacity(0.8) ?? DS.Colors.primary.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: tabWidth * 0.6, height: indicatorHeight)
                .cornerRadius(indicatorHeight / 2)
                .offset(x: indicatorOffset + (tabWidth * 0.2))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
        }
        .frame(height: indicatorHeight)
        .offset(y: -indicatorHeight / 2)
    }
    
    private func selectTab(_ tab: TabItem) {
        guard selectedTab != tab.id else { return }
        
        // Haptic feedback based on tab type
        switch tab.title {
        case "Dashboard", "Profile":
            hapticFeedback.impactOccurred(intensity: 0.8)
        case "Players", "Teams":
            hapticFeedback.impactOccurred(intensity: 0.6)
        case "AI Tools":
            hapticFeedback.impactOccurred(intensity: 1.0)
        case "Alerts":
            selectionFeedback.selectionChanged()
        default:
            hapticFeedback.impactOccurred()
        }
        
        selectedTab = tab.id
    }
    
    private func setupHaptics() {
        hapticFeedback.prepare()
        selectionFeedback.prepare()
    }
}

// MARK: - Tab Button Style
struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct EnhancedFloatingTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            EnhancedFloatingTabBar(
                selectedTab: .constant(0),
                previousTab: 1,
                tabs: [
                    TabItem(
                        id: 0,
                        title: "Dashboard",
                        icon: "chart.line.uptrend.xyaxis",
                        activeIcon: "chart.line.uptrend.xyaxis",
                        color: .blue
                    ),
                    TabItem(
                        id: 1,
                        title: "Players",
                        icon: "person.3",
                        activeIcon: "person.3.fill",
                        color: .orange
                    ),
                    TabItem(
                        id: 2,
                        title: "Teams",
                        icon: "person.2.badge.plus",
                        activeIcon: "person.2.badge.plus.fill",
                        color: .purple
                    ),
                    TabItem(
                        id: 3,
                        title: "AI Tools",
                        icon: "brain.head.profile",
                        activeIcon: "brain.head.profile",
                        color: .green
                    ),
                    TabItem(
                        id: 4,
                        title: "Alerts",
                        icon: "bell",
                        activeIcon: "bell.fill",
                        color: .red,
                        badgeCount: 3
                    ),
                    TabItem(
                        id: 5,
                        title: "Profile",
                        icon: "person.circle",
                        activeIcon: "person.circle.fill",
                        color: .indigo
                    )
                ]
            )
            .padding(.horizontal, DS.Spacing.l)
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemBackground))
        .preferredColorScheme(.dark)
    }
}

import Foundation

// MARK: - PlayerDetailTab

enum PlayerDetailTab: String, CaseIterable {
    case overview = "Overview"
    case stats = "Statistics"
    case analysis = "Analysis"
    case news = "News"
    
    var displayName: String {
        return self.rawValue
    }
}

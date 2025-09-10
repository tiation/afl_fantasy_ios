import Foundation

// MARK: - PlayerViewModel Display Helpers

public extension Player {
    /// Returns a value-for-money rating based on average score per $100k spent.
    var valueForMoney: Double {
        averageScore / (Double(currentPrice) / 100_000)
    }

    /// Returns the player's status in a human-readable format.
    var status: String {
        if isSuspended {
            "Suspended"
        } else if isDoubtful {
            "Doubtful"
        } else if isInjured {
            "Injured"
        } else {
            "Available"
        }
    }

    /// Returns a semantic color name for status indicators.
    var statusIndicatorColor: String {
        switch status {
        case "Suspended": "red"
        case "Doubtful", "Injured": "yellow"
        default: "green"
        }
    }

    /// Returns a formatted string with status-appropriate icon and color.
    var statusDisplay: String {
        let icon = switch status {
        case "Suspended": "⛔️"
        case "Doubtful": "⚠️"
        case "Injured": "🤕"
        default: "✅"
        }
        return "\(icon) \(status)"
    }
}

// MARK: - Date Formatting

public extension Date {
    /// Returns a relative date string, e.g. "2 hours ago"
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

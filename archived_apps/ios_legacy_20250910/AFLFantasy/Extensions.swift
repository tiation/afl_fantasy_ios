//
//  Extensions.swift
//  AFL Fantasy Intelligence Platform
//
//  Swift extensions, formatters, and utility functions
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Foundation Extensions

extension String {
    /// Capitalizes the first letter of the string
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).capitalized + dropFirst()
    }

    /// Removes whitespace and newlines from both ends
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Checks if string contains only letters and spaces
    var isValidName: Bool {
        let nameRegex = "^[a-zA-Z\\s]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: self)
    }

    /// Converts string to URL-safe format
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    /// Formats AFL player name for display
    var playerNameFormatted: String {
        components(separatedBy: " ")
            .map(\.capitalizedFirst)
            .joined(separator: " ")
            .trimmed
    }

    /// Extracts initials from name (e.g., "John Smith" -> "JS")
    var initials: String {
        components(separatedBy: " ")
            .compactMap { $0.first?.uppercased() }
            .prefix(2)
            .joined()
    }

    /// Safe subscript to avoid crashes
    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }
}

extension Int {
    /// Formats currency for AFL Fantasy (e.g., 750000 -> "$750K")
    var aflCurrencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0

        let value = Double(self)

        if value >= 1_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000))M"
        } else if value >= 1000 {
            return "$\(Int(value / 1000))K"
        } else {
            return formatter.string(from: NSNumber(value: self)) ?? "$0"
        }
    }

    /// Formats number with thousands separator
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    /// Ordinal representation (1st, 2nd, 3rd, etc.)
    var ordinal: String {
        let suffix: String
        let lastDigit = self % 10
        let lastTwoDigits = self % 100

        if lastTwoDigits >= 11, lastTwoDigits <= 13 {
            suffix = "th"
        } else {
            switch lastDigit {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }

        return "\(self)\(suffix)"
    }

    /// Safe division that returns 0 instead of crashing
    func safeDivide(by divisor: Int) -> Double {
        guard divisor != 0 else { return 0 }
        return Double(self) / Double(divisor)
    }
}

extension Double {
    /// Rounds to specified decimal places
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// Formats as percentage string
    var percentageString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self)) ?? "0%"
    }

    /// Formats as one decimal place string
    var oneDecimalString: String {
        String(format: "%.1f", self)
    }

    /// Formats as AFL score (no decimals)
    var aflScoreString: String {
        String(format: "%.0f", self)
    }

    /// Clamps value between min and max
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension Date {
    /// Formats date for AFL context
    var aflDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: self)
    }

    /// Formats time for AFL context
    var aflTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: self)
    }

    /// Relative time string (e.g., "2 hours ago")
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Checks if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Checks if date is in current week
    var isCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// AFL round week (Thursday to Wednesday)
    var aflWeekStart: Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        let daysToAdd = (5 - weekday) % 7 // Thursday = 5
        return calendar.date(byAdding: .day, value: daysToAdd, to: self) ?? self
    }

    /// Time until this date
    var timeUntil: String {
        let timeInterval = timeIntervalSince(Date())
        guard timeInterval > 0 else { return "Now" }

        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

extension Array {
    /// Safe subscript that returns nil instead of crashing
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }

    /// Chunks array into smaller arrays of specified size
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    /// Removes duplicates while preserving order
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen: Set<T> = []
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

extension Array where Element: Numeric {
    /// Sum of all elements
    var sum: Element {
        reduce(0, +)
    }

    /// Average of all elements
    var average: Double {
        guard !isEmpty else { return 0 }
        let total = reduce(0, +)
        return Double(total as! Int) / Double(count)
    }
}

extension Collection {
    /// Checks if collection is not empty
    var isNotEmpty: Bool {
        !isEmpty
    }
}

// MARK: - SwiftUI Extensions

extension Color {
    /// AFL team primary colors
    static let aflOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let aflBlue = Color(red: 0.0, green: 0.4, blue: 0.8)
    static let aflGreen = Color(red: 0.0, green: 0.7, blue: 0.3)
    static let aflRed = Color(red: 0.9, green: 0.2, blue: 0.2)

    /// Fantasy position colors
    static let defenderColor = Color.blue
    static let midfielderColor = Color.green
    static let ruckColor = Color.purple
    static let forwardColor = Color.red

    /// Status colors
    static let positiveColor = Color.green
    static let negativeColor = Color.red
    static let warningColor = Color.orange
    static let neutralColor = Color.gray

    /// Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Returns hex string representation
    var hex: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
}

extension View {
    /// Adds haptic feedback to tap gesture
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }

    /// Conditional view modifier
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Adds border with conditional color
    func conditionalBorder(_ condition: Bool, _ style: some ShapeStyle, width: CGFloat = 1) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(condition ? AnyShapeStyle(style) : AnyShapeStyle(Color.clear), lineWidth: width)
        )
    }

    /// AFL Fantasy card style
    func aflCard(backgroundColor: Color = Color(.systemBackground)) -> some View {
        padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    /// AFL Fantasy button style
    func aflButton(color: Color = .aflOrange) -> some View {
        foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(8)
    }

    /// Accessibility helper
    func accessibilityElement(label: String, hint: String? = nil, value: String? = nil) -> some View {
        accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
    }
}

extension Animation {
    /// AFL Fantasy standard animations
    static let aflStandard = Animation.easeInOut(duration: 0.25)
    static let aflQuick = Animation.easeInOut(duration: 0.15)
    static let aflSlow = Animation.easeInOut(duration: 0.4)
    static let aflSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)
}

// MARK: - UIKit Extensions

extension UIColor {
    /// Initialize from hex string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }

    /// AFL Fantasy brand colors
    static let aflOrange = UIColor(hex: "#FF6600")
    static let aflBlue = UIColor(hex: "#0066CC")
    static let aflGreen = UIColor(hex: "#00B84C")
    static let aflRed = UIColor(hex: "#E63946")
}

extension UIImage {
    /// Creates image from color
    static func from(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    /// Resizes image to specified size
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    /// Creates circular image
    func circularImage() -> UIImage {
        let size = CGSize(width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(ovalIn: rect).addClip()
        draw(in: rect)

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

// MARK: - Formatters

enum AFLFormatters {
    /// Currency formatter for AFL Fantasy
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// Percentage formatter
    static let percentage: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    /// Decimal formatter with one decimal place
    static let oneDecimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    /// Date formatter for AFL dates
    static let aflDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_AU")
        return formatter
    }()

    /// Time formatter for AFL times
    static let aflTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_AU")
        return formatter
    }()

    /// Relative date formatter
    static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter
    }()
}

// MARK: - Utility Functions

enum AFLUtilities {
    /// Calculates consistency score from array of scores
    static func calculateConsistency(scores: [Int]) -> Double {
        guard scores.count > 1 else { return 0 }

        let mean = scores.reduce(0, +) / scores.count
        let variance = scores.reduce(0) { sum, score in
            let diff = score - mean
            return sum + (diff * diff)
        } / scores.count

        let standardDeviation = sqrt(Double(variance))
        let coefficientOfVariation = standardDeviation / Double(mean)

        return max(0, min(100, 100 - (coefficientOfVariation * 100)))
    }

    /// Determines if a player is a cash cow based on price and breakeven
    static func isCashCow(price: Int, breakeven: Int, averageScore: Double) -> Bool {
        price < 500_000 && Double(breakeven) < averageScore * 0.8
    }

    /// Calculates projected price change
    static func projectedPriceChange(currentScore: Int, breakeven: Int) -> Int {
        let scoreDifference = currentScore - breakeven
        return scoreDifference * 150 // Simplified AFL Fantasy algorithm
    }

    /// Generates team strength rating
    static func teamStrengthRating(for teamName: String, season: Int = 2024) -> Double {
        // Mock team strength ratings - in production would come from API
        let ratings: [String: Double] = [
            "melbourne": 0.85,
            "collingwood": 0.82,
            "brisbane": 0.80,
            "sydney": 0.78,
            "carlton": 0.75,
            "geelong": 0.74,
            "fremantle": 0.72,
            "port adelaide": 0.70,
            "gws": 0.68,
            "richmond": 0.65,
            "western bulldogs": 0.62,
            "adelaide": 0.60,
            "st kilda": 0.58,
            "hawthorn": 0.55,
            "essendon": 0.52,
            "gold coast": 0.50,
            "west coast": 0.48,
            "north melbourne": 0.45
        ]

        return ratings[teamName.lowercased()] ?? 0.5
    }

    /// Validates team composition
    static func validateTeamComposition(_ players: [Player]) -> TeamValidationResult {
        let defenders = players.filter { $0.position.rawValue == "DEF" }.count
        let midfielders = players.filter { $0.position.rawValue == "MID" }.count
        let rucks = players.filter { $0.position.rawValue == "RUC" }.count
        let forwards = players.filter { $0.position.rawValue == "FWD" }.count

        var errors: [String] = []

        if defenders < 6 { errors.append("Need at least 6 defenders") }
        if midfielders < 8 { errors.append("Need at least 8 midfielders") }
        if rucks < 2 { errors.append("Need at least 2 rucks") }
        if forwards < 6 { errors.append("Need at least 6 forwards") }
        if players.count != 30 { errors.append("Team must have exactly 30 players") }

        let totalValue = players.reduce(0) { $0 + $1.currentPrice }
        if totalValue > 13_000_000 { errors.append("Team exceeds salary cap") }

        return TeamValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}

struct TeamValidationResult {
    let isValid: Bool
    let errors: [String]
}

// MARK: - Constants

enum AFLConstants {
    enum Rules {
        static let salaryCap = 13_000_000
        static let maxTrades = 30
        static let teamSize = 30
        static let playingTeamSize = 22
        static let benchSize = 8
        static let maxPlayersPerTeam = 3
        static let tradeCooldownHours = 24
    }

    enum Positions {
        static let minDefenders = 6
        static let maxDefenders = 10
        static let minMidfielders = 8
        static let maxMidfielders = 12
        static let minRucks = 2
        static let maxRucks = 4
        static let minForwards = 6
        static let maxForwards = 10
    }

    enum Scoring {
        static let kickPoints = 3
        static let handballPoints = 2
        static let markPoints = 3
        static let tacklePoints = 4
        static let goalPoints = 6
        static let behindPoints = 1
        static let hitoutPoints = 1
        static let clangerPoints = -2
        static let freeKickAgainstPoints = -1
    }

    enum UI {
        static let cardCornerRadius: CGFloat = 12
        static let buttonCornerRadius: CGFloat = 8
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        static let animationDuration: Double = 0.25
    }
}

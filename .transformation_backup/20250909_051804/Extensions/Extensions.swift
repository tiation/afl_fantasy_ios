import SwiftUI
import Combine

// MARK: - View Extensions

extension View {
    // General purpose loading overlay modifier
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            }
        }
    }
    
    // Custom navigation helper for programmatic navigation
    func navigationHelper() -> some View {
        self
    }
}

// MARK: - Date Extensions

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func isWithinDays(_ days: Int, of date: Date = Date()) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: startOfDay, to: date.startOfDay)
        return abs(diff.day ?? .max) <= days
    }
}

// MARK: - String Extensions

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Array Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element: Hashable {
    var unique: [Element] {
        Array(Set(self))
    }
}

// MARK: - Double Extensions

extension Double {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        
        if self >= 1000000 {
            return formatter.string(from: NSNumber(value: self / 1000000)) ?? "0" + "M"
        } else if self >= 1000 {
            return formatter.string(from: NSNumber(value: self / 1000)) ?? "0" + "k"
        } else {
            return formatter.string(from: NSNumber(value: self)) ?? "0"
        }
    }
    
    var formattedPercentage: String {
        String(format: "%.1f%%", self * 100)
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    var appName: String {
        infoDictionary?["CFBundleDisplayName"] as? String
        ?? infoDictionary?["CFBundleName"] as? String
        ?? "AFL Fantasy"
    }
    
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Color Extensions

extension Color {
    func opacity(if condition: Bool, _ opacity: Double) -> Color {
        condition ? self.opacity(opacity) : self
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            set(data, forKey: key)
        }
    }
    
    func codable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Published Extensions

extension Published.Publisher {
    func asOptional() -> AnyPublisher<Value?, Never> {
        map { Optional($0) }
            .eraseToAnyPublisher()
    }
    
    var nonNil: AnyPublisher<Value, Never> {
        compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

// MARK: - Optional Type Extensions

protocol OptionalType {
    var asOptional: Wrapped? { get }
    associatedtype Wrapped
}

extension Optional: OptionalType {
    var asOptional: Wrapped? { self }
}

// MARK: - Combine Extensions

extension Publisher {
    func asOptional() -> AnyPublisher<Output?, Failure> {
        map { Optional($0) }
            .eraseToAnyPublisher()
    }
}

import Foundation
import Combine

final class UserPreferencesService: ObservableObject, Sendable {
    static let shared = UserPreferencesService()
    
    @Published var favoriteTeams: Set<String> = []
    @Published var preferredPositions: [Position] = []
    @Published var priceRangeMin: Int = 100_000
    @Published var priceRangeMax: Int = 800_000
    @Published var showOnlyAvailable: Bool = true
    @Published var sortBy: PlayerSortOption = .projected
    @Published var sortAscending: Bool = false
    @Published var apiBaseURL: String = "http://localhost:8080"
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private enum Keys {
        static let favoriteTeams = "favorite_teams"
        static let preferredPositions = "preferred_positions"
        static let priceRangeMin = "price_range_min"
        static let priceRangeMax = "price_range_max"
        static let showOnlyAvailable = "show_only_available"
        static let sortBy = "sort_by"
        static let sortAscending = "sort_ascending"
        static let apiBaseURL = "api_base_url"
    }
    
    private init() {
        loadPreferences()
    }
    
    // MARK: - Team Preferences
    
    func addFavoriteTeam(_ team: String) {
        favoriteTeams.insert(team)
        saveFavoriteTeams()
    }
    
    func removeFavoriteTeam(_ team: String) {
        favoriteTeams.remove(team)
        saveFavoriteTeams()
    }
    
    func isFavoriteTeam(_ team: String) -> Bool {
        favoriteTeams.contains(team)
    }
    
    // MARK: - Position Preferences
    
    func setPreferredPositions(_ positions: [Position]) {
        preferredPositions = positions
        savePreferredPositions()
    }
    
    func addPreferredPosition(_ position: Position) {
        if !preferredPositions.contains(position) {
            preferredPositions.append(position)
            savePreferredPositions()
        }
    }
    
    func removePreferredPosition(_ position: Position) {
        preferredPositions.removeAll { $0 == position }
        savePreferredPositions()
    }
    
    // MARK: - Price Range Preferences
    
    func setPriceRange(min: Int, max: Int) {
        priceRangeMin = min
        priceRangeMax = max
        userDefaults.set(min, forKey: Keys.priceRangeMin)
        userDefaults.set(max, forKey: Keys.priceRangeMax)
    }
    
    // MARK: - Filter Preferences
    
    func setShowOnlyAvailable(_ show: Bool) {
        showOnlyAvailable = show
        userDefaults.set(show, forKey: Keys.showOnlyAvailable)
    }
    
    // MARK: - Sorting Preferences
    
    func setSortBy(_ sortBy: PlayerSortOption, ascending: Bool = false) {
        self.sortBy = sortBy
        self.sortAscending = ascending
        
        if let data = try? encoder.encode(sortBy) {
            userDefaults.set(data, forKey: Keys.sortBy)
        }
        userDefaults.set(ascending, forKey: Keys.sortAscending)
    }
    
    // MARK: - API Base URL Preferences
    
    func setAPIBaseURL(_ url: String) {
        apiBaseURL = url
        userDefaults.set(url, forKey: Keys.apiBaseURL)
    }
    
    // MARK: - Reset Preferences
    
    func resetToDefaults() {
        favoriteTeams.removeAll()
        preferredPositions.removeAll()
        priceRangeMin = 100_000
        priceRangeMax = 800_000
        showOnlyAvailable = true
        sortBy = .projected
        sortAscending = false
        apiBaseURL = "http://localhost:8080"
        
        // Clear from UserDefaults
        let keys = [Keys.favoriteTeams, Keys.preferredPositions, Keys.priceRangeMin, Keys.priceRangeMax, Keys.showOnlyAvailable, Keys.sortBy, Keys.sortAscending, Keys.apiBaseURL]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    // MARK: - Private Methods
    
    private func loadPreferences() {
        loadFavoriteTeams()
        loadPreferredPositions()
        loadPriceRange()
        loadFilterPreferences()
        loadSortingPreferences()
        loadAPIBaseURL()
    }
    
    private func loadFavoriteTeams() {
        if let data = userDefaults.data(forKey: Keys.favoriteTeams),
           let teams = try? decoder.decode(Set<String>.self, from: data) {
            favoriteTeams = teams
        }
    }
    
    private func saveFavoriteTeams() {
        if let data = try? encoder.encode(favoriteTeams) {
            userDefaults.set(data, forKey: Keys.favoriteTeams)
        }
    }
    
    private func loadPreferredPositions() {
        if let data = userDefaults.data(forKey: Keys.preferredPositions),
           let positions = try? decoder.decode([Position].self, from: data) {
            preferredPositions = positions
        }
    }
    
    private func savePreferredPositions() {
        if let data = try? encoder.encode(preferredPositions) {
            userDefaults.set(data, forKey: Keys.preferredPositions)
        }
    }
    
    private func loadPriceRange() {
        priceRangeMin = userDefaults.object(forKey: Keys.priceRangeMin) as? Int ?? 100_000
        priceRangeMax = userDefaults.object(forKey: Keys.priceRangeMax) as? Int ?? 800_000
    }
    
    private func loadFilterPreferences() {
        showOnlyAvailable = userDefaults.object(forKey: Keys.showOnlyAvailable) as? Bool ?? true
    }
    
    private func loadSortingPreferences() {
        if let data = userDefaults.data(forKey: Keys.sortBy),
           let sortOption = try? decoder.decode(PlayerSortOption.self, from: data) {
            sortBy = sortOption
        }
        sortAscending = userDefaults.object(forKey: Keys.sortAscending) as? Bool ?? false
    }
    
    private func loadAPIBaseURL() {
        apiBaseURL = userDefaults.string(forKey: Keys.apiBaseURL) ?? "http://localhost:8080"
    }
}

// MARK: - Supporting Types

enum PlayerSortOption: String, CaseIterable, Codable {
    case name = "Name"
    case price = "Price"
    case average = "Average"
    case projected = "Projected"
    case breakeven = "Breakeven"
    case team = "Team"
    case position = "Position"
    
    var displayName: String {
        return rawValue
    }
}

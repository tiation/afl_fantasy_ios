import Foundation
import SwiftUI

// MARK: - UserPreferencesService

@MainActor
final class UserPreferencesService: ObservableObject {
    static let shared = UserPreferencesService()
    
    // MARK: - Player Filter Preferences
    
    @AppStorage("selectedPosition") private var storedPosition: String = ""
    @AppStorage("playerSort") private var storedSort: String = PlayerSort.averageDesc.rawValue
    @AppStorage("lastSearchText") private var storedSearchText: String = ""
    
    // MARK: - Watchlist
    
    @AppStorage("playerWatchlist") private var watchlistData: Data = Data()
    
    // MARK: - Dashboard Preferences
    
    @AppStorage("dashboardSectionsExpanded") private var sectionsExpandedData: Data = Data()
    @AppStorage("lastTeamRefresh") private var lastTeamRefreshTimestamp: Double = 0
    
    private init() {}
    
    // MARK: - Filter Preferences
    
    var selectedPosition: Position? {
        get {
            storedPosition.isEmpty ? nil : Position(rawValue: storedPosition)
        }
        set {
            storedPosition = newValue?.rawValue ?? ""
        }
    }
    
    var playerSort: PlayerSort {
        get {
            PlayerSort(rawValue: storedSort) ?? .averageDesc
        }
        set {
            storedSort = newValue.rawValue
        }
    }
    
    var searchText: String {
        get { storedSearchText }
        set { storedSearchText = newValue }
    }
    
    // MARK: - Watchlist Management
    
    private var _watchlist: Set<String> = []
    private var watchlistLoaded = false
    
    var watchlist: Set<String> {
        if !watchlistLoaded {
            loadWatchlist()
        }
        return _watchlist
    }
    
    func addToWatchlist(_ playerId: String) {
        _watchlist.insert(playerId)
        saveWatchlist()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func removeFromWatchlist(_ playerId: String) {
        _watchlist.remove(playerId)
        saveWatchlist()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func isInWatchlist(_ playerId: String) -> Bool {
        return watchlist.contains(playerId)
    }
    
    func toggleWatchlist(_ playerId: String) {
        if isInWatchlist(playerId) {
            removeFromWatchlist(playerId)
        } else {
            addToWatchlist(playerId)
        }
    }
    
    private func loadWatchlist() {
        guard let watchlistSet = try? JSONDecoder().decode(Set<String>.self, from: watchlistData) else {
            _watchlist = Set<String>()
            watchlistLoaded = true
            return
        }
        _watchlist = watchlistSet
        watchlistLoaded = true
    }
    
    private func saveWatchlist() {
        guard let encoded = try? JSONEncoder().encode(_watchlist) else { return }
        watchlistData = encoded
    }
    
    // MARK: - Dashboard Sections
    
    private var _sectionsExpanded: [String: Bool] = [:]
    private var sectionsLoaded = false
    
    func isSectionExpanded(_ sectionId: String) -> Bool {
        if !sectionsLoaded {
            loadSectionsExpanded()
        }
        return _sectionsExpanded[sectionId] ?? true // Default to expanded
    }
    
    func setSectionExpanded(_ sectionId: String, expanded: Bool) {
        if !sectionsLoaded {
            loadSectionsExpanded()
        }
        _sectionsExpanded[sectionId] = expanded
        saveSectionsExpanded()
    }
    
    private func loadSectionsExpanded() {
        guard let sections = try? JSONDecoder().decode([String: Bool].self, from: sectionsExpandedData) else {
            _sectionsExpanded = [:]
            sectionsLoaded = true
            return
        }
        _sectionsExpanded = sections
        sectionsLoaded = true
    }
    
    private func saveSectionsExpanded() {
        guard let encoded = try? JSONEncoder().encode(_sectionsExpanded) else { return }
        sectionsExpandedData = encoded
    }
    
    // MARK: - Team Data
    
    var lastTeamRefresh: Date {
        get { Date(timeIntervalSince1970: lastTeamRefreshTimestamp) }
        set { lastTeamRefreshTimestamp = newValue.timeIntervalSince1970 }
    }
}

// MARK: - PlayerSort Extension

extension PlayerSort: RawRepresentable, CaseIterable {
    public init?(rawValue: String) {
        switch rawValue {
        case "priceDesc": self = .priceDesc
        case "priceAsc": self = .priceAsc
        case "averageDesc": self = .averageDesc
        case "averageAsc": self = .averageAsc
        case "breakevenAsc": self = .breakevenAsc
        default: return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .priceDesc: return "priceDesc"
        case .priceAsc: return "priceAsc"
        case .averageDesc: return "averageDesc"
        case .averageAsc: return "averageAsc"
        case .breakevenAsc: return "breakevenAsc"
        }
    }
}

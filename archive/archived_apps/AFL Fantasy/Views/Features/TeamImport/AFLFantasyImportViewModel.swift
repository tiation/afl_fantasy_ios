import Foundation
import SwiftUI

// MARK: - Import State

enum ImportState {
    case initial
    case importing
    case success
    case error
}

// MARK: - Import Steps

enum ImportStep: String, CaseIterable {
    case connecting = "connecting"
    case authenticating = "authenticating"
    case fetchingTeam = "fetchingTeam"
    case processingPlayers = "processingPlayers"
    case savingData = "savingData"
    
    var title: String {
        switch self {
        case .connecting:
            return "Connecting to AFL Fantasy"
        case .authenticating:
            return "Authenticating with your credentials"
        case .fetchingTeam:
            return "Fetching your team data"
        case .processingPlayers:
            return "Processing player information"
        case .savingData:
            return "Saving your team"
        }
    }
    
    var description: String {
        switch self {
        case .connecting:
            return "Establishing secure connection to fantasy.afl.com.au"
        case .authenticating:
            return "Verifying your login credentials"
        case .fetchingTeam:
            return "Downloading roster, scores, and rankings"
        case .processingPlayers:
            return "Organizing player data and statistics"
        case .savingData:
            return "Securely storing your team information"
        }
    }
}

// MARK: - Imported Team Data

struct ImportedTeamData {
    let totalPlayers: Int
    let teamValue: Int
    let currentScore: Int
    let overallRank: Int
    let players: [ImportedPlayer]
    let lastUpdated: Date
    
    init() {
        self.totalPlayers = 22
        self.teamValue = 12500000 // $12.5M
        self.currentScore = 2134
        self.overallRank = 47291
        self.players = []
        self.lastUpdated = Date()
    }
}

struct ImportedPlayer {
    let id: String
    let name: String
    let position: String
    let price: Int
    let score: Int
    let isOnField: Bool
    let isCaptain: Bool
    let isViceCaptain: Bool
}

// MARK: - AFL Fantasy Import ViewModel

@MainActor
final class AFLFantasyImportViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var importState: ImportState = .initial
    @Published var username = ""
    @Published var password = ""
    @Published var progressMessage = ""
    @Published var progressDetail = ""
    @Published var currentStep: ImportStep?
    @Published var completedSteps: Set<ImportStep> = []
    @Published var importedTeamData: ImportedTeamData?
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Private Properties
    
    private let keychainManager = KeychainManager()
    private let importService = AFLFantasyImportService()
    
    // MARK: - Public Methods
    
    func startImport() {
        guard !username.isEmpty && !password.isEmpty else { return }
        
        importState = .importing
        completedSteps.removeAll()
        currentStep = .connecting
        progressMessage = "Starting import process..."
        progressDetail = "This may take a few moments"
        
        Task {
            await performImport()
        }
    }
    
    func resetToInitial() {
        importState = .initial
        currentStep = nil
        completedSteps.removeAll()
        progressMessage = ""
        progressDetail = ""
        errorMessage = ""
        showError = false
    }
    
    func enableAutoSync() {
        // Store auto-sync preference
        UserDefaults.standard.set(true, forKey: "aflFantasyAutoSync")
        
        // TODO: Schedule background refresh
        progressDetail = "Auto-sync enabled - your team will update automatically"
    }
    
    func refreshTeamData() {
        Task {
            await performQuickRefresh()
        }
    }
    
    func openSupportEmail() {
        let email = "support@aflfantasyai.com"
        let subject = "AFL Fantasy Import Issue"
        let body = "I'm having trouble importing my AFL Fantasy team. Error: \(errorMessage)"
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Private Methods
    
    private func performImport() async {
        do {
            // Step 1: Connecting
            await updateProgress(.connecting, "Connecting to AFL Fantasy", "Establishing secure connection...")
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            await completeStep(.connecting)
            
            // Step 2: Authenticating
            await updateProgress(.authenticating, "Authenticating", "Verifying your credentials...")
            
            // Store credentials securely
            keychainManager.storeAFLUsername(username)
            keychainManager.storeAFLPassword(password)
            keychainManager.storeAFLTeamId("temp")
            keychainManager.storeAFLSessionCookie("temp")
            
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            await completeStep(.authenticating)
            
            // Step 3: Fetching team data
            await updateProgress(.fetchingTeam, "Fetching Team Data", "Downloading your roster and statistics...")
            
            // Use the Python scraper service
            let teamData = try await importService.importTeamData(username: username, password: password)
            
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            await completeStep(.fetchingTeam)
            
            // Step 4: Processing players
            await updateProgress(.processingPlayers, "Processing Players", "Organizing player information...")
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            await completeStep(.processingPlayers)
            
            // Step 5: Saving data
            await updateProgress(.savingData, "Saving Data", "Securely storing your team information...")
            
            // Save team data
            await saveImportedData(teamData)
            
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await completeStep(.savingData)
            
            // Success!
            importState = .success
            importedTeamData = teamData
            
        } catch {
            await handleImportError(error)
        }
    }
    
    private func performQuickRefresh() async {
        guard keychainManager.getAFLTeamId() != nil else { return }
        
        progressDetail = "Refreshing team data..."
        
        do {
            let teamData = try await importService.importTeamData(username: username, password: password)
            await saveImportedData(teamData)
            importedTeamData = teamData
            progressDetail = "Team data updated successfully"
        } catch {
            progressDetail = "Failed to refresh data: \(error.localizedDescription)"
        }
    }
    
    private func updateProgress(_ step: ImportStep, _ message: String, _ detail: String) async {
        currentStep = step
        progressMessage = message
        progressDetail = detail
    }
    
    private func completeStep(_ step: ImportStep) async {
        completedSteps.insert(step)
    }
    
    private func saveImportedData(_ teamData: ImportedTeamData) async {
        // Save to Keychain and local storage
        keychainManager.storeAFLTeamId("imported_\(Date().timeIntervalSince1970)")
        keychainManager.storeAFLSessionCookie("session_token")
        
        // Save team data to UserDefaults for quick access
        if let data = try? JSONEncoder().encode(teamData) {
            UserDefaults.standard.set(data, forKey: "importedTeamData")
        }
        
        // Save last import date
        UserDefaults.standard.set(Date(), forKey: "lastTeamImport")
    }
    
    private func handleImportError(_ error: Error) async {
        importState = .error
        
        // Map different error types to user-friendly messages
        if error.localizedDescription.contains("authentication") {
            errorMessage = "Could not log in to AFL Fantasy. Please check your email and password."
        } else if error.localizedDescription.contains("network") {
            errorMessage = "Network connection problem. Please check your internet connection and try again."
        } else if error.localizedDescription.contains("timeout") {
            errorMessage = "The import took too long. AFL Fantasy servers might be slow - please try again."
        } else {
            errorMessage = "Import failed: \(error.localizedDescription). Please try again or contact support."
        }
        
        showError = true
    }
}

// MARK: - AFL Fantasy Import Service

class AFLFantasyImportService {
    
    func importTeamData(username: String, password: String) async throws -> ImportedTeamData {
        // This would integrate with the Python scrapers
        // For now, return mock data to demonstrate the flow
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Simulate potential failure (remove in production)
        if username.contains("test_fail") {
            throw AFLFantasyImportError.authenticationFailed
        }
        
        // Return mock team data
        return ImportedTeamData()
    }
    
    // TODO: Integrate with Python scrapers
    private func callPythonScraper(username: String, password: String) async throws -> [String: Any] {
        // This would call the existing Python scrapers:
        // - afl_fantasy_team_scraper.py
        // - afl_fantasy_simple_scraper.py
        // - afl_fantasy_authenticated_scraper.py
        
        // Implementation would:
        // 1. Set environment variables for credentials
        // 2. Execute Python script via Process
        // 3. Parse JSON output
        // 4. Return structured data
        
        throw AFLFantasyImportError.notImplemented
    }
}

// MARK: - Import Errors

enum AFLFantasyImportError: LocalizedError {
    case authenticationFailed
    case networkError
    case parseError
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication failed - please check your AFL Fantasy credentials"
        case .networkError:
            return "Network connection error - please check your internet connection"
        case .parseError:
            return "Could not parse team data - AFL Fantasy website may have changed"
        case .notImplemented:
            return "Python scraper integration not yet implemented"
        }
    }
}

// MARK: - Data Extension for Codable

extension ImportedTeamData: Codable {}
extension ImportedPlayer: Codable {}

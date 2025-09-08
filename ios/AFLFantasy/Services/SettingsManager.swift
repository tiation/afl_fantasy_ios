import SwiftUI
import UserNotifications

@MainActor
class SettingsManager: ObservableObject {
    // MARK: - Notification Settings

    @AppStorage("enableBreakevenAlerts") var enableBreakevenAlerts = false
    @AppStorage("enableInjuryAlerts") var enableInjuryAlerts = false
    @AppStorage("enableLateOutAlerts") var enableLateOutAlerts = false
    @AppStorage("enableTradeAlerts") var enableTradeAlerts = false
    @AppStorage("enablePriceChangeAlerts") var enablePriceChangeAlerts = false
    @AppStorage("enableCaptainAlerts") var enableCaptainAlerts = false
    @AppStorage("notificationsSoundEnabled") var notificationsSoundEnabled = true
    @AppStorage("notificationsBadgeEnabled") var notificationsBadgeEnabled = true

    // MARK: - AI Analysis Settings

    @AppStorage("aiConfidenceThreshold") var aiConfidenceThreshold = 75.0
    @AppStorage("showLowConfidencePicks") var showLowConfidencePicks = false
    @AppStorage("enableAdvancedAnalytics") var enableAdvancedAnalytics = false
    @AppStorage("autoUpdateInterval") var autoUpdateInterval = 300.0 // 5 minutes default

    // MARK: - Display Settings

    @AppStorage("showPlayerOwnership") var showPlayerOwnership = true
    @AppStorage("showVenueWeather") var showVenueWeather = true
    @AppStorage("compactPlayerCards") var compactPlayerCards = false
    @AppStorage("darkModePreference") var darkModePreference = 0 // 0: System, 1: Light, 2: Dark

    // MARK: - Dependencies

    private let notificationManager: NotificationManager
    private let toolsClient: AFLFantasyToolsClient
    private let appState: AppState

    init(
        notificationManager: NotificationManager,
        toolsClient: AFLFantasyToolsClient,
        appState: AppState
    ) {
        self.notificationManager = notificationManager
        self.toolsClient = toolsClient
        self.appState = appState

        // Apply initial settings
        applySettings()
    }

    // MARK: - Public Methods

    func applySettings() {
        // Apply dark mode
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = switch darkModePreference {
            case 1: .light
            case 2: .dark
            default: .unspecified
            }
        }

        // Update notification state
        if !enableBreakevenAlerts, !enableInjuryAlerts, !enableLateOutAlerts,
           !enableTradeAlerts, !enablePriceChangeAlerts, !enableCaptainAlerts {
            notificationManager.removeAllPendingNotifications()
        }

        // Update AI analysis threshold
        toolsClient.confidenceThreshold = aiConfidenceThreshold / 100.0

        // Update app settings that affect UI
        appState.setPlayersDisplayMode(compactCards: compactPlayerCards)
        appState.setAnalysisMode(advanced: enableAdvancedAnalytics)

        // Save to user defaults for persistence
        Task {
            await saveSettingsToDefaults()
        }
    }

    // MARK: - View Lifecycle

    func onAppear() {
        // Update settings effects immediately
        applySettings()

        // Observe changes
        setupNotificationObserver()
    }

    func onDisappear() {
        // Cleanup observers and pending tasks
        cleanupNotificationObserver()
    }

    // MARK: - Private Lifecycle Methods

    private var notificationObserver: NSObjectProtocol?

    private func setupNotificationObserver() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applySettings()
        }
    }

    private func cleanupNotificationObserver() {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
    }

    // MARK: - Private Methods

    private func saveSettingsToDefaults() async {
        UserDefaults.standard.synchronize()
    }
}

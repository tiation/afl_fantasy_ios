//
//  OfflineViewModifiers.swift
//  AFL Fantasy Intelligence Platform
//
//  ViewModifiers to consistently add offline indicators to views
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - WithOfflineStatusModifier

/// Adds a standard offline indicator to the top of the view
struct WithOfflineStatusModifier: ViewModifier {
    @EnvironmentObject private var offlineManager: OfflineManager

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if !offlineManager.isOnline {
                OfflineBannerView()
            }

            content
        }
    }
}

// MARK: - WithOfflineNavigationModifier

/// Adds a standard offline indicator to navigation bar
struct WithOfflineNavigationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    OfflineStatusView()
                }
            }
    }
}

// MARK: - OfflineBannerView

struct OfflineBannerView: View {
    @EnvironmentObject private var offlineManager: OfflineManager
    @State private var showingDetails = false

    var body: some View {
        Button(action: { showingDetails = true }) {
            HStack(spacing: 6) {
                Image(systemName: "wifi.slash")
                    .font(.footnote)
                    .foregroundColor(.white)

                Text("You're offline. Some features may be limited.")
                    .font(.footnote)
                    .foregroundColor(.white)

                Spacer()

                if offlineManager.pendingSyncOperations > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption)

                        Text("\(offlineManager.pendingSyncOperations)")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.red)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetails) {
            OfflineStatusDetailView()
        }
    }
}

// MARK: - OfflineDataAlert

/// Alert shown when a network operation fails due to being offline
struct OfflineDataAlert {
    let title: String
    let message: String
    let primaryAction: OfflineDataAlertAction
    let secondaryAction: OfflineDataAlertAction?

    init(
        title: String = "No Internet Connection",
        message: String = "This action requires an internet connection. Please try again when you're online.",
        primaryAction: OfflineDataAlertAction = .tryAgainLater,
        secondaryAction: OfflineDataAlertAction? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    static let standard = OfflineDataAlert()

    static let queuedOperation = OfflineDataAlert(
        title: "Saved for Later",
        message: "Your changes will be applied automatically when you're back online.",
        primaryAction: .ok
    )

    static let dataOutdated = OfflineDataAlert(
        title: "Data May Be Outdated",
        message: "You're viewing cached data which may not be up-to-date.",
        primaryAction: .ok
    )
}

// MARK: - OfflineDataAlertAction

enum OfflineDataAlertAction {
    case ok
    case tryAgainLater
    case viewOffline
    case queueForLater
    case custom(String, () -> Void)

    var title: String {
        switch self {
        case .ok:
            "OK"
        case .tryAgainLater:
            "Try Again Later"
        case .viewOffline:
            "View Offline Data"
        case .queueForLater:
            "Save for Later"
        case let .custom(title, _):
            title
        }
    }

    func performAction() {
        if case let .custom(_, action) = self {
            action()
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Add a standard offline indicator at the top of a view
    func withOfflineStatus() -> some View {
        modifier(WithOfflineStatusModifier())
    }

    /// Add an offline indicator to the navigation bar
    func withOfflineNavigation() -> some View {
        modifier(WithOfflineNavigationModifier())
    }

    /// Presents an alert when offline and the user attempts a network operation
    func offlineAlert(isPresented: Binding<Bool>, alert: OfflineDataAlert = .standard) -> some View {
        alert(
            alert.title,
            isPresented: isPresented,
            actions: {
                Button(alert.primaryAction.title) {
                    alert.primaryAction.performAction()
                }

                if let secondary = alert.secondaryAction {
                    Button(secondary.title) {
                        secondary.performAction()
                    }
                }
            },
            message: {
                Text(alert.message)
            }
        )
    }
}

// MARK: - Preview

#Preview("Banner") {
    VStack {
        OfflineBannerView()
        Spacer()
    }
    .environmentObject(OfflineManager.shared)
}

#Preview("With Offline Status") {
    VStack {
        Text("Sample Content")
    }
    .withOfflineStatus()
    .environmentObject(OfflineManager.shared)
}

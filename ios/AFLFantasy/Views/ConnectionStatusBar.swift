//
//  ConnectionStatusBar.swift
//  AFL Fantasy Intelligence Platform
//
//  Real-time connection status with intelligent refresh controls
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - ConnectionStatusBar

struct ConnectionStatusBar: View {
    @EnvironmentObject var appState: AppState
    @State private var showingErrorDetails = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.s.value) {
            // Connection Status Indicator
            HStack(spacing: DesignSystem.Spacing.xs.value) {
                Image(systemName: appState.connectionStatus.systemImage)
                    .font(.system(size: DesignSystem.IconSize.small.value))
                    .foregroundColor(appState.connectionStatus.color)
                    .symbolEffect(.pulse, isActive: appState.isRefreshing)

                Text(appState.connectionStatus.rawValue)
                    .typography(.caption2)
                    .foregroundColor(appState.connectionStatus.color)
            }

            Spacer()

            // Last Update Time
            if let lastUpdate = appState.lastUpdateTime {
                Text("Updated \(lastUpdate, format: .relative(presentation: .numeric))")
                    .typography(.caption2)
                    .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
            }

            // Refresh Button
            Button {
                withAnimation(DesignSystem.Motion.tasteful) {
                    appState.refreshData()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: DesignSystem.IconSize.small.value))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .rotationEffect(.degrees(appState.isRefreshing ? 360 : 0))
                    .animation(
                        appState.isRefreshing
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                        value: appState.isRefreshing
                    )
            }
            .tappableFrame()
            .disabled(appState.isRefreshing)
        }
        .padding(.horizontal, DesignSystem.Spacing.m.value)
        .padding(.vertical, DesignSystem.Spacing.s.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(backgroundColorForStatus(appState.connectionStatus))
        )
        .overlay(
            // Error Message Banner
            Group {
                if let errorMessage = appState.errorMessage {
                    ErrorBanner(message: errorMessage) {
                        appState.errorMessage = nil
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        )
        .onTapGesture {
            if appState.connectionStatus == .error {
                showingErrorDetails = true
            }
        }
        .sheet(isPresented: $showingErrorDetails) {
            ErrorDetailsView()
        }
    }

    private func backgroundColorForStatus(_ status: ConnectionStatus) -> Color {
        switch status {
        case .disconnected:
            DesignSystem.Colors.onSurface.opacity(0.05)
        case .connecting:
            DesignSystem.Colors.warning.opacity(0.1)
        case .connected:
            DesignSystem.Colors.success.opacity(0.1)
        case .live:
            DesignSystem.Colors.error.opacity(0.1)
        case .error:
            DesignSystem.Colors.error.opacity(0.15)
        }
    }
}

// MARK: - ErrorBanner

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.s.value) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(DesignSystem.Colors.error)

            Text(message)
                .typography(.caption1)
                .foregroundColor(DesignSystem.Colors.error)
                .lineLimit(2)

            Spacer()

            Button {
                withAnimation(DesignSystem.Motion.tasteful) {
                    onDismiss()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(DesignSystem.Colors.error.opacity(0.6))
            }
            .tappableFrame()
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(DesignSystem.Colors.error.opacity(0.1))
                .stroke(DesignSystem.Colors.error.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, DesignSystem.Spacing.m.value)
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(DesignSystem.Motion.gentleSpring.delay(0.1)) {
                isVisible = true
            }

            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if isVisible {
                    withAnimation(DesignSystem.Motion.tasteful) {
                        onDismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ErrorDetailsView

struct ErrorDetailsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.l.value) {
                    // Error Summary
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.s.value) {
                        Text("Connection Issue")
                            .typography(.title2)

                        if let errorMessage = appState.errorMessage {
                            Text(errorMessage)
                                .typography(.body)
                                .foregroundColor(DesignSystem.Colors.error)
                        } else {
                            Text("Unable to connect to AFL Fantasy servers")
                                .typography(.body)
                                .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                        }
                    }

                    // Troubleshooting Steps
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.s.value) {
                        Text("Troubleshooting Steps")
                            .typography(.headline)

                        TroubleshootingStep(
                            icon: "wifi",
                            title: "Check Internet Connection",
                            description: "Make sure you're connected to WiFi or cellular data"
                        )

                        TroubleshootingStep(
                            icon: "key.fill",
                            title: "Verify AFL Fantasy Login",
                            description: "Ensure you're logged into your AFL Fantasy account"
                        )

                        TroubleshootingStep(
                            icon: "server.rack",
                            title: "AFL Fantasy Server Status",
                            description: "The AFL Fantasy website may be experiencing issues"
                        )

                        TroubleshootingStep(
                            icon: "arrow.clockwise",
                            title: "Try Refreshing",
                            description: "Pull down to refresh or tap the refresh button"
                        )
                    }

                    Spacer(minLength: DesignSystem.Spacing.xl.value)

                    // Action Buttons
                    VStack(spacing: DesignSystem.Spacing.m.value) {
                        Button("Retry Connection") {
                            appState.refreshData()
                            dismiss()
                        }
                        .buttonStyle(AFLButtonStyle(variant: .primary))

                        Button("Clear Cache & Retry") {
                            Task {
                                try? await PersistenceManager.shared.clearExpiredCache()
                                appState.refreshData()
                            }
                            dismiss()
                        }
                        .buttonStyle(AFLButtonStyle(variant: .secondary))
                    }
                }
                .padding(DesignSystem.Spacing.l.value)
            }
            .navigationTitle("Connection Error")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - TroubleshootingStep

struct TroubleshootingStep: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.m.value) {
            Image(systemName: icon)
                .font(.system(size: DesignSystem.IconSize.medium.value))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs.value) {
                Text(title)
                    .typography(.bodySecondary)

                Text(description)
                    .typography(.caption1)
                    .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
            }

            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.xs.value)
    }
}

// MARK: - OfflineBanner

struct OfflineBanner: View {
    let lastSyncTime: Date?

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.s.value) {
            Image(systemName: "wifi.slash")
                .foregroundColor(DesignSystem.Colors.warning)

            VStack(alignment: .leading, spacing: 2) {
                Text("Offline Mode")
                    .typography(.caption1)
                    .foregroundColor(DesignSystem.Colors.warning)

                if let lastSync = lastSyncTime {
                    Text("Last sync: \(lastSync, format: .relative(presentation: .named))")
                        .typography(.caption2)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                } else {
                    Text("No recent data available")
                        .typography(.caption2)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                }
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(DesignSystem.Colors.warning.opacity(0.1))
                .stroke(DesignSystem.Colors.warning.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - LiveDataIndicator

struct LiveDataIndicator: View {
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs.value) {
            Circle()
                .fill(DesignSystem.Colors.error)
                .frame(width: 8, height: 8)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .opacity(isPulsing ? 0.6 : 1.0)
                .animation(
                    .easeInOut(duration: 1).repeatForever(autoreverses: true),
                    value: isPulsing
                )

            Text("LIVE")
                .typography(.caption2)
                .foregroundColor(DesignSystem.Colors.error)
                .fontWeight(.bold)
        }
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ConnectionStatusBar()
            .environmentObject(AppState())

        Spacer()

        OfflineBanner(lastSyncTime: Date().addingTimeInterval(-300))

        Spacer()

        LiveDataIndicator()
    }
    .padding()
}

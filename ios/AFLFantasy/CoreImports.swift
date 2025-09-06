//
//  CoreImports.swift
//  AFL Fantasy Intelligence Platform
//
//  This file imports all Core services into the main app target.
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// This file ensures that all Core components are compiled as part of the main target
// The actual implementations are in the Core directory but need to be accessible

// Include these by copying their contents inline until we fix the project structure

// MARK: - Temporary inline DesignSystem components

// TODO: Move to proper module structure

extension DesignSystem {
    enum Spacing: CGFloat, CaseIterable {
        case xs = 4
        case s = 8
        case sm = 12
        case m = 16
        case l = 20
        case xl = 24
        case xxl = 32
        case xxxl = 40

        var value: CGFloat { rawValue }
    }

    enum IconSize: CGFloat {
        case small = 16
        case medium = 20
        case large = 24
        case xlarge = 32

        var value: CGFloat { rawValue }
    }

    enum CornerRadius: CGFloat {
        case small = 8
        case medium = 12
        case large = 16
        case xlarge = 20

        var value: CGFloat { rawValue }
    }
}

// MARK: - Temporary typography extension

// TODO: Move to proper module structure

extension View {
    @ViewBuilder
    func typography(_ style: Font.TextStyle) -> some View {
        font(.system(style))
    }
}

// MARK: - Placeholder View Modifiers

// These will be replaced with full implementations once Core files are properly included
// GitHub Issue: "Implement reachabilityStatus & backgroundSync view modifiers"
// Expected behavior:
// - reachabilityStatus(): Shows offline banner when network is unavailable, monitors connectivity
// - backgroundSync(): Triggers background data refresh on app launch and lifecycle events

extension View {
    /// Placeholder for network reachability status overlay
    /// TODO: Replace with full ReachabilityService implementation from Core/ReachabilityService.swift
    /// Expected: Shows red banner when offline with connection status and duration
    @ViewBuilder
    func reachabilityStatus() -> some View {
        self
    }

    /// Placeholder for background sync functionality
    /// TODO: Replace with full BackgroundSyncService implementation from Core/BackgroundSyncService.swift
    /// Expected: Automatically syncs data on app launch and when returning from background
    @ViewBuilder
    func backgroundSync() -> some View {
        self
    }
}

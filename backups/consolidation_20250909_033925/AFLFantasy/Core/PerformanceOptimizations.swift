//
//  PerformanceOptimizations.swift
//  AFL Fantasy Intelligence Platform
//
//  Performance-focused components and utilities for optimal iOS experience
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import Foundation
import SwiftUI
import UIKit

// MARK: - LazyLoadingManager

public class LazyLoadingManager: ObservableObject {
    @Published var criticalDataLoaded = false
    @Published var nonCriticalDataLoaded = false
    @Published var isInitialized = false

    init() {
        loadCriticalDataFirst()
    }

    private func loadCriticalDataFirst() {
        // Load only essential data for first paint
        Task {
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms simulation
            await MainActor.run {
                self.criticalDataLoaded = true
                self.isInitialized = true
            }
        }
    }

    private func loadNonCriticalData() {
        // Load analytics, additional features, etc.
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms simulation
            await MainActor.run {
                self.nonCriticalDataLoaded = true
            }
        }
    }
}

// MARK: - Performance Extensions

public extension View {
    // Stable frame to prevent layout thrash
    func stableFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        frame(
            minWidth: width, maxWidth: width,
            minHeight: height, maxHeight: height
        )
    }

    // Cancel work when view disappears
    func cancelWorkOnDisappear(_ cancellable: (some Cancellable)?) -> some View {
        onDisappear {
            cancellable?.cancel()
        }
    }

    // Efficient list items
    func listRowOptimized() -> some View {
        listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .buttonStyle(PlainButtonStyle()) // Prevents default button animations
    }
}

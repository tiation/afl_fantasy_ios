//
//  StatusReportingService.swift
//  AFL Fantasy Intelligence Platform
//
//  Status reporting service to integrate with central monitoring dashboard
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import Network
import os.log
import SwiftUI
import UIKit

// MARK: - StatusReportingService

@MainActor
class StatusReportingService: ObservableObject {
    @Published var reportingStatus: ReportingStatus = .idle
    @Published var lastReportTime: Date?
    @Published var reportingEnabled: Bool = true

    private let logger = Logger(subsystem: "AFLFantasy", category: "StatusReporting")
    private let reportingEndpoint = "http://localhost:5173/api/ios-status"
    private let reportingInterval: TimeInterval = 300 // 5 minutes

    private var reportingTimer: Timer?
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    // Device and app metrics
    private var appStartTime = Date()
    private var syncCount = 0
    private var errorCount = 0

    init() {
        startNetworkMonitoring()
        startPeriodicReporting()
    }

    deinit {
        networkMonitor.cancel()
        reportingTimer?.invalidate()
    }

    // MARK: - Public Methods

    func reportStatusNow() async {
        await performStatusReport()
    }

    func incrementSyncCount() {
        syncCount += 1
    }

    func incrementErrorCount() {
        errorCount += 1
    }

    func toggleReporting(_ enabled: Bool) {
        reportingEnabled = enabled

        if enabled {
            startPeriodicReporting()
            logger.info("📡 Status reporting enabled")
        } else {
            reportingTimer?.invalidate()
            logger.info("📡 Status reporting disabled")
        }
    }

    // MARK: - Private Methods

    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.handleNetworkChange(path)
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }

    private func handleNetworkChange(_ path: NWPath) {
        if path.status == .satisfied, reportingEnabled {
            // Network is available, try to report status
            Task {
                await performStatusReport()
            }
        }
    }

    private func startPeriodicReporting() {
        guard reportingEnabled else { return }

        reportingTimer?.invalidate()
        reportingTimer = Timer.scheduledTimer(withTimeInterval: reportingInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.performStatusReport()
            }
        }
    }

    private func performStatusReport() async {
        guard reportingEnabled else { return }

        reportingStatus = .reporting

        do {
            let statusData = generateStatusData()
            let success = await sendStatusReport(statusData)

            if success {
                lastReportTime = Date()
                reportingStatus = .success
                logger.info("📊 Status report sent successfully")
            } else {
                reportingStatus = .failed
                errorCount += 1
                logger.error("❌ Failed to send status report")
            }

        } catch {
            reportingStatus = .failed
            errorCount += 1
            logger.error("❌ Status report error: \(error.localizedDescription)")
        }

        // Reset status after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.reportingStatus = .idle
        }
    }

    private func generateStatusData() -> [String: Any] {
        let device = UIDevice.current
        let app = UIApplication.shared

        return [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "device": [
                "model": device.model,
                "systemName": device.systemName,
                "systemVersion": device.systemVersion,
                "name": device.name,
                "batteryLevel": device.batteryLevel,
                "batteryState": batteryStateString(device.batteryState)
            ],
            "app": [
                "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
                "uptime": Date().timeIntervalSince(appStartTime),
                "applicationState": applicationStateString(app.applicationState),
                "backgroundRefreshStatus": backgroundRefreshStatusString(app.backgroundRefreshStatus)
            ],
            "metrics": [
                "syncCount": syncCount,
                "errorCount": errorCount,
                "memoryUsage": getMemoryUsage(),
                "diskSpace": getDiskSpace(),
                "isNetworkReachable": networkMonitor.currentPath.status == .satisfied,
                "connectionType": connectionTypeString(networkMonitor.currentPath)
            ],
            "sync": [
                "status": "active",
                "lastSync": lastReportTime?.timeIntervalSince1970 ?? 0,
                "frequency": "5min",
                "backgroundSyncs": max(0, syncCount - 10) // Estimate background syncs
            ]
        ]
    }

    private func sendStatusReport(_ data: [String: Any]) async -> Bool {
        guard let url = URL(string: reportingEndpoint) else {
            logger.error("❌ Invalid reporting endpoint URL")
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("AFL-Fantasy-iOS/1.0", forHTTPHeaderField: "User-Agent")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }

            return false

        } catch {
            logger.error("❌ Network error sending status report: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Helper Methods

    private func batteryStateString(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .unknown: return "unknown"
        case .unplugged: return "unplugged"
        case .charging: return "charging"
        case .full: return "full"
        @unknown default: return "unknown"
        }
    }

    private func applicationStateString(_ state: UIApplication.State) -> String {
        switch state {
        case .active: return "active"
        case .inactive: return "inactive"
        case .background: return "background"
        @unknown default: return "unknown"
        }
    }

    private func backgroundRefreshStatusString(_ status: UIBackgroundRefreshStatus) -> String {
        switch status {
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .available: return "available"
        @unknown default: return "unknown"
        }
    }

    private func connectionTypeString(_ path: NWPath) -> String {
        if path.usesInterfaceType(.wifi) {
            "wifi"
        } else if path.usesInterfaceType(.cellular) {
            "cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            "ethernet"
        } else {
            "unknown"
        }
    }

    private func getMemoryUsage() -> [String: Any] {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            return [
                "resident": info.resident_size,
                "virtual": info.virtual_size,
                "residentMB": Double(info.resident_size) / 1024 / 1024,
                "virtualMB": Double(info.virtual_size) / 1024 / 1024
            ]
        }

        return [:]
    }

    private func getDiskSpace() -> [String: Any] {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())

            if let totalSpace = attributes[.systemSize] as? Int64,
               let freeSpace = attributes[.systemFreeSize] as? Int64 {
                return [
                    "total": totalSpace,
                    "free": freeSpace,
                    "used": totalSpace - freeSpace,
                    "totalGB": Double(totalSpace) / 1024 / 1024 / 1024,
                    "freeGB": Double(freeSpace) / 1024 / 1024 / 1024,
                    "usedGB": Double(totalSpace - freeSpace) / 1024 / 1024 / 1024
                ]
            }
        } catch {
            logger.error("❌ Error getting disk space: \(error.localizedDescription)")
        }

        return [:]
    }
}

// MARK: - ReportingStatus

enum ReportingStatus {
    case idle
    case reporting
    case success
    case failed

    var displayText: String {
        switch self {
        case .idle: "Ready"
        case .reporting: "Reporting..."
        case .success: "Sent"
        case .failed: "Failed"
        }
    }

    var color: UIColor {
        switch self {
        case .idle: .systemGray
        case .reporting: .systemBlue
        case .success: .systemGreen
        case .failed: .systemRed
        }
    }
}

// MARK: - StatusReportingModifier

struct StatusReportingModifier: ViewModifier {
    @StateObject private var statusReporting = StatusReportingService()

    func body(content: Content) -> some View {
        content
            .environmentObject(statusReporting)
            .task {
                // Send initial status report when app launches
                await statusReporting.reportStatusNow()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Report status when app becomes active
                Task {
                    await statusReporting.reportStatusNow()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                // Report status when app goes to background
                Task {
                    await statusReporting.reportStatusNow()
                }
            }
    }
}

extension View {
    func statusReporting() -> some View {
        modifier(StatusReportingModifier())
    }
}

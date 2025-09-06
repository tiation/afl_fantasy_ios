//
//  AlertService.swift
//  AFL Fantasy Intelligence Platform
//
//  Smart Alert System for Proactive Notifications and Risk Detection
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI
import UserNotifications

// MARK: - Smart Alert Service

@MainActor
class AlertService: ObservableObject {
    @Published var activeAlerts: [AlertFlag] = []
    @Published var alertHistory: [AlertFlag] = []
    @Published var monitoredPlayers: Set<String> = []
    @Published var alertPreferences: AlertPreferences = AlertPreferences()
    
    private var alertGenerationTimer: Timer?
    
    init() {
        setupPeriodicAlertGeneration()
        requestNotificationPermission()
    }
    
    // MARK: - AI Alert Generator
    
    func generateAIAlerts(for players: [Player], currentRound: Int) {
        var newAlerts: [AlertFlag] = []
        
        for player in players {
            // Price Drop Risk Analysis
            if let priceDropAlert = analyzePlayerForPriceDropRisk(player: player, round: currentRound) {
                newAlerts.append(priceDropAlert)
            }
            
            // Breakeven Cliff Analysis
            if let breakevenAlert = analyzeBreakevenCliff(player: player, round: currentRound) {
                newAlerts.append(breakevenAlert)
            }
            
            // Cash Cow Sell Signal
            if let cashCowAlert = analyzeCashCowSellSignal(player: player, round: currentRound) {
                newAlerts.append(cashCowAlert)
            }
            
            // Injury Risk Escalation
            if let injuryAlert = analyzeInjuryRiskEscalation(player: player) {
                newAlerts.append(injuryAlert)
            }
            
            // Role Change Detection
            if let roleAlert = analyzeRoleChanges(player: player, round: currentRound) {
                newAlerts.append(roleAlert)
            }
            
            // Weather Risk Assessment
            if let weatherAlert = analyzeWeatherRisk(player: player, round: currentRound) {
                newAlerts.append(weatherAlert)
            }
            
            // Contract Year Motivation
            if let contractAlert = analyzeContractYearImpact(player: player) {
                newAlerts.append(contractAlert)
            }
            
            // Premium Breakout Detection
            if let breakoutAlert = analyzePremiumBreakout(player: player) {
                newAlerts.append(breakoutAlert)
            }
        }
        
        // Add bye round alerts
        newAlerts.append(contentsOf: generateByeRoundAlerts(players: players, currentRound: currentRound))
        
        // Filter out duplicate alerts and add to active alerts
        let filteredAlerts = filterDuplicateAlerts(newAlerts: newAlerts)
        activeAlerts.append(contentsOf: filteredAlerts)
        
        // Send push notifications for critical alerts
        sendPushNotifications(for: filteredAlerts)
        
        // Clean up old alerts
        cleanupOldAlerts()
    }
    
    private func analyzePlayerForPriceDropRisk(player: Player, round: Int) -> AlertFlag? {
        // Complex algorithm considering multiple factors
        let riskFactors = calculatePriceDropRiskFactors(player: player)
        let totalRisk = riskFactors.reduce(0.0, +)
        
        guard totalRisk > 0.7 else { return nil }
        
        let priority: AlertPriority = totalRisk > 0.9 ? .critical : totalRisk > 0.8 ? .high : .medium
        
        return AlertFlag(
            type: .priceDrop,
            priority: priority,
            title: "⚠️ Price Drop Risk: \(player.name)",
            message: "High probability (\(Int(totalRisk * 100))%) of price drop. Current BE: \(player.breakeven). Consider trading.",
            timestamp: Date(),
            actionRequired: true
        )
    }
    
    private func calculatePriceDropRiskFactors(player: Player) -> [Double] {
        var factors: [Double] = []
        
        // Factor 1: High breakeven vs projected score
        let breakevenRisk = player.breakeven > 0 && Double(player.breakeven) > player.nextRoundProjection.projectedScore * 1.1 ? 0.3 : 0.0
        factors.append(breakevenRisk)
        
        // Factor 2: Recent form decline
        let formRisk = player.seasonalTrend.trendDirection == .declining ? 0.25 : 0.0
        factors.append(formRisk)
        
        // Factor 3: Injury concerns
        let injuryRisk = player.injuryRisk.riskLevel == .high ? 0.2 : player.injuryRisk.riskLevel == .moderate ? 0.1 : 0.0
        factors.append(injuryRisk)
        
        // Factor 4: Venue disadvantage
        let venueRisk = player.venuePerformance.first(where: { $0.venueName == player.nextRoundProjection.venue })?.bias ?? 0.0
        factors.append(venueRisk < -3 ? 0.15 : 0.0)
        
        // Factor 5: Hard opponent matchup
        let opponentRisk = player.opponentPerformance.first(where: { $0.opponentTeam == player.nextRoundProjection.opponent })?.dvpRanking ?? 10
        factors.append(opponentRisk > 15 ? 0.1 : 0.0)
        
        return factors
    }
    
    private func analyzeBreakevenCliff(player: Player, round: Int) -> AlertFlag? {
        // Detect players approaching dangerous breakeven thresholds
        guard player.breakeven > 0 && player.currentPrice > 400000 else { return nil }
        
        let breakevenMultiplier = Double(player.breakeven) / player.averageScore
        let cliffRisk = breakevenMultiplier > 1.5 // Breakeven 50%+ higher than average
        
        guard cliffRisk else { return nil }
        
        return AlertFlag(
            type: .breakEvenCliff,
            priority: breakevenMultiplier > 2.0 ? .critical : .high,
            title: "🚨 Breakeven Cliff: \(player.name)",
            message: "BE (\(player.breakeven)) is \(Int((breakevenMultiplier - 1) * 100))% above season average. Price drop imminent.",
            timestamp: Date(),
            actionRequired: true
        )
    }
    
    private func analyzeCashCowSellSignal(player: Player, round: Int) -> AlertFlag? {
        guard player.isCashCow && player.cashGenerated > 100000 else { return nil }
        
        // Analyze optimal sell timing
        let sellSignalFactors = calculateCashCowSellFactors(player: player)
        let sellConfidence = sellSignalFactors.reduce(0.0, +) / Double(sellSignalFactors.count)
        
        guard sellConfidence > 0.7 else { return nil }
        
        let priority: AlertPriority = sellConfidence > 0.9 ? .critical : sellConfidence > 0.8 ? .high : .medium
        
        return AlertFlag(
            type: .cashCowSell,
            priority: priority,
            title: "💰 Cash Cow Ready: \(player.name)",
            message: "Generated $\(player.cashGenerated/1000)k. \(Int(sellConfidence * 100))% sell confidence. Optimal sell window.",
            timestamp: Date(),
            actionRequired: true
        )
    }
    
    private func calculateCashCowSellFactors(player: Player) -> [Double] {
        var factors: [Double] = []
        
        // Factor 1: Cash generation milestone
        factors.append(player.cashGenerated > 150000 ? 1.0 : player.cashGenerated > 100000 ? 0.7 : 0.3)
        
        // Factor 2: Price trajectory flattening
        let recentGrowthRate = player.priceChangeProbability // Simplified
        factors.append(recentGrowthRate < 0.3 ? 0.8 : recentGrowthRate < 0.5 ? 0.5 : 0.2)
        
        // Factor 3: Approaching premium upgrade opportunity
        factors.append(player.currentPrice + player.cashGenerated > 550000 ? 0.9 : 0.3)
        
        // Factor 4: Future fixture difficulty
        let upcomingDifficulty = player.threeRoundProjection.reduce(0.0) { acc, projection in
            // Simplified difficulty calculation
            return acc + (projection.projectedScore < player.averageScore ? 1.0 : 0.0)
        } / 3.0
        factors.append(upcomingDifficulty > 0.6 ? 0.7 : 0.3)
        
        return factors
    }
    
    private func analyzeInjuryRiskEscalation(player: Player) -> AlertFlag? {
        guard player.injuryRisk.riskLevel != .low else { return nil }
        
        // Check for escalating injury risk patterns
        let riskIncreasing = player.injuryRisk.reinjuryProbability > 0.6
        let hasRecentHistory = !player.injuryRisk.injuryHistory.isEmpty && 
                               player.injuryRisk.injuryHistory.contains { $0.season >= 2024 }
        
        guard riskIncreasing || hasRecentHistory else { return nil }
        
        return AlertFlag(
            type: .injuryRisk,
            priority: player.injuryRisk.riskLevel == .extreme ? .critical : .high,
            title: "🏥 Injury Risk: \(player.name)",
            message: "Elevated injury risk (\(player.injuryRisk.riskLevel.rawValue)). Reinjury probability: \(Int(player.injuryRisk.reinjuryProbability * 100))%",
            timestamp: Date(),
            actionRequired: player.injuryRisk.riskLevel == .extreme
        )
    }
    
    private func analyzeRoleChanges(player: Player, round: Int) -> AlertFlag? {
        // Detect significant role changes that could impact scoring
        // This would typically analyze team news, coaching changes, etc.
        // Simplified implementation here
        
        let hasPositionalFlexibility = player.position == .midfielder || player.position == .forward
        let recentFormVariance = player.volatility > 20
        
        guard hasPositionalFlexibility && recentFormVariance else { return nil }
        
        // In a real implementation, this would analyze actual team news and role data
        let roleChangeDetected = Int.random(in: 0...100) < 15 // 15% chance for demo
        
        guard roleChangeDetected else { return nil }
        
        return AlertFlag(
            type: .roleChange,
            priority: .medium,
            title: "🔄 Role Change: \(player.name)",
            message: "Potential role/position change detected. Monitor team news and training reports.",
            timestamp: Date(),
            actionRequired: false
        )
    }
    
    private func analyzeWeatherRisk(player: Player, round: Int) -> AlertFlag? {
        let conditions = player.nextRoundProjection.conditions
        
        var riskFactors: [String] = []
        var severity: AlertPriority = .low
        
        if conditions.rainProbability > 0.8 {
            riskFactors.append("Heavy rain expected (\(Int(conditions.rainProbability * 100))%)")
            severity = .high
        } else if conditions.rainProbability > 0.6 {
            riskFactors.append("Rain likely (\(Int(conditions.rainProbability * 100))%)")
            severity = .medium
        }
        
        if conditions.windSpeed > 30 {
            riskFactors.append("Strong winds (\(conditions.windSpeed)km/h)")
            severity = max(severity, .medium)
        }
        
        if conditions.temperature < 5 || conditions.temperature > 35 {
            riskFactors.append("Extreme temperature (\(conditions.temperature)°C)")
            severity = max(severity, .medium)
        }
        
        guard !riskFactors.isEmpty else { return nil }
        
        return AlertFlag(
            type: .weatherRisk,
            priority: severity,
            title: "🌧️ Weather Alert: \(player.name)",
            message: "Adverse conditions at \(player.nextRoundProjection.venue): \(riskFactors.joined(separator: ", "))",
            timestamp: Date(),
            actionRequired: severity == .high
        )
    }
    
    private func analyzeContractYearImpact(player: Player) -> AlertFlag? {
        guard player.contractStatus.contractYear && player.contractStatus.motivationBonus > 0.05 else { return nil }
        
        // Only alert once per player per season
        let existingAlert = alertHistory.contains { alert in
            alert.type == .captainRecommendation && alert.title.contains(player.name) && alert.message.contains("contract")
        }
        guard !existingAlert else { return nil }
        
        return AlertFlag(
            type: .captainRecommendation,
            priority: .medium,
            title: "📈 Contract Motivation: \(player.name)",
            message: "Playing for new contract. Historical \(Int(player.contractStatus.motivationBonus * 100))% performance boost expected.",
            timestamp: Date(),
            actionRequired: false
        )
    }
    
    private func analyzePremiumBreakout(player: Player) -> AlertFlag? {
        guard player.seasonProjection.premiumPotential > 0.8 && player.currentPrice < 600000 else { return nil }
        
        let recentTrend = player.seasonalTrend.trendDirection == .improving
        let valuePrice = player.currentPrice < 500000
        
        guard recentTrend && valuePrice else { return nil }
        
        return AlertFlag(
            type: .tradeOpportunity,
            priority: .high,
            title: "⭐ Premium Breakout: \(player.name)",
            message: "\(Int(player.seasonProjection.premiumPotential * 100))% premium potential at value price ($\(player.currentPrice/1000)k)",
            timestamp: Date(),
            actionRequired: true
        )
    }
    
    private func generateByeRoundAlerts(players: [Player], currentRound: Int) -> [AlertFlag] {
        var byeAlerts: [AlertFlag] = []
        
        // Check upcoming bye rounds (simplified implementation)
        for round in (currentRound + 1)...(currentRound + 3) {
            let playersOnBye = players.filter { player in
                // In real implementation, this would check actual bye round data
                return player.teamId % 6 == round % 6 // Simplified bye logic
            }
            
            if playersOnBye.count >= 6 { // Major bye round impact
                byeAlerts.append(AlertFlag(
                    type: .byeRoundWarning,
                    priority: .high,
                    title: "📅 Major Bye Round \(round)",
                    message: "\(playersOnBye.count) players on bye. Plan coverage and trades.",
                    timestamp: Date(),
                    actionRequired: round == currentRound + 1
                ))
            } else if playersOnBye.count >= 3 {
                byeAlerts.append(AlertFlag(
                    type: .byeRoundWarning,
                    priority: .medium,
                    title: "📅 Bye Round \(round) Alert",
                    message: "\(playersOnBye.count) players on bye including key positions.",
                    timestamp: Date(),
                    actionRequired: false
                ))
            }
        }
        
        return byeAlerts
    }
    
    // MARK: - Trade Alert Monitoring
    
    func addPlayerToWatchList(playerName: String) {
        monitoredPlayers.insert(playerName)
        
        // Generate immediate alert for newly monitored player
        generateMonitoredPlayerAlert(playerName: playerName)
    }
    
    func removePlayerFromWatchList(playerName: String) {
        monitoredPlayers.remove(playerName)
    }
    
    private func generateMonitoredPlayerAlert(playerName: String) {
        let alert = AlertFlag(
            type: .tradeOpportunity,
            priority: .low,
            title: "👁️ Now Monitoring: \(playerName)",
            message: "Added to watchlist. You'll receive alerts for price changes, injury updates, and role changes.",
            timestamp: Date(),
            actionRequired: false
        )
        
        activeAlerts.append(alert)
    }
    
    func generateTradeAlertLockout(players: [Player]) {
        for playerName in monitoredPlayers {
            guard let player = players.first(where: { $0.name == playerName }) else { continue }
            
            // Check for significant changes since last alert
            if hasSignificantChange(player: player) {
                let alert = AlertFlag(
                    type: .tradeOpportunity,
                    priority: determineChangeSignificance(player: player),
                    title: "🎯 Watchlist Alert: \(player.name)",
                    message: generateTradeAlertMessage(player: player),
                    timestamp: Date(),
                    actionRequired: true
                )
                
                activeAlerts.append(alert)
            }
        }
    }
    
    private func hasSignificantChange(player: Player) -> Bool {
        // Check for price changes, injury updates, role changes
        let hasInjuryUpdate = player.isInjured || player.isDoubtful
        let hasPriceMovement = abs(player.priceChange) > 10000
        let hasFormChange = player.volatility > 25
        
        return hasInjuryUpdate || hasPriceMovement || hasFormChange
    }
    
    private func determineChangeSignificance(player: Player) -> AlertPriority {
        if player.isInjured { return .critical }
        if abs(player.priceChange) > 30000 { return .high }
        if player.isDoubtful { return .high }
        return .medium
    }
    
    private func generateTradeAlertMessage(player: Player) -> String {
        var messages: [String] = []
        
        if player.isInjured {
            messages.append("Injured")
        } else if player.isDoubtful {
            messages.append("Doubtful")
        }
        
        if abs(player.priceChange) > 10000 {
            messages.append("Price \(player.priceChangeText)")
        }
        
        if player.volatility > 25 {
            messages.append("High volatility")
        }
        
        return messages.isEmpty ? "Status update" : messages.joined(separator: " | ")
    }
    
    // MARK: - Centralized Alert Management
    
    func dismissAlert(alert: AlertFlag) {
        activeAlerts.removeAll { $0.id == alert.id }
        alertHistory.append(alert)
    }
    
    func dismissAllAlerts() {
        alertHistory.append(contentsOf: activeAlerts)
        activeAlerts.removeAll()
    }
    
    func markAlertAsActioned(alert: AlertFlag) {
        var actionedAlert = alert
        // In a full implementation, we'd modify the alert to mark it as actioned
        dismissAlert(alert: actionedAlert)
    }
    
    private func filterDuplicateAlerts(newAlerts: [AlertFlag]) -> [AlertFlag] {
        return newAlerts.filter { newAlert in
            !activeAlerts.contains { existingAlert in
                existingAlert.type == newAlert.type &&
                existingAlert.title == newAlert.title &&
                Calendar.current.isDate(existingAlert.timestamp, inSameDayAs: newAlert.timestamp)
            }
        }
    }
    
    private func cleanupOldAlerts() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        // Remove old active alerts (move to history)
        let oldActiveAlerts = activeAlerts.filter { $0.timestamp < cutoffDate }
        alertHistory.append(contentsOf: oldActiveAlerts)
        activeAlerts.removeAll { $0.timestamp < cutoffDate }
        
        // Remove very old history alerts
        let historyCutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        alertHistory.removeAll { $0.timestamp < historyCutoff }
    }
    
    // MARK: - Alert Preferences & Settings
    
    func updateAlertPreferences(_ preferences: AlertPreferences) {
        alertPreferences = preferences
    }
    
    func shouldShowAlert(_ alert: AlertFlag) -> Bool {
        switch alert.type {
        case .priceRise, .priceDrop:
            return alertPreferences.priceChangeAlerts
        case .injuryRisk:
            return alertPreferences.injuryAlerts
        case .breakEvenCliff:
            return alertPreferences.breakevenAlerts
        case .cashCowSell:
            return alertPreferences.cashCowAlerts
        case .tradeOpportunity:
            return alertPreferences.tradeOpportunityAlerts
        case .captainRecommendation:
            return alertPreferences.captainAlerts
        case .byeRoundWarning:
            return alertPreferences.byeRoundAlerts
        case .roleChange:
            return alertPreferences.roleChangeAlerts
        case .weatherRisk:
            return alertPreferences.weatherAlerts
        }
    }
    
    // MARK: - Push Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \\(error.localizedDescription)")
            }
        }
    }
    
    private func sendPushNotifications(for alerts: [AlertFlag]) {
        let criticalAlerts = alerts.filter { $0.priority == .critical && shouldShowAlert($0) }
        
        for alert in criticalAlerts {
            sendPushNotification(for: alert)
        }
    }
    
    private func sendPushNotification(for alert: AlertFlag) {
        let content = UNMutableNotificationContent()
        content.title = alert.title
        content.body = alert.message
        content.sound = .default
        content.badge = NSNumber(value: activeAlerts.count)
        
        // Schedule notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: alert.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Periodic Alert Generation
    
    private func setupPeriodicAlertGeneration() {
        alertGenerationTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            // In a real app, this would trigger data refresh and alert generation
            Task { @MainActor in
                self?.checkForPeriodicAlerts()
            }
        }
    }
    
    private func checkForPeriodicAlerts() {
        // This would typically fetch latest data and generate new alerts
        // For now, we'll just clean up old alerts
        cleanupOldAlerts()
    }
    
    deinit {
        alertGenerationTimer?.invalidate()
    }
}

// MARK: - Alert Preferences

struct AlertPreferences: Codable {
    var priceChangeAlerts: Bool = true
    var injuryAlerts: Bool = true
    var breakevenAlerts: Bool = true
    var cashCowAlerts: Bool = true
    var tradeOpportunityAlerts: Bool = true
    var captainAlerts: Bool = true
    var byeRoundAlerts: Bool = true
    var roleChangeAlerts: Bool = false // Default off as can be noisy
    var weatherAlerts: Bool = false // Default off as informational
    
    var minimumPriceChangeThreshold: Int = 10000 // $10k
    var notificationDelay: TimeInterval = 300 // 5 minutes
    var maxAlertsPerDay: Int = 20
}

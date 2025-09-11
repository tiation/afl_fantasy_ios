import Foundation

// MARK: - Alert Type Aliases
// 
// This file provides backward compatibility by creating type aliases 
// for the shared alert models located in Sources/Shared/Models/Models.swift

// Use the shared AlertNotification model
typealias Alert = AlertNotification

// Re-export the shared alert types for backward compatibility
// These are already defined in Sources/Shared/Models/Models.swift:
// - AlertType (enum)
// - AlertPriority (enum)
// - AlertNotification (struct)
// - AlertUpdate (struct)

//
//  TabItem.swift
//  AFL Fantasy Intelligence Platform
//
//  Tab navigation enumeration
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation

enum TabItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case captain = "Captain"
    case trades = "Trades"
    case cashCow = "Cash Cow"
    case settings = "Settings"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard:
            "house.fill"
        case .captain:
            "star.circle.fill"
        case .trades:
            "arrow.triangle.2.circlepath"
        case .cashCow:
            "dollarsign.circle.fill"
        case .settings:
            "gear"
        }
    }
}

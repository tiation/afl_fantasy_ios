//
//  DemoApp.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - DemoApp

/// Main demo app showing AFL Fantasy API integration
struct DemoApp: View {
    // MARK: - Body

    var body: some View {
        TabView {
            DashboardDemoView()
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("Dashboard")
                }

            PlayersListDemoView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Players")
                }
        }
    }
}

// MARK: - DemoApp_Previews

struct DemoApp_Previews: PreviewProvider {
    static var previews: some View {
        DemoApp()
    }
}

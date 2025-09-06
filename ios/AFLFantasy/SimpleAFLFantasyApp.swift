//
//  SimpleAFLFantasyApp.swift
//  AFL Fantasy Intelligence Platform
//
//  Simple working version with enhanced data
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI
import UserNotifications

// MARK: - SimpleAFLFantasyApp

@main
struct SimpleAFLFantasyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var dataService = AFLFantasyDataService()
    @StateObject private var toolsClient = AFLFantasyToolsClient()

    var body: some Scene {
        WindowGroup {
            SimpleContentView()
                .environmentObject(appState)
                .environmentObject(dataService)
                .environmentObject(toolsClient)
                .preferredColorScheme(.dark)
        }
    }
}


// MARK: - SimpleContentView

struct SimpleContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: AFLFantasyDataService
    @EnvironmentObject var toolsClient: AFLFantasyToolsClient
    
    var body: some View {
        NavigationView {
            VStack {
                Text("AFL Fantasy Intelligence")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Dashboard Loading...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Dashboard")
        }
        .onAppear {
            Task {
                await dataService.refreshDashboard()
            }
        }
    }
}

#!/usr/bin/env swift

import SwiftUI

// MARK: - AFLFantasyDemoApp

// Simple demo app
@main
struct AFLFantasyDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var isShowingSessionDemo = false
    @State private var sessionText = ""
    @State private var detectedFormats: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "football")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)

                    Text("AFL Fantasy")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Intelligence Platform")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                // Session Paste Demo
                VStack(spacing: 15) {
                    Text("Session Paste Demo")
                        .font(.headline)

                    Button("Show Demo") {
                        isShowingSessionDemo.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()

                    if isShowingSessionDemo {
                        SessionPasteDemoView()
                    }
                }

                Spacer()

                // Status
                Text("✅ App running in simulator")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - SessionPasteDemoView

struct SessionPasteDemoView: View {
    @State private var sessionText = ""
    @State private var detectedFormat = ""
    @State private var isDetected = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Session Detection Demo")
                .font(.title3)
                .fontWeight(.semibold)

            // Input field
            TextField("Paste session ID here...", text: $sessionText)
                .textFieldStyle(.roundedBorder)
                .onChange(of: sessionText) { _ in
                    detectSession()
                }

            // Detection result
            if isDetected {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Session Detected!")
                            .fontWeight(.medium)
                    }

                    Text("Format: \(detectedFormat)")
                        .font(.caption)
                        .padding(8)
                        .background(.green.opacity(0.1))
                        .cornerRadius(6)

                    Button("Apply Session") {
                        // Demo action
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            } else if !sessionText.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Invalid session format")
                }
                .foregroundColor(.orange)
            }

            // Sample buttons
            VStack(spacing: 8) {
                Text("Try these samples:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button("Raw Session ID") {
                    sessionText = "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
                }
                .buttonStyle(.bordered)

                Button("Cookie Header") {
                    sessionText = "sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1; csrftoken=abc123"
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }

    private func detectSession() {
        if sessionText.isEmpty {
            isDetected = false
            return
        }

        // Simple detection logic
        if sessionText.contains("sessionid=") {
            detectedFormat = "Cookie Header"
            isDetected = true
        } else if sessionText.count == 32, sessionText.allSatisfy(\.isHexDigit) {
            detectedFormat = "Raw Session ID"
            isDetected = true
        } else if sessionText.contains("\"sessionid\"") {
            detectedFormat = "JSON Format"
            isDetected = true
        } else {
            isDetected = false
        }
    }
}

extension Character {
    var isHexDigit: Bool {
        isNumber || ("a" ... "f").contains(lowercased())
    }
}

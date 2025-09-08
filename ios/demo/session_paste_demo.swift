//
//  session_paste_demo.swift
//  AFL Fantasy Intelligence Platform
//
//  Live demo script for testing session paste UX
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - DemoCoordinator

class DemoCoordinator: ObservableObject {
    @Published var isShowingDemo = true
    @Published var currentStep = 0
    @Published var clipboardContent: String?
    @Published var isShowingAlert = false

    let demoSteps = [
        DemoStep(
            id: 0,
            title: "Empty State",
            clipboard: nil,
            description: "Initial view when opened"
        ),
        DemoStep(
            id: 1,
            title: "Raw Session",
            clipboard: "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1",
            description: "Raw session ID copied"
        ),
        DemoStep(
            id: 2,
            title: "Browser Format",
            clipboard: """
            Cookie: csrftoken=abc123; sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1; other=value
            """,
            description: "Browser cookie format"
        ),
        DemoStep(
            id: 3,
            title: "JSON Format",
            clipboard: """
            {
                "name": "sessionid",
                "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1",
                "domain": ".fantasy.afl.com.au"
            }
            """,
            description: "JSON from dev tools"
        ),
        DemoStep(
            id: 4,
            title: "cURL Command",
            clipboard: """
            curl 'https://fantasy.afl.com.au/api/v1/me' \
              -H 'Cookie: sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1'
            """,
            description: "cURL command format"
        ),
        DemoStep(
            id: 5,
            title: "Multiple Formats",
            clipboard: """
            Session ID: 3f28da7c9a32b7e1b3d5f7a8c6e9d2b1

            Also in header format:
            Cookie: sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1

            And as JSON:
            {
                "name": "sessionid",
                "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
            }
            """,
            description: "Multiple formats detected"
        ),
        DemoStep(
            id: 6,
            title: "Invalid Format",
            clipboard: "not_a_valid_session_id",
            description: "Invalid session format"
        ),
        DemoStep(
            id: 7,
            title: "Success State",
            clipboard: "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1",
            description: "Successfully applied session"
        )
    ]

    func nextStep() {
        if currentStep < demoSteps.count - 1 {
            currentStep += 1
            updateClipboard()
        }
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
            updateClipboard()
        }
    }

    private func updateClipboard() {
        let step = demoSteps[currentStep]
        clipboardContent = step.clipboard
        UIPasteboard.general.string = step.clipboard
    }
}

// MARK: - DemoStep

struct DemoStep: Identifiable {
    let id: Int
    let title: String
    let clipboard: String?
    let description: String
}

// MARK: - SessionPasteDemo

struct SessionPasteDemo: View {
    @StateObject private var coordinator = DemoCoordinator()
    @StateObject private var dataService = AFLFantasyDataService()

    var body: some View {
        ZStack {
            NavigationView {
                SessionPasteView()
                    .environmentObject(dataService)
            }

            // Demo Controls Overlay
            VStack {
                Spacer()

                HStack {
                    Button {
                        coordinator.previousStep()
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title)
                    }
                    .disabled(coordinator.currentStep == 0)

                    Spacer()

                    VStack(spacing: 8) {
                        Text(coordinator.demoSteps[coordinator.currentStep].title)
                            .font(.headline)
                        Text(coordinator.demoSteps[coordinator.currentStep].description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        coordinator.nextStep()
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title)
                    }
                    .disabled(coordinator.currentStep == coordinator.demoSteps.count - 1)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 8)
                )
                .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SessionPasteDemo()
}

// MARK: - MockAFLFantasyDataService

class MockAFLFantasyDataService: AFLFantasyDataService {
    override func authenticate(teamId: String, sessionCookie: String, apiToken: String?) async -> Result<Void, Error> {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Simulate success for valid session
        if sessionCookie.count >= 20 {
            return .success(())
        }

        // Simulate error for invalid session
        return .failure(NSError(domain: "com.afl.fantasy", code: 401))
    }
}

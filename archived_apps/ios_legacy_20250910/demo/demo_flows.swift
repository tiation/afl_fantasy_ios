//
//  demo_flows.swift
//  AFL Fantasy Intelligence Platform
//
//  Demo script showing key user flows for session paste UX
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import AVKit
import SwiftUI

// MARK: - DemoPresenter

class DemoPresenter: ObservableObject {
    @Published var currentFlow: DemoFlow = .autoDetect
    @Published var currentStep = 0
    @Published var isRecording = false
    @Published var playbackURL: URL?
    @Published var annotation: DemoAnnotation?

    struct DemoAnnotation: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let position: CGPoint
        let arrowDirection: ArrowDirection

        enum ArrowDirection {
            case up, down, left, right

            var rotation: Double {
                switch self {
                case .up: 0
                case .down: 180
                case .left: -90
                case .right: 90
                }
            }
        }
    }

    enum DemoFlow: String, CaseIterable {
        case autoDetect = "Automatic Detection"
        case multipleFormats = "Multiple Formats"
        case manualInput = "Manual Input"
        case errorHandling = "Error Handling"
        case successFlow = "Success Flow"
    }

    // Sample session cookies for demos
    let sampleCookies = [
        // Raw cookie
        "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1",

        // Browser cookie header
        """
        Cookie: csrftoken=abc123; sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1; other=value
        """,

        // JSON from dev tools
        """
        {
            "name": "sessionid",
            "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1",
            "domain": ".fantasy.afl.com.au",
            "path": "/",
            "expires": "2024-12-31T23:59:59.000Z",
            "httpOnly": true,
            "secure": true
        }
        """,

        // cURL command
        """
        curl 'https://fantasy.afl.com.au/api/v1/me' \
          -H 'Cookie: sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1'
        """,

        // Invalid format
        "not_a_valid_session"
    ]

    // MARK: - Demo Flows

    func runAutoDetectFlow() async {
        currentFlow = .autoDetect

        // 1. Start with empty clipboard
        UIPasteboard.general.string = nil
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 2. Simulate copying raw session
        UIPasteboard.general.string = sampleCookies[0]
        annotation = DemoAnnotation(
            title: "Raw Cookie",
            description: "Simple session ID format",
            position: CGPoint(x: 150, y: 200),
            arrowDirection: .down
        )
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // 3. Show successful detection
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    func runMultipleFormatsFlow() async {
        currentFlow = .multipleFormats

        // 1. Complex clipboard content
        UIPasteboard.general.string = """
        Session ID: 3f28da7c9a32b7e1b3d5f7a8c6e9d2b1

        Also in header format:
        Cookie: sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1

        And as JSON:
        {
            "name": "sessionid",
            "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        }
        """
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // 2. Show format selection
        annotation = DemoAnnotation(
            title: "Multiple Formats",
            description: "Found several valid formats",
            position: CGPoint(x: 200, y: 250),
            arrowDirection: .down
        )
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // 3. Choose best format
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    func runManualInputFlow() async {
        currentFlow = .manualInput

        // 1. Empty clipboard
        UIPasteboard.general.string = nil
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 2. Manual paste
        UIPasteboard.general.string = sampleCookies[0]
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // 3. Show success
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    func runErrorHandlingFlow() async {
        currentFlow = .errorHandling

        // 1. Invalid format
        UIPasteboard.general.string = sampleCookies[4]
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // 2. Show error
        annotation = DemoAnnotation(
            title: "Invalid Format",
            description: "Session ID not recognized",
            position: CGPoint(x: 180, y: 220),
            arrowDirection: .up
        )
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 3. Show help
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }

    func runSuccessFlow() async {
        currentFlow = .successFlow

        // 1. Valid session
        UIPasteboard.general.string = sampleCookies[0]
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 2. Apply session
        annotation = DemoAnnotation(
            title: "Success!",
            description: "Session applied successfully",
            position: CGPoint(x: 220, y: 280),
            arrowDirection: .up
        )
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 3. Show success animations
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }

    func runFullDemo() async {
        isRecording = true

        // Run all flows
        await runAutoDetectFlow()
        await runMultipleFormatsFlow()
        await runManualInputFlow()
        await runErrorHandlingFlow()
        await runSuccessFlow()

        isRecording = false
    }
}

// MARK: - DemoFlowsView

struct DemoFlowsView: View {
    @StateObject private var presenter = DemoPresenter()

    var body: some View {
        VStack {
            // Main session paste view
            SessionPasteDemo()
                .overlay(demoOverlay)

            // Demo controls
            demoControls
        }
    }

    private var demoOverlay: some View {
        ZStack {
            if let annotation = presenter.annotation {
                annotationOverlay(annotation)
            }
            VStack {
                if presenter.isRecording {
                    recordingIndicator
                }

                Spacer()

                Text(presenter.currentFlow.rawValue)
                    .font(.headline)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(8)
            }
            .padding()
        }

        private func annotationOverlay(_ annotation: DemoPresenter.DemoAnnotation) -> some View {
            VStack(spacing: 8) {
                Text(annotation.title)
                    .font(.headline)
                Text(annotation.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Image(systemName: "arrow.down")
                    .rotationEffect(.degrees(annotation.arrowDirection.rotation))
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)
            .shadow(radius: 4)
            .position(annotation.position)
            .transition(.scale.combined(with: .opacity))
        }

        private var recordingIndicator: some View {
            HStack {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                Text("Recording")
                    .font(.caption)
            }
            .padding(8)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
        }

        private var demoControls: some View {
            VStack(spacing: 16) {
                Button {
                    Task {
                        await presenter.runFullDemo()
                    }
                } label: {
                    Label("Run Full Demo", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(DemoPresenter.DemoFlow.allCases, id: \.self) { flow in
                            Button {
                                Task {
                                    switch flow {
                                    case .autoDetect:
                                        await presenter.runAutoDetectFlow()
                                    case .multipleFormats:
                                        await presenter.runMultipleFormatsFlow()
                                    case .manualInput:
                                        await presenter.runManualInputFlow()
                                    case .errorHandling:
                                        await presenter.runErrorHandlingFlow()
                                    case .successFlow:
                                        await presenter.runSuccessFlow()
                                    }
                                }
                            } label: {
                                Text(flow.rawValue)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
    }
}

// MARK: - DemoFlowsView_Previews

struct DemoFlowsView_Previews: PreviewProvider {
    static var previews: some View {
        DemoFlowsView()
    }
}

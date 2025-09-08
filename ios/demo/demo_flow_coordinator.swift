//
//  demo_flow_coordinator.swift
//  AFL Fantasy Intelligence Platform
//
//  Coordinates timed state transitions for demo recording
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - DemoFlowState

enum DemoFlowState: Equatable {
    case initial
    case checkingClipboard
    case clipboardEmpty
    case clipboardFound(CookieExtractionResult)
    case multipleFormatsFound([CookieExtractionResult])
    case invalidFormat
    case success
    case error(String)

    var title: String {
        switch self {
        case .initial: "Welcome"
        case .checkingClipboard: "Checking Clipboard"
        case .clipboardEmpty: "No Session Found"
        case .clipboardFound: "Session Detected"
        case .multipleFormatsFound: "Multiple Formats"
        case .invalidFormat: "Invalid Format"
        case .success: "Success"
        case .error: "Error"
        }
    }

    var description: String {
        switch self {
        case .initial:
            "Welcome to AFL Fantasy"
        case .checkingClipboard:
            "Looking for session ID..."
        case .clipboardEmpty:
            "No session ID found in clipboard"
        case .clipboardFound:
            "Found session ID in clipboard"
        case let .multipleFormatsFound(results):
            "Found \(results.count) possible formats"
        case .invalidFormat:
            "Invalid session ID format"
        case .success:
            "Successfully connected"
        case let .error(message):
            message
        }
    }
}

// MARK: - DemoFlowCoordinator

class DemoFlowCoordinator: ObservableObject {
    @Published private(set) var state: DemoFlowState = .initial
    @Published private(set) var clipboardContent: String?
    @Published private(set) var isRecording = false

    private var timer: Timer?
    private let recorder: DemoRecorder
    private var cancellables = Set<AnyCancellable>()

    private let sampleFormats = [
        (
            "Raw Cookie",
            "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        ),
        (
            "Name=Value",
            "sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        ),
        (
            "Cookie Header",
            "Cookie: sessionid=3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
        ),
        (
            "JSON",
            """
            {
                "name": "sessionid",
                "value": "3f28da7c9a32b7e1b3d5f7a8c6e9d2b1"
            }
            """
        ),
        (
            "Invalid",
            "not_a_session"
        )
    ]

    init(recorder: DemoRecorder = DemoRecorder()) {
        self.recorder = recorder

        // Watch recorder state
        recorder.$isRecording
            .assign(to: \.isRecording, on: self)
            .store(in: &cancellables)
    }

    func startDemo() {
        guard !isRecording else { return }

        // Start recording
        recorder.startRecording { [weak self] success in
            guard success else { return }
            self?.runDemoSequence()
        }
    }

    func stopDemo() {
        timer?.invalidate()
        timer = nil

        Task {
            if let url = await recorder.stopRecording() {
                print("Demo recording saved to: \(url)")
            }
        }
    }

    private func runDemoSequence() {
        var index = 0
        let stepDuration: TimeInterval = 2.5

        timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            // Run through sample formats
            if index < sampleFormats.count {
                let (title, content) = sampleFormats[index]
                simulateClipboardContent(title: title, content: content)
                index += 1
            } else {
                stopDemo()
            }
        }
    }

    private func simulateClipboardContent(title: String, content: String) {
        // Update clipboard
        UIPasteboard.general.string = content
        clipboardContent = content

        // Transition through states
        withAnimation {
            state = .checkingClipboard
        }

        // Simulate processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                if let result = ClipboardHelperEnhanced.extractSessionCookieFromClipboard() {
                    self.state = .clipboardFound(result)
                } else {
                    self.state = .invalidFormat
                }
            }
        }
    }
}

// MARK: - FlowDemoView

struct FlowDemoView: View {
    @StateObject private var coordinator = DemoFlowCoordinator()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Main session paste view
            SessionPasteDemo()

            // Demo overlay
            VStack {
                Spacer()

                demoStateIndicator
                    .padding()
            }

            // Recording indicator
            if coordinator.isRecording {
                recordingIndicator
            }
        }
        .onAppear {
            coordinator.startDemo()
        }
    }

    private var demoStateIndicator: some View {
        VStack(spacing: 8) {
            Text(coordinator.state.title)
                .font(.headline)
            Text(coordinator.state.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(radius: 8)
        )
    }

    private var recordingIndicator: some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .padding(4)

                Text("Recording")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(radius: 4)
            )

            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    FlowDemoView()
}

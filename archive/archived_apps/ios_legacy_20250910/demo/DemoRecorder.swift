//
//  DemoRecorder.swift
//  AFL Fantasy Intelligence Platform
//
//  Screen capture utility for demo recordings
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import ReplayKit

// MARK: - DemoRecorder

class DemoRecorder: ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var recordedURL: URL?

    private let recorder = RPScreenRecorder.shared()

    func startRecording() {
        guard !isRecording else { return }

        recorder.startRecording { [weak self] error in
            if let error {
                print("Failed to start recording: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self?.isRecording = true
            }
        }
    }

    func stopRecording() async -> URL? {
        guard isRecording else { return nil }

        do {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")

            try await recorder.stopRecording(withOutput: tempURL)

            await MainActor.run {
                isRecording = false
                recordedURL = tempURL
            }

            return tempURL

        } catch {
            print("Failed to stop recording: \(error.localizedDescription)")
            return nil
        }
    }

    func discardRecording() {
        guard let url = recordedURL else { return }

        try? FileManager.default.removeItem(at: url)
        recordedURL = nil
    }

    // Utility: record a specific flow
    static func recordFlow(_ flow: @escaping () async -> Void) async -> URL? {
        let recorder = DemoRecorder()
        recorder.startRecording()

        await flow()

        return await recorder.stopRecording()
    }
}

// MARK: - DemoRecordingControl

struct DemoRecordingControl: View {
    @StateObject private var recorder = DemoRecorder()
    @State private var isShowingPreview = false

    var body: some View {
        HStack {
            if recorder.isRecording {
                Button {
                    Task {
                        if let url = await recorder.stopRecording() {
                            isShowingPreview = true
                        }
                    }
                } label: {
                    Label("Stop Recording", systemImage: "stop.circle.fill")
                        .foregroundColor(.red)
                }
            } else {
                Button {
                    recorder.startRecording()
                } label: {
                    Label("Record Demo", systemImage: "record.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingPreview) {
            if let url = recorder.recordedURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .onDisappear {
                        recorder.discardRecording()
                    }
            }
        }
    }
}

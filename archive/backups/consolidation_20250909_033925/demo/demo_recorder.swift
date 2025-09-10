//
//  demo_recorder.swift
//  AFL Fantasy Intelligence Platform
//
//  Helper for recording demo videos of the UX flow
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import AVKit
import ReplayKit
import SwiftUI

// MARK: - DemoRecorder

class DemoRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var recordedURL: URL?

    // Time intervals for demo
    static let stepDuration: TimeInterval = 2.5
    static let animationDuration: TimeInterval = 0.5
    static let totalDuration: TimeInterval = 20.0

    private let recorder = RPScreenRecorder.shared()
    private var startTime: Date?
    private var writer: AVAssetWriter?
    private var input: AVAssetWriterInput?
    private var buffer: AVAssetWriterInputPixelBufferAdaptor?

    // MARK: - Public Interface

    func startRecording(completion: @escaping (Bool) -> Void) {
        guard !isRecording else { return }

        recorder.startCapture { buffer, _, error in
            if let error {
                print("Recording error: \(error.localizedDescription)")
                completion(false)
                return
            }

            // Process frame
            self.processFrame(buffer)

        } completionHandler: { error in
            if let error {
                print("Setup error: \(error.localizedDescription)")
                completion(false)
                return
            }

            self.isRecording = true
            self.startTime = Date()
            completion(true)
        }
    }

    func stopRecording() async -> URL? {
        guard isRecording else { return nil }

        return await withCheckedContinuation { continuation in
            recorder.stopCapture { error in
                if let error {
                    print("Stop recording error: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }

                self.isRecording = false
                self.finishRecording()
                continuation.resume(returning: self.recordedURL)
            }
        }
    }

    // MARK: - Private Methods

    private func processFrame(_ buffer: CMSampleBuffer) {
        guard isRecording,
              let startTime,
              let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }

        let timestamp = Date().timeIntervalSince(startTime)

        // Add timestamp overlay
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        let timestampText = String(format: "%.1fs", timestamp)
        let textImage = createTextImage(text: timestampText)

        // Composite images
        let composite = image.composited(over: textImage)

        // Write frame
        context.render(composite, to: pixelBuffer)
        self.buffer?.append(pixelBuffer, withPresentationTime: CMTime(seconds: timestamp, preferredTimescale: 60))
    }

    private func createTextImage(text: String) -> CIImage {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .medium)
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()

        UIGraphicsBeginImageContextWithOptions(textSize, false, 0)
        attributedString.draw(at: .zero)
        let textImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return CIImage(image: textImage!)!
    }

    private func finishRecording() {
        writer?.finishWriting {
            DispatchQueue.main.async {
                self.recordedURL = self.writer?.outputURL
                self.writer = nil
                self.input = nil
                self.buffer = nil
            }
        }
    }
}

// MARK: - DemoPlayerView

struct DemoPlayerView: View {
    let url: URL
    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player = AVPlayer(url: url)
                player?.play()
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
}

// MARK: - DemoRecordingView

struct DemoRecordingView: View {
    @StateObject private var recorder = DemoRecorder()
    @State private var showPlayer = false

    var body: some View {
        VStack {
            SessionPasteDemo()
                .overlay(recordingOverlay)

            if let url = recorder.recordedURL {
                Button("Play Recording") {
                    showPlayer = true
                }
                .sheet(isPresented: $showPlayer) {
                    DemoPlayerView(url: url)
                }
            }
        }
    }

    private var recordingOverlay: some View {
        Group {
            if recorder.isRecording {
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                    )
                    .padding()
                    .opacity(0.8)
            }
        }
    }

    func startRecording() {
        recorder.startRecording { success in
            if success {
                print("Recording started")
            } else {
                print("Failed to start recording")
            }
        }
    }

    func stopRecording() {
        Task {
            if let url = await recorder.stopRecording() {
                print("Recording saved to: \(url)")
            } else {
                print("Failed to save recording")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DemoRecordingView()
}

//
//  QRScannerView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 10/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import AVFoundation
import SwiftUI
import AudioToolbox

// MARK: - QRScannerView

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let onQRCodeDetected: (String) -> Void

    @State private var showingCameraPermissionAlert = false
    @State private var cameraPermissionDenied = false

    var body: some View {
        NavigationView {
            ZStack {
                if cameraPermissionDenied {
                    CameraPermissionDeniedView()
                } else {
                    QRScannerCameraView(onQRCodeDetected: { qrCode in
                        onQRCodeDetected(qrCode)
                        dismiss()
                    })
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            checkCameraPermission()
        }
        .alert("Camera Permission Required", isPresented: $showingCameraPermissionAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {
                cameraPermissionDenied = true
            }
        } message: {
            Text("Please allow camera access in Settings to scan QR codes for your AFL Fantasy team URL.")
        }
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Camera access granted
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        cameraPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            showingCameraPermissionAlert = true
        @unknown default:
            cameraPermissionDenied = true
        }
    }
}

// MARK: - QRScannerCameraView

struct QRScannerCameraView: UIViewRepresentable {
    let onQRCodeDetected: (String) -> Void

    func makeUIView(context: Context) -> QRScannerUIView {
        let view = QRScannerUIView()
        view.onQRCodeDetected = onQRCodeDetected
        return view
    }

    func updateUIView(_ uiView: QRScannerUIView, context: Context) {
        // No updates needed
    }
}

// MARK: - QRScannerUIView

class QRScannerUIView: UIView {
    var onQRCodeDetected: ((String) -> Void)?

    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?

    override func layoutSubviews() {
        super.layoutSubviews()
        setupCamera()
    }

    private func setupCamera() {
        guard captureSession == nil else { return }

        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get video capture device")
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input: \(error)")
            return
        }

        if captureSession!.canAddInput(videoInput) {
            captureSession!.addInput(videoInput)
        } else {
            print("Could not add video input to session")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession!.canAddOutput(metadataOutput) {
            captureSession!.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add metadata output to session")
            return
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer!.videoGravity = .resizeAspectFill
        videoPreviewLayer!.frame = bounds
        layer.addSublayer(videoPreviewLayer!)

        // Add QR code frame view
        qrCodeFrameView = UIView()
        qrCodeFrameView!.layer.borderColor = UIColor.systemGreen.cgColor
        qrCodeFrameView!.layer.borderWidth = 2
        qrCodeFrameView!.layer.cornerRadius = 8
        qrCodeFrameView!.backgroundColor = UIColor.clear
        addSubview(qrCodeFrameView!)

        // Add scanning overlay
        addScanningOverlay()

        DispatchQueue.global(qos: .background).async {
            self.captureSession!.startRunning()
        }
    }

    private func addScanningOverlay() {
        let overlayView = UIView(frame: bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Create a square cutout in the center
        let cutoutSize: CGFloat = min(bounds.width, bounds.height) * 0.7
        let cutoutRect = CGRect(
            x: (bounds.width - cutoutSize) / 2,
            y: (bounds.height - cutoutSize) / 2,
            width: cutoutSize,
            height: cutoutSize
        )

        let path = UIBezierPath(rect: bounds)
        let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: 16)
        path.append(cutoutPath.reversing())

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer

        addSubview(overlayView)

        // Add instruction label
        let instructionLabel = UILabel()
        instructionLabel.text = "Point your camera at a QR code\ncontaining your AFL Fantasy team URL"
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.clipsToBounds = true

        addSubview(instructionLabel)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            instructionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            instructionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            instructionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    deinit {
        captureSession?.stopRunning()
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate

extension QRScannerUIView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        // Clear any existing frame
        qrCodeFrameView?.frame = CGRect.zero

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            // Update frame to show detected QR code
            if let videoPreviewLayer {
                let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: readableObject)
                qrCodeFrameView?.frame = barCodeObject?.bounds ?? CGRect.zero
            }

            // Process the QR code
            processQRCode(stringValue)
        }
    }

    private func processQRCode(_ qrCode: String) {
        // Give haptic feedback
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        // Extract team ID from AFL Fantasy URL if present
        if let teamId = extractTeamIdFromURL(qrCode) {
            onQRCodeDetected?(teamId)
        } else if qrCode.allSatisfy(\.isNumber) {
            // If it's just numbers, assume it's a team ID
            onQRCodeDetected?(qrCode)
        } else {
            // Return the raw QR code content
            onQRCodeDetected?(qrCode)
        }
    }

    private func extractTeamIdFromURL(_ urlString: String) -> String? {
        // Match patterns like:
        // - fantasy.afl.com.au/team/123456
        // - https://fantasy.afl.com.au/team/123456
        // - www.fantasy.afl.com.au/team/123456

        let patterns = [
            #"fantasy\.afl\.com\.au/team/(\d+)"#,
            #"/team/(\d+)"#
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: urlString.utf16.count)
                if let match = regex.firstMatch(in: urlString, options: [], range: range) {
                    if match.numberOfRanges > 1 {
                        let teamIdRange = match.range(at: 1)
                        if let swiftRange = Range(teamIdRange, in: urlString) {
                            return String(urlString[swiftRange])
                        }
                    }
                }
            }
        }

        return nil
    }
}

// MARK: - CameraPermissionDeniedView

struct CameraPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.bold)

            Text("To scan QR codes, please enable camera access in Settings.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    QRScannerView { qrCode in
        print("Detected QR Code: \(qrCode)")
    }
}

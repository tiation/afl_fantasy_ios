import SwiftUI
import AVFoundation

@available(iOS 16.0, *)
struct QRScannerView_iOS16: View {
    let onQRCodeScanned: (String) -> Void
    
    @State private var isAuthorized = false
    @State private var showingPermissionDenied = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if isAuthorized {
                    QRCodeScannerViewController(onQRCodeScanned: handleQRCodeScanned)
                        .ignoresSafeArea()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Camera Access Required")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Please grant camera access to scan QR codes from AFL Fantasy.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Open Settings") {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Camera Permission Denied", isPresented: $showingPermissionDenied) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            } message: {
                Text("Please allow camera access in Settings to scan QR codes.")
            }
        }
        .onAppear {
            checkCameraPermission()
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        isAuthorized = true
                    } else {
                        showingPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            showingPermissionDenied = true
        @unknown default:
            showingPermissionDenied = true
        }
    }
    
    private func handleQRCodeScanned(_ content: String) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        onQRCodeScanned(content)
        dismiss()
    }
}

@available(iOS 16.0, *)
struct QRCodeScannerViewController: UIViewControllerRepresentable {
    let onQRCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRCodeScannerUIViewController {
        QRCodeScannerUIViewController(onQRCodeScanned: onQRCodeScanned)
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerUIViewController, context: Context) {
        // No updates needed
    }
}

@available(iOS 16.0, *)
class QRCodeScannerUIViewController: UIViewController {
    private let onQRCodeScanned: (String) -> Void
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var isScanning = true
    
    init(onQRCodeScanned: @escaping (String) -> Void) {
        self.onQRCodeScanned = onQRCodeScanned
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRunning()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showAlert(title: "Camera Error", message: "Unable to access camera")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showAlert(title: "Camera Error", message: "Unable to create video input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showAlert(title: "Camera Error", message: "Unable to add video input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showAlert(title: "Camera Error", message: "Unable to add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black
        
        // Add overlay with scanning frame
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(overlayView)
        
        let scanningFrame = CGRect(
            x: view.bounds.midX - 125,
            y: view.bounds.midY - 125,
            width: 250,
            height: 250
        )
        
        let path = UIBezierPath(rect: overlayView.bounds)
        let scanningPath = UIBezierPath(rect: scanningFrame)
        path.append(scanningPath.reversed)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        // Add scanning frame border
        let frameView = UIView(frame: scanningFrame)
        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.borderWidth = 2
        frameView.layer.cornerRadius = 8
        frameView.backgroundColor = UIColor.clear
        view.addSubview(frameView)
        
        // Add instruction label
        let instructionLabel = UILabel()
        instructionLabel.text = "Position the QR code within the frame"
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 30)
        ])
    }
    
    private func startRunning() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
        isScanning = true
    }
    
    private func stopRunning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        isScanning = false
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

@available(iOS 16.0, *)
extension QRCodeScannerUIViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard isScanning else { return }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Stop scanning to prevent multiple triggers
            isScanning = false
            
            // Call the completion handler
            onQRCodeScanned(stringValue)
        }
    }
}

// Backwards compatibility for iOS 15
struct QRScannerView_iOS15: View {
    let onQRCodeScanned: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                
                Text("QR Scanner")
                    .font(.title)
                    .fontWeight(.medium)
                
                Text("QR code scanning requires iOS 16 or later. Please update your device or manually enter the team URL.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Enter URL Manually") {
                    // For now, just dismiss - could add manual URL entry
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("QR Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Main QRScannerView that handles iOS version compatibility
struct QRScannerView: View {
    let onQRCodeScanned: (String) -> Void
    
    var body: some View {
        if #available(iOS 16.0, *) {
            QRScannerView_iOS16(onQRCodeScanned: onQRCodeScanned)
        } else {
            QRScannerView_iOS15(onQRCodeScanned: onQRCodeScanned)
        }
    }
}

#Preview {
    QRScannerView { content in
        print("Scanned: \(content)")
    }
}

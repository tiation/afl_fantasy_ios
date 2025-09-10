import AVFoundation
import SwiftUI
import Vision

// MARK: - BarcodeScannerDelegate

protocol BarcodeScannerDelegate: AnyObject {
    func barcodeScanner(_ scanner: BarcodeScanner, didScanCode code: String, type: BarcodeType)
    func barcodeScanner(_ scanner: BarcodeScanner, didFailWithError error: BarcodeScannerError)
}

// MARK: - BarcodeScanner

@MainActor
final class BarcodeScanner: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var isScanning = false
    @Published var hasPermission = false
    @Published var error: BarcodeScannerError?
    
    // MARK: - Properties
    
    weak var delegate: BarcodeScannerDelegate?
    
    private let session = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "barcode.scanner.session")
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    // MARK: - Public Methods
    
    func startScanning() {
        guard hasPermission else {
            error = .cameraPermissionDenied
            return
        }
        
        sessionQueue.async { [weak self] in
            self?.setupCaptureSession()
            self?.session.startRunning()
            
            DispatchQueue.main.async {
                self?.isScanning = true
            }
        }
    }
    
    func stopScanning() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            
            DispatchQueue.main.async {
                self?.isScanning = false
            }
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return videoPreviewLayer
    }
    
    // MARK: - Private Methods
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            hasPermission = false
            error = .cameraPermissionDenied
        @unknown default:
            hasPermission = false
            error = .cameraPermissionDenied
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                if !granted {
                    self?.error = .cameraPermissionDenied
                }
            }
        }
    }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            DispatchQueue.main.async {
                self.error = .cameraNotAvailable
            }
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                DispatchQueue.main.async {
                    self.error = .sessionConfigurationFailed
                }
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [
                    .qr,
                    .ean8,
                    .ean13,
                    .pdf417,
                    .code128,
                    .code39,
                    .code93,
                    .upce,
                    .aztec,
                    .dataMatrix
                ]
            } else {
                DispatchQueue.main.async {
                    self.error = .sessionConfigurationFailed
                }
                return
            }
            
            // Setup preview layer
            DispatchQueue.main.async {
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                self.videoPreviewLayer?.videoGravity = .resizeAspectFill
            }
            
        } catch {
            DispatchQueue.main.async {
                self.error = .sessionConfigurationFailed
            }
        }
    }
    
    private func processScannedCode(_ code: String, type: AVMetadataObject.ObjectType) {
        // Stop scanning temporarily to avoid multiple scans
        session.stopRunning()
        
        let barcodeType = BarcodeType.from(metadataType: type)
        
        // Process the code (validate format, extract team info, etc.)
        if isValidTeamCode(code) {
            delegate?.barcodeScanner(self, didScanCode: code, type: barcodeType)
        } else {
            error = .invalidTeamCode
            // Resume scanning after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.session.startRunning()
            }
        }
    }
    
    private func isValidTeamCode(_ code: String) -> Bool {
        // AFL Fantasy team codes are typically 6-8 alphanumeric characters
        let teamCodePattern = #"^[A-Za-z0-9]{6,8}$"#
        
        // QR codes might contain JSON with team information
        if code.hasPrefix("{") && code.hasSuffix("}") {
            return isValidTeamQRCode(code)
        }
        
        // Simple barcode validation
        return code.range(of: teamCodePattern, options: .regularExpression) != nil
    }
    
    private func isValidTeamQRCode(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Check for required team fields
                return json["teamCode"] != nil || json["team_id"] != nil
            }
        } catch {
            return false
        }
        
        return false
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension BarcodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Process the scanned code
        Task { @MainActor in
            processScannedCode(stringValue, type: metadataObject.type)
        }
    }
}

// MARK: - BarcodeType

enum BarcodeType: String, CaseIterable {
    case qr = "QR Code"
    case ean8 = "EAN-8"
    case ean13 = "EAN-13"
    case code128 = "Code 128"
    case code39 = "Code 39"
    case code93 = "Code 93"
    case pdf417 = "PDF417"
    case upce = "UPC-E"
    case aztec = "Aztec"
    case dataMatrix = "Data Matrix"
    case unknown = "Unknown"
    
    static func from(metadataType: AVMetadataObject.ObjectType) -> BarcodeType {
        switch metadataType {
        case .qr: return .qr
        case .ean8: return .ean8
        case .ean13: return .ean13
        case .code128: return .code128
        case .code39: return .code39
        case .code93: return .code93
        case .pdf417: return .pdf417
        case .upce: return .upce
        case .aztec: return .aztec
        case .dataMatrix: return .dataMatrix
        default: return .unknown
        }
    }
}

// MARK: - BarcodeScannerError

enum BarcodeScannerError: Error, LocalizedError {
    case cameraPermissionDenied
    case cameraNotAvailable
    case sessionConfigurationFailed
    case invalidTeamCode
    case scanningFailed
    
    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera permission is required to scan barcodes. Please enable camera access in Settings."
        case .cameraNotAvailable:
            return "Camera is not available on this device."
        case .sessionConfigurationFailed:
            return "Failed to configure camera session."
        case .invalidTeamCode:
            return "The scanned code is not a valid AFL Fantasy team code."
        case .scanningFailed:
            return "Failed to scan barcode. Please try again."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Go to Settings → Privacy & Security → Camera → AFL Fantasy Intelligence and enable camera access."
        case .cameraNotAvailable:
            return "Try using this feature on a device with a camera."
        case .sessionConfigurationFailed, .scanningFailed:
            return "Please try again or restart the app."
        case .invalidTeamCode:
            return "Make sure you're scanning a valid AFL Fantasy team code or QR code."
        }
    }
}

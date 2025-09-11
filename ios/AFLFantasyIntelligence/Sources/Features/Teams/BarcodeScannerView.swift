import SwiftUI
import AVFoundation

// MARK: - BarcodeScannerView

struct BarcodeScannerView: View {
    @StateObject private var scanner = BarcodeScanner()
    @Environment(\.presentationMode) var presentationMode
    
    let onTeamScanned: (String, BarcodeType) -> Void
    
    @State private var showingManualEntry = false
    @State private var flashOn = false
    @State private var scannerDelegate: ScannerDelegate?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera Preview
                CameraPreview(scanner: scanner)
                    .ignoresSafeArea(.all)
                
                // Overlay UI
                VStack {
                    // Top Bar
                    HStack {
                        // Close Button
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Flash Toggle
                        Button {
                            toggleFlash()
                        } label: {
                            Image(systemName: flashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.title2)
                                .foregroundColor(flashOn ? .yellow : .white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Scanning Frame
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DS.Colors.primary, lineWidth: 3)
                            .frame(width: geometry.size.width * 0.8, height: 200)
                        
                        // Animated scanning line
                        Rectangle()
                            .fill(DS.Colors.primary.opacity(0.7))
                            .frame(height: 2)
                            .scaleEffect(x: geometry.size.width * 0.7, y: 1)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: scanner.isScanning)
                    }
                    
                    Spacer()
                    
                    // Instructions and Controls
                    VStack(spacing: DS.Spacing.l) {
                        // Instructions
                        VStack(spacing: DS.Spacing.s) {
                            Text("Scan AFL Fantasy Team Code")
                                .font(DS.Typography.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Position the barcode or QR code within the frame")
                                .font(DS.Typography.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, DS.Spacing.m)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        
                        // Manual Entry Button
                        Button {
                            showingManualEntry = true
                        } label: {
                            HStack(spacing: DS.Spacing.s) {
                                Image(systemName: "keyboard")
                                Text("Enter Code Manually")
                            }
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.primary)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                
                // Error Overlay
                if let error = scanner.error {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: DS.Spacing.m) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            
                            Text(error.localizedDescription)
                                .font(DS.Typography.body)
                                .multilineTextAlignment(.center)
                            
                            if let suggestion = error.recoverySuggestion {
                                Text(suggestion)
                                    .font(DS.Typography.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button("Try Again") {
                                scanner.error = nil
                                scanner.startScanning()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding()
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            let delegate = ScannerDelegate(onTeamScanned: onTeamScanned)
            scannerDelegate = delegate
            scanner.delegate = delegate
            scanner.startScanning()
        }
        .onDisappear {
            scanner.stopScanning()
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualTeamEntryView { teamCode in
                onTeamScanned(teamCode, .unknown)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if flashOn {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: 1.0)
            }
            
            flashOn.toggle()
            device.unlockForConfiguration()
        } catch {
            print("Flash error: \(error)")
        }
    }
}

// MARK: - CameraPreview

struct CameraPreview: UIViewRepresentable {
    let scanner: BarcodeScanner
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        if let previewLayer = scanner.getPreviewLayer() {
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - ManualTeamEntryView

struct ManualTeamEntryView: View {
    let onTeamCodeEntered: (String) -> Void
    
    @State private var teamCode = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: DS.Spacing.l) {
                VStack(alignment: .leading, spacing: DS.Spacing.s) {
                    Text("Enter Team Code")
                        .font(DS.Typography.headline)
                    
                    Text("Enter your AFL Fantasy team code manually")
                        .font(DS.Typography.body)
                        .foregroundColor(.secondary)
                }
                
                TextField("Team Code (e.g., ABC123)", text: $teamCode)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                
                Button("Add Team") {
                    onTeamCodeEntered(teamCode)
                }
                .buttonStyle(.borderedProminent)
                .disabled(teamCode.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ScannerDelegate

class ScannerDelegate: BarcodeScannerDelegate {
    let onTeamScanned: (String, BarcodeType) -> Void
    
    init(onTeamScanned: @escaping (String, BarcodeType) -> Void) {
        self.onTeamScanned = onTeamScanned
    }
    
    func barcodeScanner(_ scanner: BarcodeScanner, didScanCode code: String, type: BarcodeType) {
        onTeamScanned(code, type)
    }
    
    func barcodeScanner(_ scanner: BarcodeScanner, didFailWithError error: BarcodeScannerError) {
        // Error is handled by the scanner's published error property
        print("Scanner error: \(error)")
    }
}

// MARK: - Preview

#if DEBUG
struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView { code, type in
            print("Scanned: \(code) (\(type.rawValue))")
        }
    }
}
#endif

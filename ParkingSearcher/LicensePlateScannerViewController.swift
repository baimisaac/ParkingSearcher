import SwiftUI
import Vision
import AVFoundation

class LicensePlateScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    var onPlateRecognized: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func setupCamera() {
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            for observation in observations {
                guard let recognizedText = observation.topCandidates(1).first?.string else { continue }
                if self?.isValidMalaysianLicensePlate(recognizedText) == true {
                    DispatchQueue.main.async {
                        self?.onPlateRecognized?(recognizedText)
                    }
                    return
                }
            }
        }
        
        request.recognitionLevel = .accurate
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    private func isValidMalaysianLicensePlate(_ text: String) -> Bool {
        let plateRegex = "^([A-Z]{1,2}[0-9]{1,4}|[A-Z]{3}[0-9]{1,4}|W[0-9]{1,4}[A-Z])$"
        let trimmedText = text.replacingOccurrences(of: " ", with: "").uppercased()
        return trimmedText.range(of: plateRegex, options: .regularExpression) != nil
    }
}

struct LicensePlateScanner: UIViewControllerRepresentable {
    let onPlateRecognized: (String) -> Void
    
    func makeUIViewController(context: Context) -> LicensePlateScannerViewController {
        let viewController = LicensePlateScannerViewController()
        viewController.onPlateRecognized = onPlateRecognized
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: LicensePlateScannerViewController, context: Context) {}
}

struct CameraView: View {
    @Binding var plateNumber: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LicensePlateScanner { recognizedPlate in
                plateNumber = recognizedPlate
                presentationMode.wrappedValue.dismiss()
            }
            
            VStack {
                Spacer()
                Text("Position the license plate in the camera view")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


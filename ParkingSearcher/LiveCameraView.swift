import SwiftUI
import AVFoundation
import Vision
import CoreML

struct LiveCameraView: UIViewRepresentable {
    @Binding var vehicleType: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return view }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return view }
        captureSession.addInput(input)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        captureSession.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: LiveCameraView
        var lastClassificationTime: Date = Date()
        
        init(_ parent: LiveCameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let currentTime = Date()
            guard currentTime.timeIntervalSince(lastClassificationTime) > 1.0 else { return }
            lastClassificationTime = currentTime
            
            classifyVehicleType(pixelBuffer: pixelBuffer)
        }
        
        private func classifyVehicleType(pixelBuffer: CVPixelBuffer) {
            guard let model = try? VNCoreMLModel(for: vehicletype().model) else { return }
            
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let results = request.results as? [VNClassificationObservation] else { return }
                
                if let firstResult = results.first {
                    DispatchQueue.main.async {
                        self?.parent.vehicleType = firstResult.identifier
                    }
                }
            }
            
            try? VNImageRequestHandler(ciImage: CIImage(cvPixelBuffer: pixelBuffer), orientation: .up).perform([request])
        }
    }
}


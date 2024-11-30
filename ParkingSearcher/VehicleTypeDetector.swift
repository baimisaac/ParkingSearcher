import SwiftUI
import Vision
import AVFoundation

struct VehicleTypeDetector: View {
    @Binding var vehicleType: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isLiveDetectionActive = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLiveDetectionActive {
                    LiveCameraView(vehicleType: $vehicleType)
                        .frame(height: 300)
                } else if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                } else {
                    Text("No image selected")
                        .frame(height: 300)
                }
                
                HStack {
                    Button(action: {
                        isLiveDetectionActive.toggle()
                    }) {
                        Text(isLiveDetectionActive ? "Stop Live Detection" : "Start Live Detection")
                    }
                    .padding()
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("Select from Library")
                    }
                    .padding()
                }
                
                if !vehicleType.isEmpty {
                    Text("Detected Vehicle Type: \(vehicleType)")
                        .padding()
                }
                
                Button("Confirm") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .disabled(vehicleType.isEmpty)
            }
            .navigationTitle("Vehicle Type Detection")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    classifyVehicleType(image: image)
                }
            }
        }
    }
    
    private func classifyVehicleType(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: vehicletype().model) else {
            print("Failed to load CoreML model")
            return
        }
        
        guard let ciImage = CIImage(image: image) else {
            print("Failed to create CIImage")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                print("Failed to process image")
                return
            }
            
            if let firstResult = results.first {
                DispatchQueue.main.async {
                    self.vehicleType = firstResult.identifier
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform classification: \(error)")
        }
    }
}

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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


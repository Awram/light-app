import Flutter
import AVFoundation

class LightSensorHandler: NSObject, FlutterPlugin, AVCapturePhotoCaptureDelegate {
    private var averageBrightness: Double?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.myapp/light_sensor", binaryMessenger: registrar.messenger())
        let instance = LightSensorHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getLuxValue" {
            getBrightnessFromCamera { brightness in
                if let brightness = brightness {
                    result(brightness)
                } else {
                    result(FlutterError(code: "CAMERA_ERROR", message: "Failed to get brightness from camera", details: nil))
                }
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func getBrightnessFromCamera(completion: @escaping (Double?) -> Void) {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        
        guard let input = try? AVCaptureDeviceInput(device: device!) else {
            completion(nil)
            return
        }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let output = AVCapturePhotoOutput()
        captureSession.addOutput(output)
        let settings = AVCapturePhotoSettings()
        
        output.capturePhoto(with: settings, delegate: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            captureSession.stopRunning()
            completion(self.averageBrightness)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData),
              let ciImage = CIImage(image: image) else {
            return
        }
        
        let extent = ciImage.extent
        let inputImage = ciImage.cropped(to: extent)
        
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: CIVector(cgRect: extent)])!
        let outputImage = filter.outputImage!
        let context = CIContext(options: nil)
        let bitmap = context.createCGImage(outputImage, from: outputImage.extent)!
        
        let rawData = CFDataGetBytePtr(bitmap.dataProvider!.data)
        let red = CGFloat(rawData![0]) / 255.0
        let green = CGFloat(rawData![1]) / 255.0
        let blue = CGFloat(rawData![2]) / 255.0
        
        averageBrightness = (red + green + blue) / 3.0
    }
}

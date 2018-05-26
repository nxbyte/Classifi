/*
 Developer : Warren Seto
 Classes   : ViewController
 Project   : Classifi App (v1)
 */

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    let session = AVCaptureSession(),
        capturePhotoOutput = AVCapturePhotoOutput(),
        captureQueue = DispatchQueue.global(qos: .background)

    var previewLayer: AVCaptureVideoPreviewLayer!,
        visionRequests:[VNRequest] = [],
        captureOrientation:AVCaptureVideoOrientation = .portrait

    @IBOutlet weak var cameraView: UIView!
    
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    var classifications:[VNClassificationObservation]!
    
    /*  */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("No video camera available")
        }
        
        do {
            // add the preview layer
            previewLayer = {
                $0.videoGravity = AVLayerVideoGravity.resizeAspectFill
                return $0
            } (AVCaptureVideoPreviewLayer(session: session))

            
            cameraView.layer.addSublayer(previewLayer)
            
            // create the capture input and the video output
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            
            let videoOutput:AVCaptureVideoDataOutput = {
                $0.setSampleBufferDelegate(self, queue: captureQueue)
                $0.alwaysDiscardsLateVideoFrames = true
                $0.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                return $0
            } (AVCaptureVideoDataOutput())


            session.sessionPreset = .photo
            
            // wire up the session:
            
            // for video out to the UIView
            session.addInput(cameraInput)
            
            // for video to the Vision Framework
            session.addOutput(videoOutput)
            
            // for capturing a frame from the video
            session.addOutput(capturePhotoOutput)
            
            
            // Start the session
            session.startRunning()
            
            
            // set up the vision model
            guard let grassWeedNetwork = try? VNCoreMLModel(for: /* Custom CoreML Model */) else {
                fatalError("Could not load model")
            }
            
            // set up the request using our vision model
            let classificationRequest:VNCoreMLRequest = {
                $0.imageCropAndScaleOption = .centerCrop
                return $0
            } (VNCoreMLRequest(model: grassWeedNetwork, completionHandler: handleClassifications))

            visionRequests = [classificationRequest]
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /*  */
    override func viewDidDisappear(_ animated: Bool) {
        if session.isRunning {
            session.stopRunning()
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    /*  */
    override func viewDidAppear(_ animated: Bool) {
        if !session.isRunning {
            session.startRunning()
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    /*  */
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = self.cameraView.bounds;
        
        switch (UIDevice.current.orientation)
        {
            case .portrait:
                previewLayer?.connection?.videoOrientation = .portrait
                captureOrientation = .portrait
            
            case .landscapeRight:
                previewLayer?.connection?.videoOrientation = .landscapeLeft
                captureOrientation = .landscapeLeft
            
            case .landscapeLeft:
                previewLayer?.connection?.videoOrientation = .landscapeRight
                captureOrientation = .landscapeRight
            
            case .portraitUpsideDown:
                previewLayer?.connection?.videoOrientation = .portraitUpsideDown
                captureOrientation = .portraitUpsideDown
            
            default:
                previewLayer?.connection?.videoOrientation = .portrait
                captureOrientation = .portrait
        }
    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        // Make the instance of the View Controller to Transition to
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SubmitViewController") as? SubmitViewController {

            nextVC.imageData = UIImage(data: photo.fileDataRepresentation()!)
            nextVC.imageLabel = self.classifications.first!.identifier
            nextVC.imageScore = self.classifications.first!.confidence
            
            // Configure the transition from one view controller to the other
            let presentationController = SlideUpTransition(presentedViewController: nextVC, presenting: self)
            
            nextVC.transitioningDelegate = presentationController
            
            
            self.present(nextVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func didTapCameraView(_ sender: Any) {
        capturePhotoOutput.capturePhoto(with: {
            $0.isAutoStillImageStabilizationEnabled = true
            return $0
        } (AVCapturePhotoSettings()), delegate: self)
    }
    

    /*  */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        connection.videoOrientation = captureOrientation

        var requestOptions:[VNImageOption: Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }
        
        // for orientation see kCGImagePropertyOrientation
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    /*  */
    func handleClassifications(request: VNRequest, error: Error?) {
        if let theError = error {
            print("Error: \(theError.localizedDescription)")
            return
        }
        
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        if let results = observations as? [VNClassificationObservation] {
            DispatchQueue.main.async {
                self.resultsLabel.text = results[0...1] // top 2 results
                    .map({ "\($0.identifier) \(String(format:"%.2f", $0.confidence))" })
                    .joined(separator: "\n")
                
                self.classifications = results
            } 
        }
    }
    
    /*  */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

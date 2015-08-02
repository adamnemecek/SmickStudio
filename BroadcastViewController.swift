import Cocoa
import AVFoundation
import AVKit
import Foundation

class BroadcastViewController: NSViewController, AVCaptureFileOutputRecordingDelegate, NSWindowDelegate {
    @IBOutlet weak var previewView: NSView?
    @IBOutlet weak var videoSource: NSPopUpButton?
    @IBOutlet weak var audioSource: NSPopUpButton?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession: AVCaptureSession = AVCaptureSession()
    var currentVideoInput: AVCaptureInput?
    var currentAudioInput: AVCaptureInput?
    var captureOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    var counter: NSInteger = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var representedObject: AnyObject? {
        didSet {
        }
    }
    
    func addPreviewLayer() {
        // Add preview layer to the preview view
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = previewView!.bounds
        previewLayer?.needsDisplayOnBoundsChange = true
        previewView?.layer?.addSublayer(previewLayer)
        previewView?.layer?.backgroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)
        previewView?.window?.delegate = self
        previewView?.window?.aspectRatio = NSMakeSize(1120, 700)
    }
    
    @IBAction func changedAudioSource(sender: NSPopUpButton) {
        let newValue = audioSource?.selectedItem?.title
        let audioDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)
        for audioDevice in audioDevices {
            if audioDevice.localizedName == newValue {
                let deviceInput = AVCaptureDeviceInput(device: audioDevice as! AVCaptureDevice, error: nil)
                captureSession.beginConfiguration()
                captureSession.removeInput(currentAudioInput)
                currentAudioInput = deviceInput
                captureSession.addInput(currentAudioInput)
                captureSession.commitConfiguration()
            }
        }
    }
    
    @IBAction func changedVideoSource(sender: NSPopUpButton) {
        let newValue = videoSource?.selectedItem?.title
        if newValue == "Computer Screen" {
            let screenInput = AVCaptureScreenInput(displayID: CGMainDisplayID())
            captureSession.beginConfiguration()
            captureSession.removeInput(currentVideoInput)
            currentVideoInput = screenInput
            captureSession.addInput(screenInput)
            captureSession.commitConfiguration()
        } else {
            let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            for videoDevice in videoDevices {
                if videoDevice.localizedName == newValue {
                    let deviceInput = AVCaptureDeviceInput(device: videoDevice as! AVCaptureDevice, error: nil)
                    captureSession.beginConfiguration()
                    captureSession.removeInput(currentVideoInput)
                    currentVideoInput = deviceInput
                    captureSession.addInput(currentVideoInput)
                    captureSession.commitConfiguration()
                    return
                }
            }
        }
    }
    
    override func viewWillAppear() {
        addPreviewLayer()
        
        let allDevices = AVCaptureDevice.devices()
        for device in allDevices {
            if let deviceDescription = device.localizedName {
                if device.hasMediaType(AVMediaTypeVideo) {
                     videoSource?.addItemWithTitle(deviceDescription!)
                } else if device.hasMediaType(AVMediaTypeAudio) {
                    audioSource?.addItemWithTitle(deviceDescription!)
                }
            }
        }
        
        let defaultVideoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let defaultAudioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        videoSource?.selectItemWithTitle(defaultVideoDevice.localizedName!)
        audioSource?.selectItemWithTitle(defaultAudioDevice.localizedName!)
    }
    
    override func viewDidAppear() {
        addPreviewLayer()
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError? = nil
        let captureDeviceInput = AVCaptureDeviceInput(device: captureDevice, error: &error)
        captureSession.addInput(captureDeviceInput)
        currentVideoInput = captureDeviceInput
        
        let microphone = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        let microphoneInput = AVCaptureDeviceInput(device: microphone, error: &error)
        captureSession.addInput(microphoneInput)
        currentAudioInput = microphoneInput
        
        let outputPath = getFileName()
        captureSession.addOutput(captureOutput)
        captureSession.startRunning()
        captureOutput.startRecordingToOutputFileURL(outputPath, recordingDelegate: self)
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
    }
    
    func timerTick(timer: NSTimer) {
        let outputPath = getFileName()
        captureOutput.startRecordingToOutputFileURL(outputPath, recordingDelegate: self)
    }
    
    func windowDidResize(notification: NSNotification) {
        previewLayer?.frame = previewView!.bounds
        previewLayer?.needsDisplay()
        self.previewView?.layer?.needsDisplay()
        println(self.previewView?.window?.frame.size)
    }
    
    func getFileName() -> NSURL {
        let pathString = String(format: "/Users/Omar/Desktop/LiveVideo/fileSequence%d.mov", counter)
        let outputPath = NSURL(fileURLWithPath: pathString)
        counter++
        return outputPath!
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        let savedFile = outputFileURL.absoluteString
        let savedDirectory = savedFile?.stringByDeletingLastPathComponent
        let basename = savedFile?.lastPathComponent.stringByDeletingPathExtension
        let fullOutputPath = savedDirectory?.stringByAppendingPathComponent(basename!).stringByAppendingPathExtension("ts")
        
        let task = NSTask()
        task.launchPath = "/usr/local/bin/ffmpeg"
        task.arguments = ["-i",savedFile!,"-bsf","h264_mp4toannexb","-c","copy",fullOutputPath!]
        task.launch()
        
        task.waitUntilExit()
        
        NSFileManager.defaultManager().removeItemAtURL(outputFileURL, error: nil)
    }
    
}


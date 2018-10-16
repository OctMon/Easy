//
//  EasyScan.swift
//  Easy
//
//  Created by OctMon on 2018/10/14.
//

import UIKit
import AVFoundation

public extension Easy {
    typealias Scan = EasyScan
}

public extension EasyApp {
    static var authorizationStatusMediaTypeVideo: Bool { return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .denied }
}

public class EasyScan: NSObject {
    
    private let captureDevice = AVCaptureDevice.default(for: .video)
    
    private let captureMetadataOutput = AVCaptureMetadataOutput()
    
    private let captureSession = AVCaptureSession().then {
        if $0.canSetSessionPreset(.high) {
            $0.sessionPreset = .high
        }
    }
    
    private var scanView = EasyScanView()
    
    private var metadataObjectsHandler: (([AVMetadataMachineReadableCodeObject]) -> Void)?
    
    public var metadataObjectTypes: [AVMetadataObject.ObjectType] = [.qr, .upce, .code39, .code39Mod43, .ean13, .ean8, .code93, .code128, .pdf417, .aztec, .interleaved2of5, .itf14, .dataMatrix, .interleaved2of5, .itf14, .dataMatrix]
    
    public var cornerRadius: CGFloat = 0 {
        didSet {
            scanView.cornerRadius = cornerRadius
        }
    }
    public var strokeColor = UIColor.clear {
        didSet {
            scanView.strokeColor = strokeColor
        }
    }
    
    public init(showInView view: UIView, scanRect frame: CGRect, expansionViewHandler: (() -> UIView)? = nil) {
        super.init()
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        guard let captureDevice = captureDevice else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice), captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        guard captureSession.canAddOutput(captureMetadataOutput) else { return }
        captureSession.addOutput(captureMetadataOutput)
        let width = view.frame.width
        let height = view.frame.height
        captureMetadataOutput.rectOfInterest = CGRect(x: frame.origin.y / height, y: frame.origin.x / width, width: frame.height / height, height: frame.width / width)
        captureMetadataOutput.metadataObjectTypes = metadataObjectTypes
        let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        captureVideoPreviewLayer.videoGravity = .resizeAspectFill
        captureVideoPreviewLayer.frame = view.bounds
        view.layer.insertSublayer(captureVideoPreviewLayer, at: 0)
        scanView.frame = view.bounds
        scanView.roundedRect = frame
        view.addSubview(scanView)
        if let expansionView = expansionViewHandler?() {
            scanView.addSubview(expansionView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func didOutput(metadataObjectsHandler: @escaping ([AVMetadataMachineReadableCodeObject]) -> Void) {
        self.metadataObjectsHandler = metadataObjectsHandler
    }
    
}

extension EasyScan: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        EasyLog.debug(metadataObjects)
        if let metadataObjects = metadataObjects as? [AVMetadataMachineReadableCodeObject], metadataObjects.count > 0 {
            metadataObjectsHandler?(metadataObjects)
        }
    }
    
}

public extension EasyScan {
    
    func startRunning() {
        captureSession.startRunning()
    }
    
    func stopRunning() {
        captureSession.stopRunning()
    }
    
    func torchMode(_ state : Bool) {
        do {
            if let captureDevice = captureDevice {
                try? captureDevice.lockForConfiguration()
                captureDevice.torchMode = state ? .on : .off
                captureDevice.unlockForConfiguration()
            }
        }
    }
    
}

private class EasyScanView: UIView {
    
    var roundedRect = CGRect.zero
    var cornerRadius: CGFloat = 0
    var strokeColor = UIColor.clear
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let contentRef = UIGraphicsGetCurrentContext()
        contentRef?.saveGState()
        contentRef?.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        contentRef?.setLineWidth(3)
        let roundBezierPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        let rectBezierPath = UIBezierPath(rect: rect)
        rectBezierPath.append(roundBezierPath)
        rectBezierPath.usesEvenOddFillRule = true
        rectBezierPath.fill()
        contentRef?.setLineWidth(2)
        contentRef?.setStrokeColor(red: strokeColor.red.toCGFloat / 255, green: strokeColor.green.toCGFloat / 255, blue: strokeColor.blue.toCGFloat / 255, alpha: strokeColor.alpha)
        roundBezierPath.stroke()
        contentRef?.restoreGState()
    }
}

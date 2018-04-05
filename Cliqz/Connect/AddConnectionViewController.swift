//
//  AddConnectionViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 4/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import AVFoundation

class AddConnectionViewController: UIViewController {

    fileprivate var dataSource: ConnectDataSource
    fileprivate var captureSession:AVCaptureSession?
    fileprivate var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    fileprivate var qrCodeFrameView:UIView?
    fileprivate let instructionsLabel = UILabel()
    fileprivate var qrCodeScannerReady = true
    fileprivate var qrCodeScanned = false
    fileprivate let supportedBarCodes = [AVMetadataObjectTypeQRCode]

    init(_ dataSource: ConnectDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Scan QR-Code", tableName: "Cliqz", comment: "[Settings -> Connect] Scan QR-Code")
        configureInstructionLabel()
        configureScanningView()
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustVideoPreviewLayerFrame()
    }
    
    
    // MARK: - Private Helpers
    private func configureInstructionLabel() {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "connectDesktopMenu")
        let attachmentString = NSAttributedString(attachment: attachment)
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("Go to ", tableName: "Cliqz", comment: "[Connect] instructions text part#1"))
        attributedString.append(attachmentString)
        attributedString.append(NSAttributedString(string: NSLocalizedString(" and select connect to scan the QR-Code", tableName: "Cliqz", comment: "[Connect] instructions text part#2")))
        
        instructionsLabel.attributedText = attributedString
        instructionsLabel.numberOfLines = 2
        self.view.addSubview(instructionsLabel)
        
        let margin = 15
        instructionsLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.view).offset(margin)
            make.trailing.equalTo(self.view).offset(-1 * margin)
            make.bottom.equalTo(self.view).offset(-2 * margin)
        }
    }
    
    private func configureScanningView() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            adjustVideoPreviewLayerFrame()
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            showAllowCameraAccessAlert()
            return
        }
    }
    
    private func showAllowCameraAccessAlert() {
        let settingsOptionTitle = NSLocalizedString("Settings", tableName: "Cliqz", comment: "Settings option for turning on Camera access")
        let message = NSLocalizedString("Cliqz Browser does not have access to your camera. To enable access, tap ‘Settings’ and turn on camera.", tableName: "Cliqz", comment: "[Connect] Alert message for turning on Camera access when Scanning QR Code")
        let settingsAction = UIAlertAction(title: settingsOptionTitle, style: .default) { (_) -> Void in
            if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(settingsUrl, options: [:])
            }
        }
        
        let title = NSLocalizedString("Allow Camera Access", tableName: "Cliqz", comment: "[Connect] Alert title for turning on Camera access when scanning QRCode")
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        
        let notNowOptionTitle = NSLocalizedString("Not Now", tableName: "Cliqz", comment: "Not now option for turning on Camera access")
        let cancelAction = UIAlertAction(title: notNowOptionTitle, style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func adjustVideoPreviewLayerFrame() {
        let width = view.frame.width
        let height = view.frame.height * 0.8
        
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        switch UIDevice.current.orientation {
        case .portrait:
            videoPreviewLayer?.connection.videoOrientation = .portrait
        case .landscapeLeft:
            videoPreviewLayer?.connection.videoOrientation = .landscapeRight
        case .landscapeRight:
            videoPreviewLayer?.connection.videoOrientation = .landscapeLeft
        default:
            videoPreviewLayer?.connection.videoOrientation = .portrait
        }
    }
}

extension AddConnectionViewController : AVCaptureMetadataOutputObjectsDelegate {
    //MARK: - AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard qrCodeScannerReady == true else {
            return
        }
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let qrCode = metadataObj.stringValue {
                qrCodeScannerReady = false
                self.processScannedCode(qrCode)
            }
        }
    }
    
    private func processScannedCode(_ qrCode: String) {
        dataSource.qrcodeScanned(qrCode)
        qrCodeScanned = true
        
        // give user some time to notice the action, as scanning is done very quickly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
    }
}

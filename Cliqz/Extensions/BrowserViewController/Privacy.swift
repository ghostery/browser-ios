//
//  Privacy.swift
//  Client
//
//  Created by Sahakyan on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static let GhosteryButtonPressed = NSNotification.Name(rawValue: "GhosteryButtonPressedNotification")
    public static let DeviceOrientationChanged = NSNotification.Name(rawValue: "DeviceOrientationChangedNotification")
}

class OrientationManager {
    
    static let shared = OrientationManager()
    
    private var lastOrientation: DeviceOrientation
    
    init() {
        lastOrientation = UIDevice.current.getDeviceAndOrientation().1
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func orientationChanged(_ notification: Notification) {
        let orientation = UIDevice.current.getDeviceAndOrientation().1
        if orientation != lastOrientation {
            lastOrientation = orientation
            NotificationCenter.default.post(name: NSNotification.Name.DeviceOrientationChanged, object: nil)
        }
    }
}

extension BrowserViewController {
    
    func ghosteryButtonPressed(notification: Notification) {
        
        if let cc = self.childViewControllers.last,
            let _ = cc as? ControlCenterViewController {
            hideControlCenter()
        }
        else {
            //show it
            if let pageUrl = notification.object as? String {
                showControlCenter(pageUrl: pageUrl)
            }
        }
    }
	
    func showControlCenter(pageUrl: String? = nil) {
        
        func applyShadow(view: UIView) {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.4
            view.layer.shadowRadius = 4
            view.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        
		let controlCenter = ControlCenterViewController()
        
        controlCenter.container = self
        
        if let pageUrl = pageUrl {
            controlCenter.pageURL = pageUrl
        }
		
        let (device,orientation) = UIDevice.current.getDeviceAndOrientation()
        
		self.addChildViewController(controlCenter)
        //controlCenter.beginAppearanceTransition(true, animated: false)
        self.view.addSubview(controlCenter.view)
        //controlCenter.endAppearanceTransition()
        TelemetryHelper.sendControlCenterShow()
        
        if orientation == .portrait && device != .iPad {
            controlCenter.view.snp.makeConstraints({ (make) in
                make.top.equalTo(self.urlBar.snp.bottom)
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
            })
        }
        else if device == .iPad {
            controlCenter.view.snp.makeConstraints({ (make) in
                make.width.equalToSuperview().dividedBy(2.0)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.top.equalTo(self.urlBar.snp.bottom)
            })
            
            applyShadow(view: controlCenter.view)
        }
        else {
            controlCenter.view.snp.makeConstraints({ (make) in
                make.width.equalToSuperview().dividedBy(1.5)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.top.equalTo(self.urlBar.snp.bottom)
            })
            
            applyShadow(view: controlCenter.view)
        }
	}

	func hideControlCenter() {
        for cc in self.childViewControllers {
            if let c = cc as? ControlCenterViewController {
                c.willMove(toParentViewController: nil)
                c.beginAppearanceTransition(true, animated: false)
                c.view.removeFromSuperview()
                c.endAppearanceTransition()
                c.removeFromParentViewController()
                NotificationCenter.default.post(name: controlCenterDismissedNotification, object: nil)
                break
            }
        }
	}
    
    @objc func orientationDidChange(notification: Notification) {
        hideControlCenter()
    }
    
    func showAntiPhishingAlert(_ domainName: String) {
        //let antiPhishingShowTime = Date.getCurrentMillis()
        
        let title = NSLocalizedString("Warning: deceptive website!", tableName: "Cliqz", comment: "Antiphishing alert title")
        let message = NSLocalizedString("CLIQZ has blocked access to %1$ because it has been reported as a phishing website.Phishing websites disguise as other sites you may trust in order to trick you into disclosing your login, password or other sensitive information", tableName: "Cliqz", comment: "Antiphishing alert message")
        let personnalizedMessage = message.replace("%1$", replacement: domainName)
        
        let alert = UIAlertController(title: title, message: personnalizedMessage, preferredStyle: .alert)
        
        let backToSafeSiteButtonTitle = NSLocalizedString("Back to safe site", tableName: "Cliqz", comment: "Back to safe site buttun title in antiphishing alert title")
        alert.addAction(UIAlertAction(title: backToSafeSiteButtonTitle, style: .default, handler: { (action) in
            // go back
            self.tabManager.selectedTab?.goBack()
            //TelemetryLogger.sharedInstance.logEvent(.AntiPhishing("click", "back", nil))
            //let duration = Int(Date.getCurrentMillis()-antiPhishingShowTime)
            //TelemetryLogger.sharedInstance.logEvent(.AntiPhishing("hide", nil, duration))
        }))
        
        let continueDespiteWarningButtonTitle = NSLocalizedString("Continue despite warning", tableName: "Cliqz", comment: "Continue despite warning buttun title in antiphishing alert title")
        alert.addAction(UIAlertAction(title: continueDespiteWarningButtonTitle, style: .destructive, handler: { (action) in
            AntiPhishingDetector.disableForOneUrl = true
            self.tabManager.selectedTab?.reload()
            //TelemetryLogger.sharedInstance.logEvent(.AntiPhishing("click", "continue", nil))
            //let duration = Int(Date.getCurrentMillis()-antiPhishingShowTime)
            //TelemetryLogger.sharedInstance.logEvent(.AntiPhishing("hide", nil, duration))
        }))
        
        self.present(alert, animated: true, completion: nil)
        //TelemetryLogger.sharedInstance.logEvent(.AntiPhishing("show", nil, nil))
        
    }
}

extension BrowserViewController: ControlCenterViewControllerDelegate {
    func dismiss() {
        self.hideControlCenter()
    }
}

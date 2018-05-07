//
//  Privacy.swift
//  Client
//
//  Created by Sahakyan on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

extension NSNotification.Name {
	
	public static let ShowControlCenterNotification = NSNotification.Name(rawValue: "showControlCenter")

	public static let HideControlCenterNotification = NSNotification.Name(rawValue: "hideControlCenter")
}

extension BrowserViewController {
	
	func showControlCenter(notification: Notification) {
		let controlCenter = ControlCenterViewController()
		
		if let pageUrl = notification.object as? String {
			controlCenter.pageURL = pageUrl
			// TODO: provide a DataSource Instead
//			controlCenter.trackers = TrackerList.instance.detectedTrackersForPage(pageUrl)
//			controlCenter.pageURL = host
		}
		self.addChildViewController(controlCenter)
		self.view.addSubview(controlCenter.view)
		controlCenter.view.snp.makeConstraints({ (make) in
			make.left.right.bottom.equalToSuperview()
			make.top.equalToSuperview().offset(0)
		})
	}

	func hideControlCenter() {
		if let cc = self.childViewControllers.last,
			let c = cc as? ControlCenterViewController {
			c.removeFromParentViewController()
			c.view.removeFromSuperview()
		}
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

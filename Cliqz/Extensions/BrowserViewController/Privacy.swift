//
//  Privacy.swift
//  Client
//
//  Created by Sahakyan on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

let ShowControlCenterNotification = NSNotification.Name(rawValue: "showControlCenter")
let HideControlCenterNotification = NSNotification.Name(rawValue: "hideControlCenter")

extension BrowserViewController {
	
	func showControlCenter(notification: Notification) {
		if let appDel = UIApplication.shared.delegate as? AppDelegate {
			let controlCenter = ControlCenterViewController() //TrackersController()
			if let pageUrl = notification.object as? String {
				controlCenter.trackers = TrackerList.instance.detectedTrackersForPage(pageUrl)
				controlCenter.pageURL = pageUrl
			}
			self.addChildViewController(controlCenter)
			self.view.addSubview(controlCenter.view)
			controlCenter.view.snp.makeConstraints({ (make) in
				make.left.right.bottom.equalToSuperview()
				make.top.equalToSuperview().offset(0)
//				make.top.equalToSuperview().offset(70)
			})
//			appDel.presentContollerOnTop(controller: controlCenter)
		}
	}

	func hideControlCenter() {
		if let cc = self.childViewControllers.last,
			let c = cc as? ControlCenterViewController {
			c.removeFromParentViewController()
			c.view.removeFromSuperview()
		}
	}
}

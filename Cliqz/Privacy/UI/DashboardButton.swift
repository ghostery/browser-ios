//
//  DashboardButton.swift
//  Client
//
//  Created by Sahakyan on 3/12/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

import UIKit
import SnapKit

let didChangeTabNotification = Notification.Name(rawValue: "didChangeTab")
let didShowFreshTabNotification = Notification.Name(rawValue: "didShowFreshTabNotification")
let didLeaveOverlayNotification = Notification.Name(rawValue: "didLeaveOverlayNotification")

#if PAID

enum DashboardButtonState {
	case empty
	case full
}

#endif

class DashboardButton: InsetButton {
	
	private let trackersCount = TrackersCount()
	fileprivate let dashboardIcon = UIImageView()
	
	private let count = UILabel()
	private var isPrivate = false
	
	#if PAID
	private var checkIcon = UIImageView()

	var currentState = DashboardButtonState.full {
		didSet {
			updateDashboardIcon()
		}
	}
	var isDisabled = false {
		didSet {
			updateDashboardIcon()
		}
	}
	#endif

	override init(frame: CGRect) {
		super.init(frame: frame)
		trackersCount.delegate = self
		
		setUpComponent()
		setUpConstaints()
	}
	
	func setUpComponent() {
		addSubview(dashboardIcon)
		#if !PAID
		addSubview(count)
		#endif
		
		dashboardIcon.backgroundColor = .clear
		count.backgroundColor = .clear
		
		count.text = "HELLO"
		count.font = UIFont.systemFont(ofSize: 14)
		
		#if PAID
		count.isHidden = true
		addSubview(checkIcon)
		checkIcon.image = UIImage(named: "dashboard_button_page")
		#endif
	}
	
	func setUpConstaints() {
		
		#if !PAID
		let height: CGFloat = 25.0
		let width = (dashboardIcon.image?.widthOverHeight() ?? 1.0) * height
		var centerDifference: CGFloat = 0.0
		if isPrivate, let normalImage = UIImage.controlCenterNormalIcon(), let privImage = dashboardIcon.image {
			let ratioNormal = normalImage.widthOverHeight()
			let ratioPrivate = privImage.widthOverHeight()
			let widthNormal = ratioNormal * height
			centerDifference = 1/2 * widthNormal * (ratioPrivate / ratioNormal - 1)
		}
		
		dashboardIcon.snp.remakeConstraints { (make) in
			make.top.equalToSuperview().offset(6)
			make.centerX.equalToSuperview()
			make.height.equalTo(height)
			make.width.equalTo(width)
		}
		
		count.snp.remakeConstraints { (make) in
			make.centerX.equalToSuperview().offset(-centerDifference)
			make.bottom.equalToSuperview().offset(-4)
		}
		#else
		let height: CGFloat = 30.0
		let width = (dashboardIcon.image?.widthOverHeight() ?? 1.0) * height
		dashboardIcon.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview()
			make.centerY.equalToSuperview()
			make.height.equalTo(height)
			make.width.equalTo(width)
		}
		checkIcon.snp.remakeConstraints { (make) in
			make.center.equalTo(dashboardIcon.snp.center)
		}
		#endif
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setCount(count: Int) {
		let count_str = String(count)
		
		if count <= 99 {
			self.count.text = count_str
		}
		else {
			self.count.text = "99"
		}
	}
	
	func lookDeactivated() {
		self.dashboardIcon.alpha = 0.8
		self.count.alpha = 0.8
	}
	
	func lookActivated() {
		self.dashboardIcon.alpha = 1.0
		self.count.alpha = 1.0
	}

	private func updateDashboardIcon() {
		#if PAID
		if self.isDisabled {
			checkIcon.isHidden = true
			dashboardIcon.image = UIImage.controlCenterDisabledIcon()
		} else {
			dashboardIcon.image = UIImage.controlCenterNormalIcon()
			checkIcon.isHidden = self.currentState != .full
		}
		#else
		if isPrivate {
			dashboardIcon.image = UIImage.controlCenterPrivateIcon()
		} else {
			dashboardIcon.image = UIImage.controlCenterNormalIcon()
		}
		#endif
	}
}

extension DashboardButton: Themeable {
	func applyTheme() {
		setUpConstaints()
		self.tintColor = UIColor.theme.urlbar.urlbarButtonTint
		count.textColor = UIColor.theme.urlbar.urlbarButtonTitleText
	}
}

extension DashboardButton: TrackersCountDelegate {
	func updateCount(count: Int) {
		self.lookActivated()
		self.setCount(count: count)
		self.accessibilityValue = "\(count)"
	}
	
	func showHello() {
		self.count.text = "HELLO"
		self.lookDeactivated()
	}
}

extension DashboardButton : PrivateModeUI {
	func applyUIMode(isPrivate: Bool) {
		self.isPrivate = isPrivate
		updateDashboardIcon()
		setUpConstaints()
	}
}

protocol TrackersCountDelegate: class {
	func updateCount(count: Int)
	func showHello()
}

class TrackersCount {
	
	weak var delegate: TrackersCountDelegate? = nil
	
	init() {
		NotificationCenter.default.addObserver(self, selector: #selector(newTrackerDetected), name: detectedTrackerNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(newTabSelected), name: didChangeTabNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(urlChanged), name: urlChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didShowFreshtab), name: didShowFreshTabNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didLeaveOverlay), name: didLeaveOverlayNotification, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func urlChanged(notification: Notification) {
		guard let del = UIApplication.shared.delegate as? AppDelegate, let currentTab = del.tabManager.selectedTab else {return}
		if let tab = notification.object as? Tab, tab == currentTab {
			update(notification)
		}
	}
	
	@objc func newTrackerDetected(notification: Notification) {
		guard let dict = notification.userInfo as? [String: Any], let pageURL = dict["url"] as? URL else { return }
		guard let currentTab = (UIApplication.shared.delegate as? AppDelegate)?.tabManager.selectedTab else { return }
		if currentTab.url == pageURL {
			update(notification)
		}
	}
	
	@objc func newTabSelected(notification: Notification) {
		update(notification)
	}
	
	@objc func didShowFreshtab(_ notification: Notification) {
		self.delegate?.showHello()
	}
	
	@objc func didLeaveOverlay(_ notification: Notification) {
		update(notification)
	}
	
	private func update(_ notification: Notification) {
		var count = 0
		
		if let userInfo = notification.userInfo, let url = userInfo["url"] as? URL, let host = url.normalizedHost {
			count = TrackerList.instance.detectedTrackerCountForPage(host)
		}
		
		self.delegate?.updateCount(count: count)
	}
}

extension UIImage {
	func widthOverHeight() -> CGFloat {
		return self.size.width / self.size.height
	}
	
	func heightOverWidth() -> CGFloat {
		return self.size.width / self.size.height
	}
}

//
//  WifiProtectionViewController.swift
//  Shared
//
//  Created by Sahakyan on 5/24/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import SnapKit
import Shared
import Alamofire

class WifiProtectionViewController: UIViewController {

	@IBOutlet var navItem: UINavigationItem!
	@IBOutlet var topDescription: UITextView!
	@IBOutlet var WiFiProtectedStatus: UILabel!
	@IBOutlet var WifiProtectedStatusImage: UIImageView!
	
	@IBOutlet var connectedToWiFiStatus: UILabel!
	@IBOutlet var connectedToWifiStatusImage: UIImageView!
	
	@IBOutlet var configStatus: UILabel!
	@IBOutlet var configStatusImage: UIImageView!

	@IBOutlet var controlTitle: UILabel!
	@IBOutlet var controls: UISegmentedControl!

	@IBOutlet var copyActionDesc: UILabel!
	@IBOutlet var copiedNotificationLabel: UILabel!
	@IBOutlet var copyUrlField: UITextField!
	
	@IBOutlet var step1: UILabel!
	@IBOutlet var step2: UILabel!
	@IBOutlet var step3: UILabel!
	@IBOutlet var step4: UILabel!
	
	@IBOutlet var notesTitle: UILabel!
	@IBOutlet var notes: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupComponents()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.updateWiFiSettings()
	}

	private func setupComponents() {
		navItem.title = NSLocalizedString("WiFi connection protection", tableName: "Cliqz", comment:"[Wifi Protection] Navigation Title")
		topDescription.text = NSLocalizedString("Ghostery for iOS now lets you protect your WiFI connection. It can block trackers in OTHER applications as long as you are connected to this WiFi network. It must be set up each time for each different network (home, work, school, etc). ", tableName: "Cliqz", comment:"[Wifi Protection] Description")
		WiFiProtectedStatus.text = NSLocalizedString("WiFi connection protection", tableName: "Cliqz", comment:"[Wifi Protection] WiFi connection protection status")
		connectedToWiFiStatus.text = NSLocalizedString("Connected to WiFi", tableName: "Cliqz", comment:"[Wifi Protection] Connected to WiFi status")
		configStatus.text = NSLocalizedString("Configured Settings", tableName: "Cliqz", comment:"[Wifi Protection] Configured Settings")
		controlTitle.text = NSLocalizedString("Select trackers to block", tableName: "Cliqz", comment:"[Wifi Protection] Trackers control title")
		copyActionDesc.text = NSLocalizedString("Tap box below to copy", tableName: "Cliqz", comment:"[Wifi Protection] Copy URL action description")
		copiedNotificationLabel.text = NSLocalizedString("copied!", tableName: "Cliqz", comment:"[Wifi Protection] WiFi connection protection status")
		step1.text = NSLocalizedString("Go to Settings > WiFi settings", tableName: "Cliqz", comment:"[Wifi Protection] First step description")
		step2.text = NSLocalizedString("Tap        next to your connection", tableName: "Cliqz", comment:"[Wifi Protection] Second step description")
		step3.text = NSLocalizedString("Set \"HTTP PROXY\" to \"Auto\"", tableName: "Cliqz", comment:"[Wifi Protection] Third step description")
		step4.text = NSLocalizedString("Paste copied URL into textfield", tableName: "Cliqz", comment:"[Wifi Protection] Fourth step description")
		notesTitle.text = NSLocalizedString("Important Notes:", tableName: "Cliqz", comment:"[Wifi Protection] Notes Title")
		notes.text = NSLocalizedString("**This feature is EXPERIMENTAL, as such, it may not work as expected in some instances. \n\n**Mobile Safari has performance issues with the PAC config, so it is recommended you use Chrome or Ghostery or another Browser instead.", tableName: "Cliqz", comment:"[Wifi Protection] Notes")
		controls.setTitle(NSLocalizedString("All", tableName: "Cliqz", comment:"[Wifi Protection] Option 1 for blocking trackers"), forSegmentAt: 0)
		controls.setTitle(NSLocalizedString("Ads", tableName: "Cliqz", comment:"[Wifi Protection] Option 2 for blocking trackers"), forSegmentAt: 1)
		controls.setTitle(NSLocalizedString("Analytics", tableName: "Cliqz", comment:"[Wifi Protection] Option 3 for blocking trackers"), forSegmentAt: 2)
		controls.setTitle(NSLocalizedString("Beacons", tableName: "Cliqz", comment:"[Wifi Protection] Option 4 for blocking trackers"), forSegmentAt: 3)
		self.switchTrackerType()
	}

	@IBAction func switchTrackerType() {
		let index = self.controls.selectedSegmentIndex
		let baseURL = "https://cdn.ghostery.com/pac/"
		let copyURL = "\(baseURL)pac-\(index)-no_gr.js"
		copyUrlField.text = copyURL
	}

	@IBAction func donePressed() {
		self.dismiss(animated: true, completion: nil)
	}

	fileprivate func updateWiFiSettings() {
		let isWiFiOn = DeviceInfo.hasWiFiConnectivity()
		if isWiFiOn {
			updateImageStatus(connectedToWifiStatusImage, isOn: true)
			Alamofire.request("http://c.betrad.com/mobile/ghostery-ios-can-access").responseData { (response) in
				if response.value?.count == 0 {
					DispatchQueue.main.async {
						self.updateImageStatus(self.WifiProtectedStatusImage, isOn: true)
						self.updateImageStatus(self.configStatusImage, isOn: true)
					}
				} else {
					DispatchQueue.main.async {
						self.updateImageStatus(self.WifiProtectedStatusImage, isOn: false)
						self.updateImageStatus(self.configStatusImage, isOn: false)
					}
				}
			}
		} else {
			updateImageStatus(WifiProtectedStatusImage, isOn: false)
			updateImageStatus(connectedToWifiStatusImage, isOn: false)
			updateImageStatus(configStatusImage, isOn: false)
		}
	}

	fileprivate func updateImageStatus(_ imageView: UIImageView, isOn status: Bool) {
		if status {
			imageView.image = UIImage(named: "available")
		} else {
			imageView.image = UIImage(named: "notAvailable")
		}
	}

	fileprivate func copyConfigURL() {
		let pastBoard = UIPasteboard.general
		pastBoard.string = copyUrlField.text
		copiedNotificationLabel.isHidden = false
		UIView.animate(withDuration: 6.0, animations: {
			self.copiedNotificationLabel.alpha = 0.0
		}) { (finished) in
			self.copiedNotificationLabel.alpha = 0.8
			self.copiedNotificationLabel.isHidden = true
		}
	}
}

extension WifiProtectionViewController: UITextFieldDelegate {

	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		self.copyConfigURL()
		return false
	}
}

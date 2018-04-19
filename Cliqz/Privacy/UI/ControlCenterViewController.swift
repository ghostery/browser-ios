//
//  ControlCenterViewController.swift
//  Client
//
//  Created by Sahakyan on 4/17/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

class ControlCenterViewController: UIViewController {

	fileprivate var panelSwitchControl = UISegmentedControl(items: [])
	fileprivate var panelContainerView: UIView!
	private let toolBar = UIToolbar()

	fileprivate lazy var overviewViewController: OverviewViewController = {
		let overview = OverviewViewController()
		return overview
	}()

	fileprivate lazy var trackersViewController: TrackersController = {
		let trackers = TrackersController()
		return trackers
	}()

	fileprivate lazy var globalTrackersViewController: GlobalTrackersViewController = {
		let global = GlobalTrackersViewController()
		return global
	}()

	private var _trackers: [TrackerListApp] = []
	private var trackersCategories = [String: [TrackerListApp]]()

	var trackers: [TrackerListApp] {
		set {
			_trackers = newValue
			self.generateCategories()
			self.updateBlockedTrackersCount()
		}
		get {
			return _trackers
		}
	}

	var pageURL: String = "" {
		didSet {
			self.overviewViewController.pageURL = pageURL
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupComponents()
		self.panelSwitchControl.selectedSegmentIndex = 0
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.switchPanel(self.panelSwitchControl)
	}

	private func setupComponents() {
		createPanelSwitchControl()

//		let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
//		toolBar.setItems([done], animated: false)
//		view.addSubview(toolBar)
		
//		toolBar.snp.makeConstraints { (make) in
//			make.bottom.left.right.equalToSuperview()
//		}

		panelContainerView = UIView()
		view.addSubview(panelContainerView)
		panelContainerView.backgroundColor = UIColor.white

		panelContainerView.snp.makeConstraints { make in
			make.top.equalTo(self.panelSwitchControl.snp.bottom).offset(5)
			make.left.right.equalTo(self.view)
			make.bottom.equalTo(self.view)
		}

	}

	@objc func donePressed(_ button: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	private func createPanelSwitchControl() {
		let overview = "Overview"
		let trackers = "Trackers"
		let globalTrackers = "Global Trackers"

		let items = [overview, trackers, globalTrackers]
		self.view.backgroundColor = UIColor.clear
		let topView = UIView()
		topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideControlCenter)))
		topView.backgroundColor = UIColor.clear
		self.view.addSubview(topView)
		topView.snp.makeConstraints { (make) in
			make.top.left.right.equalToSuperview()
			make.height.equalTo(70)
		}

		let bgView = UIView()
		bgView.backgroundColor = UIColor.cliqzBluePrimary
		
		panelSwitchControl = UISegmentedControl(items: items)
		panelSwitchControl.tintColor = UIColor.white
		panelSwitchControl.backgroundColor = UIColor.cliqzBluePrimary
		panelSwitchControl.addTarget(self, action: #selector(switchPanel), for: .valueChanged)
		bgView.addSubview(panelSwitchControl)
		self.view.addSubview(bgView)
		
		bgView.snp.makeConstraints { (make) in
			make.top.equalTo(topView.snp.bottom)
			make.left.right.equalToSuperview()
			make.height.equalTo(40)
		}
		panelSwitchControl.snp.makeConstraints { make in
			make.top.equalTo(bgView).offset(5)
			make.left.equalTo(bgView).offset(10)
			make.right.equalTo(bgView).offset(-10)
			make.height.equalTo(30)
		}
	}

	@objc private func switchPanel(_ sender: UISegmentedControl) {
		if let panel = childViewControllers.first {
			panel.willMove(toParentViewController: nil)
			panel.view.removeFromSuperview()
			panel.removeFromParentViewController()
		}

		let viewController = self.getCurrentPanel()
		addChildViewController(viewController)
		self.panelContainerView.addSubview(viewController.view)
		viewController.view.snp.makeConstraints { make in
			make.top.left.right.bottom.equalToSuperview()
		}
		viewController.didMove(toParentViewController: self)

//		if let panelType = DashBoardPanelType(rawValue: sender.selectedSegmentIndex) {
//			currentPanel = panelType
//			self.switchToCurrentPanel()
//		}
	}

	@objc private func hideControlCenter() {
		NotificationCenter.default.post(name: HideControlCenterNotification, object: nil)
	}

	private func getCurrentPanel() -> UIViewController {
		switch panelSwitchControl.selectedSegmentIndex {
		case 0:
			self.overviewViewController.categories = self.trackersCategories
			return self.overviewViewController
		case 1:
			self.trackersViewController.trackers = trackersCategories
			return self.trackersViewController
		case 2:
			self.globalTrackersViewController.trackers = TrackerList.instance.apps.map { $0.1 }
			return self.globalTrackersViewController
		default:
			return UIViewController()
		}
		return UIViewController()
	}

	private func generateCategories() {
		for i in self.trackers {
//			var count = 1
			if let _ = self.trackersCategories[i.category] {
				 self.trackersCategories[i.category]?.append(i)
//				count = x + 1
			} else {
				self.trackersCategories[i.category] = [i]
			}
		}
		self.overviewViewController.categories = self.trackersCategories
	}

	private func updateBlockedTrackersCount() {
		let count = self.trackers.reduce(0) { (accumulator, value) -> Int in
			if value.isBlocked {
				return accumulator + 1
			}
			return accumulator
		}
		self.overviewViewController.blockedTrackersCount = count
	}
}

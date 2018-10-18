//
//  ControlCenterViewController.swift
//  Client
//
//  Created by Sahakyan on 4/17/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import RxSwift

let controlCenterDismissedNotification = Notification.Name(rawValue: "ControlCenterDismissed")

protocol ControlCenterViewControllerDelegate: class {
    func dismiss()
	func controlCenter(didSelectURLString url: String)
}

class ControlCenterViewController: UIViewController {

	var model: ControlCenterModel = ControlCenterModel()
    
    var privateMode: Bool = false
    
	weak var delegate: ControlCenterViewControllerDelegate? = nil

	private var topTranparentView = UIView()
	fileprivate var panelSwitchControl = UISegmentedControl(items: [])
	fileprivate var panelContainerView = UIView()

	private let disposeBag = DisposeBag()

	fileprivate lazy var overviewViewController: OverviewViewController = {
		let overview = OverviewViewController()
		return overview
	}()

	fileprivate lazy var trackersViewController: TrackersController = {
		let trackers = TrackersController()
		trackers.type = .page
		trackers.observable.asObserver().subscribe(onNext: { [weak self] value in
			self?.delegate?.controlCenter(didSelectURLString: value)
		}).disposed(by: self.disposeBag)
		return trackers
	}()

	fileprivate lazy var globalTrackersViewController: TrackersController = {
		let global = TrackersController()
		global.observable.asObserver().subscribe(onNext: { [weak self] value in
			self?.delegate?.controlCenter(didSelectURLString: value)
		}).disposed(by: self.disposeBag)
		global.type = .global
		return global
	}()

	var pageURL: String = "" {
		didSet {
			if !pageURL.isEmpty,
				let url = URL(string: pageURL) {
				self.model.url = url
				self.overviewViewController.pageURL = url.host ?? ""
			}
		}
	}
    
    var lastOrientation: DeviceOrientation
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        lastOrientation = UIDevice.current.getDeviceAndOrientation().1
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(notification:)), name: Notification.Name.DeviceOrientationChanged, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupComponents()
	}

    func setupComponents() {
		setupPanelSwitchControl()
		setupPanelContainer()
        self.panelSwitchControl.selectedSegmentIndex = 0
        self.switchPanel(self.panelSwitchControl)
	}

	func setupPanelContainer() {
		view.addSubview(panelContainerView)
		panelContainerView.backgroundColor = UIColor.white
		
		panelContainerView.snp.makeConstraints { make in
			make.top.equalTo(self.panelSwitchControl.snp.bottom).offset(5)
			make.left.right.equalTo(self.view)
			make.bottom.equalTo(self.view)
		}
	}

	private func setupPanelSwitchControl() {
		let overview = NSLocalizedString("Overview", tableName: "Cliqz", comment: "[ControlCenter] Overview panel title")
		let trackers = NSLocalizedString("Trackers", tableName: "Cliqz", comment: "[ControlCenter] Trackers panel title")
		let globalTrackers = NSLocalizedString("Global Trackers", tableName: "Cliqz", comment: "[ControlCenter] Global Trackers panel title")
		
		let items = [overview, trackers, globalTrackers]
		self.view.backgroundColor = UIColor.clear
		
		let bgView = UIView()
		bgView.backgroundColor = UIColor.CliqzURLBar.Background.color(isPBM: self.privateMode)
		panelSwitchControl = UISegmentedControl(items: items)
		panelSwitchControl.tintColor = UIColor.white
		panelSwitchControl.backgroundColor = UIColor.CliqzURLBar.Background.color(isPBM: self.privateMode)
		panelSwitchControl.addTarget(self, action: #selector(switchPanel), for: .valueChanged)
		bgView.addSubview(panelSwitchControl)
		self.view.addSubview(bgView)
		
		bgView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.right.equalToSuperview()
			make.height.equalTo(40)
		}
		panelSwitchControl.snp.makeConstraints { make in
			make.centerY.equalTo(bgView)
			make.left.equalTo(bgView).offset(10)
			make.right.equalTo(bgView).offset(-10)
		}
	}

	@objc func donePressed(_ button: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@objc private func switchPanel(_ sender: UISegmentedControl) {
		if let panel = childViewControllers.first {
			panel.willMove(toParentViewController: nil)
			panel.view.removeFromSuperview()
			panel.removeFromParentViewController()
		}

		let viewController = self.selectedPanel()
		addChildViewController(viewController)
		self.panelContainerView.addSubview(viewController.view)
		viewController.view.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		viewController.didMove(toParentViewController: self)
	}

	private func selectedPanel() -> UIViewController {
		switch panelSwitchControl.selectedSegmentIndex {
		case 0:
			self.overviewViewController.dataSource = self.model
			self.overviewViewController.delegate = self.model
			return self.overviewViewController
		case 1:
			self.trackersViewController.dataSource = self.model
			self.trackersViewController.delegate = self.model
			return self.trackersViewController
		case 2:
			self.globalTrackersViewController.dataSource = self.model
			self.globalTrackersViewController.delegate = self.model
			return self.globalTrackersViewController
		default:
			return UIViewController()
		}
	}
    
    @objc func orientationChanged(notification: Notification) {
        let orientation = UIDevice.current.getDeviceAndOrientation().1
        if orientation != lastOrientation {
            lastOrientation = orientation
            delegate?.dismiss()
        }
    }
}

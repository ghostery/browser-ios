//
//  OverviewViewController.swift
//  Client
//
//  Created by Sahakyan on 4/17/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import Charts

protocol BlockedRequestViewDelegate: class {
    func switchValueChanged(value: Bool)
	func viewIsDragging(value: Float)
	func viewStopDragging(value: Float)
}

class BlockedRequestsView: UIView {

	private var notchView = UIImageView()
	private var iconView = UIImageView()
	private var countView = UILabel()
	private var titleView = UILabel()
	private var switchControl = UISwitch()
	private var descriptionLabel = UILabel()

    weak var delegate: BlockedRequestViewDelegate? = nil

	var isSwitchOn: Bool? {
		set {
			switchControl.isOn = newValue ?? false
		}
		get {
			return switchControl.isOn
		}
	}

	var count: Int? {
		didSet {
			countView.text = "\(count ?? 0)"
		}
	}

	var title: String? {
		didSet {
			titleView.text = title
		}
	}

	var iconName: String? {
		set {
			if let name = newValue {
				self.iconView.image = UIImage(named: name)
			}
		}
		get {
			return nil
		}
	}

	init() {
		super.init(frame: CGRect.zero)
		self.addSubview(notchView)
		self.addSubview(iconView)
		self.addSubview(countView)
		self.addSubview(titleView)
		self.addSubview(descriptionLabel)
		self.addSubview(switchControl)
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
		notchView.addGestureRecognizer(gesture)
		notchView.isUserInteractionEnabled = true
		setStyles()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setStyles() {
		countView.textColor = UIColor.cliqzBluePrimary
		titleView.textColor = UIColor.cliqzBluePrimary
		switchControl.onTintColor = UIColor.cliqzBlueTwoSecondary
		switchControl.thumbTintColor = UIColor.cliqzURLBarColor
		switchControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
		notchView.image = UIImage(named:"notch")
		descriptionLabel.textColor = ControlCenterUI.textGray
		descriptionLabel.font = UIFont.systemFont(ofSize: 12)
		countView.isHidden = true
		descriptionLabel.text = ""
		descriptionLabel.textAlignment = .center
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.notchView.snp.remakeConstraints { (make) in
			make.top.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
		self.countView.snp.remakeConstraints { (make) in
			make.left.equalTo(self).offset(4)
			make.centerY.equalTo(self)
			make.height.equalTo(25)
		}
		self.titleView.snp.remakeConstraints { (make) in
			make.left.equalTo(self.countView.snp.right).offset(10)
			make.top.equalTo(self.notchView.snp.bottom)
			make.height.equalTo(25)
		}
		self.iconView.snp.remakeConstraints { (make) in
			make.top.equalTo(titleView.snp.bottom).offset(20)
			make.height.width.equalTo(30)
			make.centerX.equalToSuperview()
		}
		self.switchControl.snp.remakeConstraints { (make) in
			make.top.equalTo(self.notchView.snp.bottom)
			make.height.equalTo(25)
			make.right.equalTo(self).inset(10)
		}
		self.descriptionLabel.snp.remakeConstraints { (make) in
			make.top.equalTo(self.iconView.snp.bottom).offset(10)
			make.left.right.equalToSuperview()
		}
	}
    
    @objc func switchValueChanged(s: UISwitch) {
        s.isOn ? self.delegate?.switchValueChanged(value: true) : self.delegate?.switchValueChanged(value: false)
    }

	@objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
		if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
			let translation = gestureRecognizer.translation(in: self)
			self.delegate?.viewIsDragging(value: Float(translation.y))
		}
		if gestureRecognizer.state == UIGestureRecognizerState.ended {
			self.delegate?.viewStopDragging(value: Float(gestureRecognizer.velocity(in: self).y))
		}
		
	}
}

struct ControlCenterUX {
	static let adblockerViewMaxHeight: Float = 150
	static let adblockerViewInitialOffset: Float = -75
}

class OverviewViewController: UIViewController {
	private var chart: PieChartView!

	private var urlLabel: UILabel = UILabel()
	private var blockedTrackers = UILabel()

	private var trustSiteButton = UIButton(type: .custom)
	private var restrictSiteButton = UIButton(type: .custom)
	private var pauseGhosteryButton = UIButton(type: .custom)

	fileprivate var adBlockingView = BlockedRequestsView()

	weak var dataSource: ControlCenterDSProtocol? {
		didSet {
			updateData()
		}
	}
	weak var delegate: ControlCenterDelegateProtocol? {
		didSet {
			updateData()
		}
	}

	var categories = [String: [TrackerListApp]]() {
		didSet {
			self.updateData()
		}
	}

	var pageURL: String = "" {
		didSet {
			self.urlLabel.text = pageURL
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupComponents()
		self.setComponentsStyles()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.updateData()
	}

	private func updateData() {
        guard let datasource = self.dataSource else { return }
        
		self.urlLabel.text = datasource.domainString()
        
        updateChart()
        updateBlockedTrackersCount()
        
		let domainState = datasource.domainState()
		if domainState == .trusted {
			setTrustSite(true)
		} else if domainState == .restricted {
			setRestrictSite(true)
		}
        else {
            setSiteToNone()
        }
		setPauseGhostery(datasource.isGhosteryPaused())
	}

	private func setupComponents() {
		self.setupPieChart()
        
        self.view.addSubview(chart)
        self.view.addSubview(urlLabel)
        self.view.addSubview(blockedTrackers)
        self.view.addSubview(trustSiteButton)
        self.view.addSubview(restrictSiteButton)
        self.view.addSubview(pauseGhosteryButton)
        self.view.addSubview(adBlockingView)
        
        let (device,orientation) = UIDevice.current.getDeviceAndOrientation()
        
        if (orientation == .portrait && device != .iPad) || device == .iPad {
            chart.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(200)
            }
            
            self.urlLabel.snp.makeConstraints { (make) in
                make.left.right.equalTo(self.view).inset(7)
                make.top.equalTo(chart.snp.bottom).offset(10)
                make.height.equalTo(30)
            }
            
            self.blockedTrackers.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.top.equalTo(self.urlLabel.snp.bottom)
                make.height.equalTo(30)
            }
            
            self.trustSiteButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.top.equalTo(self.blockedTrackers.snp.bottom).offset(15)
                make.height.equalTo(30)
                make.width.equalTo(213)
            }
            
            self.restrictSiteButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.top.equalTo(self.trustSiteButton.snp.bottom).offset(10)
                make.height.equalTo(30)
                make.width.equalTo(213)
            }
            
            self.pauseGhosteryButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.top.equalTo(self.restrictSiteButton.snp.bottom).offset(10)
                make.height.equalTo(30)
                make.width.equalTo(213)
            }
            
            self.adBlockingView.snp.makeConstraints { (make) in
                make.left.right.equalTo(self.view)
                make.top.equalTo(self.view.snp.bottom).offset(-75)
                make.height.equalTo(150)
            }
        }
        else {
            
            let blockedTrackersOffset: CGFloat = 10.0
            let adblockingViewOffset: CGFloat = 75.0
            
            chart.snp.makeConstraints { (make) in
                let inset = self.blockedTrackers.intrinsicContentSize.height + self.urlLabel.intrinsicContentSize.height + blockedTrackersOffset + adblockingViewOffset
                make.top.equalToSuperview()
                make.height.equalToSuperview().offset(-inset)
                make.left.equalToSuperview()
                make.width.equalToSuperview().dividedBy(2)
            }
            
            self.urlLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.view).inset(7)
                make.right.equalToSuperview().dividedBy(2)
                make.top.equalTo(chart.snp.bottom).offset(2)
            }
            
            self.blockedTrackers.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.urlLabel.snp.centerX)
                make.top.equalTo(self.urlLabel.snp.bottom).offset(blockedTrackersOffset)
            }
            
            self.trustSiteButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view).multipliedBy(1.5)
                make.top.equalToSuperview().offset(36)
                make.height.equalTo(30)
                make.width.equalTo(self.view.snp.width).dividedBy(2.3)
            }
            
            self.restrictSiteButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view).multipliedBy(1.5)
                make.top.equalTo(self.trustSiteButton.snp.bottom).offset(10)
                make.height.equalTo(30)
                make.width.equalTo(self.view.snp.width).dividedBy(2.3)
            }
            
            self.pauseGhosteryButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view).multipliedBy(1.5)
                make.top.equalTo(self.restrictSiteButton.snp.bottom).offset(10)
                make.height.equalTo(30)
                make.width.equalTo(self.view.snp.width).dividedBy(2.3)
            }
            
            self.adBlockingView.snp.makeConstraints { (make) in
                make.left.right.equalTo(self.view)
                make.top.equalTo(self.view.snp.bottom).offset(-adblockingViewOffset)
                make.height.equalTo(150)
            }
        }
        
		let trustTitle = NSLocalizedString("Trust Site", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Trust button title")
		self.trustSiteButton.setTitle(trustTitle, for: .normal)
		self.trustSiteButton.addTarget(self, action: #selector(trustSitePressed), for: .touchUpInside)

		let restrictTitle = NSLocalizedString("Restrict Site", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Restrict button title")
		self.restrictSiteButton.setTitle(restrictTitle, for: .normal)
		self.restrictSiteButton.addTarget(self, action: #selector(restrictSitePressed), for: .touchUpInside)

		let pauseGhostery = NSLocalizedString("Pause Ghostery", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Pause Ghostery button title")
		self.pauseGhosteryButton.setTitle(pauseGhostery, for: .normal)
        self.pauseGhosteryButton.addTarget(self, action: #selector(pauseGhosteryPressed), for: .touchUpInside)
        self.pauseGhosteryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)

		// TODO: Count should be from DataSource
        self.adBlockingView.delegate = self
		self.adBlockingView.count = 0
		self.adBlockingView.title = NSLocalizedString("Enhanced Ad Blocking", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Ad blocking switch title")
		self.adBlockingView.isSwitchOn = self.dataSource?.isGlobalAdblockerOn()
		self.adBlockingView.iconName = "adblocking"
		self.adBlockingView.backgroundColor = UIColor.white
	}

	private func setComponentsStyles() {
		chart.backgroundColor = NSUIColor.clear

		self.urlLabel.font = UIFont.systemFont(ofSize: 13)
		self.urlLabel.textAlignment = .center

		self.blockedTrackers.font = UIFont.systemFont(ofSize: 20)

		self.trustSiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		self.trustSiteButton.titleLabel?.textColor = UIColor(colorString: "4A4A4A")
		self.trustSiteButton.backgroundColor = UIColor.white
		self.trustSiteButton.layer.borderColor = UIColor.gray.cgColor
		self.trustSiteButton.layer.borderWidth = 1
		self.trustSiteButton.layer.cornerRadius = 3
		self.trustSiteButton.setTitleColor(UIColor.white, for: .selected)
		self.trustSiteButton.setTitleColor(UIColor.gray, for: .normal)
		self.trustSiteButton.setImage(UIImage(named: "trust"), for: .normal)
		self.trustSiteButton.setImage(UIImage(named: "trustAction"), for: .selected)
		self.trustSiteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
		self.trustSiteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);

		self.restrictSiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		self.restrictSiteButton.backgroundColor = UIColor.white
		self.restrictSiteButton.layer.borderColor = UIColor.gray.cgColor
		self.restrictSiteButton.layer.borderWidth = 1
		self.restrictSiteButton.layer.cornerRadius = 3
		self.restrictSiteButton.setTitleColor(UIColor.gray, for: .normal)
		self.restrictSiteButton.setTitleColor(UIColor.white, for: .selected)
		self.restrictSiteButton.setImage(UIImage(named: "restrict"), for: .normal)
		self.restrictSiteButton.setImage(UIImage(named: "restrictAction"), for: .selected)
		self.restrictSiteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
		self.restrictSiteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);

		self.pauseGhosteryButton.backgroundColor = UIColor.white
		self.pauseGhosteryButton.layer.borderColor = UIColor.gray.cgColor
		self.pauseGhosteryButton.layer.borderWidth = 1
		self.pauseGhosteryButton.layer.cornerRadius = 3
		self.pauseGhosteryButton.setTitleColor(UIColor.gray, for: .normal)
		self.pauseGhosteryButton.setTitleColor(UIColor.white, for: .selected)
		self.pauseGhosteryButton.setImage(UIImage(named: "ghosteryPause"), for: .normal)
		self.pauseGhosteryButton.setImage(UIImage(named: "ghosteryPlay"), for: .selected)
		self.pauseGhosteryButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
		self.pauseGhosteryButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
	}
    
    private func showPauseActionSheet() {
        func pause(_ time: Date) {
            self.delegate?.pauseGhostery(paused: true, time: time)
            self.setPauseGhostery(!self.pauseGhosteryButton.isSelected)
        }
        
        let pauseAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let thirty = UIAlertAction(title: NSLocalizedString("30 minutes", tableName: "Cliqz", comment: "[ControlCenter - Overview] Pause Ghostery for thirty minutes title"), style: .default, handler: { (alert: UIAlertAction) -> Void in
            let time = Date(timeIntervalSinceNow: 30 * 60)
            pause(time)
        })
        pauseAlertController.addAction(thirty)
        
        let onehour = UIAlertAction(title: NSLocalizedString("1 hour", tableName: "Cliqz", comment: "[ControlCenter - Overview] Pause Ghostery for one hour title"), style: .default, handler: { (alert: UIAlertAction) -> Void in
            let time = Date(timeIntervalSinceNow: 60 * 60)
            pause(time)
        })
        pauseAlertController.addAction(onehour)
        
        let twentyfour = UIAlertAction(title: NSLocalizedString("24 hours", tableName: "Cliqz", comment: "[ControlCenter - Overview] Pause Ghostery for twentyfour hours title"), style: .default, handler: { (alert: UIAlertAction) -> Void in
            let time = Date(timeIntervalSinceNow: 24 * 60 * 60)
            pause(time)
        })
        pauseAlertController.addAction(twentyfour)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Cancel action title"), style: .cancel)
        pauseAlertController.addAction(cancelAction)
        
        if let popover = pauseAlertController.popoverPresentationController {
            popover.sourceView = pauseGhosteryButton
            popover.permittedArrowDirections = .down
            popover.sourceRect = CGRect(x: pauseGhosteryButton.bounds.width/2, y: 0, width: 0, height: 0)
        }
        
        self.present(pauseAlertController, animated: true, completion: nil)
    }
    
    @objc private func pauseGhosteryPressed() {
        if self.pauseGhosteryButton.isSelected { //already paused
            //resume
            self.delegate?.pauseGhostery(paused: false, time: Date())
            self.setPauseGhostery(!self.pauseGhosteryButton.isSelected)
        }
        else {
            //pause
            showPauseActionSheet()
        }
    }

	@objc private func trustSitePressed() {
		setTrustSite(!self.trustSiteButton.isSelected)
        self.trustSiteButton.isSelected ? self.delegate?.chageSiteState(to: .trusted) : self.delegate?.chageSiteState(to: .empty)
        updateBlockedTrackersCount()
	}

	@objc private func restrictSitePressed() {
		setRestrictSite(!self.restrictSiteButton.isSelected)
        self.restrictSiteButton.isSelected ? self.delegate?.chageSiteState(to: .restricted) : self.delegate?.chageSiteState(to: .empty)
        updateBlockedTrackersCount()
	}
    
    private func setPauseGhostery(_ value: Bool) {
        self.pauseGhosteryButton.isSelected = value
        updatePauseGhosteryUI()
        updateBlockedTrackersCount()
        updateChart()
    }
    
    private func setTrustSite(_ value: Bool) {
        self.trustSiteButton.isSelected = value
        self.restrictSiteButton.isSelected = false
        updateTrustSiteUI()
        updateRestrictSiteUI()
    }
    
    private func setRestrictSite(_ value: Bool) {
        self.restrictSiteButton.isSelected = value
        self.trustSiteButton.isSelected = false
        updateTrustSiteUI()
        updateRestrictSiteUI()
    }
    
    private func setSiteToNone() {
        self.trustSiteButton.isSelected = false
        self.restrictSiteButton.isSelected = false
        updateTrustSiteUI()
        updateRestrictSiteUI()
    }
    
    private func updatePauseGhosteryUI() {
        if self.pauseGhosteryButton.isSelected {
            self.pauseGhosteryButton.setTitle(NSLocalizedString("Resume", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Resume Ghostery button title"), for: .normal)
            self.pauseGhosteryButton.backgroundColor = UIColor.cliqzBluePrimary
        }
        else {
            self.pauseGhosteryButton.setTitle(NSLocalizedString("Pause Ghostery", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Pause Ghostery button title"), for: .normal)
            self.pauseGhosteryButton.backgroundColor = UIColor.white
        }
    }
    
    private func updateTrustSiteUI() {
        if self.trustSiteButton.isSelected {
            self.trustSiteButton.backgroundColor = UIColor.cliqzGreenLightFunctional
        } else {
            self.trustSiteButton.backgroundColor = UIColor.white
        }
    }
    
    private func updateRestrictSiteUI() {
        if self.restrictSiteButton.isSelected {
            self.restrictSiteButton.backgroundColor = UIColor(colorString: "BE4948")
        } else {
            self.restrictSiteButton.backgroundColor = UIColor.white
        }
    }
    
    private func updateBlockedTrackersCount() {
        blockedTrackers.text = String(format: NSLocalizedString("%d Trackers Blocked", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Blocked trackers count"), self.dataSource?.blockedTrackerCount() ?? 0)
    }
    
    private func updateChart() {
        guard let datasource = self.dataSource else { return }
        let countsAndColors = datasource.countAndColorByCategory()
        var values: [PieChartDataEntry] = []
        var colors: [UIColor] = []
        for key in countsAndColors.keys {
            if let touple = countsAndColors[key] {
                values.append(PieChartDataEntry(value: Double(touple.0), label: ""))
                colors.append(touple.1)
            }
        }
        let dataSet = PieChartDataSet(values: values, label: "")
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: 20.0)
        dataSet.colors = colors
        chart?.data = PieChartData(dataSet: dataSet)
        chart?.centerText = String(format: NSLocalizedString("%d Trackers found", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Detected trackers count"), self.dataSource?.detectedTrackerCount() ?? 0)
    }

	private func setupPieChart() {
		chart = PieChartView()
		chart.chartDescription?.text = ""
		chart.legend.enabled = false
		chart.holeRadiusPercent = 0.8
	}
}

extension OverviewViewController: BlockedRequestViewDelegate {

    func switchValueChanged(value: Bool) {
        self.delegate?.turnGlobalAdblocking(on: value)
    }

	func viewIsDragging(value: Float) {
		self.adBlockingView.snp.updateConstraints { (make) in
			if value + ControlCenterUX.adblockerViewInitialOffset < -ControlCenterUX.adblockerViewMaxHeight {
				make.top.equalTo(self.view.snp.bottom).offset(-ControlCenterUX.adblockerViewMaxHeight)
			} else {
				make.top.equalTo(self.view.snp.bottom).offset(value + ControlCenterUX.adblockerViewInitialOffset)
			}
		}
	}

	func viewStopDragging(value: Float) {
		if value > 0 {
			self.adBlockingView.snp.updateConstraints { (make) in
				make.top.equalTo(self.view.snp.bottom).offset(ControlCenterUX.adblockerViewInitialOffset)
			}
		} else {
			self.adBlockingView.snp.updateConstraints { (make) in
				make.top.equalTo(self.view.snp.bottom).offset(-ControlCenterUX.adblockerViewMaxHeight)
			}
		}
	}
}

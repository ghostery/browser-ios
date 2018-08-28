//
//  OverviewViewController.swift
//  Client
//
//  Created by Sahakyan on 4/17/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import Charts

protocol NotchViewDelegate: class {
    func switchValueChanged(value: Bool)
	func viewIsDragging(translation: Float, velocity: Float)
	func viewStopDragging(velocity: Float)
    func domainOnEnhancedViewPressed()
    func allWebsitesOnEnhancedViewPressed()
}

protocol TickButtonProtocol: class {
    func didSelect(button: TickButton, isSelected: Bool)
}

class TickButton: UIButton {
    let topSep = UIView()
    let bottomSep = UIView()
    let tickView = UIImageView()
    
    let customGray = UIColor.init(red: 0.91, green: 0.91, blue: 0.91, alpha: 0.91)
    
    weak var delegate: TickButtonProtocol? = nil
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                tickView.isHidden = false
                delegate?.didSelect(button: self, isSelected: true)
            }
            else {
                tickView.isHidden = true
                delegate?.didSelect(button: self, isSelected: false)
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted == true {
                UIView.animate(withDuration: 0.1) { [unowned self] in
                    self.backgroundColor = self.customGray
                }
            }
            else {
                UIView.animate(withDuration: 0.2) { [unowned self] in
                    self.backgroundColor = .white
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentHorizontalAlignment = .left
        self.addSubview(topSep)
        self.addSubview(bottomSep)
        self.addSubview(tickView)
        
        setConstraints()
        setStyles()
        
        tickView.image = UIImage(named: "checkmark")
        tickView.isHidden = true
    }
    
    func setConstraints() {
        topSep.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        bottomSep.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        tickView.snp.makeConstraints { (make) in
            make.width.equalTo(19.5)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    func setStyles() {
        tickView.backgroundColor = .clear
        topSep.backgroundColor = customGray
        bottomSep.backgroundColor = customGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TickButtonSubtitle: TickButton {
    let label = UILabel()
    let subtitleLabel = UILabel()
    
    override func setConstraints() {
        topSep.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        bottomSep.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        tickView.snp.makeConstraints { (make) in
            make.width.equalTo(19.5)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
        label.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(tickView.snp.leading)
            make.bottom.equalTo(self.snp.bottom).dividedBy(2)
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(tickView.snp.leading)
            make.top.equalTo(label.snp.bottom)
        }
    }
}

protocol EnhancedAdblockerViewProtocol: class {
    func domainPressed()
    func allWebsitesPressed()
}

class EnhancedAdblockerView: UIView {
    let label = UILabel()
    let domainButton = TickButton()
    let allWebsitesButton = TickButton()
    
    let labelContainer = UIView()
    let buttonContainer = UIView()
    
    weak var delegate: EnhancedAdblockerViewProtocol? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(labelContainer)
        self.addSubview(buttonContainer)
        labelContainer.addSubview(label)
        buttonContainer.addSubview(domainButton)
        buttonContainer.addSubview(allWebsitesButton)
        
        let domainButtonString = NSLocalizedString("This Domain", tableName: "Cliqz", comment:"[Enhanced Adblocker] Domains Button Title")
        let allWebsitesButtonString = NSLocalizedString("All Websites", tableName: "Cliqz", comment:"[Enhanced Adblocker] Domains Button Title")
        
        domainButton.setTitle(domainButtonString, for: .normal)
        allWebsitesButton.setTitle(allWebsitesButtonString, for: .normal)
        
        setContraints()
        setStyles()
        
        domainButton.addTarget(self, action: #selector(domainPressed), for: .touchUpInside)
        allWebsitesButton.addTarget(self, action: #selector(allWebsitesPressed), for: .touchUpInside)
        
        domainButton.tag = 1
        allWebsitesButton.tag = 2
        
        domainButton.delegate = self
        allWebsitesButton.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContraints() {
        
        labelContainer.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(4)
        }
        
        buttonContainer.snp.makeConstraints { (make) in
            make.top.equalTo(labelContainer.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        
        label.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }

        domainButton.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3)
        }

        allWebsitesButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(domainButton.snp.bottom)
            make.height.equalToSuperview().dividedBy(3)
        }
    }
    
    func setStyles() {
        self.backgroundColor = .white
        labelContainer.backgroundColor = .clear
        buttonContainer.backgroundColor = .clear
        label.backgroundColor = .white
        domainButton.backgroundColor = .white
        allWebsitesButton.backgroundColor = .white
        
        domainButton.setTitleColor(.black, for: .normal)
        allWebsitesButton.setTitleColor(.black, for: .normal)
        
        label.textColor = UIColor.cliqzGrayFunctional
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        
        //hide one of the separators
        allWebsitesButton.topSep.isHidden = true
        
        domainButton.titleEdgeInsets.left = 16
        allWebsitesButton.titleEdgeInsets.left = 16
    }
    
    @objc func domainPressed(sender: UIButton) {
        domainButton.isSelected = true
        self.delegate?.domainPressed()
    }
    
    @objc func allWebsitesPressed(sender: UIButton) {
        allWebsitesButton.isSelected = true
        self.delegate?.allWebsitesPressed()
    }
    
}

extension EnhancedAdblockerView: TickButtonProtocol {
    func didSelect(button: TickButton, isSelected: Bool) {
        if button.tag == 1 { // domains
            if isSelected {
                allWebsitesButton.isSelected = false
                label.text = NSLocalizedString("Enhanced Adblocking is turned off for this domain.", tableName: "Cliqz", comment:"[Enhanced Adblocker] Domain Label Title")
            }
        }
        else if button.tag == 2 { // all websites
            if isSelected {
                domainButton.isSelected = false
                label.text = NSLocalizedString("Enhanced Adblocking is turned off for all websites.", tableName: "Cliqz", comment:"[Enhanced Adblocker] All Websites Label Title")
            }
        }
    }
}

class NotchView: UIView {
    
	private let notchView = UIImageView()
	private let iconView = UIImageView()
	private let countLabel = UILabel()
	private let titleLabel = UILabel()
	private let switchControl = UISwitch()
	private let descriptionLabel = UILabel()
    private let container = UIView()
    private let enhancedView = EnhancedAdblockerView()

    weak var delegate: NotchViewDelegate? = nil
    
    var isSwitchEnabled: Bool? {
        set {
            DispatchQueue.main.async { [weak self] in
                self?.switchControl.isEnabled = newValue ?? false
                if newValue == true {
                    self?.titleLabel.textColor = UIColor.cliqzBluePrimary
                }
                else if newValue == false {
                    self?.titleLabel.textColor = UIColor.cliqzGrayFunctional
                }
            }
        }
        get {
            return switchControl.isEnabled
        }
    }

	var isSwitchOn: Bool? {
        set {
            //DispatchQueue.main.async { [weak self] in
                self.switchControl.isOn = newValue ?? false
            //}
        }
		get {
			return switchControl.isOn
		}
	}

	var count: Int? {
		didSet {
			// Disabled for now, fixed text will be shown till we have a solution for the count
//			countLabel.text = "\(count ?? 0)"
		}
	}

	var title: String? {
		didSet {
			titleLabel.text = title
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
        self.addSubview(container)
		container.addSubview(iconView)
		container.addSubview(countLabel)
		container.addSubview(titleLabel)
		container.addSubview(descriptionLabel)
		container.addSubview(switchControl)
        container.addSubview(enhancedView)
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
		self.addGestureRecognizer(gesture)
		self.isUserInteractionEnabled = true
		setStyles()
        
        enhancedView.delegate = self
	}
    
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setStyles() {
        self.backgroundColor = .clear
        container.backgroundColor = .white
		titleLabel.textColor = UIColor.cliqzBluePrimary
		titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
		switchControl.onTintColor = UIColor.cliqzBluePrimary
		switchControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
		notchView.image = UIImage(named:"notch")
        notchView.backgroundColor = .clear
		descriptionLabel.textColor = UIColor.cliqzGrayFunctional
		descriptionLabel.font = UIFont.systemFont(ofSize: 12)
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = NSLocalizedString("Enhanced Ad Blocking anonymizes unblocked and unknown trackers for greater browsing protection.", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Ad Blocking description")
		descriptionLabel.textAlignment = .left
		countLabel.textColor = UIColor.cliqzBluePrimary
		countLabel.text = NSLocalizedString("Ads Removed", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Removed Ads indicator")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
        let (_ , orientation) = UIDevice.current.getDeviceAndOrientation()
        
        if orientation == .portrait {
            self.notchView.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(30)
            }
            self.container.snp.makeConstraints { (make) in
                make.top.equalTo(self.notchView.snp.bottom)
                make.trailing.leading.bottom.equalToSuperview()
            }
            self.titleLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(20)
                make.top.equalToSuperview()
                make.height.equalTo(25)
            }
            self.iconView.snp.remakeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
            }
            self.countLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(self.iconView.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.height.equalTo(25)
            }
            self.switchControl.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.height.equalTo(25)
                make.right.equalToSuperview().inset(10)
            }
            self.descriptionLabel.snp.remakeConstraints { (make) in
                make.bottom.equalToSuperview().inset(25)
                make.left.right.equalToSuperview().inset(20)
            }
        }
        else {
            self.notchView.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(30)
            }
            self.container.snp.makeConstraints { (make) in
                make.top.equalTo(self.notchView.snp.bottom)
                make.trailing.leading.bottom.equalToSuperview()
            }
            self.titleLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(20)
                make.top.equalToSuperview()
                make.height.equalTo(25)
            }
            self.iconView.snp.remakeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.size.equalTo(44.0)
            }
            self.countLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(self.iconView.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.height.equalTo(25)
            }
            self.switchControl.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.height.equalTo(25)
                make.right.equalToSuperview().inset(10)
            }
            self.descriptionLabel.snp.remakeConstraints { (make) in
                make.bottom.equalToSuperview().inset(25)
                make.left.right.equalToSuperview().inset(20)
            }
        }
        
        self.enhancedView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
	}

    @objc func switchValueChanged(s: UISwitch) {
        updateViewStyle()
        self.delegate?.switchValueChanged(value: s.isOn)
    }

	@objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
		if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
			let translation = gestureRecognizer.translation(in: self)
			self.delegate?.viewIsDragging(translation: Float(translation.y), velocity: Float(gestureRecognizer.velocity(in: self).y))
		}
		if gestureRecognizer.state == UIGestureRecognizerState.ended {
			self.delegate?.viewStopDragging(velocity: Float(gestureRecognizer.velocity(in: self).y))
		}
        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
	}

    func updateViewStyle() {
        if switchControl.isOn {
            enhancedView.isHidden = true
            iconView.tintColor = UIColor.cliqzBluePrimary
            countLabel.textColor = UIColor.cliqzBluePrimary
        } else {
            iconView.tintColor = UIColor.gray
            countLabel.textColor = UIColor.gray
            
            if switchControl.isEnabled == true {
                enhancedView.isHidden = false
                if UserPreferences.instance.adblockingMode == .blockNone {
                    //select second option - allwebsites
                    enhancedView.allWebsitesButton.isSelected = true
                }
                else {
                    enhancedView.domainButton.isSelected = true
                }
            }
        }
        
        self.layoutIfNeeded()
	}

}

extension NotchView: EnhancedAdblockerViewProtocol {
    func domainPressed() {
        self.delegate?.domainOnEnhancedViewPressed()
    }
    
    func allWebsitesPressed() {
        self.delegate?.allWebsitesOnEnhancedViewPressed()
    }
}

struct ControlCenterUX {
    static var adblockerViewMaxHeight: Float {
        let (_, orientation) = UIDevice.current.getDeviceAndOrientation()
        if orientation == .portrait {
            return 280
        }
        else {
            return 220
        }
    }
    static var adblockerViewInitialOffset: Float {
        let (_, orientation) = UIDevice.current.getDeviceAndOrientation()
        if orientation == .portrait {
            return -85
        }
        else {
            return -75
        }
    }
}

class OverviewViewController: UIViewController {
	private var chart: PieChartView!

	private var urlLabel: UILabel = UILabel()
	private var blockedTrackers = UILabel()

	private var trustSiteButton = UIButton(type: .custom)
	private var restrictSiteButton = UIButton(type: .custom)
	private var pauseGhosteryButton = UIButton(type: .custom)

	fileprivate var adBlockingView = NotchView()

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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupComponents()
		self.setComponentsStyles()
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: detectedTrackerNotification, object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.updateData()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adBlockingView.snp.updateConstraints { [unowned self] (make) in
            make.top.equalTo(self.view.frame.height + CGFloat(ControlCenterUX.adblockerViewInitialOffset))
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

	@objc private func updateData() {
        guard let datasource = self.dataSource else { return }
	
		self.urlLabel.text = datasource.domainString()
        
        updateChart()
        updateBlockedTrackersCount()
        
		let domainState = datasource.domainState()
		if domainState == .trusted, datasource.isGhosteryPaused() == false {
			setTrustSite(true)
		} else if domainState == .restricted, datasource.isGhosteryPaused() == false {
			setRestrictSite(true)
		}
        else {
            setSiteToNone()
        }
		setPauseGhostery(datasource.isGhosteryPaused())
        self.adBlockingView.isSwitchEnabled = datasource.isGhosteryPaused() ? false : true
        self.adBlockingView.isSwitchOn = self.dataSource?.isAdblockerOn()
        self.adBlockingView.updateViewStyle()
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
                make.left.right.equalToSuperview()
				if UIDevice.current.isSmallIphoneDevice() {
					make.top.equalToSuperview()
					make.height.equalTo(160)
				} else {
					make.top.equalToSuperview().offset(5)
					make.height.equalTo(220)
				}
            }
            
            self.urlLabel.snp.makeConstraints { (make) in
				make.left.right.equalTo(self.view).inset(7)
				make.top.equalTo(chart.snp.bottom)
                make.height.equalTo(17)
            }
            
            self.blockedTrackers.snp.makeConstraints { (make) in
				make.top.equalTo(self.urlLabel.snp.bottom)
				make.width.equalTo(self.view.snp.width).offset(20)
                make.centerX.equalToSuperview()
                make.height.equalTo(50)
            }

            self.trustSiteButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
				make.bottom.equalTo(self.restrictSiteButton.snp.top).offset(-12)
                make.height.equalTo(40)
                make.width.equalTo(213)
            }

            self.restrictSiteButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
				if UIDevice.current.isSmallIphoneDevice() {
					make.bottom.equalTo(self.pauseGhosteryButton.snp.top).offset(-20)
				} else {
					make.bottom.equalTo(self.pauseGhosteryButton.snp.top).offset(-30)
				}
                make.height.equalTo(40)
                make.width.equalTo(213)
            }
            
            self.pauseGhosteryButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
				make.bottom.equalToSuperview().offset(ControlCenterUX.adblockerViewInitialOffset)
                make.height.equalTo(40)
                make.width.equalTo(213)
            }
            
            self.adBlockingView.snp.makeConstraints { [unowned self] (make) in
                //make.left.right.equalTo(self.view)
				//make.top.equalTo(self.view.snp.bottom).offset(ControlCenterUX.adblockerViewInitialOffset)
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(ControlCenterUX.adblockerViewMaxHeight)
                make.top.equalTo(self.view.frame.height + CGFloat(ControlCenterUX.adblockerViewInitialOffset))
            }
        } else {
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
				make.width.equalTo(self.urlLabel.snp.width)
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
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(ControlCenterUX.adblockerViewMaxHeight)
                make.top.equalTo(self.view.frame.height + CGFloat(ControlCenterUX.adblockerViewInitialOffset))
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
        self.pauseGhosteryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)

		// TODO: Count should be from DataSource
        self.adBlockingView.delegate = self
		self.adBlockingView.count = 0
		self.adBlockingView.title = NSLocalizedString("Enhanced Ad Blocking", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Ad blocking switch title")
		self.adBlockingView.isSwitchOn = self.dataSource?.isAdblockerOn()
		self.adBlockingView.iconName = "adblocking"
        self.adBlockingView.updateViewStyle()
	}

	private func setComponentsStyles() {
		chart.backgroundColor = NSUIColor.clear

		self.urlLabel.font = UIFont.systemFont(ofSize: 13)
		self.urlLabel.textAlignment = .center

		self.blockedTrackers.font = UIFont.systemFont(ofSize: 20)
		self.blockedTrackers.numberOfLines = 2
		self.blockedTrackers.lineBreakMode = .byWordWrapping
		self.blockedTrackers.adjustsFontSizeToFitWidth = true
		self.blockedTrackers.textAlignment = .center
		self.trustSiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
		self.trustSiteButton.backgroundColor = UIColor.white
		self.trustSiteButton.layer.borderColor = ControlCenterUI.buttonGray.cgColor
		self.trustSiteButton.layer.borderWidth = 1
		self.trustSiteButton.layer.cornerRadius = 3
		self.trustSiteButton.setTitleColor(UIColor.white, for: .selected)
		self.trustSiteButton.setTitleColor(ControlCenterUI.buttonGray, for: .normal)
		self.trustSiteButton.setImage(UIImage(named: "trust"), for: .normal)
		self.trustSiteButton.setImage(UIImage(named: "trustAction"), for: .selected)
		self.trustSiteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
		self.trustSiteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);

		self.restrictSiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
		self.restrictSiteButton.backgroundColor = UIColor.white
		self.restrictSiteButton.layer.borderColor = ControlCenterUI.buttonGray.cgColor
		self.restrictSiteButton.layer.borderWidth = 1
		self.restrictSiteButton.layer.cornerRadius = 3
		self.restrictSiteButton.setTitleColor(ControlCenterUI.buttonGray, for: .normal)
		self.restrictSiteButton.setTitleColor(UIColor.white, for: .selected)
		self.restrictSiteButton.setImage(UIImage(named: "restrict"), for: .normal)
		self.restrictSiteButton.setImage(UIImage(named: "restrictAction"), for: .selected)
		self.restrictSiteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
		self.restrictSiteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);

		self.pauseGhosteryButton.backgroundColor = UIColor.white
		self.pauseGhosteryButton.layer.borderColor = ControlCenterUI.buttonGray.cgColor
		self.pauseGhosteryButton.layer.borderWidth = 1
		self.pauseGhosteryButton.layer.cornerRadius = 3
		self.pauseGhosteryButton.setTitleColor(ControlCenterUI.buttonGray, for: .normal)
		self.pauseGhosteryButton.setTitleColor(UIColor.white, for: .selected)
		self.pauseGhosteryButton.setImage(UIImage(named: "ghosteryPause"), for: .normal)
		self.pauseGhosteryButton.setImage(UIImage(named: "ghosteryPlay"), for: .selected)
		self.pauseGhosteryButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
		self.pauseGhosteryButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
	}
    
    @objc private func pauseGhosteryPressed(_ button: UIButton) {
        if self.pauseGhosteryButton.isSelected { //already paused
            //resume
            self.delegate?.pauseGhostery(paused: false, time: Date())
            if UserPreferences.instance.prevAdblockingMode == .blockAll {
                self.delegate?.turnGlobalAdblocking(on: true)
            }
            self.updateData()
            TelemetryHelper.sendControlCenterResumeClick()
        }
        else {
            //pause
            showPauseActionSheet()
        }
    }

	@objc private func trustSitePressed() {
        if !self.trustSiteButton.isSelected {
            if self.dataSource?.domainState() == .restricted {
                self.delegate?.undoAll(tableType: .page, completion: {
                    self.delegate?.changeAll(state: .trusted, tableType: .page, completion: { [weak self] in
                        self?.pauseGhosteryAndRefresh(paused: false)
                    })
                })
            }
            else {
                self.delegate?.changeAll(state: .trusted, tableType: .page, completion: { [weak self] in
                    self?.pauseGhosteryAndRefresh(paused: false)
                })
            }
        }
        else {
			if (self.dataSource?.domainPrevState() ?? .empty) == .restricted {
				self.delegate?.changeAll(state: .empty, tableType: .page, completion: { [weak self] in
					self?.pauseGhosteryAndRefresh(paused: false)
				})
			} else {
				self.delegate?.undoAll(tableType: .page, completion: { [weak self] in
					self?.pauseGhosteryAndRefresh(paused: false)
				})
			}
        }
	}

	@objc private func restrictSitePressed() {
        if !self.restrictSiteButton.isSelected {
            if self.dataSource?.domainState() == .trusted {
                self.delegate?.undoAll(tableType: .page, completion: {
                    self.delegate?.changeAll(state: .restricted, tableType: .page, completion: { [weak self] in
                        self?.pauseGhosteryAndRefresh(paused: false)
                    })
                })
            }
            else {
                self.delegate?.changeAll(state: .restricted, tableType: .page, completion: { [weak self] in
                    self?.pauseGhosteryAndRefresh(paused: false)
                })
            }
        } else {
			if (self.dataSource?.domainPrevState() ?? .empty) == .trusted {
				self.delegate?.changeAll(state: .empty, tableType: .page, completion: { [weak self] in
					self?.pauseGhosteryAndRefresh(paused: false)
				})
			} else {
				self.delegate?.undoAll(tableType: .page, completion: { [weak self] in
					self?.pauseGhosteryAndRefresh(paused: false)
				})
			}
        }
	}
    
    private func pauseGhosteryAndRefresh(paused: Bool) {
        self.delegate?.pauseGhostery(paused: paused, time: Date())
        self.updateData()
        TelemetryHelper.sendControlCenterRestrictClick()
    }
    
    private func showPauseActionSheet() {
        
        let pauseAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let thirty = UIAlertAction(title: NSLocalizedString("30 minutes", tableName: "Cliqz", comment: "[ControlCenter - Overview] Pause Ghostery for thirty minutes title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
            let time = Date(timeIntervalSinceNow: 30 * 60)
            self?.pauseGhostery(time)
        })
        pauseAlertController.addAction(thirty)
        
        let onehour = UIAlertAction(title: NSLocalizedString("1 hour", tableName: "Cliqz", comment: "[ControlCenter - Overview] Pause Ghostery for one hour title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
            let time = Date(timeIntervalSinceNow: 60 * 60)
            self?.pauseGhostery(time)
        })
        pauseAlertController.addAction(onehour)
        
        let twentyfour = UIAlertAction(title: NSLocalizedString("24 hours", tableName: "Cliqz", comment: "[ControlCenter - Overview] Pause Ghostery for twentyfour hours title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
            let time = Date(timeIntervalSinceNow: 24 * 60 * 60)
            self?.pauseGhostery(time)
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
    
    private func pauseGhostery(_ time: Date) {
        self.delegate?.pauseGhostery(paused: true, time: time)
        self.delegate?.turnGlobalAdblocking(on: false)
        self.updateData()
        TelemetryHelper.sendControlCenterPauseClick()
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

    fileprivate func updateBlockedTrackersCount() {
		blockedTrackers.text = String(format: NSLocalizedString("%d Tracker(s) Blocked", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Blocked trackers count"), self.dataSource?.blockedTrackerCount() ?? 0)

		if let domainState = self.dataSource?.domainState() {
			switch (domainState) {
			case .trusted:
				 blockedTrackers.text = NSLocalizedString("You have trusted this site", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Blocked trackers count")
			case .restricted:
				blockedTrackers.text = NSLocalizedString("You have restricted this site", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Blocked trackers count")
			default:
				break
			}
		}
    }

    fileprivate func updateChart() {
        guard let datasource = self.dataSource else { return }
        let countsAndColors = datasource.countAndColorByCategory(tableType: .page)
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
        chart?.centerText = String(format: NSLocalizedString("%d Tracker(s) found", tableName: "Cliqz", comment: "[ControlCenter -> Overview] Detected trackers count"), self.dataSource?.detectedTrackerCount() ?? 0)
        chart?.accessibilityValue = "\(self.dataSource?.detectedTrackerCount() ?? 0)"
    }

	private func setupPieChart() {
		chart = PieChartView()
		chart.chartDescription?.text = ""
		chart.legend.enabled = false
		chart.holeRadiusPercent = 0.8
        chart.accessibilityIdentifier = "donut"
	}
}

extension OverviewViewController: NotchViewDelegate {

    func switchValueChanged(value: Bool) {
        
        if value == true {
            self.delegate?.turnGlobalAdblocking(on: value)
            self.delegate?.turnDomainAdblocking(on: nil)
            
            //bring donw the notch if it is up
            let top = self.view.frame.height - CGFloat(ControlCenterUX.adblockerViewMaxHeight)
            if self.adBlockingView.frame.origin.y == top { //not open
                self.moveNotch(velocity: 0.00001)
            }
        }
        else {
            //Default
            self.delegate?.turnDomainAdblocking(on: false)
            
            //bring up the notch if it is not up already
            let top = self.view.frame.height - CGFloat(ControlCenterUX.adblockerViewMaxHeight)
            if self.adBlockingView.frame.origin.y != top { //not open
                self.moveNotch(velocity: -0.00001)
            }
        }
	}

	func viewIsDragging(translation: Float, velocity: Float) {
        let newOffset = self.adBlockingView.frame.origin.y + CGFloat(translation)
        let upperLimit = self.view.frame.height + CGFloat(ControlCenterUX.adblockerViewInitialOffset) //bottom
        let lowerLimit = self.view.frame.height - CGFloat(ControlCenterUX.adblockerViewMaxHeight) // top
        if newOffset <= upperLimit && newOffset >= lowerLimit {
            self.adBlockingView.snp.updateConstraints { (make) in
                make.top.equalTo(newOffset)
            }
        }
		
        self.view.layoutIfNeeded()
	}
    
    func moveNotch(velocity: Float) {
        let bottom = self.view.frame.height + CGFloat(ControlCenterUX.adblockerViewInitialOffset) //bottom
        let top = self.view.frame.height - CGFloat(ControlCenterUX.adblockerViewMaxHeight) // top
        
        let delta: CGFloat
        
        if velocity > 0 {
            delta = bottom - self.adBlockingView.frame.origin.y
            self.adBlockingView.snp.updateConstraints { (make) in
                make.top.equalTo(bottom)
            }
        } else {
            delta = self.adBlockingView.frame.origin.y - top
            self.adBlockingView.snp.updateConstraints { (make) in
                make.top.equalTo(top)
            }
        }
        
        var time: TimeInterval
        
        let timeUpperLimit: TimeInterval = 0.4
        let timeLowerLimit: TimeInterval = 0.2
        
        if delta > 0 {
            time = Double(delta) / abs(Double(velocity))
        }
        else {
            time = timeUpperLimit
        }
        
        if time < 0.2 {
            time = timeLowerLimit
        }
        else if time > 0.4 {
            time = timeUpperLimit
        }
        
        UIView.animate(withDuration: time) {
            self.view.layoutIfNeeded()
        }
    }

	func viewStopDragging(velocity: Float) {
        moveNotch(velocity: velocity)
	}
    
    func domainOnEnhancedViewPressed() {
        debugPrint("domainOnEnhancedViewPressed")
        self.delegate?.turnDomainAdblocking(on: false)
        let prevAdblockerState = UserPreferences.instance.prevAdblockingMode == .blockAll ? true : false
        self.delegate?.turnGlobalAdblocking(on: prevAdblockerState)
    }
    
    func allWebsitesOnEnhancedViewPressed() {
        debugPrint("allWebsitesOnEnhancedViewPressed")
        
        self.delegate?.turnDomainAdblocking(on: nil)
        self.delegate?.turnGlobalAdblocking(on: false)
    }
}

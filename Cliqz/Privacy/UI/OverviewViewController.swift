//
//  OverviewViewController.swift
//  Client
//
//  Created by Sahakyan on 4/17/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import Charts

class BasicBlockingStatisticsView: UIView {

	private var iconView = UIImageView()
	private var countView = UILabel()
	private var titleView = UILabel()
	private var switchControl = UISwitch()

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
		self.addSubview(iconView)
		self.addSubview(countView)
		countView.textColor = UIColor.cliqzBluePrimary
		self.addSubview(titleView)
		titleView.textColor = UIColor.cliqzBluePrimary
		self.addSubview(switchControl)
		switchControl.onTintColor = UIColor.cliqzBluePrimary
		switchControl.thumbTintColor = UIColor.white
		switchControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setStyles() {
		
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.iconView.snp.remakeConstraints { (make) in
			make.centerY.equalTo(self)
			make.height.width.equalTo(30)
			make.left.equalTo(self).offset(12)
		}
		self.countView.snp.remakeConstraints { (make) in
			make.left.equalTo(self.iconView.snp.right).offset(10)
			make.centerY.equalTo(self)
			make.height.equalTo(25)
		}
		self.titleView.snp.remakeConstraints { (make) in
			make.left.equalTo(self.countView.snp.right).offset(10)
			make.centerY.equalTo(self)
			make.height.equalTo(25)
		}
		self.switchControl.snp.remakeConstraints { (make) in
			make.centerY.equalTo(self)
			make.height.equalTo(25)
			make.right.equalTo(self).inset(10)
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

	private var antitrackingView = BasicBlockingStatisticsView()
	private var adBlockingView = BasicBlockingStatisticsView()

	var categories = [String: [TrackerListApp]]() {
		didSet {
			self.updateData()
		}
	}

	var blockedTrackersCount: Int = 0 {
		didSet {
			blockedTrackers.text = "\(blockedTrackersCount) trackers blocked"
		}
	}
	var allTrackersCount: Int = 0
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
		let values = self.categories.map { PieChartDataEntry(value: Double($0.1.count), label: nil) }
		self.allTrackersCount = self.categories.flatMap({ $0.1.count }).reduce(0, +)
		let dataSet = PieChartDataSet(values: values, label: "")
		dataSet.drawIconsEnabled = false
		dataSet.drawValuesEnabled = false
		dataSet.iconsOffset = CGPoint(x: 0, y: 20.0)
		dataSet.colors = [NSUIColor(colorString: "CB55CD"), NSUIColor(colorString: "87D7EF"), NSUIColor(colorString: "43B7C5"), NSUIColor(colorString: "FDC257"), NSUIColor(colorString: "EF671E")]
		
		chart?.data = PieChartData(dataSet: dataSet)
		chart?.centerText = "\(self.allTrackersCount) Trackers found"

	}

	private func setComponentsStyles() {
		self.trustSiteButton.backgroundColor = UIColor.white
		self.trustSiteButton.layer.borderColor = UIColor.gray.cgColor
		self.trustSiteButton.layer.borderWidth = 1
		self.trustSiteButton.layer.cornerRadius = 3
		self.trustSiteButton.setTitleColor(UIColor.gray, for: .normal)
		trustSiteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
		trustSiteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);

		self.restrictSiteButton.backgroundColor = UIColor.white
		self.restrictSiteButton.layer.borderColor = UIColor.gray.cgColor
		self.restrictSiteButton.layer.borderWidth = 1
		self.restrictSiteButton.layer.cornerRadius = 3
		self.restrictSiteButton.setTitleColor(UIColor.gray, for: .normal)
		self.restrictSiteButton.setImage(UIImage(named: "restrict"), for: .normal)
		restrictSiteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
		restrictSiteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
		
		self.pauseGhosteryButton.backgroundColor = UIColor.white
		self.pauseGhosteryButton.layer.borderColor = UIColor.gray.cgColor
		self.pauseGhosteryButton.layer.borderWidth = 1
		self.pauseGhosteryButton.layer.cornerRadius = 3
		self.pauseGhosteryButton.setTitleColor(UIColor.gray, for: .normal)
	}

	private func setupComponents() {
		self.setupPieChart()
		self.view.addSubview(urlLabel)
		urlLabel.font = UIFont.systemFont(ofSize: 13)
		urlLabel.textAlignment = .center
		self.urlLabel.snp.makeConstraints { (make) in
			make.left.right.equalTo(self.view).inset(7)
			make.top.equalTo(chart.snp.bottom).offset(10)
			make.height.equalTo(30)
		}
		self.view.addSubview(blockedTrackers)
		blockedTrackers.font = UIFont.systemFont(ofSize: 20)
		self.blockedTrackers.snp.makeConstraints { (make) in
			make.centerX.equalTo(self.view)
			make.top.equalTo(self.urlLabel.snp.bottom)
			make.height.equalTo(30)
		}
		self.view.addSubview(trustSiteButton)
		self.trustSiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		self.trustSiteButton.titleLabel?.textColor = UIColor(colorString: "4A4A4A")
		self.trustSiteButton.snp.makeConstraints { (make) in
			make.centerX.equalTo(self.view)
			make.top.equalTo(self.blockedTrackers.snp.bottom).offset(15)
			make.height.equalTo(30)
			make.width.equalTo(213)
		}
		self.view.addSubview(restrictSiteButton)
		self.restrictSiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		self.restrictSiteButton.snp.makeConstraints { (make) in
			make.centerX.equalTo(self.view)
			make.top.equalTo(self.trustSiteButton.snp.bottom).offset(10)
			make.height.equalTo(30)
			make.width.equalTo(213)
		}
		self.view.addSubview(pauseGhosteryButton)
		self.pauseGhosteryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		self.pauseGhosteryButton.snp.makeConstraints { (make) in
			make.centerX.equalTo(self.view)
			make.top.equalTo(self.restrictSiteButton.snp.bottom).offset(10)
			make.height.equalTo(30)
			make.width.equalTo(213)
		}
		self.view.addSubview(antitrackingView)
		self.antitrackingView.snp.makeConstraints { (make) in
			make.left.right.equalTo(self.view)
			make.top.equalTo(self.pauseGhosteryButton.snp.bottom).offset(10)
			make.height.equalTo(40)
		}
		self.view.addSubview(adBlockingView)
		self.adBlockingView.snp.makeConstraints { (make) in
			make.left.right.equalTo(self.view)
			make.top.equalTo(self.antitrackingView.snp.bottom)
			make.height.equalTo(40)
		}

//		self.urlLabel.text = "nytimes.com"
		self.blockedTrackers.text = "\(self.blockedTrackersCount) trackers blocked"
		self.trustSiteButton.setTitle("Trust Site", for: .normal)
		self.trustSiteButton.setTitleColor(UIColor.white, for: .selected)
		self.trustSiteButton.setImage(UIImage(named: "trust"), for: .normal)
		self.trustSiteButton.setImage(UIImage(named: "trustAction"), for: .selected)
		self.trustSiteButton.addTarget(self, action: #selector(trustSite), for: .touchUpInside)

		
		self.restrictSiteButton.setTitle("Restrict Site", for: .normal)
		self.restrictSiteButton.addTarget(self, action: #selector(restrictSite), for: .touchUpInside)
		self.restrictSiteButton.setImage(UIImage(named: "restrictAction"), for: .selected)
		self.restrictSiteButton.setTitleColor(UIColor.white, for: .selected)


		self.pauseGhosteryButton.setTitle("Pause Ghostery", for: .normal)
		
		self.antitrackingView.count = self.blockedTrackersCount
		self.antitrackingView.title = "Enhanced Anti-Tracking"
		self.antitrackingView.isSwitchOn = true
		self.antitrackingView.iconName = "antitracking"
		self.adBlockingView.count = 0
		self.adBlockingView.title = "Enhanced Ad Blocking"
		self.adBlockingView.isSwitchOn = true
		self.adBlockingView.iconName = "adblocking"
	}

	@objc private func trustSite() {
		self.trustSiteButton.isSelected = !self.trustSiteButton.isSelected
		if self.trustSiteButton.isSelected {
			self.trustSiteButton.backgroundColor = UIColor(colorString: "9ECC42")
		} else {
			self.trustSiteButton.backgroundColor = UIColor.white
		}
		if self.restrictSiteButton.isSelected {
			self.restrictSite()
		}
	}

	@objc private func restrictSite() {
		self.restrictSiteButton.isSelected = !self.restrictSiteButton.isSelected
		if self.restrictSiteButton.isSelected {
			self.restrictSiteButton.backgroundColor = UIColor(colorString: "BE4948")
		} else {
			self.restrictSiteButton.backgroundColor = UIColor.white
		}
		if self.trustSiteButton.isSelected {
			self.trustSite()
		}
	}

	private func setupPieChart() {
		let values: [Double] = [11, 33, 81, 52, 97, 101, 75]
		
		var entries: [PieChartDataEntry] = Array()
		
		for value in values
		{
			entries.append(PieChartDataEntry(value: value, icon: UIImage(named: "icon", in: Bundle(for: self.classForCoder), compatibleWith: nil)))
		}
		
		let dataSet = PieChartDataSet(values: entries, label: "")
		dataSet.drawIconsEnabled = false
		dataSet.drawValuesEnabled = false
		dataSet.iconsOffset = CGPoint(x: 0, y: 20.0)
		dataSet.colors = ChartColorTemplates.vordiplom()
			+ ChartColorTemplates.joyful()
			+ ChartColorTemplates.colorful()
			+ ChartColorTemplates.liberty()
			+ ChartColorTemplates.pastel()
			+ [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
		
		chart = PieChartView(frame: CGRect(x: 0, y: 0, width: 480, height: 350))
		chart.backgroundColor = NSUIColor.clear
//		chart.data = PieChartData(dataSet: dataSet)
		chart.chartDescription?.text = ""
		chart.legend.enabled = false
		chart.holeRadiusPercent = 0.8
		self.view.addSubview(chart)
		chart.snp.makeConstraints { (make) in
			make.left.right.top.equalToSuperview()
			make.height.equalTo(200)
		}
	}
}

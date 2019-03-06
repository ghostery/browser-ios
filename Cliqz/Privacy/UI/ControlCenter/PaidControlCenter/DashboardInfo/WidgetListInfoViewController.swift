//
//  WidgetListInfoViewController.swift
//  Client
//
//  Created by Sahakyan on 3/1/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation


class WidgetDetailHeaderView: UIView {
	
	var iconName: String? {
		get {
			return ""
		}
		set {
			iconView.image = UIImage(named: newValue ?? "")
		}
	}
	
	var count: String? {
		get {
			return countLabel.text
		}
		set {
			countLabel.text = newValue
			countLabel.sizeToFit()
		}
	}
	
	var title: String? {
		get {
			return titleLabel.text
		}
		set {
			titleLabel.text = newValue
			titleLabel.sizeToFit()
		}
	}
	
	var descriptionText: String? {
		get {
			return descriptionLabel.text
		}
		set {
			descriptionLabel.text = newValue
			descriptionLabel.sizeToFit()
		}
	}
	
	private let iconView = UIImageView()
	private let countLabel = UILabel()
	private let titleLabel = UILabel()
	private let descriptionLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupSubviews()
		setupConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		setupConstraints()
	}

	private func setupSubviews() {
		self.addSubview(iconView)
		self.addSubview(countLabel)
		self.addSubview(titleLabel)
		self.addSubview(descriptionLabel)
		iconView.contentMode = .center
		countLabel.font = UIFont.systemFont(ofSize: 21, weight: .regular)
		countLabel.textColor = UIColor.white
		titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
		titleLabel.textColor = UIColor.white
		descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		descriptionLabel.textColor = UIColor.white
		descriptionLabel.numberOfLines = 0
	}
	
	private func setupConstraints() {
		iconView.snp.remakeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().offset(10)
		}
		countLabel.snp.remakeConstraints { (make) in
			make.top.equalTo(iconView.snp.top).offset(30)
			make.height.equalTo(20)
			make.centerX.equalTo(iconView.snp.centerX)
		}
		titleLabel.snp.remakeConstraints { (make) in
			make.left.equalTo(iconView.snp.right).offset(30)
			make.top.equalToSuperview().offset(10)
			make.right.equalToSuperview()
		}
		descriptionLabel.snp.remakeConstraints { (make) in
			make.left.equalTo(titleLabel.snp.left)
			make.top.equalTo(titleLabel.snp.bottom).offset(4)
			make.right.equalToSuperview()
		}
	}
}

class WidgetListInfoViewController: WidgetInfoViewController {
	
	var dataSource: DashboardListInfoDataSource?

	private let tableView = UITableView()
	private let headerView = WidgetDetailHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 80))

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupViews()
		self.setupConstraints()
		self.updateData()
	}
	
	private func setupViews() {
		self.containerView.addSubview(tableView)
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.separatorColor = UIColor.lumenBrightBlue.withAlphaComponent(0.3)
		self.tableView.register(BlockedItemCell.self, forCellReuseIdentifier: "DashboardInfoCell")
		self.tableView.tableHeaderView = self.headerView
		self.tableView.tableFooterView = UIView()
		self.tableView.backgroundColor = UIColor.clear
	}

	private func setupConstraints() {
		self.tableView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		self.tableView.tableHeaderView?.snp.makeConstraints { (make) in
			make.top.width.equalToSuperview()
			make.height.equalTo(80)
		}
	}

	private func updateData() {
		self.headerView.iconName = dataSource?.imageName
		self.headerView.count = dataSource?.count
		self.headerView.title = dataSource?.headerTitle
		self.headerView.descriptionText = dataSource?.headerDescription
	}
}

extension WidgetListInfoViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10 //self.dataSource?.listCount ?? 10
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 38
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 24
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardInfoCell", for: indexPath) as? BlockedItemCell {
			cell.nameLabel.text = "Hello"
			cell.selectionStyle = .none
			return cell
		}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let sectionHeader = UIView()
		let title = UILabel()
		title.textColor = UIColor.lumenTextBlue
		title.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		title.textAlignment = .left
		title.text = self.dataSource?.sectionHeaderTitle
		title.sizeToFit()
		sectionHeader.addSubview(title)
		title.snp.makeConstraints { (make) in
			make.left.equalToSuperview().offset(4)
			make.centerY.equalToSuperview()
		}
		let line = UIView()
		line.backgroundColor = UIColor.lumenBrightBlue.withAlphaComponent(0.3)
		sectionHeader.addSubview(line)
		line.snp.makeConstraints { (make) in
			make.left.right.bottom.equalToSuperview()
			make.height.equalTo(1)
		}
		return sectionHeader
	}

}

extension WidgetListInfoViewController: UITableViewDelegate {
	
}

class BlockedItemCell: UITableViewCell {
	let nameLabel = UILabel()
	let infoIcon = UIImageView()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.setupSubviews()
		self.setConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateBlockedItemName(companyName: String) {
		nameLabel.text = companyName
	}

	private func setupSubviews() {
		self.addSubview(self.nameLabel)
		self.nameLabel.textAlignment = .left
		self.nameLabel.textColor = UIColor.white
		self.nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		self.backgroundColor = UIColor.clear
		// TODO: Include in future when we have the flow how to handle info action
//		self.addSubview(self.infoIcon)
	}

	private func setConstraints() {
		nameLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().offset(5)
			make.centerY.equalToSuperview()
		}
	}
}

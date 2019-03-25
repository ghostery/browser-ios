//
//  WidgetGeneralInfoViewController.swift
//  Client
//
//  Created by Sahakyan on 3/1/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#if PAID

import Foundation

class WidgetGeneralInfoViewController: WidgetInfoViewController {

	var dataSource: DashboardGeneralInfoDataSource?

	fileprivate let imageView = UIImageView()
	fileprivate let countLabel = UILabel()
	fileprivate let unitLabel = UILabel()
	fileprivate let titleLabel = UILabel()
	fileprivate let descriptionLabel = UILabel()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupViews()
		self.setConstraints()
		self.loadData()
	}

	fileprivate func setupViews() {
		self.view.addSubview(self.imageView)
		self.view.addSubview(self.countLabel)
		self.view.addSubview(self.unitLabel)
		self.view.addSubview(self.titleLabel)
		self.view.addSubview(self.descriptionLabel)
		self.countLabel.font = UIFont.systemFont(ofSize: 62, weight: .regular)
		self.countLabel.textColor = UIColor.white
		self.unitLabel.font = UIFont.systemFont(ofSize: 62, weight: .regular)
		self.unitLabel.textColor = UIColor.white
		self.titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
		self.titleLabel.textColor = UIColor.lumenTextBlue
		self.titleLabel.textAlignment = .center
		self.descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
		self.descriptionLabel.textColor = UIColor.lumenTextBlue
		self.descriptionLabel.textAlignment = .center
		self.descriptionLabel.numberOfLines = 0
  	}

	fileprivate func setConstraints() {
		self.imageView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().dividedBy(1.4)
		}
		self.countLabel.snp.makeConstraints { (make) in
			make.centerX.equalTo(self.imageView.snp.centerX)
			make.top.equalTo(self.imageView.snp.top).offset(38)
			make.height.equalTo(60)
		}
		self.unitLabel.snp.makeConstraints { (make) in
			make.centerX.equalTo(self.imageView.snp.centerX)
			make.top.equalTo(self.countLabel.snp.bottom)
			make.height.equalTo(55)
		}
		self.titleLabel.snp.makeConstraints { (make) in
			make.top.equalTo(self.imageView.snp.bottom).offset(10)
			make.centerX.equalToSuperview()
		}
		self.descriptionLabel.snp.makeConstraints { (make) in
			make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
			make.left.right.equalToSuperview().inset(4)
		}
	}

	private func loadData() {
		self.imageView.image = UIImage(named: self.dataSource?.imageName ?? "")
		self.countLabel.text = self.dataSource?.count
		self.countLabel.sizeToFit()
		self.unitLabel.text = self.dataSource?.unit
		self.titleLabel.text = self.dataSource?.title
		self.descriptionLabel.text = self.dataSource?.description
		self.descriptionLabel.sizeToFit()
	}
}

class SavedTimeWidgetInfoViewController: WidgetGeneralInfoViewController {
	
	override func setupViews() {
		super.setupViews()
		countLabel.font = UIFont.systemFont(ofSize: 40, weight: .regular)
		unitLabel.font = UIFont.systemFont(ofSize: 40, weight: .regular)
	}

	override func setConstraints() {
		super.setConstraints()
		self.countLabel.snp.remakeConstraints { (make) in
			make.centerX.equalTo(self.imageView.snp.centerX)
			make.top.equalTo(self.imageView.snp.top).offset(42)
			make.height.equalTo(40)
		}
		self.unitLabel.snp.remakeConstraints { (make) in
			make.centerX.equalTo(self.imageView.snp.centerX)
			make.top.equalTo(self.countLabel.snp.bottom)
			make.height.equalTo(40)
		}
	}
}

class AntiPhishingWidgetInfoViewController: WidgetGeneralInfoViewController {
	
	override func setupViews() {
		super.setupViews()
		self.unitLabel.isHidden = true
		self.countLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
	}

	override func setConstraints() {
		super.setConstraints()
		self.countLabel.snp.remakeConstraints { (make) in
			make.top.equalTo(imageView.snp.bottom).offset(10)
			make.centerX.equalToSuperview()
		}
		self.titleLabel.snp.remakeConstraints { (make) in
			make.top.equalTo(self.countLabel.snp.bottom).offset(20)
			make.centerX.equalToSuperview()
		}
	}
}

#endif

//
//  SubscriptionTableViewCell.swift
//  Client
//
//  Created by Mahmoud Adam on 2/5/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

class SubscriptionTableViewCell: UITableViewCell {
    let nameLabel = UILabel()
    let durationLabel = UILabel()
    let priceLabel = UILabel()
    let billingLabel = UILabel()
    let descriptionLabel = UILabel()
    let subscribeButton = UIButton()
    
    var buyButtonHandler: ((_ premiumType: PremiumType) -> Void)?
    var premiumType: PremiumType? {
        didSet {
            guard let premiumType = premiumType else { return }
            configureCell(premiumType)
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupComponents()
        self.setStyles()
        self.setConstraints()
    }
    
    private func setupComponents() {
        self.addSubview(nameLabel)
        self.addSubview(durationLabel)
        self.addSubview(priceLabel)
        self.addSubview(billingLabel)
        descriptionLabel.numberOfLines = 0
        self.addSubview(descriptionLabel)
        
        subscribeButton.setTitle(NSLocalizedString("SUBSCRIBE", tableName: "Lumen", comment: "Subscribe Button"), for: .normal)
        subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
        self.addSubview(subscribeButton)

    }
    
    private func setStyles() {
        self.backgroundColor = UIColor.clear
        nameLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        nameLabel.textColor = UIColor.white
        
        durationLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        durationLabel.textColor = UIColor.white
        
        priceLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
        priceLabel.textColor = UIColor.white
        
        billingLabel.font = UIFont.systemFont(ofSize: 10.0, weight: .regular)
        billingLabel.textColor = UIColor(colorString: "BDC0CE")
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        descriptionLabel.textColor = UIColor(colorString: "BDC0CE")
        
        subscribeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        subscribeButton.backgroundColor = UIColor.lumenBrightBlue
        subscribeButton.setTitleColor(UIColor.white, for: .normal)
        subscribeButton.layer.cornerRadius = 15
    }
    
    private func setConstraints() {
        nameLabel.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().inset(10.0)
        }
        
        durationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.top)
            make.trailing.equalToSuperview().inset(20.0)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(10.0)
        }
        
        billingLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(priceLabel.snp.bottom).offset(5.0)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalToSuperview().inset(20.0)
            make.bottom.equalToSuperview().inset(10.0)
        }
        
        subscribeButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(10.0)
            make.top.equalTo(durationLabel.snp.bottom).offset(10.0)
            make.width.equalTo(110.0)
            make.height.equalTo(30.0)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configureCell(_ premiumType: PremiumType) {
        nameLabel.text = premiumType.getName()
        durationLabel.text = premiumType.getDuration()
        priceLabel.text = premiumType.getPrice()
        billingLabel.text = premiumType.getBilling()
        descriptionLabel.text = premiumType.getDescription()
        
    }
    
    @objc func subscribeButtonTapped() {
        if let premiumType = self.premiumType {
            buyButtonHandler?(premiumType)
        }
    }
    
}

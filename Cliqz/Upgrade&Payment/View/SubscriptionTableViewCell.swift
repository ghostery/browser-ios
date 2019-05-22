//
//  SubscriptionTableViewCell.swift
//  Client
//
//  Created by Mahmoud Adam on 2/5/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit
class SubscribeButton: UIButton {
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(colorString: "2557A5") : UIColor.lumenBrightBlue
        }
    }
}

class SubscriptionTableViewCell: UITableViewCell {
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    let descriptionLabel = UILabel()
    let bestOfferLabel = UILabel()
    let subscribedIcon = UIImageView()
    let subscribeButton = SubscribeButton()
    let frameView = UIImageView()
    var isProCell: Bool = false
    var isSubscribed: Bool = false
    
    var buyButtonHandler: ((_ product: LumenSubscriptionProduct) -> Void)?
//    var premiumType: PremiumType? {
//        didSet {
//            guard let premiumType = premiumType else { return }
//            configureCell(premiumType)
//        }
//    }

	var subscriptionInfo: SubscriptionCellInfo? {
		didSet {
			guard let subscriptionInfo = subscriptionInfo else { return }
			configureCell(subscriptionInfo)
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
        self.addSubview(priceLabel)
        descriptionLabel.numberOfLines = 0
        self.addSubview(descriptionLabel)
        bestOfferLabel.numberOfLines = 0
        bestOfferLabel.textAlignment = .right
        self.addSubview(bestOfferLabel)
        
        self.addSubview(frameView)
        self.sendSubview(toBack: frameView)
        
        subscribeButton.setTitle(NSLocalizedString("SUBSCRIBE", tableName: "Lumen", comment: "Subscribe Button"), for: .normal)
        subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
        self.addSubview(subscribeButton)
        
        subscribedIcon.image = UIImage(named: "VPN_Checkmark")
        self.addSubview(subscribedIcon)

    }
    
    private func setStyles() {
        self.backgroundColor = UIColor.clear
        nameLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        nameLabel.textColor = isProCell ? UIColor.black : UIColor.white
        
        priceLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
        priceLabel.textColor = UIColor.white
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        descriptionLabel.textColor = UIColor(colorString: "BDC0CE")
        
        subscribeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        subscribeButton.layer.cornerRadius = 15
        
        frameView.image = isProCell ? UIImage(named: "Frame_Solid") : UIImage(named: "Frame")
        
        bestOfferLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        bestOfferLabel.textColor = UIColor.black
        bestOfferLabel.isHidden = !isProCell
        
        subscribedIcon.isHidden = !isSubscribed
        
        if isSubscribed {
            subscribeButton.setTitle(NSLocalizedString("SUBSCRIBED", tableName: "Lumen", comment: "Subscribe Button"), for: .normal)
            subscribeButton.isUserInteractionEnabled = false
            subscribeButton.backgroundColor = UIColor.clear
            subscribeButton.setTitleColor(UIColor.lumenBrightBlue, for: .normal)
        } else {
            subscribeButton.setTitle(NSLocalizedString("UPGRADE", tableName: "Lumen", comment: "Subscribe Button"), for: .normal)
            subscribeButton.isUserInteractionEnabled = true
            subscribeButton.backgroundColor = UIColor.lumenBrightBlue
            subscribeButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    private func setConstraints() {
        
        nameLabel.snp.remakeConstraints { (make) in
            if isProCell {
                make.leading.equalToSuperview().inset(20.0)
                make.top.equalToSuperview().inset(15.0)
            } else {
                make.leading.equalToSuperview().inset(30.0)
                make.top.equalToSuperview().inset(13.0)
            }
        }
        
        bestOfferLabel.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(nameLabel)
        }
        
        priceLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(23.0)
        }
        
        descriptionLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalToSuperview().inset(25.0)
            make.bottom.equalToSuperview().inset(20.0)
        }
        
        frameView.snp.remakeConstraints { (make) in
            if isProCell {
                make.leading.trailing.equalToSuperview().inset(10)
            } else {
                make.leading.trailing.equalToSuperview().inset(20)
            }
            make.top.bottom.equalToSuperview().inset(5)
            
        }
        
        subscribeButton.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview().inset(isProCell ? 20.0 : 30)
            make.centerY.equalTo(priceLabel).offset(isSubscribed ? 10 : 0)
            make.width.equalTo(110.0)
            make.height.equalTo(30.0)
        }
        
        subscribedIcon.snp.remakeConstraints { (make) in
            make.centerY.equalTo(priceLabel).offset(-10)
            make.centerX.equalTo(subscribeButton)
            make.size.equalTo(11)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
	private func configureCell(_ subscriptionInfo: SubscriptionCellInfo) {
        nameLabel.text = subscriptionInfo.name
        priceLabel.text = subscriptionInfo.price //premiumType.getPrice()
        descriptionLabel.text = subscriptionInfo.description //premiumType.getDescription()
		bestOfferLabel.text = subscriptionInfo.offerDetails //NSLocalizedString("BEST OFFER LIMITED TIME ONLY", tableName: "Lumen", value:"BEST OFFER\nLIMITED TIME ONLY", comment: "BEST OFFER\nLIMITED TIME ONLY")

        isProCell = subscriptionInfo.offerDetails != nil
        isSubscribed = subscriptionInfo.isSubscribed //SubscriptionController.shared.hasSubscription(premiumType)
        self.setStyles()
        self.setConstraints()
    }
    
    @objc func subscribeButtonTapped() {
        if let subscriptionInfo = self.subscriptionInfo {
            buyButtonHandler?(subscriptionInfo.lumenProduct)
        }
    }
    
}

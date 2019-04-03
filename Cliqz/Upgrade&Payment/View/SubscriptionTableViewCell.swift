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
    let includeLabel = UILabel()
    let vpnIcon = UIImageView()
    let durationLabel = UILabel()
    let priceLabel = UILabel()
    let billingLabel = UILabel()
    let descriptionLabel = UILabel()
    let bestOfferLabel = UILabel()
    let subscribeButton = SubscribeButton()
    let frameView = UIImageView()
    var isProCell: Bool = false
    var isBasicCell: Bool = false
    
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
        includeLabel.text = NSLocalizedString("INCL.", tableName: "Lumen", comment: "Include vpn label")
        self.addSubview(includeLabel)
        self.addSubview(vpnIcon)
        self.addSubview(durationLabel)
        self.addSubview(priceLabel)
        self.addSubview(billingLabel)
        descriptionLabel.numberOfLines = 0
        self.addSubview(descriptionLabel)
        
        self.addSubview(bestOfferLabel)
        
        self.addSubview(frameView)
        self.sendSubview(toBack: frameView)
        
        subscribeButton.setTitle(NSLocalizedString("SUBSCRIBE", tableName: "Lumen", comment: "Subscribe Button"), for: .normal)
        subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
        self.addSubview(subscribeButton)

    }
    
    private func setStyles() {
        self.backgroundColor = UIColor.clear
        nameLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        nameLabel.textColor = isProCell ? UIColor.black : UIColor.white
        includeLabel.font = UIFont.systemFont(ofSize: 10.0, weight: .regular)
        includeLabel.textColor = isProCell ? UIColor.black : UIColor.white
        
        durationLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        durationLabel.textColor = isProCell ? UIColor.black : UIColor.white
        
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
        
        frameView.image = isProCell ? UIImage(named: "Frame_Solid") : UIImage(named: "Frame")
        vpnIcon.image = isProCell ? UIImage(named: "VPN_Dark") : UIImage(named: "VPN_White")
        
        bestOfferLabel.font = UIFont.systemFont(ofSize: 9.0, weight: .medium)
        bestOfferLabel.textColor = UIColor.black
        bestOfferLabel.isHidden = !isProCell
        includeLabel.isHidden = isBasicCell
        vpnIcon.isHidden = isBasicCell
    }
    
    private func setConstraints() {
        
        nameLabel.snp.remakeConstraints { (make) in
            if isProCell {
                make.leading.equalToSuperview().inset(20.0)
                make.top.equalToSuperview().inset(20.0)
            } else {
                make.leading.equalToSuperview().inset(30.0)
                make.top.equalToSuperview().inset(13.0)
            }
        }
        
        includeLabel.snp.remakeConstraints { (make) in
            make.bottom.equalTo(nameLabel.snp.bottom)
            make.leading.equalTo(nameLabel.snp.trailing).offset(5)
        }
        
        vpnIcon.snp.remakeConstraints { (make) in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.leading.equalTo(includeLabel.snp.trailing).offset(5)
        }
        
        durationLabel.snp.remakeConstraints { (make) in
            make.centerY.equalTo(nameLabel.snp.centerY)
            if isProCell {
                make.trailing.equalToSuperview().inset(20.0)
            } else {
                make.trailing.equalToSuperview().inset(30.0)
            }
        }
        bestOfferLabel.snp.remakeConstraints { (make) in
            make.trailing.equalTo(durationLabel.snp.trailing)
            make.top.equalToSuperview().inset(8)
        }
        
        priceLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(10.0)
        }
        
        billingLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(priceLabel.snp.bottom)
        }
        
        descriptionLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalToSuperview().inset(25.0)
            make.bottom.equalToSuperview().inset(10.0)
        }
        
        subscribeButton.snp.remakeConstraints { (make) in
            if isProCell {
                make.trailing.equalToSuperview().inset(20.0)
            } else {
                make.trailing.equalToSuperview().inset(30.0)
            }
            make.top.equalTo(durationLabel.snp.bottom).offset(15.0)
            make.width.equalTo(110.0)
            make.height.equalTo(30.0)
        }
        
        frameView.snp.remakeConstraints { (make) in
            if isProCell {
                make.leading.trailing.equalToSuperview().inset(10)
            } else {
                make.leading.trailing.equalToSuperview().inset(20)
            }
            make.top.bottom.equalToSuperview().inset(5)
            
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
        bestOfferLabel.text = ""//NSLocalizedString("BEST VALUE: SAVE 20%", tableName: "Lumen", comment: "BEST VALUE: SAVE 20%")
            
        isProCell = premiumType == .Pro
        isBasicCell = premiumType == .Basic
        if SubscriptionController.shared.hasBasicSubscription() {
            if isBasicCell {
                subscribeButton.setTitle(NSLocalizedString("SUBSCRIBED", tableName: "Lumen", comment: "Subscribe Button"), for: .normal)
                subscribeButton.isUserInteractionEnabled = false
            } else if isProCell {
                subscribeButton.setTitle(NSLocalizedString("UPGRADE", tableName: "Lumen", comment: "Subscribe Button"), for: .normal)
                subscribeButton.isUserInteractionEnabled = true
            }
        }
        self.setStyles()
        self.setConstraints()
    }
    
    @objc func subscribeButtonTapped() {
        if let premiumType = self.premiumType {
            buyButtonHandler?(premiumType)
        }
    }
    
}

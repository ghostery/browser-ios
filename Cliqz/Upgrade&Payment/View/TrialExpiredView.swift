//
//  TrialExpiredView.swift
//  Client
//
//  Created by Mahmoud Adam on 1/31/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

struct TrialExpiredViewUX {
    static let height: CGFloat = 200.0
}

class TrialExpiredView: UIView {
    private let textColor = UIColor(colorString: "7C90D1")
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let upgradeButton = UIButton()
    private let closeButton = UIButton()
    
    weak var delegate: UpgradeLumenDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        self.setupComponents()
        self.setStyles()
        self.setConstraints()
        SubscriptionController.shared.trialExpiredViewDisplayed()
        LegacyTelemetryHelper.logMessage(action: "show", topic: "upgrade", style: "reminder", view: "start_tab")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupComponents() {
        titleLabel.text = NSLocalizedString("Your trial is over", tableName: "Lumen", comment: "Trial Expired view title")
        subtitleLabel.text = NSLocalizedString("You can still use Lumen, but without ultimate protection and VPN. Or go premium.", tableName: "Lumen", comment: "Trial Expired view subtitle")
        subtitleLabel.numberOfLines = 0
        upgradeButton.setTitle(NSLocalizedString("Learn More", tableName: "Lumen", comment: "Trial Expired view Learn more button text"), for: .normal)
        closeButton.setTitle(NSLocalizedString("No, Thanks", tableName: "Lumen", comment: "Close Trial Expired button text"), for: .normal)
        
        
        upgradeButton.addTarget(self, action: #selector(upgradeToPremium), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(hideView), for: .touchUpInside)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(upgradeButton)
        addSubview(closeButton)
    }
    
    fileprivate func setStyles() {
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        upgradeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
        upgradeButton.setTitleColor(UIColor.white, for: .normal)
        upgradeButton.backgroundColor = UIColor.lumenBrightBlue
        upgradeButton.layer.cornerRadius = 20
        
        closeButton.setTitleColor(UIColor.lumenTextBlue, for: .normal)
        closeButton.layer.borderColor = UIColor.lumenTextBlue.cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.layer.cornerRadius = 20
        
        titleLabel.textColor = textColor
        subtitleLabel.textColor = textColor
        
    }
    
    fileprivate func setConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(170.0)
            make.height.equalTo(40.0)
        }
        
        upgradeButton.snp.makeConstraints { (make) in
            make.top.equalTo(closeButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(170.0)
            make.height.equalTo(40.0)
        }
    }
    
    @objc func upgradeToPremium() {
        delegate?.showUpgradeViewController()
        LegacyTelemetryHelper.logMessage(action: "click", topic: "upgrade", style: "reminder", view: "start_tab", target: "upgrade")
    }
    
    @objc func hideView() {
        self.isHidden = true
        SubscriptionController.shared.trialExpiredViewDismissed()
        LegacyTelemetryHelper.logMessage(action: "click", topic: "upgrade", style: "reminder", view: "start_tab", target: "cancel")
    }
}


extension TrialExpiredView : Themeable {
    func applyTheme() {
        self.setStyles()
    }
}

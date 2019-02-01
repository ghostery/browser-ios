//
//  TrialExpiredView.swift
//  Client
//
//  Created by Mahmoud Adam on 1/31/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

struct TrialExpiredViewUX {
    static let height: CGFloat = 185.0
}

class TrialExpiredView: UIView {
    private let textColor = UIColor(colorString: "7C90D1")
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let upgradeButton = UIButton()
    private let clsoeButton = UIButton()
    
    weak var delegate: UpgradeLumenDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        self.setupComponents()
        self.setStyles()
        self.setConstraints()
        SubscriptionController.shared.trialExpiredViewDisplayed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupComponents() {
        titleLabel.text = NSLocalizedString("Your trial is over", tableName: "Lumen", comment: "Trial Expired view title")
        subtitleLabel.text = NSLocalizedString("You can still use Lumen, but without ultimate protection and VPN. Or go premium.", tableName: "Lumen", comment: "Trial Expired view subtitle")
        subtitleLabel.numberOfLines = 2
        upgradeButton.setTitle(NSLocalizedString("Learn More", tableName: "Lumen", comment: "Trial Expired view Learn more button text"), for: .normal)
        clsoeButton.setTitle(NSLocalizedString("No, Thanks", tableName: "Lumen", comment: "Close Trial Expired button text"), for: .normal)
        
        
        upgradeButton.addTarget(self, action: #selector(upgradeToPremium), for: .touchUpInside)
        clsoeButton.addTarget(self, action: #selector(hideView), for: .touchUpInside)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(upgradeButton)
        addSubview(clsoeButton)
    }
    
    fileprivate func setStyles() {
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        upgradeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        clsoeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
        upgradeButton.setTitleColor(UIColor.white, for: .normal)
        upgradeButton.backgroundColor = UIColor.lumenBrightBlue
        upgradeButton.layer.cornerRadius = 20
        
        clsoeButton.setTitleColor(UIColor.lumenBrightBlue, for: .normal)
        clsoeButton.layer.borderColor = UIColor.lumenBrightBlue.cgColor
        clsoeButton.layer.borderWidth = 1.0
        clsoeButton.layer.cornerRadius = 20
        
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
        
        clsoeButton.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(170.0)
            make.height.equalTo(40.0)
        }
        
        upgradeButton.snp.makeConstraints { (make) in
            make.top.equalTo(clsoeButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(170.0)
            make.height.equalTo(40.0)
        }
    }
    
    @objc func upgradeToPremium() {
        delegate?.showUpgradeViewController()
    }
    
    @objc func hideView() {
        self.isHidden = true
        SubscriptionController.shared.trialExpiredViewDismissed()
    }
}


extension TrialExpiredView : Themeable {
    func applyTheme() {
        self.setStyles()
    }
}

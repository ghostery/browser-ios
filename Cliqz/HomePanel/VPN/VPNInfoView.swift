//
//  VPNInfoView.swift
//  Client
//
//  Created by Mahmoud Adam on 4/1/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

class UILabelWithIcon: UIView {
    let label = UILabel()
    let iconView = UIImageView()
    let font = UIFont.systemFont(ofSize: 18, weight: .medium)
    var width: CGFloat = 0
    
    init(text: String, icon: UIImage? = nil) {
        super.init(frame: CGRect.zero)
        self.label.text = text
        self.label.font = font
        self.label.textAlignment = .center
        
        self.addSubview(label)
        self.addSubview(iconView)
        
        setConstrains(text.width(usingFont: font) + 10)
        self.updateIcon(icon)
    }
    
    func setConstrains(_ textWidth: CGFloat) {
        width = textWidth + 11
        label.snp.makeConstraints { (make) in
            make.centerY.trailing.equalToSuperview()
            make.width.equalTo(textWidth)
        }
        
        iconView.snp.makeConstraints { (make) in
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(11)
        }
    }
    
    func updateIcon( _ icon: UIImage?) {
        self.iconView.image = icon
    }
    
    func updateTextColor(_ textColor: UIColor) {
        label.textColor = textColor
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VPNInfoView: UIView {

    let vpnInfoLabel1 = UILabelWithIcon(text: NSLocalizedString("Protection from hackers", tableName: "Lumen", comment: "[VPN] Protection from hackers"))
    let vpnInfoLabel2 = UILabelWithIcon(text: NSLocalizedString("Video streaming from other countries", tableName: "Lumen", comment: "[VPN] Video streaming from other countries"))
    

    init() {
        super.init(frame: CGRect.zero)
        self.addSubview(vpnInfoLabel1)
        self.addSubview(vpnInfoLabel2)
        setConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(_ isVPNConnected: Bool) {
        if isVPNConnected {
            vpnInfoLabel1.updateTextColor(UIColor.white)
            vpnInfoLabel1.updateIcon(UIImage(named: "VPN_Checkmark"))
            
            vpnInfoLabel2.updateTextColor(UIColor.white)
            vpnInfoLabel2.updateIcon(UIImage(named: "VPN_Checkmark"))
            
        } else {
            vpnInfoLabel1.updateTextColor(UIColor.gray)
            vpnInfoLabel1.updateIcon(UIImage(named: "Protection_X"))
            
            vpnInfoLabel2.updateTextColor(UIColor.gray)
            vpnInfoLabel2.updateIcon(UIImage(named: "Protection_X"))
        }
    }
    
    private func setConstrains() {
        vpnInfoLabel1.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
            make.height.equalTo(20)
            make.width.equalTo(vpnInfoLabel1.width)
        }
        
        vpnInfoLabel2.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.width.equalTo(vpnInfoLabel2.width)
        }
    }
    
}

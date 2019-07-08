//
//  LumenURLBar.swift
//  Client
//
//  Created by Mahmoud Adam on 3/8/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit
import NetworkExtension
#if PAID
class LumenURLBar: CliqzURLBar {
    
    lazy var vpnAccessButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "vpnButton"
        button.addTarget(self, action: #selector(SELdidClickVpnAccess), for: .touchUpInside)
        button.alpha = 1
        if status == .connected {
            button.setImage(UIImage(named: "VPN_ON"), for: .normal)
        } else {
            button.setImage(UIImage(named: "VPN_OFF"), for: .normal)
        }
        return button
    }()
    
    var status: NEVPNStatus {
        return NEVPNManager.shared().connection.status;
    }

    override func createCancelButton() -> UIButton {
        let button = super.createCancelButton()
        button.backgroundColor = UIColor.white
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
        return button
    }

    override func layoutLocationContainer(inOverlay: Bool) {
        let height = URLBarViewUX.LocationHeight + (URLBarViewUX.TextFieldBorderWidthSelected * 2)
        self.locationContainer.layer.borderWidth = 0.1

        if inOverlay {
            self.locationContainer.snp.remakeConstraints { make in
                make.height.equalTo(height)
                make.trailing.equalTo(self.safeArea.trailing).offset(-10)
                make.leading.equalTo(self.safeArea.leading).offset(10)
                make.centerY.equalTo(self)
            }
        } else {
            self.locationContainer.snp.remakeConstraints { make in
                make.height.equalTo(height)
                make.leading.equalTo(self.safeArea.leading).offset(10)
                make.trailing.equalTo(self.vpnAccessButton.snp.leading)
                make.centerY.equalTo(self)
            }
        }
    }

    override func layoutLocationTextField() {
        self.locationTextField?.snp.remakeConstraints { make in
            make.height.equalTo(self.locationView)
            make.leading.equalTo(self.locationView.snp.leading).offset(10)
            make.trailing.equalTo(self.cancelButtonSeparator.snp.leading)
            make.centerY.equalTo(self.locationView)
        }
    }

    override func commonInit() {
        super.commonInit()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
    }
    
    @objc func VPNStatusDidChange(notification: Notification) {
        
        if status == .connected {
            vpnAccessButton.setImage(UIImage(named: "VPN_ON"), for: .normal)
        } else {
            vpnAccessButton.setImage(UIImage(named: "VPN_OFF"), for: .normal)
        }
        
    }
    
    @objc func SELdidClickVpnAccess(button: UIButton) {
        self.delegate?.urlBarDidPressVpnAccessButton()
    }

    override func setupCancelButtonConstraints() {
        cancelButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.locationContainer.snp.trailing).inset(10)
            make.centerY.equalTo(self.locationContainer)
            make.width.equalTo(self.cancelButton.intrinsicContentSize.width)
            make.height.equalTo(URLBarViewUX.ButtonHeight)
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        cancelButtonSeparator.snp.makeConstraints { make in
            make.trailing.equalTo(self.cancelButton.snp.leading)
            make.centerY.equalTo(self.locationContainer)
            make.width.equalTo(1)
            make.height.equalTo(26)
        }

        if vpnAccessButton.superview == nil {
            addSubview(vpnAccessButton)
        }
        
        vpnAccessButton.snp.makeConstraints { (make) in
            make.width.equalTo(50.0)
            make.height.equalTo(34.0)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self.dashboardButton.snp.leading)
        }
    }
    
    
    override func prepareOverlayAnimation() {
        super.prepareOverlayAnimation()
        bringSubview(toFront: vpnAccessButton)
    }
    
    override func transitionToOverlay(_ didCancel: Bool = false) {
        super.transitionToOverlay()
        vpnAccessButton.alpha = inOverlayMode ? 0 : 1
    }

    override func applyTheme() {
        super.applyTheme()
        cancelButtonSeparator.backgroundColor = UIColor.lumenURLBarPurple
    }
}
#endif

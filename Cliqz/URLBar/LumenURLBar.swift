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
    
    
    override func setupConstraints() {
        super.setupConstraints()
        
        if vpnAccessButton.superview == nil {
            addSubview(vpnAccessButton)
        }
        
        vpnAccessButton.snp.makeConstraints { (make) in
            make.width.equalTo(ghostyWidth)
            make.height.equalTo(ghostyHeight)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self.ghosteryButton.snp.leading)
        }
        
        pageOptionsButton.snp.remakeConstraints { (make) in
            make.size.equalTo(TabLocationViewUX.ButtonSize)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self.vpnAccessButton.snp.leading)
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
    
    
    override func updateConstraints() {
        super.updateConstraints()
        if !inOverlayMode {
            self.locationContainer.snp.remakeConstraints { make in
                if self.toolbarIsShowing {
                    // If we are showing a toolbar, show the text field next to the forward button
                    make.leading.equalTo(self.stopReloadButton.snp.trailing).offset(URLBarViewUX.Padding)
                } else {
                    // Otherwise, left align the location view
                    make.leading.equalTo(self).inset(UIEdgeInsets(top: 0, left: URLBarViewUX.LocationLeftPadding-1, bottom: 0, right: URLBarViewUX.LocationLeftPadding-1))
                }
                make.trailing.equalTo(self.vpnAccessButton.snp.leading)
                make.height.equalTo(URLBarViewUX.LocationHeight+2)
                make.centerY.equalTo(self)
            }
        }
    }
}
#endif

//
//  VPNButton.swift
//  VPNViews
//
//  Created by Tim Palade on 10/26/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit

class VPNButton: UIButton {
    
    enum StateVPN: Int {
        case Connect
        case Connecting
        case Disconnect
        case Disconnecting
        case Retry
        
        func labelColor() -> UIColor {
            switch self {
            case .Disconnect:
                return VPNUX.cliqzBlue
            default:
                return VPNUX.bgColor
            }
        }
        
        func toString() -> String {
            switch self {
            case .Connect:
                return "CONNECT"
            case .Connecting:
                return "CONNECTING"
            case .Disconnect:
                return "DISCONNECT"
            case .Disconnecting:
                return "DISCONNECTING"
            case .Retry:
                return "RETRY"
            }
        }
        
        func bgImage() -> UIImage? {
            switch self {
            case .Connect:
                return UIImage(named: "VPNButtonFilled")
            case .Disconnect:
                return UIImage(named: "VPNButtonOutline")
            case .Retry:
                return UIImage(named: "VPNButtonFilled")
            default:
                return UIImage(named: "VPNButtonFilled")
            }
        }
    }
    
    let labelContainer = UIView()
    let mainLabel = UILabel()
    let auxLabel = UILabel()
    
    let lastConnectButtonStateKey = "VPNLastConnectButtonStateKey"
    var currentState: StateVPN {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: lastConnectButtonStateKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let raw = UserDefaults.standard.value(forKey: lastConnectButtonStateKey) as? Int {
                if let state = StateVPN(rawValue: raw) {
                    return state
                }
            }
            
            return .Disconnect //default
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //add a container for the labels.
        //max width and height should be the side of the biggest rectangle that fits inside the circle
        //side = radius * sqrt(2)
        
        addSubview(labelContainer)
        labelContainer.addSubview(mainLabel)
        labelContainer.addSubview(auxLabel)
        
        labelContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.lessThanOrEqualTo(self.snp.height).multipliedBy(0.7) // sqrt(2) ~= 0.7
        }
        
        mainLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY).offset(6)
        }
        
        auxLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.centerY).offset(6)
        }
        
        setStyling()
    }
    
    func setStyling() {
        
        self.setBackgroundImage(currentState.bgImage(), for: .normal)
        
        self.layer.shadowColor = UIColor(red: 0, green: 175/255, blue: 240/255, alpha: 1.0).cgColor
        self.layer.shadowRadius = 4.0
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 1.0
        
        mainLabel.textColor = currentState.labelColor()
        auxLabel.textColor = currentState.labelColor()
        
        mainLabel.font = UIFont.systemFont(ofSize: 26, weight: .regular)
        auxLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        mainLabel.textAlignment = .center
        auxLabel.textAlignment = .center
        
        //        if let imageSize = self.backgroundImage(for: .normal)?.size {
        //            let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        //            self.layer.shadowPath = CGPath(roundedRect: rect, cornerWidth: imageSize.width/2, cornerHeight: imageSize.height/2, transform: nil)
        //        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(state: StateVPN) {
        
        currentState = state
        
        mainLabel.text = "VPN"
        auxLabel.text = state.toString()
        
        mainLabel.textColor = currentState.labelColor()
        auxLabel.textColor = currentState.labelColor()
        
        self.setBackgroundImage(state.bgImage(), for: .normal)
        if state == .Connecting || state == .Disconnecting {
            self.isUserInteractionEnabled = false
        }
        else {
            self.isUserInteractionEnabled = true
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControlState) {
        mainLabel.text = title
    }
}

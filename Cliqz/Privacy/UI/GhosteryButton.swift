//
//  GhosteryButton.swift
//  Client
//
//  Created by Tim Palade on 3/26/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import UIKit
import SnapKit

let didChangeTabNotification = Notification.Name(rawValue: "didChangeTab")
let didShowFreshTabNotification = Notification.Name(rawValue: "didShowFreshTabNotification")
let didLeaveOverlayNotification = Notification.Name(rawValue: "didLeaveOverlayNotification")

class GhosteryButton: InsetButton {
    
    private let ghosteryCount: GhosteryCount = GhosteryCount()
    fileprivate let ghosty = UIImageView()
    private let count = UILabel()
    private var isPrivate = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ghosteryCount.delegate = self
        
        setUpComponent()
        setUpConstaints()
    }
    
    func setUpComponent() {
        addSubview(ghosty)
        #if !PAID
        addSubview(count)
        #endif
        
        ghosty.backgroundColor = .clear
        count.backgroundColor = .clear
        
        count.text = "HELLO"
        count.textColor = .white
        count.font = UIFont.systemFont(ofSize: 14)
        
        #if PAID
        count.isHidden = true
        #endif
    }
    
    func setUpConstaints() {
        
        #if !PAID
        let height: CGFloat = 25.0
        let width = (ghosty.image?.widthOverHeight() ?? 1.0) * height
        var centerDifference: CGFloat = 0.0
        if isPrivate, let normalImage = UIImage.controlCenterNormalIcon(), let privImage = ghosty.image {
            let ratioNormal = normalImage.widthOverHeight()
            let ratioPrivate = privImage.widthOverHeight()
            let widthNormal = ratioNormal * height
            centerDifference = 1/2 * widthNormal * (ratioPrivate / ratioNormal - 1)
        }
        
        ghosty.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
        
        count.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview().offset(-centerDifference)
            make.bottom.equalToSuperview().offset(-4)
        }
        #else
        let height: CGFloat = 40.0
        let width = (ghosty.image?.widthOverHeight() ?? 1.0) * height
        ghosty.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCount(count: Int) {
        let count_str = String(count)
        
        if count <= 99 {
            self.count.text = count_str
        }
        else {
            self.count.text = "99"
        }
    }
    
    func lookDeactivated() {
        self.ghosty.alpha = 0.8
        self.count.alpha = 0.8
    }
    
    func lookActivated() {
        self.ghosty.alpha = 1.0
        self.count.alpha = 1.0
    }
}

extension GhosteryButton: Themeable {
    func applyTheme() {
        setUpConstaints()
        self.tintColor = UIColor.theme.browser.tint
    }
}

extension GhosteryButton: GhosteryCountDelegate {
    func updateCount(count: Int) {
        self.lookActivated()
        self.setCount(count: count)
        self.accessibilityValue = "\(count)"
    }
    
    func showHello() {
        self.count.text = "HELLO"
        self.lookDeactivated()
    }
}

extension GhosteryButton : PrivateModeUI {
    func applyUIMode(isPrivate: Bool) {
        self.isPrivate = isPrivate
        if isPrivate {
            ghosty.image = UIImage.controlCenterPrivateIcon()
        } else {
            ghosty.image = UIImage.controlCenterNormalIcon()
        }
        setUpConstaints()
    }
}

protocol GhosteryCountDelegate: class {
    func updateCount(count: Int)
    func showHello()
}

class GhosteryCount {
    
    weak var delegate: GhosteryCountDelegate? = nil
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(newTrackerDetected), name: detectedTrackerNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newTabSelected), name: didChangeTabNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(urlChanged), name: urlChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didShowFreshtab), name: didShowFreshTabNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLeaveOverlay), name: didLeaveOverlayNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func urlChanged(notification: Notification) {
        guard let del = UIApplication.shared.delegate as? AppDelegate, let currentTab = del.tabManager.selectedTab else {return}
        if let tab = notification.object as? Tab, tab == currentTab {
            update(notification)
        }
    }
    
    @objc func newTrackerDetected(notification: Notification) {
        guard let dict = notification.userInfo as? [String: Any], let pageURL = dict["url"] as? URL else { return }
        guard let currentTab = (UIApplication.shared.delegate as? AppDelegate)?.tabManager.selectedTab else { return }
        if currentTab.url == pageURL {
            update(notification)
        }
    }
    
    @objc func newTabSelected(notification: Notification) {
        update(notification)
    }
    
    @objc func didShowFreshtab(_ notification: Notification) {
        self.delegate?.showHello()
    }
    
    @objc func didLeaveOverlay(_ notification: Notification) {
        update(notification)
    }
    
    private func update(_ notification: Notification) {
        var count = 0
        
        if let userInfo = notification.userInfo, let url = userInfo["url"] as? URL, let host = url.normalizedHost {
            count = TrackerList.instance.detectedTrackerCountForPage(host)
        }
        
        self.delegate?.updateCount(count: count)
    }
}

extension UIImage {
    func widthOverHeight() -> CGFloat {
        return self.size.width / self.size.height
    }
    
    func heightOverWidth() -> CGFloat {
        return self.size.width / self.size.height
    }
}

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
    
    fileprivate var currentTheme: Theme = .Normal
    
    fileprivate let ghosty = UIImageView()
    private let count = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ghosteryCount.delegate = self
        
        setUpComponent()
        setUpConstaints(currentTheme)
    }
    
    func setUpComponent() {
        addSubview(ghosty)
        addSubview(count)
        
        ghosty.backgroundColor = .clear
        count.backgroundColor = .clear
        
        count.text = "HELLO"
        count.textColor = .white
        count.font = UIFont.systemFont(ofSize: 14)
    }
    
    func setUpConstaints(_ theme: Theme) {
        
        if theme == .Normal {
            ghosty.image = UIImage.init(named: "ghosty")
        }
        else {
            ghosty.image = UIImage.init(named: "ghostyPrivate")
        }
        
        let height: CGFloat = 25.0
        let width = (ghosty.image?.widthOverHeight() ?? 1.0) * height
        
        var centerDifference: CGFloat = 0.0
        if theme == .Private, let normalImage = UIImage.init(named: "ghosty"), let privImage = ghosty.image {
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
}

extension GhosteryButton: Themeable {
    func applyTheme(_ theme: Theme) {
        currentTheme = theme
        setUpConstaints(theme)
    }
}

extension GhosteryButton: GhosteryCountDelegate {
    func updateCount(count: Int) {
        self.setCount(count: count)
        self.accessibilityValue = "\(count)"
    }
    
    func showHello() {
        self.count.text = "HELLO"
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
        guard let dict = notification.userInfo as? [String: Any], let currentUrl = dict["url"] as? URL, let host = currentUrl.normalizedHost else { return }
        if let tab = notification.object as? Tab, tab == currentTab {
            let count = TrackerList.instance.detectedTrackerCountForPage(host)
            self.delegate?.updateCount(count: count)
        }
    }
    
    @objc func newTrackerDetected(notification: Notification) {
        guard let dict = notification.userInfo as? [String: Any], let currentUrl = dict["url"] as? URL, let host = currentUrl.normalizedHost else { return }
        let count = TrackerList.instance.detectedTrackerCountForPage(host)
        self.delegate?.updateCount(count: count)
    }
    
    @objc func newTabSelected(notification: Notification) {
        update(notification)
    }
    
    @objc func didShowFreshtab(_ notification: Notification) {
        self.delegate?.updateCount(count: 0)
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

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

class GhosteryButton: InsetButton {
    
    private let ghosteryCount: GhosteryCount = GhosteryCount()
    
    fileprivate var currentTheme: Theme = .Normal
    
    fileprivate let ghosty = UIImageView()
    private let circle = UIView()
    private let count = UILabel()
    
    let circleSize: CGFloat = 20
    
    init(frame: CGRect = CGRect.zero, dataSource: GhosteryCountDataSource) {
        super.init(frame: frame)
        ghosteryCount.delegate = self
        ghosteryCount.dataSource = dataSource
        
        setUpComponent()
        setUpConstaints()
        configureGhosty(currentTheme)
    }
    
    func setUpComponent() {
        addSubview(ghosty)
        addSubview(circle)
        circle.addSubview(count)
        
        circle.layer.cornerRadius = circleSize/2
        circle.backgroundColor = UIColor(colorString: "930194").withAlphaComponent(0.9)
        
        ghosty.backgroundColor = .clear
        count.backgroundColor = .clear
        
        count.text = "0"
        count.textColor = .white
        count.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
    }
    
    func setUpConstaints() {
        
        circle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(1)
            make.right.equalToSuperview().offset(-12)
            make.size.equalTo(circleSize)
        }
        
        count.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func configureGhosty(_ theme: Theme) {
        
        if theme == .Normal {
            ghosty.image = UIImage.init(named: "ghosty")
        }
        else {
            ghosty.image = UIImage.init(named: "ghostyPrivate")
        }
        
        let height: CGFloat = 40.0
        let width = (ghosty.image?.widthOverHeight() ?? 1.0) * height
        
        ghosty.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCount(count: Int) {
        
        let count_str = String(count)
        
        if count_str.count > 1 {
            self.count.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        }
        
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
        configureGhosty(theme)
    }
}

extension GhosteryButton: GhosteryCountDelegate {
    func updateCount(count: Int) {
        self.setCount(count: count)
    }
}

protocol GhosteryCountDelegate: class {
    func updateCount(count: Int)
}

protocol GhosteryCountDataSource: class {
    func currentUrl() -> URL?
}

class GhosteryCount {
    
    weak var delegate: GhosteryCountDelegate? = nil
    weak var dataSource: GhosteryCountDataSource? = nil
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(newTrackerDetected), name: detectedTrackerNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newTabSelected), name: didChangeTabNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(urlChanged), name: urlChangedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func urlChanged(notification: Notification) {
        guard let del = UIApplication.shared.delegate as? AppDelegate, let currentTab = del.tabManager.selectedTab else {return}
        if let tab = notification.object as? Tab, tab == currentTab, let currentUrl = self.dataSource?.currentUrl(), let host = currentUrl.normalizedHost {
            let count = TrackerList.instance.detectedTrackerCountForPage(host)
            self.delegate?.updateCount(count: count)
        }
    }
    
    @objc func newTrackerDetected(notification: Notification) {
        if let currentUrl = self.dataSource?.currentUrl(), let host = currentUrl.normalizedHost {
            let count = TrackerList.instance.detectedTrackerCountForPage(host)
            self.delegate?.updateCount(count: count)
        }
    }
    
    @objc func newTabSelected(notification: Notification) {
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

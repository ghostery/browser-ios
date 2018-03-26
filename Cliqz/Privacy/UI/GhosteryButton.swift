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
    
    private let ghosty = UIImageView()
    private let circle = UIView()
    private let count = UILabel()
    
    let circleSize: CGFloat = 20
    
    init(frame: CGRect = CGRect.zero, dataSource: GhosteryCountDataSource) {
        super.init(frame: frame)
        ghosteryCount.delegate = self
        ghosteryCount.dataSource = dataSource
        
        setUpComponent()
        setUpConstaints()
    }
    
    func setUpComponent() {
        addSubview(ghosty)
        addSubview(circle)
        circle.addSubview(count)
        
        circle.layer.cornerRadius = circleSize/2
        circle.backgroundColor = UIColor(colorString: "930194")
        
        ghosty.backgroundColor = .clear
        count.backgroundColor = .clear
        
        count.text = "0"
        count.textColor = .white
        count.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        
        ghosty.image = UIImage.init(named: "ghosty")
    }
    
    func setUpConstaints() {
        ghosty.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            let size = circleSize / 3
            let sideInset = (size * 1.09) / 2
            make.size.equalToSuperview().inset(UIEdgeInsets(top: size, left: sideInset, bottom: 0, right: sideInset))
        }
        
        circle.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.size.equalTo(circleSize)
        }
        
        count.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func newTrackerDetected(notification: Notification) {
        if let currentUrl = self.dataSource?.currentUrl() {
            let count = TrackerList.instance.detectedTrackerCountForPage(currentUrl.absoluteString)
            self.delegate?.updateCount(count: count)
        }
    }
    
    @objc func newTabSelected(notification: Notification) {
        var count = 0
        
        if let userInfo = notification.userInfo, let url = userInfo["url"] as? URL {
            count = TrackerList.instance.detectedTrackerCountForPage(url.absoluteString)
        }
        
        self.delegate?.updateCount(count: count)
    }
}

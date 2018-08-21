//
//  TopTabs.swift
//  Client
//
//  Created by Tim Palade on 5/16/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class CliqziPadTabsButton: UIButton {
    
    var titleBackgroundColor: UIColor = .white
    var textColor: UIColor = .white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage.templateImageNamed("cliqz-nav-tabs"), for: .normal)
        self.imageView?.tintColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTabCount(_ count: Int, animated: Bool = true) {
        // we don't show count in our tabs button
    }
}

extension CliqziPadTabsButton: Themeable {
    func applyTheme(_ theme: Theme) {
        // not supported
    }
}

class CliqzTopTabCell: TopTabCell {
    
    override var selectedTab: Bool {
        didSet {
            backgroundColor = selectedTab ? UIColor.cliqzBluePrimary : UIColor(colorString: "275574")
            titleText.textColor = selectedTab ? UIColor.white : UIColor.Photon.Grey40
            highlightLine.isHidden = !selectedTab
            closeButton.tintColor = selectedTab ? UIColor.white : UIColor.Photon.Grey40
            closeButton.backgroundColor = backgroundColor
            closeButton.layer.shadowColor = backgroundColor?.cgColor
            highlightLine.isHidden = true
        }
    }
}

class CliqzTopTabsViewController: TopTabsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        privateModeButton.snp.remakeConstraints { (make) in
            make.centerY.equalTo(view)
            make.leading.equalTo(view)
            make.size.equalTo(0)
        }
        
        privateModeButton.isHidden = true
        view.backgroundColor = UIColor.cliqzBluePrimary
    }
}

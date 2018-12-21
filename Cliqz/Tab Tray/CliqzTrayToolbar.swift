//
//  CliqzTrayToolbar.swift
//  Client
//
//  Created by Mahmoud Adam on 12/20/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class CliqzTrayToolbar : TrayToolbar {
    lazy var doneButton = TabTrayDoneButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deleteButton.removeFromSuperview()
        addTabButton.setImage(UIImage.templateImageNamed("cliqz-nav-add"), for: .normal)
        addTabButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(toolbarButtonSize)
        }
        
        addSubview(doneButton)
        doneButton.snp.makeConstraints { [unowned self] make in
            make.centerY.equalTo(self.addTabButton.snp.centerY)
            make.right.equalTo(self).offset(-sideOffset)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func applyTheme() {
        super.applyTheme()
        doneButton.setTitleColor(UIColor.theme.tabTray.tabTitleText, for: [])
    }
}

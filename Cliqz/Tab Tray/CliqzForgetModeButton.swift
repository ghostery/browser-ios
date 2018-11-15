//
//  CliqzForgetModeButton.swift
//  Client
//
//  Created by Mahmoud Adam on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import QuartzCore

class CliqzForgetModeButton: UIButton, Themeable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        #if PAID
            setTitle(NSLocalizedString("Private Tabs", tableName: "Lumen", comment: "Private tabs toogle button in tab overview"), for: [])
        #else
            setTitle(NSLocalizedString("Ghost Tabs", tableName: "Ghostery", comment: "Ghost tabs toogle button in tab overview"), for: [])
        #endif
        self.accessibilityIdentifier = "TabTrayController.forgetModeButton"
        self.layer.cornerRadius  = 5.0
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyTheme(_ theme: Theme) {
        setTitleColor(UIColor.CliqzTabTray.ButtonText.colorFor(theme), for: [])
        isSelected = theme == .Private
        accessibilityValue = isSelected ? PrivateModeStrings.toggleAccessibilityValueOn : PrivateModeStrings.toggleAccessibilityValueOff
    }
    
    func setSelected(_ selected: Bool, animated: Bool = true) {
        self.isSelected = selected
        let duration = animated ? 0.4 : 0.0
        UIView.transition(with: self, duration:duration, options: .curveEaseInOut, animations: {
            self.backgroundColor = selected ? UIColor.cliqzBluePrimary : UIColor.clear
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setSelected(isSelected, animated: false)
    }
}

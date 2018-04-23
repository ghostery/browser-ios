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
        setTitle(NSLocalizedString("Forget", tableName: "Cliqz", comment: "Forget toogle button in tab overview"), for: [])
        self.accessibilityIdentifier = "TabTrayController.forgetModeButton"
        self.layer.cornerRadius  = 5.0
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyTheme(_ theme: Theme) {
        setTitleColor(UIColor.CliqzTabTray.ButtonText.colorFor(theme), for: [])
    }
    
    func setSelected(_ selected: Bool, animated: Bool = true) {
        self.isSelected = selected
        let duration = animated ? 0.4 : 0.0
        UIView.transition(with: self, duration:duration, options: .curveEaseInOut, animations: {
            self.backgroundColor = selected ? UIColor.cliqzBluePrimary : UIColor.clear
        })
    }
    
}

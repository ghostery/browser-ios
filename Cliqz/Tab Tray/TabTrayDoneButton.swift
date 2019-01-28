//
//  TabTrayDoneButton.swift
//  Client
//
//  Created by Mahmoud Adam on 5/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class TabTrayDoneButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let title = NSLocalizedString("Done", comment: "Done button in the tabTray Toolbar")
        setTitle(title, for: .normal)
        accessibilityIdentifier = "TabTrayController.doneButton"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

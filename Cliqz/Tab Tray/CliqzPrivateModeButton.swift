//
//  CliqzPrivateModeButton.swift
//  Client
//
//  Created by Mahmoud Adam on 3/26/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

class CliqzPrivateModeButton: UIButton, PrivateModeUI {
    var offTint = UIColor.black
    var onTint = UIColor.black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityLabel = PrivateModeStrings.toggleAccessibilityLabel
        accessibilityHint = PrivateModeStrings.toggleAccessibilityHint
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        
        #if PAID
        setTitle(NSLocalizedString("Private", tableName: "Lumen", comment: "Private mode toggle button"), for: .normal)
        #else
        setTitle(NSLocalizedString("Forget Tabs", tableName: "Lumen", comment: "Forget mode toggle button"), for: .normal)
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyUIMode(isPrivate: Bool) {
        isSelected = isPrivate
        accessibilityValue = isSelected ? PrivateModeStrings.toggleAccessibilityValueOn : PrivateModeStrings.toggleAccessibilityValueOff
		
		// TODO: It should be moved to themes for private mode as well. Just a quick fix
		#if PAID
		let privateModeTitleColor = UIColor.lumenDeepBlue
		let selectedColor = UIColor.lumenBrightBlue
		#else
		let privateModeTitleColor = UIColor.theme.tabTray.toolbarButtonTint
		let selectedColor = UIColor.cliqzBluePrimary
		#endif
        self.setTitleColor(isPrivate ? privateModeTitleColor : UIColor.theme.tabTray.toolbarButtonTint, for: .normal)
        self.backgroundColor = isSelected ? selectedColor : UIColor.clear
    }
    
    func setSelected(_ selected: Bool, animated: Bool = true) {
        self.isSelected = selected
    }
    
}

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
        
        self.setTitleColor(isPrivate ? UIColor.lumenDeepBlue : UIColor.lumenBrightBlue, for: .normal)
        self.backgroundColor = isSelected ? UIColor.lumenBrightBlue : UIColor.clear
    }
    
    func setSelected(_ selected: Bool, animated: Bool = true) {
        self.isSelected = selected
    }
    
}

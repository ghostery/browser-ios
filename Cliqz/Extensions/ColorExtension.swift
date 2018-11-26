//
//  ColorExtension.swift
//  Client
//
//  Created by Sahakyan on 2/26/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation

//Lumen colors
//Enumerate all colors that I need

//Then have the colors for each element by component
//Ex: Dashboard - Shadow Color

//Every theme can have a number of modes
enum LumenThemeName {
    case Light
    case Dark
}

enum LumenThemeMode {
    case Private
    case Normal
    case Disabled
}

//What do I want? I want a structure to which I pass a theme name and mode and get the color for a certain element

//(theme, mode) -> UIColor
typealias LumenImage = (LumenThemeName, LumenThemeMode) -> UIImage?
typealias LumenImageCombo = [LumenThemeName: [LumenThemeMode : UIImage?]]
typealias LumenColor = (LumenThemeName, LumenThemeMode) -> UIColor
typealias LumenColorCombo = [LumenThemeName: [LumenThemeMode : UIColor]]

extension UIColor {
    //Enumerate lumen colors here
    static let lumenBrightBlue = UIColor(colorString: "3073DB")
    static let lumenDeepBlue = UIColor(colorString: "0D0F22")
    static let lumenPurple = UIColor(colorString: "1E2247")
}

struct Lumen {
    
    //helpers
    static let defaultColor: (LumenThemeName) -> UIColor = { name in
        if (name == .Light) {
            return .black
        }
        return .white
    }
    
    static let fallback: (LumenThemeName, LumenColorCombo) -> UIColor = { name, combo in
        return combo[name]?.values.first ?? Lumen.defaultColor(name)
    }
    
//    let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Private: .black], .Dark: [.Normal: .black, .Private: .black]]
    
    struct Browser {
        static let backgroundGradient: (LumenThemeName) -> ([CGColor], [NSNumber]) = { name in
            
            if name == .Light {
                return ([UIColor.white.cgColor, UIColor.white.cgColor], [0.0, 1.0])
            }
            
            return ([UIColor.lumenDeepBlue.cgColor, UIColor.lumenPurple.cgColor, UIColor.lumenDeepBlue.cgColor], [0.0, 0.5 ,1.0])
        }
    }
    
    struct VPN {
        static let separatorColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
    }
    
    struct Dashboard {
        static let backgroundColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .white, .Disabled: .white], .Dark: [.Normal: .black, .Disabled: .black]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let backgroundColorAlpha: (LumenThemeName) -> CGFloat = { name in
            if (name == .Light) {
                return 0.97
            }
            return 0.9
        }
        
        static let widgetBackgroundColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .white, .Disabled: .white], .Dark: [.Normal: .black, .Disabled: .black]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let shadowColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Disabled: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Disabled: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let widgetTextColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Disabled: .black], .Dark: [.Normal: .white, .Disabled: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let titleColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Disabled: .black], .Dark: [.Normal: .white, .Disabled: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let descriptionColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Disabled: .black], .Dark: [.Normal: .white, .Disabled: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let protectionLabelColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Disabled: .black], .Dark: [.Normal: .white, .Disabled: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let segmentedControlColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Disabled: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Disabled: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let buttonTitleColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Disabled: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Disabled: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let startButtonImage: LumenImage = { name, mode in
            let bright = UIImage(named: "CCPause_Bright")
            let dark   = UIImage(named: "CCPause_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
        
        static let startButtonImageSelected: LumenImage = { name, mode in
            let bright = UIImage(named: "CCStart_Bright")
            let dark   = UIImage(named: "CCStart_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
        
        static let VPNButtonImage: LumenImage = { name, mode in
            let bright = UIImage(named: "CCVPNOff_Bright")
            let dark   = UIImage(named: "CCVPNOff_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
        
        static let VPNButtonImageSelected: LumenImage = { name, mode in
            let bright = UIImage(named: "CCVPNOn_Bright")
            let dark   = UIImage(named: "CCVPNOn_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
        
        static let clearButtonImage: LumenImage = { name, mode in
            let bright = UIImage(named: "CCClear_Bright")
            let dark   = UIImage(named: "CCClear_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
    }
}

extension UIColor {
    //Primary Colors
	static let cliqzBluePrimary = UIColor(colorString: "00AEF0")
    static let cliqzBlackPrimary = UIColor(colorString: "1A1A25")
    static let cliqzWhitePrimary = UIColor(colorString: "FFFFFF")
    static let cliqzForgetPrimary =  UIColor(red: 0.067, green: 0.333, blue: 0.467, alpha: 1)
    
    //Secondary Colors
    static let cliqzBlueOneSecondary = UIColor(colorString: "0078CA")
    static let cliqzBlueTwoSecondary = UIColor(colorString: "2B5993")
    static let cliqzGrayOneSecondary = UIColor(colorString: "E7ECEE")
    static let cliqzGrayTwoSecondary = UIColor(colorString: "BFCBD6")
    static let cliqzGrayThreeSecondary = UIColor(colorString: "607c85")
    
    //Functional Colors
    static let cliqzPurpleFunctional = UIColor(colorString: "930194")
    static let cliqzGreenLightFunctional = UIColor(colorString: "9ECC42")
    static let cliqzGreenDarkFunctional = UIColor(colorString: "67A73A")
    static let cliqzPinkFunctional = UIColor(colorString: "FF7E74")
    static let cliqzGrayFunctional = UIColor(colorString: "97A4AE")
    
    //Other
    static let cliqzURLBarColor = UIColor(colorString: "4EABEA")
    
    struct CliqzTabTray {
        static let ButtonText = BrowserColor(normal: cliqzWhitePrimary, pbm: cliqzWhitePrimary)
    }
    
    struct CliqzToolbarButton {
        static let Tint = BrowserColor(normal: UIColor.white, pbm: UIColor.white)
        static let SelectedTint = BrowserColor(normal: UIColor.gray, pbm: UIColor.gray)
        static let DisabledTint = BrowserColor(normal: UIColor.gray, pbm: UIColor.gray)
    }
    
    struct CliqzToolbar {
        #if PAID
        static let Background = BrowserColor(normal: UIColor.lumenDeepBlue, pbm: UIColor.lumenDeepBlue)
        #else
        static let Background = BrowserColor(normal: UIColor.black, pbm: UIColor.black)
        #endif
    }
    struct CliqzURLBar {
        #if PAID
        static let Background = BrowserColor(normal: UIColor.lumenDeepBlue, pbm: UIColor.lumenDeepBlue)
        #else
        static let Background = BrowserColor(normal: UIColor.cliqzBluePrimary, pbm: UIColor.cliqzForgetPrimary)
        #endif
    }
    
	struct ControlCenter {
		static let restrictedColorSet = [
			UIColor(colorString: "E74055"),
			UIColor(colorString: "E95366"),
			UIColor(colorString: "EC6677"),
			UIColor(colorString: "EE7988"),
			UIColor(colorString: "F18C99"),
			UIColor(colorString: "F39FAA"),
			UIColor(colorString: "F5B3BB"),
			UIColor(colorString: "F7C5CC"),
			UIColor(colorString: "FAD9DD")
		]

		static let pausedColorSet = [
			UIColor(colorString: "97A4AE"),
			UIColor(colorString: "A1ADB6"),
			UIColor(colorString: "ACB6BE"),
			UIColor(colorString: "B6BFC6"),
			UIColor(colorString: "C1C8CE"),
			UIColor(colorString: "CBD1D6"),
			UIColor(colorString: "D5DBDF"),
			UIColor(colorString: "DFE3E6"),
			UIColor(colorString: "EAEDEF")
		]

	}
}

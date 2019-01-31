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
enum LumenThemeName: Int {
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
    static let lumenDisabled = UIColor(colorString: "BDC0CE")
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
    
    static let fallbackImage: (LumenThemeName, LumenImageCombo) -> UIImage? = { name, combo in
        return combo[name]?.values.first ?? nil
    }
    
//    let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Private: .black], .Dark: [.Normal: .black, .Private: .black]]
    
    struct Browser {
        static let backgroundGradient: (LumenThemeName) -> ([CGColor], [NSNumber]) = { name in
            
            if name == .Light {
                return ([UIColor.white.cgColor, UIColor.white.cgColor], [0.0, 1.0])
            }
            
            return ([UIColor.lumenDeepBlue.cgColor, UIColor.lumenPurple.cgColor, UIColor.lumenDeepBlue.cgColor], [0.0, 0.5 ,1.0])
        }
        
        static let homePanelSegmentedControlTint : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let toolBarColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .white, .Private: .white], .Dark: [.Normal: .lumenDeepBlue, .Private: .lumenDeepBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let toolBarButtonColorTint : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let toolBarButtonColorSelectedTint : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let toolBarButtonColorDisabledTint : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let homePanelTextColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Private: .black], .Dark: [.Normal: .white, .Private: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let tintColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
    }
    
    struct Search {
        static let textColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .white, .Private: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
    }
    
    struct URLBar {
        
        static let backgroundColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .white, .Private: .white], .Dark: [.Normal: .lumenDeepBlue, .Private: .lumenDeepBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let cancelButtonTextColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let readerModeButtonColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenDeepBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenDeepBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let readerModeButtonSelectedColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .white, .Private: .white], .Dark: [.Normal: .white, .Private: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let textFieldBackgroundColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenDeepBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenDeepBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let textFieldBorderColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let textFieldActiveBorderColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let textFieldTintColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let textFieldCursorColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .white, .Private: .lumenBrightBlue], .Dark: [.Normal: .white, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let textFieldTextColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .white, .Private: .lumenBrightBlue], .Dark: [.Normal: .white, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let textFieldTextColorInactive: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .white, .Private: .lumenBrightBlue], .Dark: [.Normal: .white, .Private: .lumenBrightBlue]]
            return combo[name]?[mode]?.withAlphaComponent(0.7) ?? Lumen.fallback(name, combo)
        }
        
        static let pageOptionsColorUnselected: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenDeepBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenDeepBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let pageOptionsColorSelected: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenDeepBlue, .Private: .lumenBrightBlue], .Dark: [.Normal: .lumenDeepBlue, .Private: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
    }
    
    struct VPN {
        static let separatorColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let selectTextColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black], .Dark: [.Normal: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let selectDetailTextColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let infoLabelTextColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue], .Dark: [.Normal: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let VPNButtonTextColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black], .Dark: [.Normal: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let countryTextColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black], .Dark: [.Normal: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let navigationBarTextColor : LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue], .Dark: [.Normal: .white]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let buttonImage: LumenImage = { name, mode in
            let image = UIImage(named: "VPNButtonOutline")
            let combo: LumenImageCombo  = [.Light: [.Normal: image, .Disabled: image], .Dark: [.Normal: image, .Disabled: image]]
            return combo[name]?[mode] ?? nil
        }
        
        static let mapImageInactive: LumenImage = { name, mode in
            let bright = UIImage(named: "VPNMapInactive_Bright")
            let dark = UIImage(named: "VPNMapInactive_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
        
        static let mapImageActive: LumenImage = { name, mode in
            let image = UIImage(named: "VPNMapActive")
            let combo: LumenImageCombo  = [.Light: [.Normal: image, .Disabled: image], .Dark: [.Normal: image, .Disabled: image]]
            return combo[name]?[mode] ?? nil
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
            let combo: LumenColorCombo  = [.Light: [.Normal: .lumenBrightBlue, .Disabled: .lumenDisabled], .Dark: [.Normal: .lumenBrightBlue, .Disabled: .lumenDisabled]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let widgetTextColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Disabled: .lumenDisabled], .Dark: [.Normal: .white, .Disabled: .lumenDisabled]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let titleColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Disabled: .lumenDisabled], .Dark: [.Normal: .white, .Disabled: .lumenDisabled]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
        }
        
        static let descriptionColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black, .Disabled: .lumenDisabled], .Dark: [.Normal: .white, .Disabled: .lumenDisabled]]
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
        
        static let timeSavedImage: LumenImage = { name, mode in
            let enabled  = UIImage(named: "CCCircle_Normal")
            let disabled = UIImage(named: "CCCircle_Disabled")
            let combo: LumenImageCombo  = [.Light: [.Normal: enabled, .Disabled: disabled], .Dark: [.Normal: enabled, .Disabled: disabled]]
            return combo[name]?[mode] ?? nil
        }
        
        
        static let disabledStartButtonImage: LumenImage = { name, mode in
            let bright = UIImage(named: "CCPause_disabled_Bright")
            let dark   = UIImage(named: "CCPause_disabled_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
        static let disabledVPNButtonImage: LumenImage = { name, mode in
            let bright = UIImage(named: "CCVPNOff_disabled_Bright")
            let dark   = UIImage(named: "CCVPNOff_disabled_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
        static let disabledClearButtonImage: LumenImage = { name, mode in
            let bright = UIImage(named: "CCClear_disabled_Bright")
            let dark   = UIImage(named: "CCClear_disabled_Dark")
            let combo: LumenImageCombo  = [.Light: [.Normal: bright, .Disabled: bright], .Dark: [.Normal: dark, .Disabled: dark]]
            return combo[name]?[mode] ?? nil
        }
        
        static let adsBlockedImage: LumenImage = { name, mode in
            let enabled  = UIImage(named: "CCAdBlocking_Normal")
            let disabled = UIImage(named: "CCAdBlocking_Disabled")
            let combo: LumenImageCombo  = [.Light: [.Normal: enabled, .Disabled: disabled], .Dark: [.Normal: enabled, .Disabled: disabled]]
            return combo[name]?[mode] ?? nil
        }
        
        static let batterySavedImage: LumenImage = { name, mode in
            let enabled  = UIImage(named: "CCBattery_Normal")
            let disabled = UIImage(named: "CCBattery_Disabled")
            let combo: LumenImageCombo  = [.Light: [.Normal: enabled, .Disabled: disabled], .Dark: [.Normal: enabled, .Disabled: disabled]]
            return combo[name]?[mode] ?? nil
        }
        
        static let companiesBlockedImage: LumenImage = { name, mode in
            let enabled  = UIImage(named: "CCCompanies_Normal")
            let disabled = UIImage(named: "CCCompanies_Disabled")
            let combo: LumenImageCombo  = [.Light: [.Normal: enabled, .Disabled: disabled], .Dark: [.Normal: enabled, .Disabled: disabled]]
            return combo[name]?[mode] ?? nil
        }
        
        static let antiphisingImage: LumenImage = { name, mode in
            let enabled  = UIImage(named: "CCHook_Normal")
            let disabled = UIImage(named: "CCHook_Disabled")
            let combo: LumenImageCombo  = [.Light: [.Normal: enabled, .Disabled: disabled], .Dark: [.Normal: enabled, .Disabled: disabled]]
            return combo[name]?[mode] ?? nil
        }
    }
    
    struct TabTray {
        static let highlightColor: LumenColor = { name, mode in
            let combo: LumenColorCombo  = [.Light: [.Normal: .black], .Dark: [.Normal: .lumenBrightBlue]]
            return combo[name]?[mode] ?? Lumen.fallback(name, combo)
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
    //TODO: FF14 Merge
    /*
    struct CliqzTabTray {
        #if !PAID
        static let ButtonText = BrowserColor(normal: cliqzWhitePrimary, pbm: cliqzWhitePrimary)
        static let PrivateTabsButtonText = BrowserColor(normal: cliqzWhitePrimary, pbm: cliqzWhitePrimary)
        static let ButtonText = BrowserColor(normal: UIColor.red, pbm: UIColor.red)
        static let PrivateTabsButtonText = BrowserColor(normal: UIColor.red, pbm: UIColor.red)
        #else
        static let ButtonText = BrowserColor(normal: .lumenBrightBlue, pbm: .lumenBrightBlue)
        static let PrivateTabsButtonText = BrowserColor(normal: .lumenBrightBlue, pbm: .lumenDeepBlue)
        #endif
    }
    
    struct CliqzToolbarButton {
        #if PAID
        static let Tint = BrowserColor(normal: Lumen.Browser.toolBarButtonColorTint(lumenTheme, .Normal), pbm: Lumen.Browser.toolBarButtonColorTint(lumenTheme, .Private))
        static let SelectedTint = BrowserColor(normal: Lumen.Browser.toolBarButtonColorSelectedTint(lumenTheme, .Normal), pbm: Lumen.Browser.toolBarButtonColorSelectedTint(lumenTheme, .Private))
        static let DisabledTint = BrowserColor(normal: Lumen.Browser.toolBarButtonColorDisabledTint(lumenTheme, .Normal), pbm: Lumen.Browser.toolBarButtonColorDisabledTint(lumenTheme, .Private))
        #else
        static let Tint = BrowserColor(normal: UIColor.white, pbm: UIColor.white)
        static let SelectedTint = BrowserColor(normal: UIColor.gray, pbm: UIColor.gray)
        static let DisabledTint = BrowserColor(normal: UIColor.gray, pbm: UIColor.gray)
        #endif
    }
    
    struct CliqzToolbar {
        #if PAID
        static let Background = BrowserColor(normal: Lumen.Browser.toolBarColor(lumenTheme, .Normal), pbm: Lumen.Browser.toolBarColor(lumenTheme, .Private))
        #else
        static let Background = BrowserColor(normal: UIColor.black, pbm: UIColor.black)
        #endif
    }
    struct CliqzURLBar {
        #if PAID
        static let Background = BrowserColor(normal: Lumen.URLBar.backgroundColor(lumenTheme, .Normal), pbm: Lumen.URLBar.backgroundColor(lumenTheme, .Private))
        #else
        static let Background = BrowserColor(normal: UIColor.cliqzBluePrimary, pbm: UIColor.cliqzForgetPrimary)
        #endif
    }
    */
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

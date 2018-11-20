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
}

//What do I want? I want a structure to which I pass a theme name and mode and get the color for a certain element

//(theme, mode) -> UIColor

typealias LumenColor = (LumenThemeName, LumenThemeMode) -> UIColor
typealias LumenColorCombo = [LumenThemeName: [LumenThemeMode : UIColor]]

extension UIColor {
    //Enumerate lumen colors here
}

struct Lumen {
    
    //helpers
    private static let bgCombo: LumenColorCombo  = [.Light: [.Normal: .white, .Private: .black], .Dark: [.Normal: .black, .Private: .white]]
    
    static let defaultColor: (LumenThemeName) -> UIColor = { name in
        if (name == .Light) {
            return .black
        }
        return .white
    }
    
    struct Dashboard {
        static let backgroundColor: LumenColor = { name, mode in
            return bgCombo[name]?[mode] ?? Lumen.defaultColor(name)
        }
        
        static let shadowColor: LumenColor = { name, mode in
            return bgCombo[name]?[mode] ?? Lumen.defaultColor(name)
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
        static let Background = BrowserColor(normal: UIColor.black, pbm: UIColor.black)
    }
    struct CliqzURLBar {
        static let Background = BrowserColor(normal: UIColor.cliqzBluePrimary, pbm: UIColor.cliqzForgetPrimary)
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

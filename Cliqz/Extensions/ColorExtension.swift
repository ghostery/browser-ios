//
//  ColorExtension.swift
//  Client
//
//  Created by Sahakyan on 2/26/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation

extension UIColor {
    //Primary Colors
	static let cliqzBluePrimary = UIColor(colorString: "00AEF0")
    static let cliqzBlackPrimary = UIColor(colorString: "1A1A25")
    static let cliqzWhitePrimary = UIColor(colorString: "FFFFFF")
    
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
    
    struct Browser {
        static let Background = BrowserColor(normal: Defaults.Grey10, pbm: Defaults.Grey10)
        static let Text = BrowserColor(normal: .white, pbm: .white)
        static let URLBarDivider = BrowserColor(normal: Defaults.MobileGreyC, pbm: Defaults.MobileGreyC)
        static let LocationBarBackground = Defaults.Grey30
        static let Tint = BrowserColor(normal: Defaults.Grey80, pbm: Defaults.Grey80)
    }
    
    struct URLBar {
        static let Border = BrowserColor(normal: Defaults.Grey50, pbm: Defaults.Grey50)
        static let ActiveBorder = BrowserColor(normal: Defaults.MobileBlueA, pbm: Defaults.MobileBlueA)
        static let Tint = BrowserColor(normal: Defaults.MobileBlueB, pbm: Defaults.MobileBlueB)
    }
    
    struct TextField {
        static let Background = BrowserColor(normal: .white, pbm: .white)
        static let TextAndTint = BrowserColor(normal: Defaults.Grey80, pbm: Defaults.Grey80)
        static let Highlight = BrowserColor(normal: Defaults.MobileBlueC, pbm: Defaults.MobileBlueC)
        static let ReaderModeButtonSelected = BrowserColor(normal: Defaults.MobileBlueD, pbm: Defaults.MobileBlueD)
        static let ReaderModeButtonUnselected = BrowserColor(normal: Defaults.Grey50, pbm: Defaults.Grey50)
        static let PageOptionsSelected = ReaderModeButtonSelected
        static let PageOptionsUnselected = UIColor.Browser.Tint
        static let Separator = BrowserColor(normal: Defaults.MobileGreyJ, pbm: Defaults.MobileGreyJ)
    }
    
    // The back/forward/refresh/menu button (bottom toolbar)
    struct ToolbarButton {
        static let SelectedTint = BrowserColor(normal: Defaults.MobileBlueD, pbm: Defaults.MobileBlueD)
        static let DisabledTint = BrowserColor(normal: UIColor.lightGray, pbm: UIColor.lightGray)
    }
    
    struct LoadingBar {
        static let Start = BrowserColor(normal: Defaults.MobileBlueB, pbm: Defaults.MobileBlueB)
        static let End = BrowserColor(normal: Defaults.Blue50, pbm: Defaults.Blue50)
    }
    
    struct TabTray {
        static let Background = Browser.Background
    }
    
    struct TopTabs {
        static let PrivateModeTint = BrowserColor(normal: Defaults.Grey10, pbm: Defaults.Grey10)
        static let Background = UIColor.Defaults.Grey80
    }
    
    struct HomePanel {
        // These values are the same for both private/normal.
        // The homepanel toolbar needed to be able to theme, not anymore.
        // Keep this just in case someone decides they want it to theme again
        static let ToolbarBackground = BrowserColor(normal: Defaults.Grey10, pbm: Defaults.Grey10)
        static let ToolbarHighlight = BrowserColor(normal: Defaults.Blue50, pbm: Defaults.Blue50)
        static let ToolbarTint = BrowserColor(normal: Defaults.Grey50, pbm: Defaults.Grey50)
    }
}

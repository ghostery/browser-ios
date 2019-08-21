//
//  GhosteryDarkTheme.swift
//  Client
//
//  Created by Mahmoud Adam on 1/23/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

#if !PAID
// Convenience reference to these normal mode colors which are used in a few color classes.
fileprivate let defaultBackground = UIColor.cliqzBluePrimary
fileprivate let defaultSeparator = UIColor.Photon.Grey60
fileprivate let defaultTextAndTint = UIColor.black
fileprivate let defaultTextSelectionColor = UIColor(colorString: "CFDCEC")

fileprivate class DarkTableViewColor: TableViewColor {
    override var rowBackground: UIColor { return UIColor.white }
    override var rowText: UIColor { return defaultTextAndTint }
    override var rowDetailText: UIColor { return UIColor.Photon.Grey30 }
    override var disabledRowText: UIColor { return UIColor.Photon.Grey40 }
    override var separator: UIColor { return UIColor.Photon.Grey30 }
    override var headerBackground: UIColor { return UIColor.white }
    override var headerTextLight: UIColor { return UIColor.darkGray }
    override var headerTextDark: UIColor { return UIColor.cliqzBluePrimary }
    override var syncText: UIColor { return defaultTextAndTint }
}

fileprivate class DarkActionMenuColor: ActionMenuColor {
    override var foreground: UIColor { return UIColor.white }
    override var iPhoneBackground: UIColor { return UIColor.Photon.Grey90.withAlphaComponent(0.9) }
    override var closeButtonBackground: UIColor { return defaultBackground }
    
}

fileprivate class DarkURLBarColor: URLBarColor {
    override var border: UIColor { return defaultBackground }
    override func activeBorder(_ isPrivate: Bool) -> UIColor {
		//TODO: For now I keep both options as probably it should be changed in future for private mode
        return !isPrivate ? UIColor.lightGray :  UIColor.lightGray
    }
    override func textSelectionHighlight(_ isPrivate: Bool) -> TextSelectionHighlight {
        let color = isPrivate ? UIColor(colorString: "AEC5DA") : defaultTextSelectionColor
        return (labelMode: color.withAlphaComponent(1), textFieldMode: color)
        
    }
    override var urlbarButtonTitleText: UIColor { return UIColor.white }
    override var urlbarButtonTint: UIColor { return UIColor.Photon.Grey10 }
    override var pageOptionsUnselected: UIColor { return UIColor.cliqzBluePrimary }
}

fileprivate class DarkBrowserColor: BrowserColor {
    override var background: UIColor { return defaultBackground }
    override var tint: UIColor { return UIColor.white }
}

// The back/forward/refresh/menu button (bottom toolbar)
fileprivate class DarkToolbarButtonColor: ToolbarButtonColor {
    override var selectedTint: UIColor { return UIColor.white }
    override var disabledTint: UIColor { return UIColor(colorString: "193162") }
}

fileprivate class DarkTabTrayColor: TabTrayColor {
    override var tabTitleText: UIColor { return defaultTextAndTint }
    override var tabTitleBlur: UIBlurEffectStyle { return UIBlurEffectStyle.extraLight }
    override var background: UIColor { return UIColor.Photon.Grey90 }
    override var cellBackground: UIColor { return defaultBackground }
    override var toolbar: UIColor { return UIColor.black }
    override var toolbarButtonTint: UIColor { return UIColor.white }
    override var cellCloseButton: UIColor { return defaultTextAndTint }
    override var cellTitleBackground: UIColor { return UIColor.Photon.Grey70 }
    override var searchBackground: UIColor { return UIColor.Photon.Grey60 }
}

fileprivate class DarkTopTabsColor: TopTabsColor {
    override var background: UIColor { return UIColor.Photon.Grey80 }
    override var tabBackgroundSelected: UIColor { return UIColor.Photon.Grey80 }
    override var tabBackgroundUnselected: UIColor { return UIColor.Photon.Grey80 }
    override var tabForegroundSelected: UIColor { return UIColor.Photon.Grey10 }
    override var tabForegroundUnselected: UIColor { return UIColor.Photon.Grey40 }
    override var closeButtonSelectedTab: UIColor { return tabForegroundSelected }
    override var closeButtonUnselectedTab: UIColor { return tabForegroundUnselected }
    override var separator: UIColor { return UIColor.Photon.Grey50 }
}

fileprivate class DarkTextFieldColor: TextFieldColor {
    override func background(_ isPrivate: Bool) -> UIColor {
		// TODO: it needs to be checked for the final designreview if both should be white or not. It was  UIColor(colorString: "3D3F4E") before. But it seems this is not right color
        return isPrivate ? UIColor(colorString: "2B6895") : UIColor.white
    }
    override var textAndTint: UIColor { return defaultTextAndTint }
    
}

fileprivate class DarkHomePanelColor: HomePanelColor {
    override var toolbarBackground: UIColor { return UIColor.black }
    override var toolbarHighlight: UIColor { return UIColor.Photon.Blue40 }
    override var toolbarTint: UIColor { return UIColor.Photon.Grey30 }
    override var panelBackground: UIColor { return UIColor.Photon.Grey90 }
    override var separator: UIColor { return defaultSeparator }
    override var border: UIColor { return UIColor.Photon.Grey60 }
    override var buttonContainerBorder: UIColor { return separator }
    
    override var welcomeScreenText: UIColor { return UIColor.Photon.Grey30 }
    override var bookmarkIconBorder: UIColor { return UIColor.Photon.Grey30 }
    override var bookmarkFolderBackground: UIColor { return UIColor.Photon.Grey80 }
    override var bookmarkFolderText: UIColor { return UIColor.Photon.White100 }
    override var bookmarkCurrentFolderText: UIColor { return UIColor.Photon.White100 }
    override var bookmarkBackNavCellBackground: UIColor { return UIColor.Photon.Grey70 }
    
    override var activityStreamHeaderText: UIColor { return UIColor.Photon.Grey30 }
    override var activityStreamCellTitle: UIColor { return UIColor.Photon.Grey20 }
    override var activityStreamCellDescription: UIColor { return UIColor.Photon.Grey30 }
    
    override var topSiteDomain: UIColor { return defaultTextAndTint }
    
    override var downloadedFileIcon: UIColor { return UIColor.Photon.Grey30 }
    
    override var historyHeaderIconsBackground: UIColor { return UIColor.clear }
    
    override var readingListActive: UIColor { return UIColor.Photon.Grey10 }
    override var readingListDimmed: UIColor { return UIColor.Photon.Grey40 }
    
    override var searchSuggestionPillBackground: UIColor { return UIColor.Photon.Grey70 }
    override var searchSuggestionPillForeground: UIColor { return defaultTextAndTint }
    
    override var topsitesLabel: UIColor { return UIColor.white }
}

fileprivate class DarkSnackBarColor: SnackBarColor {
    // Use defaults
}

fileprivate class DarkGeneralColor: GeneralColor {
    override var settingsTextPlaceholder: UIColor? { return UIColor.black }
    override var faviconBackground: UIColor { return UIColor.Photon.White100 }
    override var passcodeDot: UIColor { return UIColor.Photon.Grey40 }
	override var controlTint: UIColor { return UIColor.cliqzBluePrimary }
}

class DarkTheme: NormalTheme {
    override var name: String { return BuiltinThemeName.dark.rawValue }
    override var tableView: TableViewColor { return DarkTableViewColor() }
    override var urlbar: URLBarColor { return DarkURLBarColor() }
    override var browser: BrowserColor { return DarkBrowserColor() }
    override var toolbarButton: ToolbarButtonColor { return DarkToolbarButtonColor() }
    override var tabTray: TabTrayColor { return DarkTabTrayColor() }
    override var topTabs: TopTabsColor { return DarkTopTabsColor() }
    override var textField: TextFieldColor { return DarkTextFieldColor() }
    override var homePanel: HomePanelColor { return DarkHomePanelColor() }
    override var snackbar: SnackBarColor { return DarkSnackBarColor() }
    override var general: GeneralColor { return DarkGeneralColor() }
    override var actionMenu: ActionMenuColor { return DarkActionMenuColor() }
}

#endif

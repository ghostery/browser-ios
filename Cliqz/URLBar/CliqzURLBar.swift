//
//  CliqzURLBar.swift
//  Client
//
//  Created by Tim Palade on 3/12/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import UIKit
import SnapKit


let URLBarDidPressPageOptionsNotification = Notification.Name(rawValue: "NotificationURLBarDidPressPageOptions")

extension URLBarDelegate {
	
	func urlBarDidPressCliqzPageOptions(_ urlBar: URLBarView, from button: UIButton) {
		NotificationCenter.default.post(name: URLBarDidPressPageOptionsNotification, object: button)
	}

}

extension URLBarView {
    func updateCurrentQuery(_ autocompleteTextField: AutocompleteTextField, _ text: String) {
        if let view = autocompleteTextField.inputAccessoryView as? KeyboardAccessoryView {
            view.updateCurrentQuery(text)
        }
    }
}

class CliqzURLBar: URLBarView {

    struct UXOverrides {
        static let TextFieldBorderWidthSelected: CGFloat = 2.0
        static let LineHeight: CGFloat = 0.0
    }
    
    override var currentURL: URL? {
        get {
            return locationView.url as URL?
        }
        
        set(newURL) {
            locationView.url = newURL
            line.isHidden = newURL?.isAboutHomeURL ?? true
            if newURL != nil {
                pageOptionsButton.alpha = 0
            }
            
        }
    }
    
    let ghostyHeight = 54.0
    let ghostyWidth = 54.0
    
    private lazy var _cancelButton: UIButton = {
        let cancelButton = InsetButton()
        //cancelButton.setImage(UIImage.templateImageNamed("goBack"), for: .normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", tableName: "Cliqz", comment: "Cancel button title in the urlbar"), for: .normal)
        #if !PAID
        cancelButton.setTitleColor(.white, for: .normal)
        #else
        cancelButton.setTitleColor(Lumen.URLBar.cancelButtonTextColor(lumenTheme, .Normal), for: .normal)
        #endif
        cancelButton.setTitleColor(UIColor.cliqzBlueTwoSecondary, for: UIControlState.highlighted)
        cancelButton.accessibilityIdentifier = "urlBar-cancel"
        cancelButton.addTarget(self, action: #selector(didClickCancel), for: .touchUpInside)
        cancelButton.alpha = 0
        return cancelButton
    }()
    
    override var cancelButton: UIButton {
        get { return _cancelButton }
        set { _cancelButton = newValue }
    }
    
    lazy var ghosteryButton: GhosteryButton = {
        let button = GhosteryButton()
        button.accessibilityIdentifier = "ghosty"
        button.addTarget(self, action: #selector(SELdidClickGhosty), for: .touchDown)
        button.alpha = 1
        return button
    }()
    
    lazy var pageOptionsButton: UIButton = {
        let pageOptionsButton = UIButton(frame: .zero)
        pageOptionsButton.setImage(UIImage.templateImageNamed("menu-More-Options"), for: .normal)
        pageOptionsButton.addTarget(self, action: #selector(SELDidPressPageOptionsButton), for: .touchUpInside)
        pageOptionsButton.isAccessibilityElement = true
        pageOptionsButton.imageView?.contentMode = .left
        pageOptionsButton.accessibilityIdentifier = "UrlBar.pageOptionsButton"
        return pageOptionsButton
    }()
    
    @objc func SELdidClickGhosty(button: UIButton) {
        debugPrint("pressed ghosty")
		NotificationCenter.default.post(name: Notification.Name.GhosteryButtonPressed, object: self.currentURL?.absoluteString)
    }
    
    
    @objc func SELDidPressPageOptionsButton(button: UIButton) {
        self.delegate?.urlBarDidPressCliqzPageOptions(self, from: button)
    }
    
    override func commonInit() {
        super.commonInit()
        helper = CliqzTabToolbarHelper(toolbar: self)
    }
    
    override func setupConstraints() {
        
        if ghosteryButton.superview == nil {
            addSubview(ghosteryButton)
        }
        if pageOptionsButton.superview == nil {
            addSubview(pageOptionsButton)
        }
        
        line.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(self)
            make.height.equalTo(UXOverrides.LineHeight)
        }
        
        scrollToTopButton.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.right.equalTo(self.locationContainer)
        }
        
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).inset(URLBarViewUX.ProgressBarHeight / 2)
            make.height.equalTo(URLBarViewUX.ProgressBarHeight)
            make.left.right.equalTo(self)
        }
        
        locationView.snp.makeConstraints { make in
            make.edges.equalTo(self.locationContainer)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.safeArea.trailing).inset(10)
            make.centerY.equalTo(self.locationContainer)
            make.width.equalTo(self.cancelButton.intrinsicContentSize.width)
            make.height.equalTo(URLBarViewUX.ButtonHeight)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(self.safeArea.leading).offset(URLBarViewUX.Padding)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }
        
        forwardButton.snp.makeConstraints { make in
            make.left.equalTo(self.backButton.snp.right)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }
        
        stopReloadButton.snp.remakeConstraints { make in
            make.left.equalTo(self.forwardButton.snp.right)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }
        
        tabsButton.snp.remakeConstraints { make in
            make.trailing.equalTo(self.safeArea.trailing).offset(-URLBarViewUX.Padding)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }
        
        menuButton.snp.remakeConstraints { make in
            make.trailing.equalTo(self.tabsButton.snp.leading)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }
        
        ghosteryButton.snp.makeConstraints { (make) in
            make.width.equalTo(ghostyWidth)
            make.height.equalTo(ghostyHeight)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self.safeArea.trailing)//.offset(-URLBarViewUX.Padding)
        }
        
        pageOptionsButton.snp.makeConstraints { (make) in
            make.size.equalTo(TabLocationViewUX.ButtonSize)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self.ghosteryButton.snp.leading)
        }
        
        setStyle()
    }
    
    func setStyle() {
        locationContainer.layer.cornerRadius = 10
        locationContainer.clipsToBounds = true
    }
    
    override func prepareOverlayAnimation() {
        super.prepareOverlayAnimation()
        bringSubview(toFront: ghosteryButton)
        bringSubview(toFront: pageOptionsButton)
    }
    
    override func transitionToOverlay(_ didCancel: Bool = false) {
        super.transitionToOverlay()
        ghosteryButton.alpha = inOverlayMode ? 0 : 1
        if inOverlayMode {
            pageOptionsButton.alpha = 0
        } else {
            pageOptionsButton.alpha = self.currentURL == nil ? 1 : 0
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if inOverlayMode {
            // In overlay mode, we always show the location view full width
            self.locationContainer.layer.borderWidth = UXOverrides.TextFieldBorderWidthSelected
            self.locationContainer.snp.remakeConstraints { make in
                let height = URLBarViewUX.LocationHeight + (URLBarViewUX.TextFieldBorderWidthSelected * 2)
                make.height.equalTo(height)
                make.trailing.equalTo(self.cancelButton.snp.leading).offset(-10)
                make.leading.equalTo(self.safeArea.leading).offset(10)
                make.centerY.equalTo(self)
            }
            self.locationView.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationContainer).inset(UIEdgeInsets(equalInset: UXOverrides.TextFieldBorderWidthSelected))
            }
            self.locationTextField?.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationView).inset(UIEdgeInsets(top: 0, left: URLBarViewUX.LocationLeftPadding, bottom: 0, right: URLBarViewUX.LocationLeftPadding))
            }
        } else {
            self.ghosteryButton.snp.remakeConstraints { (make) in
                if self.toolbarIsShowing {
                    make.trailing.equalTo(self.menuButton.snp.leading)
                }
                else {
                    make.trailing.equalTo(self.safeArea.trailing)//.offset(-URLBarViewUX.Padding)
                }
                make.width.equalTo(ghostyWidth)
                make.height.equalTo(ghostyHeight)
                make.centerY.equalTo(self)
            }
            
            self.locationContainer.snp.remakeConstraints { make in
                if self.toolbarIsShowing {
                    // If we are showing a toolbar, show the text field next to the forward button
                    make.leading.equalTo(self.stopReloadButton.snp.trailing).offset(URLBarViewUX.Padding)
//                    if self.topTabsIsShowing {
//                        make.trailing.equalTo(self.menuButton.snp.leading).offset(-URLBarViewUX.Padding)
//                    } else {
//                        make.trailing.equalTo(self.tabsButton.snp.leading).offset(-URLBarViewUX.Padding)
//                    }
                    //make.trailing.equalTo(self.ghosteryButton.snp.leading).offset(-URLBarViewUX.Padding)
                    
                } else {
                    // Otherwise, left align the location view
                    make.leading/*.trailing*/.equalTo(self).inset(UIEdgeInsets(top: 0, left: URLBarViewUX.LocationLeftPadding-1, bottom: 0, right: URLBarViewUX.LocationLeftPadding-1))
                }
                
                make.trailing.equalTo(self.ghosteryButton.snp.leading)//.offset(-URLBarViewUX.Padding)
                
                make.height.equalTo(URLBarViewUX.LocationHeight+2)
                make.centerY.equalTo(self)
            }
            self.locationContainer.layer.borderWidth = URLBarViewUX.TextFieldBorderWidth
            self.locationView.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationContainer).inset(UIEdgeInsets(equalInset: URLBarViewUX.TextFieldBorderWidth))
            }
        }
        
    }
	
	override func tabLocationViewDidTapPageOptions(_ tabLocationView: TabLocationView, from button: UIButton) {
		self.delegate?.urlBarDidPressCliqzPageOptions(self, from: button)
	}

    // MARK:- keyboard Accessory View
    override func createLocationTextField() {
        super.createLocationTextField()
        
        if SettingsPrefs.shared.getCliqzSearchPref() {
            let keyboardAccessoryView = KeyboardAccessoryView.sharedInstance
            keyboardAccessoryView.setHandelAccessoryViewAction { [weak self] (action) in
                switch (action) {
                case .AutoComplete(let completion):
                    self?.locationTextField?.text = completion
                }
            }
            locationTextField?.inputAccessoryView = keyboardAccessoryView
        }
    }
    
    override func didApplyTheme(_ theme: Theme) {
        ghosteryButton.applyTheme(theme)
        pageOptionsButton.tintColor = UIColor.CliqzURLBar.Background.colorFor(theme)
    }
}

// Cliqz: hide keyboard
extension CliqzURLBar {
    func hideKeyboard() {
        locationTextField?.resignFirstResponder()
    }
}

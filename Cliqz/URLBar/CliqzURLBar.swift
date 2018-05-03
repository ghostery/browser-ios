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

class CliqzURLBar: URLBarView {

    struct UXOverrides {
        static let TextFieldBorderWidthSelected: CGFloat = 2.0
        static let LineHeight: CGFloat = 0.0
    }
    
    let ghostySize = URLBarViewUX.ButtonHeight
    
    override lazy var cancelButton: UIButton = {
        let cancelButton = InsetButton()
        //cancelButton.setImage(UIImage.templateImageNamed("goBack"), for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitleColor(UIColor.cliqzBlueTwoSecondary, for: UIControlState.highlighted)
        cancelButton.accessibilityIdentifier = "urlBar-cancel"
        cancelButton.addTarget(self, action: #selector(SELdidClickCancel), for: .touchUpInside)
        cancelButton.alpha = 0
        return cancelButton
    }()
    
    lazy var ghosteryButton: UIButton = {
        let button = GhosteryButton(dataSource: self)
        //button.setImage(UIImage.init(named: "ghosty"), for: .normal)
        button.accessibilityIdentifier = "ghosty"
        button.addTarget(self, action: #selector(SELdidClickGhosty), for: .touchUpInside)
        button.alpha = 1
        return button
    }()
    
    @objc func SELdidClickGhosty(button: UIButton) {
        debugPrint("pressed ghosty")
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            let trackersVC = TrackersController()
            if let pageUrl = self.currentURL?.absoluteString {
                trackersVC.trackers = TrackerList.instance.detectedTrackersForPage(pageUrl)
            }
            appDel.presentContollerOnTop(controller: trackersVC)
        }
    }
    
    override func commonInit() {
        super.commonInit()
        helper = CliqzTabToolbarHelper(toolbar: self)
    }
    
    override func setupConstraints() {
        
        if ghosteryButton.superview == nil {
            addSubview(ghosteryButton)
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
            make.size.equalTo(ghostySize)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self.safeArea.trailing).offset(-URLBarViewUX.Padding)
        }
        
        showQRScannerButton.snp.makeConstraints { make in
            make.leading.equalTo(self.locationContainer.snp.trailing)
            make.trailing.equalTo(self.cancelButton.snp.leading)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
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
    }
    
    override func transitionToOverlay(_ didCancel: Bool = false) {
        super.transitionToOverlay()
        ghosteryButton.alpha = inOverlayMode ? 0 : 1
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if inOverlayMode {
            // In overlay mode, we always show the location view full width
            self.locationContainer.layer.borderWidth = UXOverrides.TextFieldBorderWidthSelected
            self.locationContainer.snp.remakeConstraints { make in
                let height = URLBarViewUX.LocationHeight + (URLBarViewUX.TextFieldBorderWidthSelected * 2)
                make.height.equalTo(height)
                make.trailing.equalTo(self.showQRScannerButton.snp.leading)
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
                    make.trailing.equalTo(self.safeArea.trailing).offset(-URLBarViewUX.Padding)
                }
                make.size.equalTo(ghostySize)
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
                
                make.trailing.equalTo(self.ghosteryButton.snp.leading).offset(-URLBarViewUX.Padding)
                
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
		self.delegate?.urlBarDidPressCliqzPageOptions(self, from: tabLocationView.pageOptionsButton)
	}

    // MARK:- keyboard Accessory View
    override func createLocationTextField() {
        super.createLocationTextField()
        
        let keyboardAccessoryView = KeyboardAccessoryView.sharedInstance
        keyboardAccessoryView.setHandelAccessoryViewAction { [weak self] (action) in
            switch (action) {
            case .AutoComplete(let completion):
                self?.locationTextField?.text = completion
            }
        }
        locationTextField?.inputAccessoryView = keyboardAccessoryView
    }
    
    override func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didEnterText text: String) {
        if let view = autocompleteTextField.inputAccessoryView as? KeyboardAccessoryView {
            view.updateCurrentQuery(text)
        }
        super.autocompleteTextField(autocompleteTextField, didEnterText: text)
    }
    
    override func autocompleteTextFieldShouldClear(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        if let view = autocompleteTextField.inputAccessoryView as? KeyboardAccessoryView {
            view.updateCurrentQuery("")
        }
        return super.autocompleteTextFieldShouldClear(autocompleteTextField)
    }
    
    override func enterOverlayMode(_ locationText: String?, pasted: Bool, search: Bool) {
        super.enterOverlayMode(locationText, pasted: pasted, search: search)
        Engine.sharedInstance.sendUrlBarFocusEvent()
    }
    
    override func leaveOverlayMode(didCancel cancel: Bool = false) {
        super.leaveOverlayMode(didCancel: cancel)
        Engine.sharedInstance.sendUrlBarNotInFocusEvent()
    }
}

// Cliqz: hide keyboard
extension CliqzURLBar {
    func hideKeyboard() {
        locationTextField?.resignFirstResponder()
    }
}

extension CliqzURLBar: GhosteryCountDataSource {
    func currentUrl() -> URL? {
        return self.currentURL
    }
}

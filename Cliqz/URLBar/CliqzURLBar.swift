//
//  CliqzURLBar.swift
//  Client
//
//  Created by Tim Palade on 3/12/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import UIKit

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

    override func setupConstraints() {
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
        
        stopReloadButton.snp.makeConstraints { make in
            make.left.equalTo(self.forwardButton.snp.right)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.safeArea.trailing).offset(-URLBarViewUX.Padding)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }
        
        tabsButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.menuButton.snp.leading)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
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
    
    override func updateConstraints() {
        super.updateConstraints()
        if inOverlayMode {
            // In overlay mode, we always show the location view full width
            self.locationContainer.layer.borderWidth = UXOverrides.TextFieldBorderWidthSelected
            self.locationContainer.snp.remakeConstraints { make in
                let height = URLBarViewUX.LocationHeight + (URLBarViewUX.TextFieldBorderWidthSelected * 2)
                make.height.equalTo(height)
                make.trailing.equalTo(self.showQRScannerButton.snp.leading)
                //make.leading.equalTo(self.cancelButton.snp.trailing)
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
            self.locationContainer.snp.remakeConstraints { make in
                if self.toolbarIsShowing {
                    // If we are showing a toolbar, show the text field next to the forward button
                    make.leading.equalTo(self.stopReloadButton.snp.trailing).offset(URLBarViewUX.Padding)
                    if self.topTabsIsShowing {
                        make.trailing.equalTo(self.menuButton.snp.leading).offset(-URLBarViewUX.Padding)
                    } else {
                        make.trailing.equalTo(self.tabsButton.snp.leading).offset(-URLBarViewUX.Padding)
                    }
                    
                } else {
                    // Otherwise, left align the location view
                    make.leading.trailing.equalTo(self).inset(UIEdgeInsets(top: 0, left: URLBarViewUX.LocationLeftPadding-1, bottom: 0, right: URLBarViewUX.LocationLeftPadding-1))
                }
                
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
}

// Cliqz: hide keyboard
extension CliqzURLBar {
    func hideKeyboard() {
        locationTextField?.resignFirstResponder()
    }
}

//
//  CliqzTabLocationView.swift
//  Client
//
//  Created by Mahmoud Adam on 3/22/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import UIKit

let URLBarDidPressVideoDownloadNotification = Notification.Name(rawValue: "NotificationURLBarDidPressVideoDownload")

extension TabLocationViewDelegate {
    
    func tabLocationViewDidTapVideoDownload(_ tabLocationView: TabLocationView, for url: URL) {
        NotificationCenter.default.post(name: URLBarDidPressVideoDownloadNotification, object: url)
    }
}
extension TabLocationView {
    @objc func updateVideoDownloadButton() {
        
    }
}

class CliqzTabLocationView: TabLocationView {
    
    private lazy var videoDownloadButton: UIButton = {
        let videoDownloadButton = UIButton(frame: CGRect.zero)
        videoDownloadButton.setImage(UIImage(named: "downloadVideo"), for: .normal)
        videoDownloadButton.addTarget(self, action: #selector(SELtapVideoDownloadButton), for: .touchUpInside)
        videoDownloadButton.isAccessibilityElement = true
        videoDownloadButton.isHidden = true
        videoDownloadButton.imageView?.contentMode = .scaleAspectFit
        videoDownloadButton.contentHorizontalAlignment = .left
        videoDownloadButton.accessibilityIdentifier = "TabLocationView.downloadVideoButton"
        videoDownloadButton.accessibilityLabel = NSLocalizedString("Download Video", comment: "Accessibility label for the Download Video button")
        #if PAID
        videoDownloadButton.tintColor =  UIColor.lumenURLBarPurple
        #else
        videoDownloadButton.tintColor =  UIColor.cliqzBluePrimary
        #endif
        return videoDownloadButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        lockImageView.tintColor =  UIColor.URLBar.lockIconColor

        
        // re-init contectView
        contentView.removeFromSuperview()
        
        let subviews = [lockImageView, urlTextField, videoDownloadButton, readerModeButton, separatorLine, pageOptionsButton]
        contentView = UIStackView(arrangedSubviews: subviews)
        contentView.distribution = .fill
        contentView.alignment = .center
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.left.equalTo(self).inset(TabLocationViewUX.Spacing)
            make.top.right.bottom.equalTo(self)
        }
        
        videoDownloadButton.snp.makeConstraints { make in
            // The videoDownloadButton only has the padding on one side.
            // The buttons "contentHorizontalAlignment" helps make the button still look centered
            make.size.equalTo(TabLocationViewUX.ButtonSize - 10)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
    
    override func updateVideoDownloadButton() {
        guard let url = url  else {
            hideVideoDownloadButton()
            return
        }
        url.isYoutubeURL() ? showVideoDownloadButton() : hideVideoDownloadButton()
    }

    @objc func SELtapVideoDownloadButton() {
        if let url = url {
            delegate?.tabLocationViewDidTapVideoDownload(self, for: url)
        }
    }
    
    private func showVideoDownloadButton() {
        videoDownloadButton.isHidden = false
        separatorLine.isHidden = false
        readerModeButton.isHidden = true
    }
    
    private func hideVideoDownloadButton() {
        videoDownloadButton.isHidden = true
        separatorLine.isHidden = readerModeButton.isHidden
    }
}


extension TabLocationView: PrivateModeUI {
    func applyUIMode(isPrivate: Bool) {
        backgroundColor = UIColor.theme.textField.background(isPrivate)
        urlTextField.textColor = isPrivate ? UIColor.URLBar.privateTabTintColor : UIColor.URLBar.textColor
        lockImageView.tintColor = isPrivate ? UIColor.URLBar.privateTabTintColor : UIColor.URLBar.lockIconColor

        #if PAID
        if !isPrivate {
            readerModeButton.selectedTintColor = UIColor.black
            readerModeButton.unselectedTintColor = UIColor.lumenURLBarPurple

            pageOptionsButton.selectedTintColor = UIColor.black
            pageOptionsButton.unselectedTintColor = UIColor.lumenURLBarPurple
            pageOptionsButton.tintColor = UIColor.lumenURLBarPurple
            separatorLine.backgroundColor = UIColor.lumenURLBarPurple
        } else {
            readerModeButton.selectedTintColor = UIColor.lumenURLBarPurple
            readerModeButton.unselectedTintColor = UIColor.URLBar.privateTabTintColor

            pageOptionsButton.selectedTintColor = UIColor.lumenURLBarPurple
            pageOptionsButton.unselectedTintColor = UIColor.URLBar.privateTabTintColor
            pageOptionsButton.tintColor = UIColor.URLBar.privateTabTintColor
            separatorLine.backgroundColor = UIColor.URLBar.privateTabTintColor
        }
        #endif
    }
}

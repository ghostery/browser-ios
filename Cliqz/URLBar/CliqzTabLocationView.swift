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
    func updateVideoDownloadButton() {
        
    }
}

class CliqzTabLocationView: TabLocationView {
    
    private lazy var videoDownloadButton: UIButton = {
        let videoDownloadButton = UIButton(frame: CGRect.zero)
        videoDownloadButton.isHidden = true
        videoDownloadButton.setImage(UIImage(named: "downloadVideo"), for: .normal)
        videoDownloadButton.addTarget(self, action: #selector(SELtapVideoDownloadButton), for: .touchUpInside)
        videoDownloadButton.isAccessibilityElement = true
        videoDownloadButton.accessibilityLabel = NSLocalizedString("Download Video", comment: "Accessibility label for the Download Video button")
        return videoDownloadButton
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(videoDownloadButton)
        videoDownloadButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(separatorLine.snp.leading).offset(-9)
            make.size.equalTo(24)
        }
    }
    
    
    override func updateConstraints() {
        super.updateConstraints()
        urlTextField.snp.remakeConstraints { make in
            make.top.bottom.equalTo(self)
            
            if lockImageView.isHidden {
                make.leading.equalTo(self).offset(TabLocationViewUX.LocationContentInset)
            } else {
                make.leading.equalTo(self.lockImageView.snp.trailing).offset(TabLocationViewUX.URLBarPadding)
            }
            
            if !readerModeButton.isHidden {
                make.trailing.equalTo(self.readerModeButton.snp.leading).offset(-TabLocationViewUX.URLBarPadding)
            } else if !videoDownloadButton.isHidden {
                make.trailing.equalTo(self.videoDownloadButton.snp.leading).offset(-TabLocationViewUX.URLBarPadding)
            } else {
                make.trailing.equalTo(self.pageOptionsButton.snp.leading).offset(-TabLocationViewUX.URLBarPadding)
            }
        }
    }
    
    override func updateVideoDownloadButton() {
        guard let url = url  else {
            videoDownloadButton.isHidden = true
            return
        }
        videoDownloadButton.isHidden = !url.isYoutubeURL()
        if !videoDownloadButton.isHidden {
            separatorLine.isHidden = false
            readerModeButton.isHidden = true
        } else {
            separatorLine.isHidden = readerModeButton.isHidden
        }
    }
    
    func SELtapVideoDownloadButton() {
        if let url = url {
            delegate?.tabLocationViewDidTapVideoDownload(self, for: url)
        }
    }
}

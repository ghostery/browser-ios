//
//  VideoDownloader.swift
//  Client
//
//  Created by Mahmoud Adam on 3/25/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared

extension BrowserViewController {
    @objc func urlBarDidPressVideoDownload(notification: Notification) {
        if let videoUrl = notification.object as? URL {
            self.downloadVideoFromURL(videoUrl.absoluteString, sourceRect: urlBar.frame)
        }
    }
    
    func downloadVideoFromURL(_ url: String, sourceRect: CGRect) {
        
        let hudMessage = NSLocalizedString("Retrieving video information", tableName: "Cliqz", comment: "[VidoeDownloader] HUD message displayed while youtube downloader grabing the download URLs of the video")
        FeedbackUI.showLoadingHUD(hudMessage)
        
        Engine.sharedInstance.findVideoLinks(url: url, callback: { [weak self] (videoLinks) in
            DispatchQueue.main.async {
                var supportedVideoLinks = [[String: Any]]()
                for videoLink in videoLinks {
                    if let videoClass = videoLink["class"] as? String, videoClass == "video" {
                        supportedVideoLinks.append(videoLink)
                    }
                }
                self?.downloadVideoOfSelectedFormat(supportedVideoLinks, sourceRect: sourceRect)
            }
        })
    }
    
    private func downloadVideoOfSelectedFormat(_ videoLinks: [[String: Any]], sourceRect: CGRect) {
        FeedbackUI.dismissHUD()
        guard videoLinks.count > 0 else {
            return
        }
        let title = NSLocalizedString("Video quality", tableName: "Cliqz", comment: "[VidoeDownloader] Youtube downloader action sheet title")
        let message = NSLocalizedString("Please select video quality", tableName: "Cliqz", comment: "[VidoeDownloader] Youtube downloader action sheet message")
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for videoLink in videoLinks {
            if let name = videoLink["name"] as? String, let url = videoLink["url"] as? String {
                actionSheet.addAction(UIAlertAction(title: name, style: .default, handler: { [weak self] _ in
                    self?.doDownloadVideo(url)
                }))
            }
        }
        actionSheet.addAction(UIAlertAction(title: Strings.CancelString, style: .cancel, handler: nil))
        
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = view
            let center = self.view.center
            popoverPresentationController.sourceRect = CGRect(x: center.x, y: center.y, width: 1, height: 1)
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func doDownloadVideo(_ url: String) {
        let labelText = NSLocalizedString("Your video is being downloaded.", tableName: "Cliqz", comment: "[VidoeDownloader] Toast message shown when youtube video download started")
        DispatchQueue.main.async { [weak self] in
            let toast = ButtonToast(labelText: labelText, buttonText: Strings.OKString) { (_) in }
            self?.show(buttonToast: toast)
        }
        
        DownloadManager.downloadVideo(url) { [weak self] (error) in
            if let error = error {
                self?.showDownloadErrorMessage(error)
            } else {
                self?.showDownloadSuccessMessage()
            }
        }
    }
    
    private func showDownloadErrorMessage(_ error: DownloadError) {
        //TODO: Add messages for each error type
        var labelText = NSLocalizedString("Could not download Video.", tableName: "Cliqz", comment: "[VidoeDownloader] Toast message shown when youtube video download faild")
        if error == .mobileDataUsageLimited {
            labelText = NSLocalizedString("No Wi-Fi Connection message", tableName: "Cliqz", comment: "[VidoeDownloader] No Wi-Fi connection alert message")
        }
        let toast = ButtonToast(labelText: labelText, buttonText: Strings.OKString) { (_) in }
        self.show(buttonToast: toast)
    }
    
    private func showDownloadSuccessMessage() {
        let labelText = NSLocalizedString("The download is complete.", tableName: "Cliqz", comment: "[VidoeDownloader] Toast message shown when youtube video is Successfully downloaded")
        let buttonText = NSLocalizedString("Open the Photos", tableName: "Cliqz", comment: "[VidoeDownloader] Toast button text shown when youtube video is Successfully downloaded")
        DispatchQueue.main.async { [weak self] in
            let toast = ButtonToast(labelText: labelText, buttonText: buttonText) { (buttonPressed) in
                if buttonPressed, let photosAppUrl = URL(string: "photos-redirect://") {
                    UIApplication.shared.open(photosAppUrl, options: [:])
                }
            }
            self?.show(buttonToast: toast)
        }
    }
}

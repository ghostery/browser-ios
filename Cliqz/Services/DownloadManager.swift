//
//  DownloadManager.swift
//  Client
//
//  Created by Mahmoud Adam on 3/20/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared
import Photos
import Alamofire

enum DownloadError {
    case invaildUrl
    case notAuthorized
    case noInternetConnection
    case mobileDataUsageLimited
    case downloadFailed
}

class DownloadManager: NSObject {
    private static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // MARK:- Public APIs
    class func downloadVideo(_ url: String, completionHandler: @escaping (_ error: DownloadError?) -> Void) {
        if SettingsPrefs.shared.getLimitMobileDataUsagePref() && DeviceInfo.hasWwanConnectivity() {
            completionHandler(.mobileDataUsageLimited)
            return
        }
        
        PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
            guard authorizationStatus == .authorized  else {
                completionHandler(.notAuthorized)
                return
            }
            
            downloadFile(url, completionHandler: { (localPath, error) in
                if let localPath = localPath {
                    saveVideoToPhotoLibrary(localPath, completionHandler: completionHandler)
                } else {
                    completionHandler(error)
                }
            })
        })
    }
    
    class func downloadFile(_ url: String, completionHandler: @escaping (_ localPath: URL?, _ error: DownloadError?) -> Void) {
        guard let downloadUrl = url.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            completionHandler(nil, .invaildUrl)
            return
        }
        guard DeviceInfo.hasConnectivity() else {
            completionHandler(nil, .noInternetConnection)
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        var localPath: URL?
        Alamofire.download(downloadUrl, to: {  (temporaryURL, response) -> (destinationURL: URL, options: Alamofire.DownloadRequest.DownloadOptions) in
            let pathComponent = Date().description + (response.suggestedFilename ?? "")
            localPath = documentDirectory.appendingPathComponent(pathComponent)
            return (localPath!, [.removePreviousFile])
        })
            .response {
                response in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                if response.error != nil {
                    completionHandler(localPath, .downloadFailed)
                } else {
                    completionHandler(localPath, nil)
                }
        }
    }
    
    // MARK:- Private Helpers
    fileprivate class func saveVideoToPhotoLibrary(_ localPath: URL, completionHandler: @escaping (_ error: DownloadError?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localPath)
            creationRequest?.creationDate = Date()
        }) { completed, error in
            
            FileManager.default.deleteLocalFile(localPath)
            completionHandler(completed ? nil : .downloadFailed)
        }
    }
}

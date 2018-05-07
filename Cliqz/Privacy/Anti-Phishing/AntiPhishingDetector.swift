//
//  AntiPhishingDetector.swift
//  Client
//
//  Created by Mahmoud Adam on 8/18/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import Foundation
import Shared

let PhishingDetectedNotification = Notification.Name(rawValue: "PhishingDetectedNotification")

class AntiPhishingDetector: NSObject {
    
    //MARK: - Singltone
    static let antiPhisingAPIURL = "https://antiphishing.cliqz.com/api/bwlist?md5="
    static var detectedPhishingURLs = [URL]()
    static var disableForOneUrl = false
    
    //MARK: - public APIs
    class func isPhishingURL(_ url: URL, completion:@escaping (Bool) -> Void) {
        guard disableForOneUrl == false else { disableForOneUrl = false; return } 
        guard url.host != "localhost" else {
            completion(false)
            return
        }
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            AntiPhishingDetector.scanURL(url, queue: queue, completion: completion)
        }
    }
    
    class func isDetectedPhishingURL(_ url: URL) -> Bool {
        return detectedPhishingURLs.contains(url)
    }
    
    fileprivate class func scanURL(_ url: URL, queue: DispatchQueue, completion:@escaping (Bool) -> Void) {
        
        if let host = url.host {
            let md5Hash = host.md5()
            
            let middelIndex = md5Hash.index(md5Hash.startIndex, offsetBy: 16) //md5Hash.characters.index(md5Hash.startIndex, offsetBy: 16)
            
            let md5Prefix = md5Hash.substring(to: middelIndex)
            let md5Suffix = md5Hash.substring(from: middelIndex)
            
            let antiPhishingURL = antiPhisingAPIURL + md5Prefix
            
            ConnectionManager.sharedInstance.sendRequest(.get, url: antiPhishingURL, parameters: nil, responseType: .jsonResponse, queue: queue, onSuccess: { (result) in
                if let result = result as? [String: Any] {
                    if let blacklist = result["blacklist"] as? [Any] {
                        for suffixTuples in blacklist {
                            let suffixTuplesArray = suffixTuples as! [AnyObject]
                            if let suffix = suffixTuplesArray.first as? String, md5Suffix == suffix {
                                DispatchQueue.main.async(execute: {
                                    completion(true)
                                    detectedPhishingURLs.append(url)
                                    NotificationCenter.default.post(name: PhishingDetectedNotification, object: nil, userInfo: nil)
                                })
                            }
                        }
                        completion(false)
                    }
                }
            }, onFailure: { (data, error) in
                debugPrint(error)
                DispatchQueue.main.async(execute: {
                    completion(false)
                })
            })
        }
    }
}

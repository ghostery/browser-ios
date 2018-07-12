//
//  LoadingNotificationManager.swift
//  Client
//
//  Created by Tim Palade on 7/12/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class LoadingNotificationManager {
    weak var bvc: BrowserViewController? = nil
    static let shared = LoadingNotificationManager()
    var changesMade: Bool = false
    var notificationCount: Int = 0
    
    init() {
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            bvc = appDel.browserViewController
        }
    }
    
    func controlCenterShown() {
        changesMade = false
    }
    
    func controlCenterClosed() {
        if changesMade, let b = bvc {
            //show toast
            notificationCount += 1
            b.showBlocklistLoadToast()
        }
    }
    
    func changeInControlCenter() {
        changesMade = true
    }
    
    func loadingFinished() {
        if let b = bvc {
            notificationCount -= 1
            if notificationCount == 0 {
                //show
                b.showBlocklistLoadDoneToast()
            }
            else if notificationCount < 0 {
                notificationCount = 0
            }
        }
    }
}

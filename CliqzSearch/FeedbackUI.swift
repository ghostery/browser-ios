//
//  FeedbackUI.swift
//  Client
//
//  Created by Mahmoud Adam on 11/10/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import Foundation
import CRToast
import SVProgressHUD

public enum ToastMessageType {
    case info
    case error
    case done
}
class FeedbackUI: NSObject {
    static var defaultOptions : [AnyHashable: Any] = [
        kCRToastTextAlignmentKey : NSNumber(value: NSTextAlignment.left.rawValue),
        kCRToastNotificationTypeKey: NSNumber(value: CRToastType.navigationBar.rawValue),
        kCRToastNotificationPresentationTypeKey: NSNumber(value: CRToastPresentationType.cover.rawValue),
        kCRToastAnimationInTypeKey : NSNumber(value: CRToastAnimationType.linear.rawValue),
        kCRToastAnimationOutTypeKey : NSNumber(value: CRToastAnimationType.linear.rawValue),
        kCRToastAnimationInDirectionKey : NSNumber(value: CRToastAnimationDirection.top.rawValue),
        kCRToastAnimationOutDirectionKey : NSNumber(value: CRToastAnimationDirection.top.rawValue),
        kCRToastImageAlignmentKey: NSNumber(value: CRToastAccessoryViewAlignment.left.rawValue)
        
    ]
    
    //MARK:- Toast
    class func showToastMessage(_ message: String, messageType: ToastMessageType, timeInterval: TimeInterval? = nil, tabHandler: (() -> Void)? = nil) {
        var options : [AnyHashable: Any] = [kCRToastTextKey: message]
        
        switch messageType {
        case .info:
            options[kCRToastBackgroundColorKey] = UIColor(colorString: "E8E8E8")
            options[kCRToastImageKey] = UIImage(named:"toastInfo")!
            options[kCRToastTextColorKey] = UIColor.black
            
        case .error:
            options[kCRToastBackgroundColorKey] = UIColor(colorString: "E64C66")
            options[kCRToastImageKey] = UIImage(named:"toastError")!
        
        case .done:
            options[kCRToastBackgroundColorKey] = UIColor(colorString: "2CBA84")
            options[kCRToastImageKey] = UIImage(named:"toastCheckmark")!
            
        }
        
        if let timeInterval = timeInterval {
            options[kCRToastTimeIntervalKey] = timeInterval
        }
        
        if let tabHandler = tabHandler {
            let tapInteraction = CRToastInteractionResponder.init(interactionType: .tap, automaticallyDismiss: true) { (tap) in
                tabHandler()
            }
            options[kCRToastInteractionRespondersKey] = [tapInteraction]
        }
        
        // copy default options to the current options dictionary
        defaultOptions.forEach { options[$0] = $1 }
        
        DispatchQueue.main.async {
            CRToastManager.showNotification(options: options, completionBlock: nil)
        }
    }
    
    //MARK:- HUD
    class func showLoadingHUD(_ message: String) {
        DispatchQueue.main.async {
            SVProgressHUD.show(withStatus: message)
        }
    }

    class func dismissHUD() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    

}

//
//  ShareCardModule.swift
//  Client
//
//  Created by Tim Palade on 1/3/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import React

@objc(ShareCardModule)
open class ShareCardModule: RCTEventEmitter {
    @objc(share:success:error:)
    func share(data: NSDictionary, success: RCTResponseSenderBlock, error: RCTResponseErrorBlock) {
        debugPrint("share")
        if var image_data_str = data["url"] as? String {
            //the image_data_str has this format: "data:image/png;base64," + base64Image
            //so what I am interested in is after the ","
            let components = image_data_str.components(separatedBy: ",")
            
            if components.count == 2 {
                image_data_str = components[1]
            }
            
            if let image_data = Data.init(base64Encoded: image_data_str, options: .ignoreUnknownCharacters) {
                if let title = data["title"] as? String {
                    self.presentShareCardActivityViewController(title, data: image_data)
                    success([])
                }
            }
            else {
                let error_msg = NSError.init(domain: "com.cliqz.ShareCardModule", code: 0, userInfo: ["error": "Could not extract image from string"]) as Error
                error(error_msg)
            }
            
        }
    }
    
    
    func presentShareCardActivityViewController(_ title:String, data: Data) {

        let fileName = String(Date().timeIntervalSince1970 * 1000.0)
        let tempFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(fileName).png")
        do {
            try data.write(to: tempFile)
            var activityItems = [AnyObject]()
            //activityItems.append(TitleActivityItemProvider(title: title, activitiesToIgnore: [UIActivityType.init("net.whatsapp.WhatsApp.ShareExtension")]))
            activityItems.append(tempFile as AnyObject)
            
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            //activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [.assignToContact]
            
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
                if let target = activityType?.rawValue {
                    //TelemetryLogger.sharedInstance.logEvent(.ContextMenu(target, "card_sharing", ["is_success": completed]))
                }
                try? FileManager.default.removeItem(at: tempFile)
            }
            
            DispatchQueue.main.async {
                if let appDel = UIApplication.shared.delegate as? AppDelegate {
                    appDel.presentContollerOnTop(controller: activityViewController)
                }
            }

        } catch _ {
            
        }
    }
}

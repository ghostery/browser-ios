//
//  Engine.swift
//  jsengine
//
//  Created by Sam Macbeth on 21/02/2017.
//  Copyright © 2017 Cliqz GmbH. All rights reserved.
//

import Foundation
import React

open class Engine {
    
    //MARK: - Singleton
    static let sharedInstance = Engine()
    
    let bridge : RCTBridge
    open let rootView : RCTRootView
    
    //MARK: - Init
    public init() {
        #if React_Debug
            let jsCodeLocation = URL(string: "http://localhost:8081/index.bundle?platform=ios")
        #else
            let jsCodeLocation = Bundle.main.url(forResource: "jsengine.bundle", withExtension: "js")
        #endif
        
        rootView = RCTRootView( bundleURL: jsCodeLocation, moduleName: "ExtensionApp", initialProperties: nil, launchOptions: nil )
        bridge = rootView.bridge
        //ConnectManager.sharedInstance.refresh()
    }
    
    open func getBridge() -> JSBridge {
        return bridge.module(for: JSBridge.self) as! JSBridge
    }
    
//    open func getWebRequest() -> WebRequest {
//        return bridge.module(for: WebRequest.self) as! WebRequest
//    }
    
    open func getCrypto() -> Crypto {
        return bridge.module(for: Crypto.self) as! Crypto
    }
    
    //MARK: - Public APIs
    open func isRunning() -> Bool {
        return true
    }
    
    open func startup(_ defaultPrefs: [String: AnyObject]? = [String: AnyObject]()) {
        
    }
    
    open func shutdown(_ strict: Bool? = false) throws {
        
    }
    
    func setPref(_ prefName: String, prefValue: Any) {
        self.getBridge().callAction("core:setPref", args: [prefName, prefValue as! NSObject])
    }
    
    func getPref(_ prefName: String, callback: @escaping (Any) -> Void) {
        self.getBridge().callAction("core:getPref", args: [prefName]) { (result) in
            if let val = result["result"] as? [[String: Any]] {
                callback(val)
            }
        }
    }
    
    open func parseJSON(_ dictionary: [String: AnyObject]) -> String {
        if JSONSerialization.isValidJSONObject(dictionary) {
            do {
                let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                return jsonString
            } catch let error as NSError {
                //DebugingLogger.log("<< Error while parsing the dictionary into JSON: \(error)")
            }
        }
        return "{}"
    }
    
    //MARK: - Connect
    func requestPairingData() {
        self.getBridge().callAction("mobile-pairing:requestPairingData", args: [])
    }
    
    func receiveQRValue(_ qrCode: String) {
        self.getBridge().callAction("mobile-pairing:receiveQRValue", args: [qrCode])
    }
    
    func unpairDevice(_ deviceId: String) {
        self.getBridge().callAction("mobile-pairing:unpairDevice", args: [deviceId])
    }
    
    func renameDevice(_ peerId: String, newName: String) {
        self.getBridge().callAction("mobile-pairing:renameDevice", args: [peerId, newName])
    }
    
    // MARK :- Youtube Downloader
    func findVideoLinks(url: String, callback: @escaping ([[String: Any]]) -> ()) {
        
        let _ = self.getBridge().callAction("video-downloader:getVideoLinks", args: [url as AnyObject]) { (result) in
            if let results = result["result"] as? [String: Any], let videoLinks = results["formats"] as? [[String: Any]] {
                callback(videoLinks)
            }
        }
        
    }
    
    // MARK :- Search
    func sendUrlBarInputEvent(newString: String?, lastString: String?) {
        debugPrint("newString = \(newString ?? "null") | lastString = \(lastString ?? "null")")

        guard let newString = newString else {
            return
        }
        
        let contextId = "mobile-cards"
        var keyCode = ""
        let lastStringLength = lastString?.count ?? 0
		
        if lastStringLength - newString.count == 1 {
             keyCode = "Backspace"
        } else if newString.count > lastStringLength {
            keyCode = "Key" + String(newString.last!).uppercased()
        }

        self.getBridge().callAction("search:startSearch", args: [newString, ["key": keyCode], ["contextId": contextId]])
    }
}

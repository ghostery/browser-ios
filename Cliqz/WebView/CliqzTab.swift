//
//  CliqzTab.swift
//  Client
//
//  Created by Tim Palade on 3/23/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import WebKit

class CliqzTab: Tab {
    override func createWebview() {
        
        super.createWebview()
        
        //Cliqz: Privacy - Add handler for user scripts
        webView?.configuration.userContentController.add(URLInterceptor.shared, name: "cliqzTrackingProtection")
        webView?.configuration.userContentController.add(URLInterceptor.shared, name: "cliqzTrackingProtectionPostLoad")
        
        //Cliqz: Privacy - Add user scripts
        let source = try! String(contentsOf: Bundle.main.url(forResource: "preload", withExtension: "js")!)
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(script)
        
        let source2 = try! String(contentsOf: Bundle.main.url(forResource: "postload", withExtension: "js")!)
        let script2 = WKUserScript(source: source2, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView?.configuration.userContentController.addUserScript(script2)
    }
}

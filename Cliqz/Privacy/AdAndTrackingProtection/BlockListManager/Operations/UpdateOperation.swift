//
//  UpdateOperation.swift
//  Client
//
//  Created by Tim Palade on 6/5/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import WebKit

class UpdateOperation: Operation {
    
    private weak var webView: WKWebView? = nil
    private let domain: String?
    
    private var _executing: Bool = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    init(webView: WKWebView, domain: String?) {
        self.webView = webView
        self.domain = domain
        super.init()
    }
    
    override func main() {
        self.isExecuting = true
        let timer = ParkBenchTimer()
        var blockLists: [WKContentRuleList] = []
        let dispatchGroup = DispatchGroup()
        for type in BlockingCoordinator.order {
            if BlockingCoordinator.featureIsOn(forType: type, domain: domain) {
                //get the blocklists for that type
                dispatchGroup.enter()
                let (identifiers, info) = BlockingCoordinator.blockIdentifiers(forType: type, domain: domain, webView: webView)
                let shouldHitCache: Bool = info?["hitCache"] ?? true
                BlockListManager.shared.getBlockLists(forIdentifiers: identifiers, type: type, domain: domain, hitCache: shouldHitCache, callback: { (lists) in
                    blockLists.append(contentsOf: lists)
                    type == .antitracking ? debugPrint("Antitracking is ON") : debugPrint("Adblocking is ON")
                    dispatchGroup.leave()
                })
            }
            else {
                type == .antitracking ? debugPrint("Antitracking is OFF") : debugPrint("Adblocking is OFF")
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.webView?.configuration.userContentController.removeAllContentRuleLists()
            if let webView = self.webView {
                blockLists.forEach(webView.configuration.userContentController.add)
                debugPrint("BlockLists Loaded")
            }
            timer.stop()
            debugPrint("Load time: \(String(describing: timer.duration))")
            self.isFinished = true
        }
    }
}

//
//  BrowserViewController+ContextualMessages.swift
//  Client
//
//  Created by Mahmoud Adam on 3/19/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

extension BrowserViewController {
    
    @objc func handleContextualMessage(notification: Notification) {
        #if PAID
        if let messageType = notification.object as? ContextualMessageType {
            DispatchQueue.main.async { [weak self] in
                self?.showContextualMessage(messageType: messageType)
            }
        }
        #endif
    }
    
    func showContextualMessage(messageType: ContextualMessageType) {
        #if PAID
        self.contextualMessageView?.removeFromSuperview()
        self.contextualMessageView = nil
        
        switch messageType {
        case .onboarding:
            contextualMessageView = DashboardContextualOnboardingView()
            break
            
        case .expiredTrial:
            break
            
        case .adBlocking(let blockedAds):
            contextualMessageView = AdblokingContextualOnboardingView(blockedAdsCount: blockedAds)
            self.hideContextualMessageViewAfterDelay()
            
        case .antiTracking(let trackerName):
            contextualMessageView = AntitrackingContextualOnboardingView(trackerName: trackerName)
            self.hideContextualMessageViewAfterDelay()
            
        }
        if let messageView = contextualMessageView {
            messageView.alpha = 0
            webViewContainer.addSubview(messageView)
            webViewContainer.bringSubview(toFront: messageView)
            
            messageView.snp.makeConstraints { make in
                make.left.right.top.equalTo(self.webViewContainer)
                make.height.equalTo(70)
            }
            UIView.animate(withDuration: 1.0) {
                messageView.alpha = 1
            }
            // set the ContexualMessageView so that it can be shown & hidden with the urlBar
            scrollController.contextualMessageView = contextualMessageView
           
        }
        #endif
    }
    
    func hideContextualMessageViewAfterDelay() {
        #if PAID
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {[weak self] in
            self?.hideContextualMessageView()
        }
        #endif
    }
    
    func hideContextualMessageView() {
        #if PAID
        if let messageView = self.contextualMessageView {
            UIView.animate(withDuration: 1.0, animations: {
                messageView.alpha = 0
            }, completion: { [weak self]  (finished: Bool) -> Void in
                if finished {
                    messageView.removeFromSuperview()
                    self?.contextualMessageView = nil
                }
            })
        }
        #endif
    }
}

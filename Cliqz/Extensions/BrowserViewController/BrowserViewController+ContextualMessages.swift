//
//  BrowserViewController+ContextualMessages.swift
//  Client
//
//  Created by Mahmoud Adam on 3/19/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

private let contextualMessageDismissalPeriod = 20.0
private let contextualMessageViewHeight = 70.0


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
		guard self.contextualMessageView == nil else {
			self.webViewContainer.bringSubview(toFront: contextualMessageView!)
			return
		}

		switch messageType {
        case .onboarding:
            contextualMessageView = DashboardContextualOnboardingView()
            break
            
        case .expiredTrial:
            break
            
        case .adBlocking(let blockedAds):
            contextualMessageView = AdblokingContextualOnboardingView(blockedAdsCount: blockedAds)
            self.configureContextualMessageViewDismissal(view: contextualMessageView!)
            
        case .antiTracking(let trackerName):
            contextualMessageView = AntitrackingContextualOnboardingView(trackerName: trackerName)
            self.configureContextualMessageViewDismissal(view: contextualMessageView!)
            
        }
        if let messageView = contextualMessageView {
            messageView.alpha = 0
            webViewContainer.addSubview(messageView)
            webViewContainer.bringSubview(toFront: messageView)
            
            messageView.snp.makeConstraints { make in
                make.left.right.top.equalTo(self.webViewContainer)
                make.height.equalTo(contextualMessageViewHeight)
            }
            UIView.animate(withDuration: 1.0) {
                messageView.alpha = 1
            }
            // set the ContexualMessageView so that it can be shown & hidden with the urlBar
            scrollController.contextualMessageView = contextualMessageView
        }
        #endif
    }
    
    func hideContextualMessageView() {
        #if PAID
        if let messageView = self.contextualMessageView {
            UIView.animate(withDuration: 0.3, animations: {
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
    
    func hideContextualMessageViewWithMoveUpAnimation() {
        #if PAID
        if let messageView = self.contextualMessageView {
            UIView.animate(withDuration: 0.2, animations: {
                messageView.frame.origin.y = -messageView.frame.size.height
            }, completion: { [weak self]  (finished: Bool) -> Void in
                if finished {
                    messageView.removeFromSuperview()
                    self?.contextualMessageView = nil
                }
            })
        }
        #endif
    }
    
    
    // Private methods
    
    private func configureContextualMessageViewDismissal(view: UIView) {
        view.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.tapGestureAction(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureAction(_:)))
        swipeGestureRecognizer.direction = .up
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        self.hideContextualMessageViewAfterDelay()
    }
    
    
    private func hideContextualMessageViewAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + contextualMessageDismissalPeriod) {[weak self] in
            self?.hideContextualMessageView()
        }
    }
    
    private func logMessageViewClosing() {
        #if PAID
        if let messageView = self.contextualMessageView {
            var topic: String?
            if messageView is AdblokingContextualOnboardingView {
                topic = "onboarding_ad_blocking"
            } else if messageView is AntitrackingContextualOnboardingView {
                topic = "onboarding_anti_tracking"
            }
            if let topic = topic {
                LegacyTelemetryHelper.logMessage(action: "click", topic: topic, style: "notification", view: "web", target: "close")
            }
        }
        #endif
    }
    
    @objc private func tapGestureAction(_ sender: UITapGestureRecognizer) {
        self.logMessageViewClosing()
        self.hideContextualMessageView()
    }
    
    @objc private func swipeGestureAction(_ sender: UISwipeGestureRecognizer) {
        self.logMessageViewClosing()
        self.hideContextualMessageViewWithMoveUpAnimation()
    }
}

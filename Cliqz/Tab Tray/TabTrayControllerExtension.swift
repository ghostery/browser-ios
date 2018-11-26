//
//  TabTrayControllerExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 4/20/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension TabTrayController {

    @objc func didTapDone() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func SELlongPressDoneButton(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            self.didTapDelete(self.toolbar.doneButton)
        }
    }
    
    func setUpOverlay() {
        #if !PAID
        if privateMode && privateModeOverlay == nil{
            privateModeOverlay = UIView.overlay(frame: CGRect.zero)
            backgroundView.addSubview(privateModeOverlay!)
            backgroundView.bringSubview(toFront: privateModeOverlay!)
            privateModeOverlay?.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        else if !privateMode {
            privateModeOverlay?.removeFromSuperview()
            privateModeOverlay = nil
        }
        #endif
    }
    
    func setBackgroundImage() {
        #if !PAID
        collectionView.backgroundColor = UIColor.clear
        
        if backgroundView.superview == nil {
            self.view.addSubview(backgroundView)
            self.view.sendSubview(toBack: backgroundView)
        }
        
        if backgroundView.constraints.isEmpty {
            backgroundView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        self.backgroundView.image = UIImage.cliqzBackgroundImage()
        setUpOverlay()
        #endif
    }
    
    func updateBackgroundColor() {
        #if !PAID
        UIApplication.shared.windows.first?.backgroundColor = privateMode ? UIColor.cliqzForgetPrimary : UIColor.cliqzBluePrimary
        #endif
    }
    @objc func orientationDidChange(_ notification: Notification) {
        setBackgroundImage()
    }
}

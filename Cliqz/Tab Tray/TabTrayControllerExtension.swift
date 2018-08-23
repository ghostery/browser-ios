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
    
    func setBackgroundImage() {
        let backgroundView = UIImageView(image: UIImage.cliqzBackgroundImage())
        if privateMode {
            backgroundView.addSubview(UIView.overlay(frame: self.view.bounds))
        }
        collectionView.backgroundView = backgroundView
        collectionView.backgroundColor = UIColor.clear
    }
    
    func updateBackgroundColor() {
        UIApplication.shared.windows.first?.backgroundColor = privateMode ? UIColor.cliqzForgetPrimary : UIColor.cliqzBluePrimary
    }
    @objc func orientationDidChange(_ notification: Notification) {
        setBackgroundImage()
    }
}

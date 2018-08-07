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
        collectionView.backgroundView = UIImageView(image: UIImage.cliqzBackgroundImage(blurred: true))
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        setBackgroundImage()
    }
}

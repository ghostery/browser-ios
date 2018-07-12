//
//  CustomSimpleToast.swift
//  Client
//
//  Created by Tim Palade on 7/12/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

struct CustomSimpleToast {
    
    func showAlertWithText(_ text: String, bottomContainer: UIView) {
        let toast = self.createView()
        toast.text = text
        toast.tag = 101 // use this to see if there is a toast on screen already
        bottomContainer.addSubview(toast)
        toast.snp.makeConstraints { (make) in
            make.width.equalTo(bottomContainer)
            make.left.equalTo(bottomContainer)
            make.height.equalTo(SimpleToastUX.ToastHeight)
            make.bottom.equalTo(bottomContainer)
        }
        animate(toast)
    }
    
    fileprivate func createView() -> UILabel {
        let toast = UILabel()
        toast.textColor = UIColor.white
        toast.backgroundColor = SimpleToastUX.ToastDefaultColor
        toast.font = SimpleToastUX.ToastFont
        toast.textAlignment = .center
        return toast
    }
    
    fileprivate func dismiss(_ toast: UIView) {
        UIView.animate(withDuration: SimpleToastUX.ToastAnimationDuration,
                       animations: {
                        var frame = toast.frame
                        frame.origin.y = frame.origin.y + SimpleToastUX.ToastHeight
                        frame.size.height = 0
                        toast.frame = frame
        },
                       completion: { finished in
                        toast.removeFromSuperview()
        }
        )
    }
    
    fileprivate func animate(_ toast: UIView) {
        UIView.animate(withDuration: SimpleToastUX.ToastAnimationDuration,
                       animations: {
                        var frame = toast.frame
                        frame.origin.y = frame.origin.y - SimpleToastUX.ToastHeight
                        frame.size.height = SimpleToastUX.ToastHeight
                        toast.frame = frame
        },
                       completion: { finished in
                        let dispatchTime = DispatchTime.now() + SimpleToastUX.ToastDismissAfter
                        
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                            self.dismiss(toast)
                        })
        }
        )
    }
}



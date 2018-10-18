//
//  PaidControlCenterViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 10/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class PaidControlCenterViewController: ControlCenterViewController {

    fileprivate var containerView = UIView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupComponents() {
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor.white
        
        containerView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }

}

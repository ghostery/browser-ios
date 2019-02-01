//
//  UpgradLumenViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 2/1/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

class UpgradLumenViewController: UIViewController {
    #if PAID
    private let closeButton = UIButton()
    private let gradient = BrowserGradientView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupComponents()
        self.setStyles()
        self.setConstraints()
    }
    
    private func setupComponents() {
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        view.addSubview(gradient)
        view.sendSubview(toBack: gradient)
    }
    
    private func setStyles() {
        
    }
    
    private func setConstraints() {
        closeButton.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview().inset(25)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        gradient.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func closeView() {
        self.dismiss(animated: true)
    }
    
    #endif
}

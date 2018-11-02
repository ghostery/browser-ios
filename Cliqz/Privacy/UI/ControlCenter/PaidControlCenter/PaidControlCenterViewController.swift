//
//  PaidControlCenterViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 10/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class PaidControlCenterViewController: ControlCenterViewController {

    let dashboard = CCCollectionViewController()
    let cellDataSource = CCDataSource()
    
    override func setupComponents() {
        dashboard.dataSource = self
        self.addChildViewController(dashboard)
        self.view.addSubview(dashboard.view)
    }

}

extension PaidControlCenterViewController: CCCollectionDataSourceProtocol {
    func numberOfRows() -> Int {
        return cellDataSource.numberOfCells() - 1
    }
    
    func heightFor(index: Int) -> CGFloat {
        if index == 0 {
            return cellDataSource.heightFor(index: 0)
        }
        return cellDataSource.heightFor(index: index + 1)
    }
    
    func cellFor(index: Int) -> UIView {
        if index == 0 {
            let v = UIStackView()
            
            v.axis = .horizontal
            //v.spacing = 10
            v.distribution = .equalSpacing
            
            let c1 = CCVerticalCell(widgetRatio: CCUX.VerticalContentWidgetRatio, descriptionRatio: 1 - CCUX.VerticalContentWidgetRatio)
            let c2 = CCVerticalCell(widgetRatio: CCUX.VerticalContentWidgetRatio, descriptionRatio: 1 - CCUX.VerticalContentWidgetRatio)
            
            v.addArrangedSubview(c1)
            v.addArrangedSubview(c2)
            
            c1.snp.makeConstraints { (make) in
                make.width.equalToSuperview().dividedBy(2).offset(-5)
                make.height.equalToSuperview()
            }
            
            c2.snp.makeConstraints { (make) in
                make.width.equalToSuperview().dividedBy(2).offset(-5)
                make.height.equalToSuperview()
            }
            
            cellDataSource.configureCell(cell: c1, index: 0)
            cellDataSource.configureCell(cell: c2, index: 1)
            
            return v
        }
        
        let cell = CCHorizontalCell(widgetRatio: CCUX.HorizontalContentWigetRatio, descriptionRatio: 1 - CCUX.HorizontalContentWigetRatio)
        cellDataSource.configureCell(cell: cell, index: index + 1)
        
        return cell
    }
    
    func cellSpacing() -> CGFloat {
        return 22.0
    }
    
    func horizontalPadding() -> CGFloat {
        return 20
    }
}

//
//  CCDataSource.swift
//  Cockpit
//
//  Created by Tim Palade on 10/23/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit

protocol CCDataSourceProtocol {
    func titleFor(index: Int) -> String
    func descriptionFor(index: Int) -> String
    func widgetFor(index: Int) -> CCWidget
    func numberOfCells() -> Int
}

class CCDataSource {
    
    //struct and mapping
    //struct for cell
    //map: i -> cell struct
    
    struct CCCell {
        let title: String
        let description: String
        let widget: CCWidget
        let height: CGFloat
    }
    
    var cells: [CCCell] = []
    
    init() {
        //create the cells here
        let timeSaved = CCCell(title: "Time Saved", description: "that you can spend with your friends", widget: CCTimeSavedWidget(quanitity: 100, scale: "MIN"), height: 250)
        let adsBlocked = CCCell(title: "AdsBlocked", description: "so that you can enjoy surfing without ads", widget: CCAdsBlockedWidget(quanitity: 4000), height: 250)
        let dataSaved = CCCell(title: "Data Saved", description: "more than enough to watch another video", widget: CCDataSavedWidget(quanitity: 251, scale: "MB"), height: 120)
        let batterySaved = CCCell(title: "Battery Saved", description: "so that you can enjoy your phone a little longer", widget: CCBatterySavedWidget(quanitity: 225, scale: "MIN"), height: 120)
        let phishingProtection = CCCell(title: "Phishing protection", description: "so that you can swim freely with our browser", widget: CCAntiPhishingWidget(), height: 120)
        
        cells = [timeSaved, adsBlocked, dataSaved, batterySaved, phishingProtection]
    }
    
    func configureCell(cell: CCAbstractCell, index: Int) {
        cell.descriptionLabel.text = self.descriptionFor(index: index)
        cell.titleLabel.text = self.titleFor(index: index)
        cell.widget = self.widgetFor(index: index)
    }
}

extension CCDataSource: CCDataSourceProtocol {
    func titleFor(index: Int) -> String {
        guard cells.isIndexValid(index: index) else {
            return ""
        }
        return cells[index].title
    }
    
    func descriptionFor(index: Int) -> String {
        guard cells.isIndexValid(index: index) else {
            return ""
        }
        return cells[index].description
    }
    
    func widgetFor(index: Int) -> CCWidget {
        guard cells.isIndexValid(index: index) else {
            return CCWidget()
        }
        return cells[index].widget
    }
    
    func numberOfCells() -> Int {
        return cells.count
    }
    
    func heightFor(index: Int) -> CGFloat {
        guard cells.isIndexValid(index: index) else {
            return 120
        }
        return cells[index].height
    }
}

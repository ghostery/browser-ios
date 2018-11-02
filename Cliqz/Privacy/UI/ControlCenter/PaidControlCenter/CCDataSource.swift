//
//  CCDataSource.swift
//  Cockpit
//
//  Created by Tim Palade on 10/23/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit

class OptionalView: UIView {
    
}

class IncomeSlider: OptionalView {
    let slider = UISlider()

    let max: Float = 300
    
    let floatingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(slider)
        addSubview(floatingLabel)
        slider.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        floatingLabel.textAlignment = .center
        
        floatingLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(slider.snp.bottom).offset(10)
        }
        
        floatingLabel.text = "0 EUR"
        floatingLabel.textColor = CCUX.CliqzBlueGlow
        floatingLabel.font = UIFont.systemFont(ofSize: 20)
        
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        slider.setThumbImage(UIImage(named: "CCSliderThumb"), for: .normal)
        slider.tintColor = CCUX.CliqzBlueGlow //UIColor(red:0.24, green:0.40, blue:0.54, alpha:1.00)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func valueChanged(_ slider: UISlider) {
        floatingLabel.text = "\(Int(slider.value * max)) EUR"
    }
}

protocol CCDataSourceProtocol {
    func titleFor(index: Int) -> String
    func descriptionFor(index: Int) -> String
    func widgetFor(index: Int) -> CCWidget
    func numberOfCells() -> Int
    func optionalView(index: Int) -> OptionalView?
    func optionalViewHeight(index: Int) -> CGFloat?
}

class CCDataSource {
    
    //struct and mapping
    //struct for cell
    //map: i -> cell struct
    
    struct CCCell {
        let title: String
        let description: String
        let widget: CCWidget
        let cellHeight: CGFloat //cell total height
        let optionalView: OptionalView?
        let optionalViewHeight: CGFloat? //optional view height
        
        init(title: String, description: String, widget: CCWidget, cellHeight: CGFloat, optionalView: OptionalView? = nil, optionalViewHeight: CGFloat? = nil) {
            self.title = title
            self.description = description
            self.widget = widget
            self.cellHeight = cellHeight
            self.optionalView = optionalView
            self.optionalViewHeight = optionalViewHeight
        }
    }
    
    var cells: [CCCell] = []
    
    init() {
        //create the cells here
        let timeSaved = CCCell(title: "Time Saved", description: "that you can spend with your friends", widget: CCTimeSavedWidget(quanitity: 100, scale: "MIN"), cellHeight: 250)
        let adsBlocked = CCCell(title: "AdsBlocked", description: "so that you can enjoy surfing without ads", widget: CCAdsBlockedWidget(quanitity: 4000), cellHeight: 250)
        let dataSaved = CCCell(title: "Data Saved", description: "more than enough to watch another video", widget: CCDataSavedWidget(quanitity: 251, scale: "MB"), cellHeight: 120)
        let batterySaved = CCCell(title: "Battery Saved", description: "so that you can enjoy your phone a little longer", widget: CCBatterySavedWidget(quanitity: 225, scale: "MIN"), cellHeight: 120)
        let companies = CCCell(title: "Tracker Companies Blocked", description: "Companies with most trackers: Google, Facebook, Amazon,...", widget: CCCompaniesWidget(quanitity: 4000), cellHeight: 120)
        let moneySaved = CCCell(title: "Money Saved", description: "how much is your time worth per hour?", widget: CCMoneySavedWidget(quanitity: 251, scale: "EUR"), cellHeight: 204, optionalView: IncomeSlider(), optionalViewHeight: 84)
        let phishingProtection = CCCell(title: "Phishing protection", description: "so that you can swim freely with our browser", widget: CCAntiPhishingWidget(), cellHeight: 120)
        
        cells = [timeSaved, adsBlocked, dataSaved, batterySaved, companies, moneySaved, phishingProtection]
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
        return cells[index].cellHeight
    }
    
    func optionalView(index: Int) -> OptionalView? {
        guard cells.isIndexValid(index: index) else {
            return nil
        }
        return cells[index].optionalView
    }
    
    func optionalViewHeight(index: Int) -> CGFloat? {
        guard cells.isIndexValid(index: index) else {
            return nil
        }
        return cells[index].optionalViewHeight
    }
}

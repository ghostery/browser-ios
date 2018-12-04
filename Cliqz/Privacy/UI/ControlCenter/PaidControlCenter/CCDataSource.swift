//
//  CCDataSource.swift
//  Cockpit
//
//  Created by Tim Palade on 10/23/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//
#if PAID
import UIKit

class OptionalView: UIView {
    
}

protocol CCDataSourceProtocol {
    func titleFor(index: Int) -> String
    func descriptionFor(index: Int, period: Period) -> String
    func cellViewHeight(index: Int) -> CGFloat
    func widgetFor(index: Int) -> CCWidget
    func optionalView(index: Int) -> OptionalView?
    func optionalViewHeight(index: Int) -> CGFloat?
}

typealias CellDescription = (Period) -> String

let timeSavedDesc: CellDescription = ({ period in
    return NSLocalizedString("for things that really matter", tableName: "Lumen", comment:"[Lumen->Dashboard] time saved widget description")
})

let adsBlockedDesc: CellDescription = ({ period in
    return NSLocalizedString("Enjoy clutter-free browsing", tableName: "Lumen", comment:"[Lumen->Dashboard] AdsBlock widget description")
})

let dataSavedDesc: CellDescription = ({ period in
    return NSLocalizedString("Enjoy clutter-free browsing", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Saved widget description")
})

let batterySavedDesc: CellDescription = ({ period in
    return NSLocalizedString("for longer device usage", tableName: "Lumen", comment:"[Lumen->Dashboard] Battery Saved widget description")
})

let companiesDesc: CellDescription = ({ period in
    return NSLocalizedString("Number of tracker companies that tried to spy on you", tableName: "Lumen", comment:"[Lumen->Dashboard] Tracking companies widget description")
})

let phishingDesc: CellDescription = ({ period in
    return NSLocalizedString("prevents identity theft by fraudulent websites", tableName: "Lumen", comment:"[Lumen->Dashboard] Phishing protection widget description")
})

let moneySavedDesc: CellDescription = ({ period in
    
    if period == .Today {
        return "Was ist dir deine Zeit Wert?"
    }
    else if period == .Last7Days {
        return "Was ist dir deine Zeit Wert?"
    }
    
    return ""
})

class CellGroupView: UIStackView {
    
}

extension CellGroupView: UpdateViewProtocol {
    func update() {
        for subview in self.subviews {
            if let s = subview as? UpdateViewProtocol {
                s.update()
            }
        }
    }
}

class CCDataSource {
    
    //struct and mapping
    //struct for cell
    //map: i -> cell struct
    
    struct CCCell {
        let title: String
        let description: CellDescription
        let widget: CCWidget
        let cellHeight: CGFloat //cell total height
        let optionalView: OptionalView?
        let optionalViewHeight: CGFloat? //optional view height
        
        init(title: String, description: @escaping CellDescription, widget: CCWidget, cellHeight: CGFloat, optionalView: OptionalView? = nil, optionalViewHeight: CGFloat? = nil) {
            self.title = title
            self.description = description
            self.widget = widget
            self.cellHeight = cellHeight
            self.optionalView = optionalView
            self.optionalViewHeight = optionalViewHeight
        }
    }
    
    var currentPeriod: Period = .Today
    var cells: [CCCell] = []
    var cellViews: [UIView] = []
    
    init() {
        //create the cells here
        let timeSaved = CCCell(title: NSLocalizedString("Time Saved", tableName: "Lumen", comment:"[Lumen->Dashboard] Time Saved widget title"),
                               description: timeSavedDesc,
                               widget: CCTimeSavedWidget(),
                               cellHeight: 250)
        
        let adsBlocked = CCCell(title: NSLocalizedString("Ads Blocked", tableName: "Lumen", comment:"[Lumen->Dashboard] Ads Blocked widget title"),
                                description: adsBlockedDesc,
                                widget: CCAdsBlockedWidget(),
                                cellHeight: 250)
        
        let dataSaved = CCCell(title: NSLocalizedString("Data Volume Saved", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title"),
                               description: dataSavedDesc,
                               widget: CCDataSavedWidget(),
                               cellHeight: 120)
        
//        let batterySaved = CCCell(title: NSLocalizedString("Battery Life Saved", tableName: "Lumen", comment:"[Lumen->Dashboard] Battery Life Saved widget title"),
//                                  description: batterySavedDesc,
//                                  widget: CCBatterySavedWidget(),
//                                  cellHeight: 120)
        
        let companies = CCCell(title: NSLocalizedString("Data Collectors Detained", tableName: "Lumen", comment:"[Lumen->Dashboard]  widget title"),
                               description: companiesDesc,
                               widget: CCCompaniesWidget(),
                               cellHeight: 120)
        
        let phishingProtection = CCCell(title: NSLocalizedString("Phishing Protection", tableName: "Lumen", comment:"[Lumen->Dashboard] Phishing Protection widget title"),
                                        description: phishingDesc,
                                        widget: CCAntiPhishingWidget(),
                                        cellHeight: 120)
        
        cells = [timeSaved, adsBlocked, dataSaved, companies, phishingProtection]
        createCellViews()
    }
    
    func createCellViews() {
        
        //first group time saved and adsblocked
        let group = createTimeSaveAdsBlockedGroup()
        cellViews.append(group)
        
        //add the rest
        for i in 2..<cells.count {
            let cell = CCHorizontalCell(widgetRatio: CCUX.HorizontalContentWigetRatio,
                                        descriptionRatio: 1 - CCUX.HorizontalContentWigetRatio,
                                        optionalView: self.optionalView(index: i),
                                        optionalViewHeight: self.optionalViewHeight(index: i))
            
            self.configureCell(cell: cell, index: i, period: currentPeriod)
            
            cellViews.append(cell)
        }
    }
    
    func createTimeSaveAdsBlockedGroup() -> UIView {
        let v = CellGroupView()
        
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
        
        self.configureCell(cell: c1, index: 0, period: currentPeriod)
        self.configureCell(cell: c2, index: 1, period: currentPeriod)
        
        return v
    }
    
    func configureCell(cell: CCAbstractCell, index: Int, period: Period) {
        cell.descriptionLabel.text = self.descriptionFor(index: index, period: period)
        cell.titleLabel.text = self.titleFor(index: index)
        cell.widget = self.widgetFor(index: index)
    }
}

extension CCDataSource: CCCollectionDataSourceProtocol {
    func numberOfRows() -> Int {
        return self.cellViews.count
    }
    
    func heightFor(index: Int) -> CGFloat {
        //special case because of the group
        if index == 0 {
            return self.cellViewHeight(index: 0)
        }
        return self.cellViewHeight(index: index + 1)
    }
    
    func cellFor(index: Int) -> UIView {
        guard cellViews.isIndexValid(index) else { return UIView() }
        return cellViews[index]
    }
    
    func cellSpacing() -> CGFloat {
        return 22.0
    }
    
    func horizontalPadding() -> CGFloat {
        return 20
    }
}

extension CCDataSource: CCDataSourceProtocol {
    func titleFor(index: Int) -> String {
        guard cells.isIndexValid(index: index) else {
            return ""
        }
        return cells[index].title
    }
    
    func descriptionFor(index: Int, period: Period) -> String {
        guard cells.isIndexValid(index: index) else {
            return ""
        }
        return cells[index].description(period)
    }
    
    func widgetFor(index: Int) -> CCWidget {
        guard cells.isIndexValid(index: index) else {
            return CCWidget()
        }
        return cells[index].widget
    }
    
    func cellViewHeight(index: Int) -> CGFloat {
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

#endif

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

class IncomeSlider: OptionalView {
    let slider = UISlider()

    let max: Float = 200
    
    static let defaultValue: Int = 60 //euros
    let defaultSliderValueValue: Float = Float(IncomeSlider.defaultValue)/200
    
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
        
        slider.value = defaultSliderValueValue
        floatingLabel.text = "\(IncomeSlider.defaultValue) EUR / Stunde"
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
        floatingLabel.text = "\(Int(slider.value * max)) EUR / Stunde"
    }
}

protocol CCDataSourceProtocol {
    func titleFor(index: Int) -> String
    func descriptionFor(index: Int, period: Period) -> String
    func widgetFor(index: Int) -> CCWidget
    func numberOfCells() -> Int
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
    
    var cells: [CCCell] = []
    
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
        
        let batterySaved = CCCell(title: NSLocalizedString("Battery Life Saved", tableName: "Lumen", comment:"[Lumen->Dashboard] Battery Life Saved widget title"),
                                  description: batterySavedDesc,
                                  widget: CCBatterySavedWidget(),
                                  cellHeight: 120)
        
        let companies = CCCell(title: NSLocalizedString("Data Collectors Detained", tableName: "Lumen", comment:"[Lumen->Dashboard]  widget title"),
                               description: companiesDesc,
                               widget: CCCompaniesWidget(),
                               cellHeight: 120)
        
        let phishingProtection = CCCell(title: NSLocalizedString("Phishing Protection", tableName: "Lumen", comment:"[Lumen->Dashboard] Phishing Protection widget title"),
                                        description: phishingDesc,
                                        widget: CCAntiPhishingWidget(),
                                        cellHeight: 120)
        
//        let moneySaved = CCCell(title: "Geld gespart", description: moneySavedDesc, widget: CCMoneySavedWidget(), cellHeight: 204, optionalView: IncomeSlider(), optionalViewHeight: 84)
        
        cells = [timeSaved, adsBlocked, dataSaved, batterySaved, companies, phishingProtection]
    }
    
    func configureCell(cell: CCAbstractCell, index: Int, period: Period) {
        cell.descriptionLabel.text = self.descriptionFor(index: index, period: period)
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

#endif

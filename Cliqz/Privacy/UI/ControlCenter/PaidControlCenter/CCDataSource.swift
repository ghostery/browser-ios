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
    
    if period == .Today {
        return "2 Minuten um jemandem deine ungeteilte Aufmerksamkeit zu schenken"
    }
    else if period == .Last7Days {
        return "Genug Zeit um 1,3km zu gehen"
    }
    
    return ""
})

let adsBlockedDesc: CellDescription = ({ period in
    
    if period == .Today {
        return "Für ungestörtes Surfen"
    }
    else if period == .Last7Days {
        return "Für ungestörtes Surfen"
    }
    
    return ""
})

let dataSavedDesc: CellDescription = ({ period in
    
    if period == .Today {
        return "Genug um einen Song herunterzuladen"
    }
    else if period == .Last7Days {
        return "Genug für 8 Minuten lustige YouTube Videos"
    }
    
    return ""
})

let batterySavedDesc: CellDescription = ({ period in
    
    if period == .Today {
        return "Damit dein Handy etwas länger hält"
    }
    else if period == .Last7Days {
        return "Damit dein Handy etwas länger hält"
    }
    
    return ""
})

let companiesDesc: CellDescription = ({ period in
    
    if period == .Today {
        return "Firmen mit den meisten Trackern: Google, Facebook, Amazon"
    }
    else if period == .Last7Days {
        return "Firmen mit den meisten Trackern: Google, Facebook, Amazon"
    }
    
    return ""
})

let phishingDesc: CellDescription = ({ period in
    
    if period == .Today {
        return "Geschützt vor Webseiten, die versuchen vertrauliche Informationen zu stehlen."
    }
    else if period == .Last7Days {
        return "Geschützt vor Webseiten, die versuchen vertrauliche Informationen zu stehlen."
    }
    
    return ""
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
        let timeSaved = CCCell(title: "Zeit gespart", description: timeSavedDesc, widget: CCTimeSavedWidget(), cellHeight: 250)
        let adsBlocked = CCCell(title: "Ads blockiert", description: adsBlockedDesc, widget: CCAdsBlockedWidget(), cellHeight: 250)
        let dataSaved = CCCell(title: "Datenvolumen gespart", description: dataSavedDesc, widget: CCDataSavedWidget(), cellHeight: 120)
        let batterySaved = CCCell(title: "Akku gespart", description: batterySavedDesc, widget: CCBatterySavedWidget(), cellHeight: 120)
        let companies = CCCell(title: "Tracker-Firmen blockiert", description: companiesDesc, widget: CCCompaniesWidget(), cellHeight: 120)
        let phishingProtection = CCCell(title: "Phishing-Schutz", description: phishingDesc, widget: CCAntiPhishingWidget(), cellHeight: 120)
        let moneySaved = CCCell(title: "Geld gespart", description: moneySavedDesc, widget: CCMoneySavedWidget(), cellHeight: 204, optionalView: IncomeSlider(), optionalViewHeight: 84)
        
        cells = [timeSaved, adsBlocked, dataSaved, batterySaved, companies, phishingProtection, moneySaved]
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

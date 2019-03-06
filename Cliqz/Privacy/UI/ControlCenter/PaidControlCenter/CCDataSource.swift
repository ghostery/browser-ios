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
    return NSLocalizedString("No data wasted on ads", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Saved widget description")
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

enum WidgetType {
	case blockedTrackers
	case blockedAds
	case savedTime
	case savedData
	case blockedPhishingSites
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

	typealias TapHandler = (_ type: WidgetType) -> Void
	public var tapHandler: TapHandler?
	
	init(tapHandler: TapHandler? = nil) {
		self.tapHandler = tapHandler
        //create the cells here
        let timeSaved = CCCell(title: NSLocalizedString("Time Saved", tableName: "Lumen", comment:"[Lumen->Dashboard] Time Saved widget title"),
                               description: timeSavedDesc,
                               widget: CCTimeSavedWidget(),
                               cellHeight: 175)
        
        let adsBlocked = CCCell(title: NSLocalizedString("Ads Blocked", tableName: "Lumen", comment:"[Lumen->Dashboard] Ads Blocked widget title"),
                                description: adsBlockedDesc,
                                widget: CCAdsBlockedWidget(),
                                cellHeight: 175)
        
        let dataSaved = CCCell(title: NSLocalizedString("Data Volume Saved", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title"),
                               description: dataSavedDesc,
                               widget: CCDataSavedWidget(),
                               cellHeight: 175)
        
        let companies = CCCell(title: NSLocalizedString("Data Collectors Detained", tableName: "Lumen", comment:"[Lumen->Dashboard]  widget title"),
                               description: companiesDesc,
                               widget: CCCompaniesWidget(),
                               cellHeight: 175)
        
        let phishingProtection = CCCell(title: NSLocalizedString("Phishing Protection", tableName: "Lumen", comment:"[Lumen->Dashboard] Phishing Protection widget title"),
                                        description: phishingDesc,
                                        widget: CCAntiPhishingWidget(),
                                        cellHeight: 120)

        cells = [adsBlocked, companies, dataSaved, timeSaved, phishingProtection]
        createCellViews()
    }
    
    func createCellViews() {
        
        //first group time saved and adsblocked
        let group1 = createCellGroup(of: (0, 1))
        cellViews.append(group1)
		let group2 = createCellGroup(of: (2, 3))
		cellViews.append(group2)
		
        //add the rest
        for i in 4..<cells.count {
            let cell = CCHorizontalCell(widgetRatio: CCUX.HorizontalContentWigetRatio,
                                        descriptionRatio: 1 - CCUX.HorizontalContentWigetRatio,
                                        optionalView: self.optionalView(index: i),
                                        optionalViewHeight: self.optionalViewHeight(index: i))
            
            self.configureCell(cell: cell, index: i, period: currentPeriod)
            
            cellViews.append(cell)
        }
    }
    
	func createCellGroup(of indexPair: (Int, Int)) -> UIView {
        let v = CellGroupView()
        
        v.axis = .horizontal
        //v.spacing = 10
        v.distribution = .equalSpacing
        
        let c1 = CCVerticalCell(widgetRatio: CCUX.VerticalContentWidgetRatio, descriptionRatio: 1 - CCUX.VerticalContentWidgetRatio)
        let c2 = CCVerticalCell(widgetRatio: CCUX.VerticalContentWidgetRatio, descriptionRatio: 1 - CCUX.VerticalContentWidgetRatio)
        
        v.addArrangedSubview(c1)
        v.addArrangedSubview(c2)
        
        c1.snp.makeConstraints { (make) in
            make.width.equalToSuperview().dividedBy(2).offset(-10)
            make.height.equalToSuperview()
        }
        
        c2.snp.makeConstraints { (make) in
            make.width.equalToSuperview().dividedBy(2).offset(-10)
            make.height.equalToSuperview()
        }
        
        self.configureCell(cell: c1, index: indexPair.0, period: currentPeriod)
        self.configureCell(cell: c2, index: indexPair.1, period: currentPeriod)
        
        return v
    }
    
    func configureCell(cell: CCAbstractCell, index: Int, period: Period) {
        cell.titleLabel.text = self.titleFor(index: index)
        cell.widget = self.widgetFor(index: index)
		cell.tag = index
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
		cell.addGestureRecognizer(tapGesture)
		// Extremely bad solution but with current messy design of widgets, cells and datasources no better way.
		// ALL THESE WIDGETS/CELLS LOGIC SHOULD BE REFACTORED AND REDESIGNED. THIS IS AWEFUL
		if let c = cell as? CCHorizontalCell {
			c.countLabel.text = CCWidgetManager.shared.pagesChecked()
		}
    }

	@objc private func cellTapped(sender: UITapGestureRecognizer) {
		if let indx = sender.view?.tag {
			var widgetType: WidgetType?
			switch (indx) {
			case 0:
				widgetType = .blockedAds
			case 1:
				widgetType = .blockedTrackers
			case 2:
				widgetType = .savedData
			case 3:
				widgetType = .savedTime
			case 4:
				widgetType = .blockedPhishingSites
			default:
				break
			}
			if let type = widgetType {
				self.tapHandler?(type)
			}
		}
	}
}

extension CCDataSource: CCCollectionDataSourceProtocol {
    func numberOfRows() -> Int {
        return self.cellViews.count
    }
    
    func heightFor(index: Int) -> CGFloat {
        //special case because of the group
        if index < 2 {
            return self.cellViewHeight(index: index * 2)
        }
        return self.cellViewHeight(index: index * 2)
    }
    
    func cellFor(index: Int) -> UIView {
        guard cellViews.isIndexValid(index: index) else { return UIView() }
        return cellViews[index]
    }
    
    func cellSpacing() -> CGFloat {
        return 20.0
    }
    
    func horizontalPadding() -> CGFloat {
        return 10
    }
}

extension CCDataSource: CCDataSourceProtocol {
    func titleFor(index: Int) -> String {
        guard cells.isIndexValid(index: index) else {
            return ""
        }
        return cells[index].title
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

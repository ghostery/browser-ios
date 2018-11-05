//
//  CCWidget.swift
//  Cockpit
//
//  Created by Tim Palade on 10/23/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit
import SnapKit
import Shared

enum Period {
    case Today
    case Last7Days
}

class CCWidgetManager {
    //this is where the data for the widgets is managed.
    static let shared = CCWidgetManager()
    
    private let registeredWidgets = WeakList<CCWidget>()
    
    var currentPeriod: Period = .Today
    
    func registerWidget(widget: CCWidget) {
        registeredWidgets.insert(widget)
    }
    
    //period changed
    func update(period: Period) {
        currentPeriod = period
        //push update
        for widget in registeredWidgets {
            widget.update()
        }
    }
    
    func savedTime() -> (Int, String) {
        if currentPeriod == .Today {
            return (100, "MIN")
        }
        
        return (200, "MIN")
    }
    
    func adsBlocked() -> Int {
        if currentPeriod == .Today {
            return 4000
        }
        
        return 5000
    }
    
    func dataSaved() -> (Int, String) {
        if currentPeriod == .Today {
            return (100, "MB")
        }
        
        return (200, "MB")
    }
    
    func batterySaved() -> (Int, String) {
        if currentPeriod == .Today {
            return (100, "MIN")
        }
        
        return (200, "MIN")
    }
    
    func companies() -> Int {
        if currentPeriod == .Today {
            return 4000
        }
        
        return 5000
    }
    
    func moneySaved() -> (Int, String) {
        if currentPeriod == .Today {
            return (100, "EUR")
        }
        
        return (200, "EUR")
    }
}

class CCWidget: UIView {
    
    var imageView: UIImageView? = nil
    var mainLabel: UILabel? = nil
    var auxLabel: UILabel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        CCWidgetManager.shared.registerWidget(widget: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        //to be overriden
    }
}

class CCTimeSavedWidget: CCWidget {
    
    init() {
        super.init(frame: CGRect.zero)
        
        imageView = UIImageView()
        mainLabel = UILabel()
        mainLabel?.textColor = CCUX.CliqzBlueGlow
        mainLabel?.textAlignment = .center
        mainLabel?.font = UIFont.systemFont(ofSize: 36, weight: .regular)
        auxLabel = UILabel()
        auxLabel?.textColor = CCUX.CliqzBlueGlow
        auxLabel?.textAlignment = .center
        auxLabel?.font = UIFont.systemFont(ofSize: 36, weight: .ultraLight)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0.0
        stackView.addArrangedSubview(mainLabel!)
        stackView.addArrangedSubview(auxLabel!)
        
        self.addSubview(stackView)
        self.addSubview(imageView!)
        
        imageView!.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
        
        stackView.snp.makeConstraints { (make) in
            make.center.equalTo(imageView!.snp.center)
            make.size.equalTo(70)
        }
        
        imageView?.image = UIImage(named: "CCCircle")
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update() {
        let (quantity, scale) = CCWidgetManager.shared.savedTime()
        mainLabel?.text = String(quantity)
        auxLabel?.text = scale
    }
}

class CCAdsBlockedWidget: CCWidget {
    
    init() {
        super.init(frame: CGRect.zero)
        
        imageView = UIImageView()
        mainLabel = UILabel()
        mainLabel?.textColor = CCUX.CliqzBlueGlow
        mainLabel?.font = UIFont.systemFont(ofSize: 36, weight: .light)
        
        self.addSubview(imageView!)
        self.addSubview(mainLabel!)
        
        imageView!.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
        
        mainLabel!.snp.makeConstraints { (make) in
            make.center.equalTo(imageView!.snp.center)
        }
        
        imageView?.image = UIImage(named: "CCAdBlocking")
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update() {
        let quantity = CCWidgetManager.shared.adsBlocked()
        mainLabel?.text = String(quantity)
    }
}

class CCDataSavedWidget: CCWidget {
    static private let QuantityFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 50, weight: .ultraLight),
                                                 NSAttributedStringKey.foregroundColor: CCUX.CliqzBlueGlow]
    
    static private let ScaleFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 50, weight: .medium),
                                              NSAttributedStringKey.foregroundColor: CCUX.CliqzBlueGlow]
    
    
    init() {
        super.init(frame: CGRect.zero)
        
        mainLabel = UILabel()
        mainLabel?.textAlignment = .center
        mainLabel?.sizeToFit()
        
        auxLabel = UILabel()
        auxLabel?.textAlignment = .center
        auxLabel?.sizeToFit()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = -40.0
        stackView.addArrangedSubview(mainLabel!)
        stackView.addArrangedSubview(auxLabel!)
        
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().dividedBy(1.2)
        }
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(quanitity: Int, scale: String) {
        mainLabel?.attributedText = NSAttributedString(string: String(quanitity), attributes: CCDataSavedWidget.QuantityFontAttributes)
        auxLabel?.attributedText = NSAttributedString(string: scale, attributes: CCDataSavedWidget.ScaleFontAttributes)
    }
    
    override func update() {
        let (quantity, scale) = CCWidgetManager.shared.dataSaved()
        updateView(quanitity: quantity, scale: scale)
    }
}

class CCBatterySavedWidget: CCWidget {
    static private let QuantityFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 36, weight: .regular), NSAttributedStringKey.foregroundColor: CCUX.CliqzBlueGlow]
    static private let ScaleFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12, weight: .regular), NSAttributedStringKey.foregroundColor: CCUX.CliqzBlueGlow]
    
    init() {
        super.init(frame: CGRect.zero)
        
        imageView = UIImageView(image: UIImage.init(named: "CCBattery"))
        mainLabel = UILabel()
        mainLabel?.textAlignment = .center
        
        self.addSubview(imageView!)
        self.addSubview(mainLabel!)
        
        imageView!.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().dividedBy(1.5)
        })
        
        mainLabel!.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView!)
            make.top.equalTo(imageView!.snp.bottom)
        }
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(quanitity: Int, scale: String) {
        let attributedText = NSMutableAttributedString(string: String(quanitity), attributes: CCBatterySavedWidget.QuantityFontAttributes)
        attributedText.append(NSAttributedString(string: scale, attributes: CCBatterySavedWidget.ScaleFontAttributes))
        mainLabel?.attributedText = attributedText
    }
    
    override func update() {
        let (quantity, scale) = CCWidgetManager.shared.batterySaved()
        updateView(quanitity: quantity, scale: scale)
    }
}

class CCAntiPhishingWidget: CCWidget {
    
    init() {
        super.init(frame: CGRect.zero)
        
        imageView = UIImageView(image: UIImage.init(named: "CCHook"))
        self.addSubview(imageView!)
        
        imageView!.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CCCompaniesWidget: CCWidget {
    static private let QuantityFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 36, weight: .regular), NSAttributedStringKey.foregroundColor: CCUX.CliqzBlueGlow]
    static private let ScaleFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .regular), NSAttributedStringKey.foregroundColor: CCUX.CliqzBlueGlow]
    
    init() {
        super.init(frame: CGRect.zero)
        
        imageView = UIImageView(image: UIImage.init(named: "CCCompanies"))
        
        let container = UIView()
        
        mainLabel = UILabel()
        mainLabel?.textAlignment = .center
        mainLabel?.sizeToFit()
        
        auxLabel = UILabel()
        auxLabel?.textAlignment = .center
        auxLabel?.sizeToFit()
        
        self.addSubview(container)
        container.addSubview(imageView!)
        container.addSubview(mainLabel!)
        container.addSubview(auxLabel!)
        
        container.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.top.equalTo(imageView!.snp.top)
            make.bottom.equalTo(auxLabel!.snp.bottom)
        }
        
        imageView!.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        })
        
        mainLabel!.snp.makeConstraints { (make) in
            make.top.equalTo(imageView!.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        auxLabel!.snp.makeConstraints { (make) in
            make.top.equalTo(mainLabel!.snp.bottom).offset(-6)
            make.centerX.equalToSuperview()
        }
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(quanitity: Int) {
        let attributedText = NSMutableAttributedString(string: String(quanitity), attributes: CCCompaniesWidget.QuantityFontAttributes)
        let auxText = NSAttributedString(string: "COMPANIES", attributes: CCCompaniesWidget.ScaleFontAttributes)
        mainLabel?.attributedText = attributedText
        auxLabel?.attributedText = auxText
    }
    
    override func update() {
        let quantity = CCWidgetManager.shared.companies()
        updateView(quanitity: quantity)
    }
}

class CCMoneySavedWidget: CCWidget {
    static private let QuantityFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 50, weight: .ultraLight),
                                                 NSAttributedStringKey.foregroundColor: CCUX.CliqzBlueGlow]
    
    static private let ScaleFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 42, weight: .medium),
                                              NSAttributedStringKey.foregroundColor: CCUX.CliqzBlueGlow]
    
    
    init() {
        super.init(frame: CGRect.zero)
        
        mainLabel = UILabel()
        mainLabel?.textAlignment = .center
        mainLabel?.sizeToFit()
        
        auxLabel = UILabel()
        auxLabel?.textAlignment = .center
        auxLabel?.sizeToFit()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = -40.0
        stackView.addArrangedSubview(mainLabel!)
        stackView.addArrangedSubview(auxLabel!)
        
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().dividedBy(1.2)
        }
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(quanitity: Int, scale: String) {
        mainLabel?.attributedText = NSAttributedString(string: String(quanitity), attributes: CCMoneySavedWidget.QuantityFontAttributes)
        auxLabel?.attributedText = NSAttributedString(string: scale, attributes: CCMoneySavedWidget.ScaleFontAttributes)
    }
    
    override func update() {
        let (quantity, scale) = CCWidgetManager.shared.moneySaved()
        updateView(quanitity: quantity, scale: scale)
    }
}


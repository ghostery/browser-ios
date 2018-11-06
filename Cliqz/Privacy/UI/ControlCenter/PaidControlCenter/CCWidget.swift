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
    
    func savedTime() -> (String, String) {
        if currentPeriod == .Today {
            return ("2:32", "MIN")
        }
        
        return ("16:03", "MIN")
    }
    
    func adsBlocked() -> Int {
        if currentPeriod == .Today {
            return 432
        }
        
        return 3842
    }
    
    func dataSaved() -> (String, String) {
        if currentPeriod == .Today {
            return ("3,5", "MB")
        }
        
        return ("26,4", "MB")
    }
    
    func batterySaved() -> (String, String) {
        if currentPeriod == .Today {
            return ("4:01", "MIN")
        }
        
        return ("29:03", "MIN")
    }
    
    func companies() -> Int {
        if currentPeriod == .Today {
            return 89
        }
        
        return 234
    }
    
    func moneySaved() -> (String, String) {
        if currentPeriod == .Today {
            return ("2,54", "EUR")
        }
        
        return ("16,01", "EUR")
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
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        auxLabel?.adjustsFontSizeToFitWidth = true
        
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
            make.width.lessThanOrEqualTo(imageView!.snp.width).multipliedBy(0.7)
            make.height.equalTo(70)
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
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        auxLabel?.adjustsFontSizeToFitWidth = true
        
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
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        auxLabel?.adjustsFontSizeToFitWidth = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = -32.0
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
    
    func updateView(quanitity: String, scale: String) {
        mainLabel?.attributedText = NSAttributedString(string: quanitity, attributes: CCDataSavedWidget.QuantityFontAttributes)
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
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        auxLabel?.adjustsFontSizeToFitWidth = true
        
        self.addSubview(imageView!)
        self.addSubview(mainLabel!)
        
        imageView!.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().dividedBy(1.5)
        })
        
        mainLabel!.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView!)
            make.top.equalTo(imageView!.snp.bottom)
            make.width.lessThanOrEqualToSuperview().offset(-10)
        }
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(quanitity: String, scale: String) {
        let attributedText = NSMutableAttributedString(string: quanitity, attributes: CCBatterySavedWidget.QuantityFontAttributes)
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
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        auxLabel?.adjustsFontSizeToFitWidth = true
        
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
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        auxLabel?.adjustsFontSizeToFitWidth = true
        
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
        let auxText = NSAttributedString(string: "FIRMEN", attributes: CCCompaniesWidget.ScaleFontAttributes)
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
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        auxLabel?.adjustsFontSizeToFitWidth = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = -32.0
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
    
    func updateView(quanitity: String, scale: String) {
        mainLabel?.attributedText = NSAttributedString(string: quanitity, attributes: CCMoneySavedWidget.QuantityFontAttributes)
        auxLabel?.attributedText = NSAttributedString(string: scale, attributes: CCMoneySavedWidget.ScaleFontAttributes)
    }
    
    override func update() {
        let (quantity, scale) = CCWidgetManager.shared.moneySaved()
        updateView(quanitity: quantity, scale: scale)
    }
}


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
    
    func toString() -> String {
        switch self {
        case .Today:
            return "day"
        case .Last7Days:
            return "week"
        }
    }
}

extension Int {
    func add(num: Int?) -> Int {
        guard let num = num else {return self}
        return self + num
    }
}

class CCWidgetManager {
    //this is where the data for the widgets is managed.
    
    //Note: Time from ghostery comes in miliseconds. Data comes in bytes.
    
    static private func milisec2Sec(_ mili: Int?) -> Float? {
        guard let mili = mili else {return nil}
        return Float(mili) / 1000.0
    }
    
    static private func sec2Min(_ sec: Float?) -> Float? {
        guard let sec = sec else {return nil}
        return sec / 60
    }
    
    static private func min2Hour(_ min: Float?) -> Float? {
        guard let min = min else {return nil}
        return min / 60
    }
    
    static private func hour2Day(_ hour: Float?) -> Float? {
        guard let hour = hour else {return nil}
        return hour / 24
    }
    
    static private func bytes2MB(_ bytes: Float?) -> Float? {
        guard let bytes = bytes else {return nil}
        return bytes / 1000000.0
    }
    
    enum TimeUnit {
        case Seconds
        case Milliseconds
        case Minutes
        case Hours
        case Days
        
        func toString() -> String {
            switch self {
            case .Seconds:
                return "SEC"
            case .Milliseconds:
                return "MILLI"
            case .Minutes:
                return "MIN"
            case .Hours:
                return "HOURS"
            case .Days:
                return "DAYS"
            }
        }
    }
    
    enum DataUnit {
        case Bytes
        case Megabytes
        
        func toString() -> String {
            switch self {
            case .Bytes:
                return "BYTES"
            case .Megabytes:
                return "MB"
            }
        }
    }
    
    struct Info: Codable {
        let timeSaved: Int?
        let adsBlocked: Int?
        let dataSaved: Int?
        let batterySaved: Int?
        let trackersDetected: Int?
        
        func merge(info: Info) -> Info {
            let timeSaved = self.timeSaved?.add(num: info.timeSaved)
            let adsBlocked = self.adsBlocked?.add(num: info.adsBlocked)
            let dataSaved = self.dataSaved?.add(num: info.dataSaved)
            let batterySaved = self.dataSaved?.add(num: info.dataSaved)
            let trackersDetected = self.trackersDetected?.add(num: info.trackersDetected)
            
            return Info(timeSaved: timeSaved, adsBlocked: adsBlocked, dataSaved: dataSaved, batterySaved: batterySaved, trackersDetected: trackersDetected)
        }
        
        static var zero: Info {
            return Info(timeSaved: 0, adsBlocked: 0, dataSaved: 0, batterySaved: 0, trackersDetected: 0)
        }

        
        func timeSavedStrings() -> (String, String) {
            
            var unit: TimeUnit = .Seconds
            
            if var time = milisec2Sec(self.timeSaved) {
                if time > 59 {
                    //convert to mins
                    time = sec2Min(time) ?? 0.0
                    unit = .Minutes
                    
                    if time > 59 {
                        time = min2Hour(time) ?? 0.0
                        unit = .Hours
                        
                        if time > 24 {
                            time = hour2Day(time) ?? 0.0
                            unit = .Days
                        }
                    }
                }

                return (String(format: "%.1f", time), unit.toString())
            }
            
            return (String(0), unit.toString())
        }
        
        func dataSavedStrings() -> (String, String) {
            
            var unit: DataUnit = .Bytes
            
            var data = Float(self.dataSaved ?? 0)
            if data > 1000000.0 {
                data = bytes2MB(data) ?? 0.0
                unit = .Megabytes
            }
            
            return (String(format: "%.1f", data), unit.toString())
        }
        
        func batterySavedStrings() -> (String, String) {
            
            var unit: TimeUnit = .Seconds
            
            if var time = milisec2Sec(self.batterySaved) {
                if time > 59 {
                    //convert to mins
                    time = sec2Min(time) ?? 0.0
                    unit = .Minutes
                    
                    if time > 59 {
                        time = min2Hour(time) ?? 0.0
                        unit = .Hours
                        
                        if time > 24 {
                            time = hour2Day(time) ?? 0.0
                            unit = .Days
                        }
                    }
                }
                
                return (String(format: "%.1f", time), unit.toString())
            }
            
            return (String(0), unit.toString())
        }
    }
    
    static let shared = CCWidgetManager()
    
    private let registeredWidgets = WeakList<CCWidget>()
    
    var currentPeriod: Period = .Today
    
    var todayInfo: Info = Info.zero
    var last7DaysInfo: Info = Info.zero
    
    func registerWidget(widget: CCWidget) {
        registeredWidgets.insert(widget)
    }
    
    //period changed
    func update(period: Period) {
        currentPeriod = period
        //push update
        
        Engine.sharedInstance.getBridge().callAction("insights:getDashboardStats", args: [currentPeriod.toString()]) { [weak self] (response) in
            print("getDashboardStats = \(response)")
            if let info = self?.parseResponse(response: response),
                let widgets = self?.registeredWidgets {
                
                if period == .Today {
                    self?.todayInfo = info
                }
                else if period == .Last7Days {
                    self?.last7DaysInfo = info
                }
                
                DispatchQueue.main.async {
                    for widget in widgets {
                        widget.update()
                    }
                }
                
            }
        }
    }
    
    private func parseResponse(response: NSDictionary) -> Info? {
        if let result = response.value(forKey: "result") as? [String: Any] {
            var timeSaved: Int? = nil
            var adsBlocked: Int? = nil
            var dataSaved: Int? = nil
            var batterySaved: Int? = nil
            var trackersDetected: Int? = nil
            
            if let v = result["timeSaved"] as? Int {
                timeSaved = v
                //TODO: Battery saved
                //batterySaved = v
            }
            
            if let v = result["adsBlocked"] as? Int {
                adsBlocked = v
            }
            
            if let v = result["dataSaved"] as? Int {
                dataSaved = v
            }
            
            if let v = result["trackersDetected"] as? Int {
                trackersDetected = v
            }
            
            return Info(timeSaved: timeSaved, adsBlocked: adsBlocked, dataSaved: dataSaved, batterySaved: batterySaved, trackersDetected: trackersDetected)
            
        }
        
        return nil;
    }
    
    func savedTime() -> (String, String) {
        if currentPeriod == .Today {
            return todayInfo.timeSavedStrings()
        }
        
        return last7DaysInfo.timeSavedStrings()
    }
    
    func adsBlocked() -> Int {
        if currentPeriod == .Today {
            return todayInfo.adsBlocked ?? 0
        }
        
        return last7DaysInfo.adsBlocked ?? 0
    }
    
    func dataSaved() -> (String, String) {
        if currentPeriod == .Today {
            return todayInfo.dataSavedStrings()
        }
        
        return last7DaysInfo.dataSavedStrings()
    }
    
    func batterySaved() -> (String, String) {
        if currentPeriod == .Today {
            return todayInfo.batterySavedStrings()
        }
        
        return last7DaysInfo.batterySavedStrings()
    }
    
    func companies() -> Int {
        if currentPeriod == .Today {
            return todayInfo.trackersDetected ?? 0
        }
        
        return last7DaysInfo.trackersDetected ?? 0
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


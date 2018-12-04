//
//  CCWidget.swift
//  Cockpit
//
//  Created by Tim Palade on 10/23/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//
#if PAID
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
    
    static func timeSavedTuple(seconds: Int) -> (String, String) {
        if seconds < 60 {
            // Seconds
            return (String(format: "%d", seconds), TimeUnit.Seconds.toString())
        } else if seconds < 3600 {
            // Minutes : Seconds
            let minutes = seconds / 60
            let seconds = seconds % 60
            return (String(format: "%d:%d", minutes, seconds), TimeUnit.Minutes.toString())
        } else if seconds < 86400 {
            // Hours : Minutes
            let hours = seconds / 3600
            let minutes = (seconds / 60) % 60
            return (String(format: "%d:%d", hours, minutes), TimeUnit.Hours.toString())
        } else {
            // Days
            let days = seconds / 86400
            return (String(format: "%d", days), TimeUnit.Days.toString())
        }
    }
    
    static func dataSavedTuple(kiloBytes: Int) -> (String, String) {
        if kiloBytes < 1000 {
            // Kilobytes
            return (String(format: "%d", kiloBytes), DataUnit.Kilobytes.toString())
        } else if kiloBytes < 1000000 {
            // Megabytes
            let megabytes = Float(kiloBytes) / 1000.0
            if megabytes < 100 {
                return (String(format: "%.1f", megabytes), DataUnit.Megabytes.toString())
            } else {
                return (String(format: "%.0f", megabytes), DataUnit.Megabytes.toString())
            }
        } else {
            // Gigabytes
            let gigabytes = Float(kiloBytes) / 1000000.0
            return (String(format: "%.2f", gigabytes), DataUnit.Gigabytes.toString())
        }
    }
    
    //this is where the data for the widgets is managed.
    enum TimeUnit {
        case Seconds
        case Minutes
        case Hours
        case Days
        
        func toString() -> String {
            switch self {
            case .Seconds:
                return NSLocalizedString("SEC", tableName: "Lumen", comment: "Seconds unit for dashboard")
            case .Minutes:
                return NSLocalizedString("MIN", tableName: "Lumen", comment: "Minutes unit for dashboard")
            case .Hours:
                return NSLocalizedString("HRS", tableName: "Lumen", comment: "Hours unit for dashboard")
            case .Days:
                return NSLocalizedString("DAY(S)", tableName: "Lumen", comment: "Day(s) unit for dashboard")
            }
        }
    }
    
    enum DataUnit {
        case Kilobytes
        case Megabytes
        case Gigabytes
        
        func toString() -> String {
            switch self {
            case .Kilobytes:
                return "KB"
            case .Megabytes:
                return "MB"
            case .Gigabytes:
                return "GB"
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
            // self.timeSaved is in milliseconds
            return timeSavedTuple(seconds: (self.timeSaved ?? 0) / 1000)
        }
        
        func dataSavedStrings() -> (String, String) {
            // self.dataSaved is in bytes
            return dataSavedTuple(kiloBytes: (self.dataSaved ?? 0) / 1000)
        }
        
        func batterySavedStrings() -> (String, String) {
            // self.batterySaved is in milliseconds
            return timeSavedTuple(seconds: (self.batterySaved ?? 0) / 1000)
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
    
    func updateAppearance() {
        
    }
    
    //period changed
    func update(period: Period) {
        currentPeriod = period
        //push update
        
        Engine.sharedInstance.getBridge().callAction("insights:getDashboardStats", args: [currentPeriod.toString()]) { [weak self] (response) in
            //print("getDashboardStats = \(response)")
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
        
        if response.allKeys.count == 0 {
            return Info.zero
        }
        
        if let result = response.value(forKey: "result") as? [String: Any] {
            var timeSaved: Int? = nil
            var adsBlocked: Int? = nil
            var dataSaved: Int? = nil
            var batterySaved: Int? = nil
            var trackersDetected: Int? = nil
            
            if let v = result["timeSaved"] as? Int {
                timeSaved = v
                //Battery saved in time = C / T * TimeSaved, where C is the rate at which Cliqz is consuming battery, and T the rate at which the system is consuming battery with all apps running.
                //Since we cannot get C (Tim has not found a way), we assume that C = T/10, and therefore Battery saved in time = 1/10 * TimeSaved
                batterySaved = v / 10
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
        mainLabel?.textColor = Lumen.Dashboard.widgetTextColor(lumenTheme, lumenDashboardMode)
        auxLabel?.textColor = Lumen.Dashboard.widgetTextColor(lumenTheme, lumenDashboardMode)
        self.alpha = (lumenDashboardMode == .Normal) ? 1.0 : 0.7
    }
}

class CCTimeSavedWidget: CCWidget {
    
    init() {
        super.init(frame: CGRect.zero)
        
        imageView = UIImageView()
        mainLabel = UILabel()
        mainLabel?.textAlignment = .center
        mainLabel?.font = UIFont.systemFont(ofSize: 36, weight: .regular)
        auxLabel = UILabel()
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
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update() {
        super.update()
        imageView?.image = Lumen.Dashboard.timeSavedImage(lumenTheme, lumenDashboardMode)
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
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update() {
        super.update()
        imageView?.image = Lumen.Dashboard.adsBlockedImage(lumenTheme, lumenDashboardMode)
        let quantity = CCWidgetManager.shared.adsBlocked()
        mainLabel?.text = String(quantity)
    }
}

class CCDataSavedWidget: CCWidget {
    var QuantityFontAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 50, weight: .ultraLight),
                NSAttributedStringKey.foregroundColor: Lumen.Dashboard.widgetTextColor(lumenTheme, lumenDashboardMode)]
    }
    
    var ScaleFontAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 50, weight: .medium),
                NSAttributedStringKey.foregroundColor: Lumen.Dashboard.widgetTextColor(lumenTheme, lumenDashboardMode)]
    }
    
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
        mainLabel?.attributedText = NSAttributedString(string: quanitity, attributes: QuantityFontAttributes)
        auxLabel?.attributedText = NSAttributedString(string: scale, attributes: ScaleFontAttributes)
    }
    
    override func update() {
        super.update()
        let (quantity, scale) = CCWidgetManager.shared.dataSaved()
        updateView(quanitity: quantity, scale: scale)
    }
}

class CCBatterySavedWidget: CCWidget {
    var QuantityFontAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 36, weight: .regular), NSAttributedStringKey.foregroundColor: Lumen.Dashboard.widgetTextColor(lumenTheme, lumenDashboardMode)]
    }
    var ScaleFontAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12, weight: .regular), NSAttributedStringKey.foregroundColor: Lumen.Dashboard.widgetTextColor(lumenTheme, lumenDashboardMode)]
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        imageView = UIImageView()
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
        let attributedText = NSMutableAttributedString(string: quanitity, attributes: QuantityFontAttributes)
        attributedText.append(NSAttributedString(string: scale, attributes: ScaleFontAttributes))
        mainLabel?.attributedText = attributedText
    }
    
    override func update() {
        super.update()
        imageView?.image = Lumen.Dashboard.batterySavedImage(lumenTheme, lumenDashboardMode)
        let (quantity, scale) = CCWidgetManager.shared.batterySaved()
        updateView(quanitity: quantity, scale: scale)
    }
}

class CCAntiPhishingWidget: CCWidget {
    
    init() {
        super.init(frame: CGRect.zero)
        
        imageView = UIImageView()
        
        mainLabel?.adjustsFontSizeToFitWidth = true
        auxLabel?.adjustsFontSizeToFitWidth = true
        
        self.addSubview(imageView!)
        
        imageView!.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update() {
        super.update()
        imageView?.image = Lumen.Dashboard.antiphisingImage(lumenTheme, lumenDashboardMode)
    }
}

class CCCompaniesWidget: CCWidget {
    var QuantityFontAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 36, weight: .regular), NSAttributedStringKey.foregroundColor: Lumen.Dashboard.widgetTextColor(lumenTheme, lumenDashboardMode)]
    }
    var ScaleFontAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .regular), NSAttributedStringKey.foregroundColor: Lumen.Dashboard.widgetTextColor(lumenTheme, lumenDashboardMode)]
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        let container = UIView()
        
        imageView = UIImageView()
        
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
        let attributedText = NSMutableAttributedString(string: String(quanitity), attributes: QuantityFontAttributes)
        let auxText = NSAttributedString(string: "FIRMEN", attributes: ScaleFontAttributes)
        mainLabel?.attributedText = attributedText
        auxLabel?.attributedText = auxText
    }
    
    override func update() {
        super.update()
        imageView?.image = Lumen.Dashboard.companiesBlockedImage(lumenTheme, lumenDashboardMode)
        let quantity = CCWidgetManager.shared.companies()
        updateView(quanitity: quantity)
    }
}
#endif

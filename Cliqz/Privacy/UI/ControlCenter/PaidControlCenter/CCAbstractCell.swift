//
//  CCAbstractCell.swift
//  Cockpit
//
//  Created by Tim Palade on 10/22/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//
#if PAID
import UIKit
import SnapKit

protocol UpdateViewProtocol {
    func update()
}

struct CCCellUX {
    static let CornerRadius: CGFloat = 20.0
    static let ShadowRadius: CGFloat = 4.0
    static let ShadowOpacity: Float = 0.9
}

class CCAbstractCell: UIView, UpdateViewProtocol {

    var titleLabel: UILabel = UILabel()
    private var _widget: CCWidget? = nil
    
    var widget: CCWidget? {
        get {
            return _widget
        }
        set {
            _widget?.removeFromSuperview()
            _widget = newValue
            if let w = _widget {
                widgetContainer.addSubview(w)
                w.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
        }
    }
    
    let contentView = UIView()
    let stackView = UIStackView()
    let widgetContainer = UIView()
    let descriptionContainer = UIView()
    let mainContainer = UIView()
    var extraContainer: UIView? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(stackView)
        stackView.addArrangedSubview(widgetContainer)
        stackView.addArrangedSubview(descriptionContainer)
        descriptionContainer.addSubview(titleLabel)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        mainContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.backgroundColor = Lumen.Dashboard.widgetBackgroundColor(lumenTheme, lumenDashboardMode)
        self.layer.shadowColor = Lumen.Dashboard.shadowColor(lumenTheme, lumenDashboardMode).cgColor
        self.layer.shadowRadius = CCCellUX.ShadowRadius
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = CCCellUX.ShadowOpacity
        self.layer.cornerRadius = CCCellUX.CornerRadius
        self.clipsToBounds = false
        
        self.contentView.layer.cornerRadius = CCCellUX.CornerRadius
        self.contentView.clipsToBounds = true
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = Lumen.Dashboard.titleColor(lumenTheme, lumenDashboardMode)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        //to be overriden
        self.backgroundColor = Lumen.Dashboard.widgetBackgroundColor(lumenTheme, lumenDashboardMode)
        self.layer.shadowColor = Lumen.Dashboard.shadowColor(lumenTheme, lumenDashboardMode).cgColor
        titleLabel.textColor = Lumen.Dashboard.titleColor(lumenTheme, lumenDashboardMode)
        widget?.update()
    }
}

class CCVerticalCell: CCAbstractCell {
    
    //widgetRatio is the height of the widget over the height of the cell
    //descrRatio is the height of the description over the height of the cell
    init(widgetRatio: CGFloat, descriptionRatio: CGFloat) {
        super.init(frame: CGRect.zero)
        
        stackView.axis = .vertical
        
        widgetContainer.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(widgetRatio)
        }
        
        descriptionContainer.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(descriptionRatio)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        fatalError("ratios is not specified")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update() {
        super.update()
    }
}

class CCHorizontalCell: CCAbstractCell {
	
	let countLabel = UILabel()
    //widgetRatio is the width of the widget over the height of the cell
    //descrRatio is the width of the description over the height of the cell
    init(widgetRatio: CGFloat, descriptionRatio: CGFloat, optionalView: UIView? = nil, optionalViewHeight: CGFloat? = nil) {
        super.init(frame: CGRect.zero)
		
		self.descriptionContainer.addSubview(countLabel)

        titleLabel.textAlignment = .left

        stackView.axis = .horizontal
        
        widgetContainer.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(widgetRatio)
        }
        
        descriptionContainer.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(descriptionRatio)
        }
		
		countLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview().offset(10)
			make.leading.equalToSuperview().inset(25)
		}
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(countLabel.snp.bottom).offset(0)
            make.trailing.equalToSuperview().inset(5)
			make.leading.equalToSuperview().inset(25)
        }
		
		countLabel.textColor = UIColor.white
		countLabel.font = UIFont.systemFont(ofSize: 35, weight: .medium)
        if let optView = optionalView, let h = optionalViewHeight {
            extraContainer = UIView()
            contentView.addSubview(extraContainer!)
            extraContainer!.addSubview(optView)
            optView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            mainContainer.snp.remakeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
                make.bottom.equalTo(extraContainer!.snp.top)
            }
            
            extraContainer?.snp.makeConstraints({ (make) in
                make.top.equalTo(mainContainer.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(h)
            })
        }
        
    }
    
    override init(frame: CGRect) {
        fatalError("ratios is not specified")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update() {
        super.update()
		self.countLabel.text = CCWidgetManager.shared.pagesChecked()
    }
}

#endif

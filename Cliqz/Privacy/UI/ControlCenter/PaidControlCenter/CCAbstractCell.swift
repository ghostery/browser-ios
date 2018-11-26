//
//  CCAbstractCell.swift
//  Cockpit
//
//  Created by Tim Palade on 10/22/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit
import SnapKit

struct CCCellUX {
    static let CornerRadius: CGFloat = 20.0
    static let ShadowRadius: CGFloat = 4.0
    static let ShadowOpacity: Float = 0.9
}

class CCAbstractCell: UIView {

    var titleLabel: UILabel = UILabel()
    var descriptionLabel: UILabel = UILabel()
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
        descriptionContainer.addSubview(descriptionLabel)
        
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
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = Lumen.Dashboard.descriptionColor(lumenTheme, lumenDashboardMode)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        fatalError("ratios is not specified")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CCHorizontalCell: CCAbstractCell {
    
    //widgetRatio is the width of the widget over the height of the cell
    //descrRatio is the width of the description over the height of the cell
    init(widgetRatio: CGFloat, descriptionRatio: CGFloat, optionalView: UIView? = nil, optionalViewHeight: CGFloat? = nil) {
        super.init(frame: CGRect.zero)
        
        titleLabel.textAlignment = .left
        descriptionLabel.textAlignment = .left
        
        stackView.axis = .horizontal
        
        widgetContainer.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(widgetRatio)
        }
        
        descriptionContainer.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(descriptionRatio)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(5)
        }

        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
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
}

//
//  CliqzSiteTableViewCell.swift
//  Client
//
//  Created by Mahmoud Adam on 5/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import QuartzCore

class CliqzSiteTableViewCell: SiteTableViewCell {
    
    let imageShadowView = UIView()
    let customImageView = UIImageView()
    var fakeView: UIView? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorInset = UIEdgeInsets(top: 0, left: CliqzHistoryPanelUX.separatorLeftInset, bottom: 0, right: 0)
        contentView.addSubview(imageShadowView)
        imageShadowView.addSubview(customImageView)
        customImageView.layer.cornerRadius = CliqzHistoryPanelUX.iconCornerRadius
        customImageView.clipsToBounds = true
        setupImageShadow()
        setUpLabels()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
        else {
            self.backgroundColor = UIColor.clear
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
        else {
            self.backgroundColor = UIColor.clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        separatorInset = UIEdgeInsets(top: 0, left: CliqzHistoryPanelUX.separatorLeftInset, bottom: 0, right: 0)
        setupImageShadow()
        setUpLabels()
        fakeView?.removeFromSuperview()
        fakeView = nil
        customImageView.image = nil
    }
    
    func fakeIt(_ view: UIView) {
        contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalTo(self.customImageView)
        }
        contentView.bringSubview(toFront: view)
        view.layer.cornerRadius = CliqzHistoryPanelUX.iconCornerRadius
        fakeView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageShadow() {
        
        imageShadowView.clipsToBounds = false
        imageShadowView.backgroundColor = UIColor.cliqzURLBarColor
        contentView.sendSubview(toBack: imageShadowView)
        contentView.bringSubview(toFront: customImageView)
        
        customImageView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        imageShadowView.snp.remakeConstraints { (make) in
            make.size.equalTo(CliqzHistoryPanelUX.iconSize)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        }
        
        imageShadowView.layer.cornerRadius = CliqzHistoryPanelUX.iconCornerRadius
        imageShadowView.layer.shadowColor = UIColor.black.cgColor
        imageShadowView.layer.shadowOpacity = 0.5
        imageShadowView.layer.shadowRadius = 0.5
        imageShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }
    
    private func setUpLabels() {
        
        _textLabel.textColor = .white
        _textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        #if !PAID
        _textLabel.applyShadow()
        #endif
        
        _detailTextLabel.textColor = .white
        _detailTextLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        #if !PAID
        _detailTextLabel.applyShadow()
        #endif
    }
}

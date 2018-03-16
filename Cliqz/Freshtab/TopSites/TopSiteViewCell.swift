//
//  TopSiteViewCell.swift
//  Client
//
//  Created by Sahakyan on 1/26/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

protocol TopSiteCellDelegate: NSObjectProtocol {
	
	func topSiteHided(_ index: Int)
}

class TopSiteViewCell: UICollectionViewCell {

	weak var delegate: TopSiteCellDelegate?

	lazy var logoContainerView = UIView()
	lazy var logoImageView: UIImageView = UIImageView()
	var fakeLogoView: UIView?
	lazy var logoHostLabel = UILabel()

	lazy var deleteButton: UIButton = {
		let b = UIButton(type: .custom)
		b.setImage(UIImage(named: "removeTopsite"), for: UIControlState())
		b.addTarget(self, action: #selector(hideTopSite), for: .touchUpInside)
		return b
	}()
	
	var isDeleteMode = false {
		didSet {
			if isDeleteMode && !self.isEmptyContent() {
				self.contentView.addSubview(self.deleteButton)
				self.deleteButton.snp.makeConstraints({ (make) in
					make.top.equalTo(self.contentView.frame.origin.y)
                    make.left.equalTo(self.contentView.frame.origin.x)
				})
				self.startWobbling()
			} else {
				self.deleteButton.removeFromSuperview()
				self.stopWobbling()
			}
		}
	}
	
	fileprivate func isEmptyContent() -> Bool {
		return self.logoContainerView.subviews.count == 0 || (self.logoImageView.image == nil && self.fakeLogoView?.superview == nil)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.clear
		self.contentView.backgroundColor = UIColor.clear

		self.contentView.addSubview(self.logoContainerView)
		logoContainerView.snp.makeConstraints { make in
			make.top.equalTo(self.contentView.frame.origin.y + 8)
			make.left.equalTo(self.contentView.frame.origin.x + 8)
			make.height.width.equalTo(60)
		}

		self.logoContainerView.addSubview(self.logoImageView) //isn't this a retain cycle?
		logoImageView.snp.makeConstraints { make in
			make.top.left.bottom.right.equalTo(self.logoContainerView)
		}
		self.logoContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		self.logoContainerView.layer.cornerRadius = 12
        self.logoContainerView.layer.borderWidth = 2
        self.logoContainerView.layer.borderColor = UIColor.clear.cgColor//UIConstants.AppBackgroundColor.CGColor
        self.logoContainerView.layer.shouldRasterize = false
		self.logoContainerView.clipsToBounds = true
		
		self.contentView.addSubview(self.logoHostLabel);
		self.logoHostLabel.snp.makeConstraints { (make) in
			make.left.right.bottom.equalTo(self.contentView)
			make.top.equalTo(self.logoContainerView.snp.bottom).offset(3)
		}
		self.logoHostLabel.textAlignment = .center
		self.logoHostLabel.font = UIFont.systemFont(ofSize: 10)
		self.logoHostLabel.textColor = UIColor.black
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.logoImageView.image = nil
		self.fakeLogoView?.removeFromSuperview()
		self.fakeLogoView = nil
		self.deleteButton.removeFromSuperview()
		self.logoHostLabel.text = ""
	}
	
	fileprivate func startWobbling() {
		let startAngle = -Double.pi/40
		let endAngle = Double.pi/40
		
		let wobblingAnimation = CAKeyframeAnimation.init(keyPath: "transform.rotation")
		wobblingAnimation.values = [startAngle, endAngle]
		wobblingAnimation.duration = 0.13
		wobblingAnimation.autoreverses = true
		wobblingAnimation.repeatCount = Float.greatestFiniteMagnitude
		wobblingAnimation.timingFunction = CAMediaTimingFunction.init(name:kCAMediaTimingFunctionLinear)
        self.logoContainerView.layer.shouldRasterize = true
		self.layer.add(wobblingAnimation, forKey: "rotation")
	}
	
	fileprivate func stopWobbling() {
		self.layer.removeAllAnimations()
        self.logoContainerView.layer.shouldRasterize = false
	}
	
	@objc fileprivate func hideTopSite() {
        self.logoImageView.image = nil
        self.fakeLogoView?.removeFromSuperview()
        self.fakeLogoView = nil
        self.isDeleteMode = false
		self.logoHostLabel.text = ""
		self.delegate?.topSiteHided(self.tag)
	}
}

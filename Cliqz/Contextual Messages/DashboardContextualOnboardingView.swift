//
//  DashboardContextualOnboardingView.swift
//  Client
//
//  Created by Sahakyan on 2/22/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class DashboardContextualOnboardingView: UIView {
	
	lazy var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.text = NSLocalizedString("Did you know?", tableName: "Lumen", comment: "[Contextual onboarding] For Dashboard")
		titleLabel.numberOfLines = 1
		titleLabel.textAlignment = .left
		titleLabel.textColor = UIColor.white
		titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
		return titleLabel
	}()
	
	lazy var descriptionLabel: UILabel = {
		let textLabel = UILabel()
		textLabel.text = NSLocalizedString("Ultimate protection: Lumen blocks ads and trackers.", tableName: "Lumen", comment: "[Contextual onboarding] For Dashboard")
		textLabel.numberOfLines = 2
		textLabel.adjustsFontSizeToFitWidth = true
		textLabel.minimumScaleFactor = 0.5
		textLabel.textAlignment = .left
		textLabel.textColor = UIColor.white
		textLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		textLabel.lineBreakMode = .byTruncatingTail
		textLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
		return textLabel
	}()

	lazy var imageView: UIImageView = {
		let img = UIImage(named: "arrow_to_dashboard")
		return UIImageView(image: img)
	}()

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	init() {
		super.init(frame: .zero)
		self.addSubview(titleLabel)
		self.addSubview(descriptionLabel)
		self.addSubview(imageView)
		titleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(10)
			make.left.equalToSuperview().inset(10)
			make.right.equalTo(imageView.snp.left)
		}
		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(imageView.snp.left)
		}
		self.backgroundColor = UIColor.lumenDeepBlue
		self.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: Notification.Name.DeviceOrientationChanged, object: nil)
        self.animateArrow()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func animateArrow() {
        
        imageView.layer.removeAllAnimations()
        imageView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            let orientation = UIDevice.current.getDeviceAndOrientation().1
            if orientation == .portrait {
                make.right.equalToSuperview().inset(20)
            } else {
                make.right.equalToSuperview().inset(117)
            }
            make.width.equalTo(14)
            make.height.equalTo(17)
        }
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.1, options: [.repeat,.autoreverse], animations: {
            self.imageView.frame.origin.y -= 10
        })
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        self.animateArrow()
    }
}

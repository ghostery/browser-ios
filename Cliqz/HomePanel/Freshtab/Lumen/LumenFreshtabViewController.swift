//
//  LumenFreshtabViewController.swift
//  Client
//
//  Created by Sahakyan on 2/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

struct LumenFreshtabUI {
	static let mainTextColor = UIColor(colorString: "7C90D1")
}

class LumenFreshtabViewController: FreshtabViewController {

	private var infoView: UIView?
	private var welcomeView: UIView?
    private var madeIndGermany = UILabel()

	private static let welcomeViewShown = "welcomeViewShown"

	override func viewDidLoad() {
		super.viewDidLoad()
        madeIndGermany.text = "MADE IN GERMANY"
        madeIndGermany.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        madeIndGermany.textColor = UIColor.lumenBrightBlue
        madeIndGermany.textAlignment = .center
        madeIndGermany.alpha = 0.4
        madeIndGermany.addCharacterSpacing(kernValue: 4.0)
        view.addSubview(madeIndGermany)
        
		setupViews()
		setupConstraints()
        scrollView.isScrollEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView(_:)),
                                               name: .ProductPurchaseSuccessNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView(_:)),
                                               name: .SubscriptionRefreshNotification,
                                               object: nil)
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func refreshView(_ notification: Notification) {
        infoView?.removeFromSuperview()
        infoView = nil
        setupViews()
        setupConstraints()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		newsViewController.view.isHidden = true
	}

	private func setupViews() {
		let type = SubscriptionController.shared.getCurrentSubscription()
		switch (type) {
		case .limited:
            if SubscriptionController.shared.shouldShowTrialExpiredView() {
                let trialExpiredView = TrialExpiredView()
                trialExpiredView.delegate = self
                infoView = trialExpiredView
                view.addSubview(trialExpiredView)
            }
		case .trial:
			let days = type.trialRemainingDays() ?? -1
			if days > 3 {
				let title = String(format: NSLocalizedString("%d more days left in trial", tableName: "Lumen", comment: "Trial days left title"), days)
				let action = NSLocalizedString("UPGRADE", tableName: "Lumen", comment: "Upgrade action")
				let btn = ButtonWithUnderlinedText(startText: (title, LumenFreshtabUI.mainTextColor),
                                                   underlinedText: (action, UIColor.lumenTextBlue),
                                                   position: .bottom,
                                                   view: "start_tab")
				btn.addTarget(self, action: #selector(upgrade), for: .touchUpInside)
				infoView = btn
				self.view.addSubview(btn)
			} else if days >= 0 {
				let upgradeView = UpgradeView(view: "start_tab")
				upgradeView.delegate = self
				infoView = upgradeView
				view.addSubview(upgradeView)
			} else {
				// TODO: invalid state
			}
		default:
			break
		}
		if LocalDataStore.value(forKey: LumenFreshtabViewController.welcomeViewShown) == nil {
			self.welcomeView = WelcomeView()
			self.container.addSubview(self.welcomeView!)
			LocalDataStore.set(value: true, forKey: LumenFreshtabViewController.welcomeViewShown)
		}
	}

	@objc
	private func upgrade() {
		self.showUpgradeOptionsViewController()
	}

	private func setupConstraints() {
        madeIndGermany.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview().inset(25)
            make.centerX.equalToSuperview()
        }
        
		if let view1stWeek = self.infoView as? UIButton {
			view1stWeek.snp.makeConstraints { (make) in
				make.centerX.equalToSuperview()
                make.bottom.equalTo(self.madeIndGermany.snp.top).offset(-25)
				make.height.equalTo(50)
			}
			self.scrollView.snp.remakeConstraints({ (make) in
				make.top.left.right.equalToSuperview()
				make.bottom.equalTo(view1stWeek.snp.top)
			})
		} else if let view2ndWeek = self.infoView as? UpgradeView {
			view2ndWeek.snp.makeConstraints { (make) in
				make.left.right.top.equalToSuperview().inset(10)
				make.height.equalTo(UpgradeViewUX.height)
			}
			self.scrollView.snp.remakeConstraints({ (make) in
				make.bottom.left.right.equalToSuperview()
				make.top.equalTo(view2ndWeek.snp.bottom)
			})
        } else if let trialExpiredView = self.infoView as? TrialExpiredView {
            trialExpiredView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(self.madeIndGermany.snp.top).offset(-25)
                make.height.equalTo(TrialExpiredViewUX.height)
            }
            self.scrollView.snp.remakeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(trialExpiredView.snp.top)
            })
        } else {
            self.scrollView.snp.remakeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(self.madeIndGermany.snp.top)
            })
        }
		if let w = self.welcomeView {
			w.snp.makeConstraints { (make) in
				make.top.equalTo(self.topSitesViewController.view.snp.bottom).offset(20)	
				make.left.right.equalToSuperview().inset(10)
//				make.top.equalTo()
			}
		}
	}

	fileprivate func showUpgradeOptionsViewController() {
		let upgradLumenViewController = UpgradLumenViewController()
		let navController = UINavigationController(rootViewController: upgradLumenViewController)
		self.present(navController, animated: true, completion: nil)
	}
}

extension LumenFreshtabViewController : UpgradeLumenDelegate {

	func showUpgradeViewController() {
		self.showUpgradeOptionsViewController()
	}
}

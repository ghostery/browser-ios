//
//  OffrzViewController.swift
//  Client
//
//  Created by Sahakyan on 12/5/17.
//  Copyright © 2017 Cliqz. All rights reserved.
//

import Foundation

class OffrzViewController: UIViewController, HomePanel {

	weak var homePanelDelegate: HomePanelDelegate?

    private var scrollView = UIScrollView()
    private var containerView = UIView()

	private static let learnMoreURL = "https://cliqz.com/myoffrz"
	private var onboardingView: OffrzOnboardingView!

	private var emptyView: OffrzEmptyView!
	
	private var myOffr: Offr?
	private var offrView: OffrView?
	private let offrHeight: CGFloat = 510

	private var offrOverlay: UIView?
	private weak var expandedOffrView: OffrView?

    weak var offrzDataSource : OffrzDataSource!

	private var startDate = Date()

    init(dataSource: OffrzDataSource) {
        super.init(nibName: nil, bundle: nil)
        self.offrzDataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
		super.viewDidLoad()

        setStyles()
        setupComponents()
        
        if self.offrzDataSource.hasOffrz() {
            self.offrzDataSource.markCurrentOffrSeen()
        }
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.startDate = Date()
		// TODO: Refactor after Telemetry integration
//		TelemetryLogger.sharedInstance.logEvent(.Toolbar("show", nil, "offrz", nil, ["offer_count": self.offrzDataSource.hasOffrz() ? 1 : 0]))
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		// TODO: Refactor after Telemetry integration
//		TelemetryLogger.sharedInstance.logEvent(.Toolbar("hide", nil, "offrz", nil, ["show_duration": Date().timeIntervalSince(self.startDate)]))
	}

    private func setStyles() {
        self.view.backgroundColor = UIConstants.AppBackgroundColor
        containerView.backgroundColor = UIColor.clear
    }
    
    private func setupComponents() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        if offrzDataSource.hasOffrz(), let currentOffr = offrzDataSource.getCurrentOffr() {
			self.myOffr = currentOffr
            offrView = OffrView(offr: currentOffr)
            containerView.addSubview(offrView!)
			offrView?.addTapAction(self, action: #selector(openOffr))
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(expandOffr))
			offrView?.addGestureRecognizer(tapGesture)
        } else {
			self.emptyView = OffrzEmptyView()
			self.containerView.addSubview(self.emptyView)
        }
        
        setupOnboardingView()
		layoutComponents(withOnboarding: true)
    }
    
    private func setupOnboardingView() {
        if offrzDataSource.hasOffrz() && offrzDataSource.shouldShowOnBoarding() {
			self.onboardingView = OffrzOnboardingView()
			containerView.addSubview(onboardingView)
			onboardingView.addActionHandler(.hide) {
				weak var weakSelf = self
				weakSelf?.hideOnboardingView()
			}
			onboardingView.addActionHandler(.learnMore) {
				weak var weakSelf = self
				weakSelf?.openLearnMore()
			}
			// TODO: Refactor after Telemetry integration
//			TelemetryLogger.sharedInstance.logEvent(.Onboarding("show", "offrz", nil))
        }
    }
    
    @objc private func hideOnboardingView() {
		// TODO: Refactor after Telemetry integration
//		TelemetryLogger.sharedInstance.logEvent(.Onboarding("hide", nil, ["view" : "offrz"]))
        self.onboardingView.removeFromSuperview()
        self.offrzDataSource?.hideOnBoarding()
		self.layoutComponents(withOnboarding: false)
    }
    
	private func layoutComponents(withOnboarding isOnboardingOn: Bool) {
        self.scrollView.snp.remakeConstraints({ (make) in
            make.top.left.bottom.right.equalTo(self.view)
        })
        
        self.containerView.snp.remakeConstraints({ (make) in
            make.top.left.right.bottom.equalTo(scrollView)
            make.width.equalTo(self.view)
			if isOnboardingOn && offrzDataSource.shouldShowOnBoarding() {
				make.height.equalTo(offrHeight + 200)
			} else {
				make.height.equalTo(offrHeight + 30)
			}
        })

        if offrzDataSource.hasOffrz() {
            if isOnboardingOn && offrzDataSource.shouldShowOnBoarding() {
                self.onboardingView.snp.remakeConstraints({ (make) in
                    make.top.left.right.equalTo(containerView)
                    make.height.equalTo(175)
                })
            }
            if let offrView = self.offrView {
                offrView.snp.remakeConstraints({ (make) in
                    if isOnboardingOn && offrzDataSource.shouldShowOnBoarding() {
                        make.top.equalTo(onboardingView.snp.bottom).offset(25)
                    } else {
                        make.top.equalTo(containerView).offset(25)
                    }
                    make.left.equalTo(containerView).offset(50)
					make.right.equalTo(containerView).offset(-50)
                    make.height.equalTo(offrHeight)
                })
            }
        } else {
			emptyView?.snp.remakeConstraints({ (make) in
				make.edges.equalTo(self.containerView)
			})
        }
    }

	@objc
	private func openLearnMore() {
		// TODO: Telemetry integration
//		TelemetryLogger.sharedInstance.logEvent(.Onboarding("click", nil, ["view" : "offrz"]))
		if let url = URL(string: OffrzViewController.learnMoreURL) {
			self.homePanelDelegate?.homePanel(self, didSelectURL: url, visitType: .link)
		}
	}

	@objc
	private func openOffr() {
		if self.offrOverlay != nil {
			self.shrinkOffr()
		}
		// TODO: Refactor after Telemetry integration
//		TelemetryLogger.sharedInstance.logEvent(.MyOffrz("click", "use"))
		if let urlStr = self.myOffr?.url,
			let url = URL(string: urlStr) {
			self.homePanelDelegate?.homePanel(self, didSelectURL: url, visitType: .link)
		}
	}

	@objc
	private func expandOffr() {
		if let w = UIApplication.shared.windows.first,
			let offr = self.myOffr {
			let overlay = UIView()
			overlay.backgroundColor = UIColor.clear
			w.addSubview(overlay)
			overlay.snp.remakeConstraints({ (make) in
				make.top.left.right.bottom.equalTo(w)
			})

			let blurEffect = UIBlurEffect(style: .dark)
			let blurView = UIVisualEffectView(effect: blurEffect)
			overlay.addSubview(blurView)
			blurView.snp.makeConstraints({ (make) in
				make.top.left.right.bottom.equalTo(overlay)
			})
			let expandedOffrView = OffrView(offr: offr)
			overlay.addSubview(expandedOffrView)
			expandedOffrView.expand()
			expandedOffrView.snp.makeConstraints({ (make) in
					make.top.equalTo(overlay).offset(45)
					make.bottom.equalTo(overlay).offset(-25)
					make.left.right.equalTo(overlay).inset(50)
			})
			expandedOffrView.addTapAction(self, action: #selector(openOffr))
			self.expandedOffrView = expandedOffrView
			self.offrOverlay = overlay

			let closeBtn = UIButton(type: .custom)
			closeBtn.setBackgroundImage(UIImage(named:"closeOffr"), for: .normal)
			overlay.addSubview(closeBtn)
			closeBtn.snp.makeConstraints({ (make) in
				make.top.equalTo(overlay).offset(40)
				make.left.equalTo(overlay).offset(45)
			})
			closeBtn.addTarget(self, action: #selector(self.shrinkOffr), for: .touchUpInside)
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnOverlay))
			overlay.addGestureRecognizer(tapGesture)
		}
	}
	
	@objc
	private func tapOnOverlay(_ sender: UITapGestureRecognizer) {
		let point = sender.location(in: self.expandedOffrView)
		if !(self.expandedOffrView?.point(inside: point, with: nil) ?? true) {
			self.shrinkOffr()
		}
	}

	@objc
	private func shrinkOffr() {
		self.offrOverlay?.removeFromSuperview()
		self.offrOverlay = nil
	}
}

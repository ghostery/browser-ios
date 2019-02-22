//
//  FreshtabViewController.swift
//  Client
//
//  Created by Sahakyan on 2/13/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import Shared

struct FreshtabViewUX {
	static let TopSitesMinHeight: CGFloat = 95.0
	static let TopSitesOffset = 0.0
	
	static let NewsViewMinHeight: CGFloat = 162.0

	static let topOffset: CGFloat = 10.0
	static let bottomOffset: CGFloat = 45.0
}

class FreshtabViewController: UIViewController, HomePanel {
    
	weak var homePanelDelegate: HomePanelDelegate?

	private var profile: Profile!

	var isForgetMode = false {
		didSet {
			self.updateViews()
		}
	}

	internal let scrollView: UIScrollView = UIScrollView()
	fileprivate let normalModeView: UIView = UIView()
	// TODO: Finialize need of forgetModeView and hopefully remove
	fileprivate var forgetModeView: ForgetModeView?

	internal let topSitesViewController = TopSitesViewController(dataSource: TopSitesDataSource.instance)
	internal let newsViewController = NewsViewController(dataSource: NewsDataSource.instance)
    
    fileprivate let topSitesEditModeOverlay = UIView()
    
    internal let container = UIView()

	fileprivate var scrollCount = 0
	fileprivate var startTime : Timestamp = Date.now()

	init(profile: Profile) {
		super.init(nibName: nil, bundle: nil)
		self.profile = profile
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupViews()
        self.setupConstraints()
        
        self.normalModeView.alpha = 0.0
        self.logShowSignal()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		startTime = Date.now()
		scrollCount = 0
		restoreToInitialState()
		
		updateViews()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseIn, animations: {
            self.normalModeView.alpha = 1.0
        }, completion: nil)
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		logHideSignal()
		logScrollSignal()
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
			self?.updateViewConstraints()
		}
	}

    private func setupConstraints() {
        if !isForgetMode {
            
            self.scrollView.snp.makeConstraints({ (make) in
                make.top.left.bottom.right.equalTo(self.view)
            })

            self.topSitesViewController.view.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().offset(FreshtabViewUX.topOffset)
                make.left.equalToSuperview().offset(FreshtabViewUX.TopSitesOffset)
                make.right.equalToSuperview().offset(-FreshtabViewUX.TopSitesOffset)
                make.height.equalTo(self.topSitesViewController.topSitesCollection.snp.height).offset(TopSitesUX.TopSiteHintHeight)
            })
            
            self.newsViewController.view.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(0)
                make.right.equalToSuperview().offset(0)
                make.height.equalTo(self.newsViewController.newsTableView.snp.height)
                make.top.equalTo(self.topSitesViewController.view.snp.bottom).offset(FreshtabViewUX.topOffset)
            }
            
            self.normalModeView.snp.makeConstraints({ (make) in
                make.top.left.bottom.right.equalTo(scrollView)
                make.width.equalToSuperview()
                make.height.equalTo(self.container.snp.height)
            })
            
            self.container.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.newsViewController.view.snp.bottom)
            }
            
            self.topSitesEditModeOverlay.snp.updateConstraints({ (make) in
                make.top.equalTo(self.topSitesViewController.view.snp.bottom)
                make.left.height.width.equalTo(self.view)
            })
        }
    }

    func applyTheme() {
        topSitesViewController.applyTheme()
        newsViewController.applyTheme()
    }

	private func getInvisibleFreshTabHeight(topSitesHeight: CGFloat, newsHeight: CGFloat) -> CGFloat {
		let viewHeight = self.view.bounds.height - FreshtabViewUX.bottomOffset
		var freshTabHeight = topSitesHeight + newsHeight + 10.0
		if topSitesHeight > 0 { freshTabHeight += FreshtabViewUX.topOffset }
		if newsHeight > 0 { freshTabHeight += FreshtabViewUX.topOffset}
		if freshTabHeight > viewHeight {
			return freshTabHeight - viewHeight
		} else {
			return 0.0
		}
		
	}

	private func restoreToInitialState() {
		if !isForgetMode {
			self.newsViewController.restoreToInitialState()
		}
	}

	fileprivate func updateViews() {
		if isForgetMode {
			self.forgetModeView?.isHidden = false
			self.normalModeView.isHidden = true
		} else {
			TopSitesDataSource.instance.refresh()
			self.normalModeView.isHidden = false
			self.forgetModeView?.isHidden = true
		}
	}

	private func setupViews() {
		if isForgetMode {
			setupForgetModeView()
		} else {
			setupNormalModeView()
		}
	}

	private func setupForgetModeView() {
        if self.forgetModeView == nil {
            self.forgetModeView = ForgetModeView()
        }
	}

	private func setupNormalModeView() {
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        self.normalModeView.backgroundColor = UIColor.clear

        self.scrollView.delegate = self
        self.scrollView.addSubview(self.normalModeView)

        self.normalModeView.addSubview(container)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        normalModeView.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        pan.cancelsTouchesInView = false
        pan.delegate = self
        normalModeView.addGestureRecognizer(pan)
        
        self.topSitesViewController.homePanelDelegate = self.homePanelDelegate
        self.topSitesViewController.freshTabDelegate = self
        self.addChildViewController(self.topSitesViewController)
        if let topSites = self.topSitesViewController.view {
            self.container.addSubview(topSites)
            topSites.backgroundColor = UIColor.clear
        }

        self.newsViewController.homePanelDelegate = self.homePanelDelegate
        self.addChildViewController(self.newsViewController)
        if let newsView = self.newsViewController.view {
            self.container.addSubview(newsView)
            newsView.backgroundColor = UIColor.clear
        }
		
        // Added topSitesEditModeOverlay view
        self.view.addSubview(self.topSitesEditModeOverlay)
        self.hideTopSitesOVerlay()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cancelActions))
        tapGestureRecognizer.delegate = self
        self.topSitesEditModeOverlay.addGestureRecognizer(tapGestureRecognizer)
        
	}
    
    @objc fileprivate func cancelActions(_ sender: UITapGestureRecognizer) {
        topSitesViewController.removeDeletedTopSites()
    }
    @objc func dismissKeyboard(_ sender: Any? = nil) {
        view.window?.rootViewController?.view.endEditing(true)
    }
}

extension FreshtabViewController: UIScrollViewDelegate {
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.dismissKeyboard()
	}
}

extension FreshtabViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// extension for telemetry signals
extension FreshtabViewController {

	fileprivate func logShowSignal() {
		/*
		guard isForgetMode == false else { return }
		
		let loadDuration = Int(Date.getCurrentMillis() - startTime)
		var customData: [String: Any] = ["topsite_count": topSites.count, "load_duration": loadDuration]
		let breakingNewsCount = self.breakingNewsCount()
		let localNewsCount = self.localNewsCount()
		
		if isLoadCompleted {
			customData["is_complete"] = true
			customData["topnews_available_count"] = news.count - breakingNewsCount - localNewsCount
			customData["topnews_count"] = min(news.count, FreshtabViewUX.MinNewsCellsCount) - breakingNewsCount - localNewsCount
			customData["breakingnews_count"] = breakingNewsCount
			customData["localnews_count"] = localNewsCount
		} else {
			customData["is_complete"] = false
			customData["topnews_available_count"] = 0
			customData["topnews_count"] = 0
			customData["breakingnews_count"] = 0
			customData["localnews_count"] = 0
		}
		customData["is_topsites_on"] = SettingsPrefs.shared.getShowTopSitesPref()
		customData["is_news_on"] = SettingsPrefs.shared.getShowNewsPref()
		logFreshTabSignal("show", target: nil, customData: customData)
*/
        TelemetryHelper.sendFreshTabShow()
	}
	
	fileprivate func logHideSignal() {
		guard isForgetMode == false else { return }
		// TODO: ...
	}
	
	fileprivate func logScrollSignal() {
		guard isForgetMode == false else { return }
		
		guard self.scrollCount > 0 else {
			return
		}
		// TODO: ...
	}
}

extension FreshtabViewController : FreshTabDelegate {
    
    func showTopSitesOVerlay() {
        self.topSitesEditModeOverlay.isHidden = false
    }
    
    func hideTopSitesOVerlay() {
        self.topSitesEditModeOverlay.isHidden = true
    }
}

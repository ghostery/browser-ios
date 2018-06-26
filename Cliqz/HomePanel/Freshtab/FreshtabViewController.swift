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
	static let TopSitesOffset = 5.0
	
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

	fileprivate var scrollView: UIScrollView!
	fileprivate var normalModeView: UIView?
	// TODO: Finialize need of forgetModeView and hopefully remove
	fileprivate var forgetModeView: ForgetModeView?

	fileprivate var topSitesViewController: TopSitesViewController?
	fileprivate var newsViewController: NewsViewController?

	fileprivate var topSitesDataSource: TopSitesDataSource!
	fileprivate var newsDataSource: NewsDataSource!

	fileprivate var scrollCount = 0
	fileprivate var startTime : Timestamp = Date.now()

	init(profile: Profile) {
		super.init(nibName: nil, bundle: nil)
		self.profile = profile
		self.topSitesDataSource = TopSitesDataSource.instance
		self.newsDataSource = NewsDataSource.instance
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupViews()
        self.setupConstraints()
        
        self.normalModeView?.alpha = 0.0
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
            self.normalModeView?.alpha = 1.0
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
    
    func setupConstraints() {
        if !isForgetMode {
            self.scrollView.snp.makeConstraints({ (make) in
                make.top.left.bottom.right.equalTo(self.view)
            })
            let topSitesHeight = self.topSitesViewController?.getTopSitesHeight() ?? 0
            self.topSitesViewController?.view.snp.makeConstraints({ (make) in
                make.top.equalTo(self.normalModeView!).offset(FreshtabViewUX.topOffset)
                make.left.equalTo(self.normalModeView!).offset(FreshtabViewUX.TopSitesOffset)
                make.right.equalTo(self.normalModeView!).offset(-FreshtabViewUX.TopSitesOffset)
                make.height.equalTo((self.topSitesViewController?.topSitesCollection?.snp.height)!).offset(TopSitesUX.TopSiteHintHeight)
            })
            
            // news table
            let newsHeight = self.newsViewController?.getNewsHeight() ?? 0
            self.newsViewController?.view.snp.makeConstraints { (make) in
                make.left.equalTo(self.view).offset(21)
                make.right.equalTo(self.view).offset(-21)
                make.height.equalTo((self.newsViewController?.newsTableView?.snp.height)!)
                make.top.equalTo((self.topSitesViewController?.view.snp.bottom)!).offset(FreshtabViewUX.topOffset)
            }
            
            // normalModeView height
            let invisibleFreshTabHeight = getInvisibleFreshTabHeight(topSitesHeight: topSitesHeight, newsHeight: newsHeight)
            let normalModeViewHeight = self.view.bounds.height + invisibleFreshTabHeight
            
            self.normalModeView?.snp.makeConstraints({ (make) in
                make.top.left.bottom.right.equalTo(scrollView)
                make.width.equalTo(self.view)
                make.height.equalTo(normalModeViewHeight)
            })
        }
    }

	override func updateViewConstraints() {
        
		if !isForgetMode {
			let topSitesHeight = self.topSitesViewController?.getTopSitesHeight() ?? 0
            let newsHeight = self.newsViewController?.getNewsHeight() ?? 0
			// normalModeView height
			let invisibleFreshTabHeight = getInvisibleFreshTabHeight(topSitesHeight: topSitesHeight, newsHeight: newsHeight)
			let normalModeViewHeight = self.view.bounds.height + invisibleFreshTabHeight
			
			self.normalModeView?.snp.updateConstraints({ (make) in
				make.height.equalTo(normalModeViewHeight)
			})
		}
        
        //Apple says this should be at the end
        super.updateViewConstraints()
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
			self.newsViewController?.restoreToInitialState()
		}
	}

	fileprivate func updateViews() {
		if isForgetMode {
			self.forgetModeView?.isHidden = false
			self.normalModeView?.isHidden = true
		} else {
			self.topSitesDataSource.refresh()
			self.normalModeView?.isHidden = false
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
		if self.normalModeView == nil {
			self.scrollView = UIScrollView()
			self.scrollView.delegate = self
			self.view.addSubview(self.scrollView)
			self.normalModeView = UIView()
			self.normalModeView?.backgroundColor = UIColor.clear
            
            self.scrollView.delegate = self
			self.scrollView.addSubview(self.normalModeView!)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            normalModeView?.addGestureRecognizer(tap)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            pan.cancelsTouchesInView = false
            normalModeView?.addGestureRecognizer(pan)
			
			self.topSitesViewController = TopSitesViewController(dataSource: self.topSitesDataSource)
			self.topSitesViewController?.homePanelDelegate = self.homePanelDelegate
			self.addChildViewController(self.topSitesViewController!)
			if let topSites = self.topSitesViewController?.view {
				self.normalModeView?.addSubview(topSites)
				topSites.backgroundColor = UIColor.clear
			}
			self.newsViewController = NewsViewController(dataSource: self.newsDataSource)
			self.newsViewController?.homePanelDelegate = self.homePanelDelegate
			self.addChildViewController(self.newsViewController!)
			if let newsView = self.newsViewController?.view {
				self.normalModeView?.addSubview(newsView)
				newsView.backgroundColor = UIColor.clear
			}
		}
	}
    
    func dismissKeyboard(_ sender: Any? = nil) {
        view.window?.rootViewController?.view.endEditing(true)
    }
}

extension FreshtabViewController: UIScrollViewDelegate {
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.dismissKeyboard()
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

//
//  NewsViewController.swift
//  Client
//
//  Created by Sahakyan on 2/13/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import RxSwift

struct NewsViewUX {
	
	static let NewsViewMinHeight: CGFloat = 162.0
	static let NewsCellHeight: CGFloat = 68.0
	static let MinNewsCellsCount = 2
}

// TODO: Region is missing
class NewsViewController: UIViewController, HomePanel {

	weak var homePanelDelegate: HomePanelDelegate?

	private var profile: Profile!
	fileprivate var dataSource: NewsDataSource!
	private let disposeBag = DisposeBag()

	fileprivate var isNewsExpanded = false

    var newsTableView: UITableView?
	fileprivate var expandNewsbutton = UIButton()

	init(dataSource: NewsDataSource) {
		self.dataSource = dataSource
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.dataSource.observable.asObserver().subscribe(onNext: { value in
			self.newsTableView?.reloadData()
		}).disposed(by: disposeBag)
		self.setupComponents()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.restoreToInitialState()
	}

	func restoreToInitialState() {
		isNewsExpanded = false
		self.newsTableView?.reloadData()
	}

    override func updateViewConstraints() {
        
        let newsHeight = getNewsHeight()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.newsTableView?.snp.updateConstraints({ (make) in
                make.height.equalTo(newsHeight)
            })
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutSubviews()
            })
        }
        
        //Apple says this should be at the end
        super.updateViewConstraints()
    }

	func getNewsHeight() -> CGFloat {
//		guard SettingsPrefs.shared.getShowNewsPref() && self.news.count != 0 else {
//			return 0.0
//		}
		
		if self.isNewsExpanded {
			return (NewsViewUX.NewsViewMinHeight + CGFloat((self.tableView(self.newsTableView!, numberOfRowsInSection: 0)) - NewsViewUX.MinNewsCellsCount) * NewsViewUX.NewsCellHeight)
		} else {
			return NewsViewUX.NewsViewMinHeight
		}
	}
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.isNewsExpanded ? self.dataSource.newsCount() : min(NewsViewUX.MinNewsCellsCount, self.dataSource.newsCount())
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.newsTableView?.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsViewCell
		if indexPath.row < self.dataSource.newsCount() {
			if let currentNewsViewModel = self.dataSource.getNewsViewModel(at: indexPath.row) {
				cell.viewModel = currentNewsViewModel
			}
		}
		cell.selectionStyle = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return NewsViewUX.NewsCellHeight
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		guard SettingsPrefs.shared.getShowNewsPref() else { return }
		
		if indexPath.row < self.dataSource.newsCount(),
			let selectedNews = self.dataSource.getNews(at: indexPath.row),
			let urlString = selectedNews.url {
			if let url = URL(string: urlString) {
				self.homePanelDelegate?.homePanel(self, didSelectURL: url, visitType: .link)
			} else if let encodedURL = urlString.escapeURL(),
				let url = URL(string: encodedURL) {
				self.homePanelDelegate?.homePanel(self, didSelectURL: url, visitType: .link)
			}
			if let currentCell = tableView.cellForRow(at: indexPath) as? ClickableUITableViewCell {
				let target = getNewsTarget(selectedNews)
				logNewsSignal(target, element: currentCell.clickedElement, index: indexPath.row)
			}
		}
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let v = UIView()
		v.backgroundColor = UIColor.black
		let l = UILabel()
		l.text = NSLocalizedString("NEWS", tableName: "Cliqz", comment: "Title to expand news stream")
		l.textColor = UIColor.white
		l.font = UIFont.systemFont(ofSize: 13)
		v.addSubview(l)
		l.snp.makeConstraints { (make) in
			make.left.equalTo(v).offset(10)
			make.top.equalTo(v)
			make.height.equalTo(27)
			make.right.equalTo(v)
		}
		expandNewsbutton = UIButton()
		v.addSubview(expandNewsbutton)
		expandNewsbutton.contentHorizontalAlignment = .right
		expandNewsbutton.snp.makeConstraints { (make) in
			make.top.equalTo(v).offset(-2)
			make.right.equalTo(v).offset(-9)
			make.height.equalTo(30)
			make.width.equalTo(v).dividedBy(2)
		}
		if isNewsExpanded {
			expandNewsbutton.setTitle(NSLocalizedString("LessNews", tableName: "Cliqz", comment: "Title to expand news stream"), for: .normal)
		} else {
			expandNewsbutton.setTitle(NSLocalizedString("MoreNews", tableName: "Cliqz", comment: "Title to expand news stream"), for: .normal)
		}
		expandNewsbutton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
		expandNewsbutton.titleLabel?.textAlignment = .right
		expandNewsbutton.setTitleColor(UIColor.white, for: .normal)
		expandNewsbutton.addTarget(self, action: #selector(toggleShowMoreNews), for: .touchUpInside)
		return v
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1.0
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		var rect = CGRect.zero
		rect.size.height = 1
		return UIView(frame: rect)
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 27.0
	}
}

extension NewsViewController {

	fileprivate func setupComponents() {
		self.newsTableView = UITableView(frame: CGRect.zero, style: .grouped)
		self.newsTableView?.delegate = self
		self.newsTableView?.dataSource = self
		self.newsTableView?.backgroundColor = UIColor.clear
		self.view.addSubview(self.newsTableView!)
		//			self.newsTableView?.isHidden = true
		self.newsTableView?.tableFooterView = UIView(frame: CGRect.zero)
		self.newsTableView?.layer.cornerRadius = 9.0
		self.newsTableView?.isScrollEnabled = false
		self.newsTableView?.snp.makeConstraints { (make) in
			make.left.equalTo(self.view).offset(9)
			make.right.equalTo(self.view).offset(-9)
			make.height.equalTo(FreshtabViewUX.NewsViewMinHeight)
			make.top.equalTo(self.view).offset(FreshtabViewUX.topOffset)
		}	
		newsTableView?.register(NewsViewCell.self, forCellReuseIdentifier: "NewsCell")
		newsTableView?.separatorStyle = .singleLine
		self.newsTableView?.accessibilityLabel = "topNews"
	}

	@objc fileprivate func toggleShowMoreNews() {
		//		self.delegate?.dismissKeyboard()
		self.isNewsExpanded = !self.isNewsExpanded
		
		self.updateViewConstraints()
		self.parent?.updateViewConstraints()
		isNewsExpanded ? showMoreNews() : showLessNews()
		
		if isNewsExpanded {
			expandNewsbutton.setTitle(NSLocalizedString("LessNews", tableName: "Cliqz", comment: "Title to expand news stream"), for: .normal)
		} else {
			expandNewsbutton.setTitle(NSLocalizedString("MoreNews", tableName: "Cliqz", comment: "Title to expand news stream"), for: .normal)
		}
		self.logNewsViewModifiedSignal(isExpanded: self.isNewsExpanded)
	}
	
	fileprivate func showMoreNews() {
        self.newsTableView?.beginUpdates()
		let indexPaths = getExtraNewsIndexPaths()
		self.newsTableView?.insertRows(at:indexPaths, with: .none)
        self.newsTableView?.endUpdates()
	}
	
	fileprivate func showLessNews() {
        self.newsTableView?.beginUpdates()
		let indexPaths = getExtraNewsIndexPaths()
		self.newsTableView?.deleteRows(at:indexPaths, with: .none)
        self.newsTableView?.endUpdates()
	}
	
	fileprivate func getExtraNewsIndexPaths() -> [IndexPath] {
		var indexPaths = [IndexPath]()
		for i in NewsViewUX.MinNewsCellsCount..<self.dataSource.newsCount() {
			indexPaths.append(IndexPath(row: i, section: 0))
		}
		return indexPaths
	}

	fileprivate func getNewsTarget(_ selectedNews: News) -> String {
		var target = "topnews"
		if selectedNews.isBreaking ?? false {
			target  = "breakingnews"
		}
		if let _ = selectedNews.localLabel {
			target = "localnews"
		}
		return target
	}

	fileprivate func logNewsViewModifiedSignal(isExpanded expanded: Bool) {
	}

	fileprivate func logNewsSignal(_ target: String, element: String, index: Int) {
	}

}

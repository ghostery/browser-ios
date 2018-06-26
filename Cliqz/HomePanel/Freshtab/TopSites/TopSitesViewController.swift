//
//  TopSitesViewController.swift
//  Client
//
//  Created by Sahakyan on 2/13/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import RxSwift

struct TopSitesUX {
	static let TopSitesMinHeight: CGFloat = 95.0
	static let TopSitesMaxHeight: CGFloat = 185.0
	static let TopSitesCellSize = CGSize(width: 76, height: 86)
	static let TopSitesCountOnRow = 4
	static let TopSitesOffset = 5.0
    static let TopSiteHintHeight: CGFloat = 14.0
}

class TopSitesViewController: UIViewController, HomePanel {

	weak var homePanelDelegate: HomePanelDelegate?

	fileprivate var dataSource: TopSitesDataSource!

	private let disposeBag = DisposeBag()

    var topSitesCollection: UICollectionView?

    var emptyTopSitesHint: UILabel?

	init(dataSource: TopSitesDataSource) {
		self.dataSource = dataSource
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupComponents()
        self.setConstraints()
		
		self.dataSource.observable.asObserver().subscribe({ value in
			self.updateViews()
            self.topSitesCollection?.alpha = 1.0
		}).disposed(by: disposeBag)

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.topSitesCollection?.collectionViewLayout.invalidateLayout()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		self.topSitesCollection?.collectionViewLayout.invalidateLayout()
	}
    
    fileprivate func setConstraints() {
        if self.emptyTopSitesHint?.superview != nil {
            self.emptyTopSitesHint!.snp.makeConstraints({ (make) in
                make.top.equalTo(self.view).offset(8)
                make.left.right.equalTo(self.view)
                make.height.equalTo(TopSitesUX.TopSiteHintHeight)
            })
        }
        let topSitesHeight = getTopSitesHeight()
        self.topSitesCollection?.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(FreshtabViewUX.topOffset)
            make.left.equalTo(self.view).offset(FreshtabViewUX.TopSitesOffset)
            make.right.equalTo(self.view).offset(-FreshtabViewUX.TopSitesOffset)
            make.height.equalTo(topSitesHeight)
        }
    }

	func getTopSitesHeight() -> CGFloat {
        guard SettingsPrefs.shared.getShowTopSitesPref() else {
            return 0.0
        }

		if self.dataSource.topSitesCount() > TopSitesUX.TopSitesCountOnRow && !UIDevice.current.isSmallIphoneDevice() {
			return TopSitesUX.TopSitesMaxHeight
		}
        
        return TopSitesUX.TopSitesMinHeight
		
	}
	
	@objc fileprivate func cancelActions(_ sender: UITapGestureRecognizer) {
		self.removeDeletedTopSites()
	}
}

extension TopSitesViewController {

	fileprivate func setupComponents() {
		self.topSitesCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
		self.topSitesCollection?.delegate = self
		self.topSitesCollection?.dataSource = self
		self.topSitesCollection?.backgroundColor = UIColor.clear
		self.topSitesCollection?.register(TopSiteViewCell.self, forCellWithReuseIdentifier: "TopSite")
		self.topSitesCollection?.isScrollEnabled = false
		self.topSitesCollection?.accessibilityLabel = "topSites"
		self.view.addSubview(self.topSitesCollection!)
        self.topSitesCollection?.alpha = 0.0
		
		self.emptyTopSitesHint = UILabel()
		self.emptyTopSitesHint?.text = NSLocalizedString("Empty TopSites hint", tableName: "Cliqz", comment: "Hint on Freshtab when there is no topsites")
		self.emptyTopSitesHint?.font = UIFont.systemFont(ofSize: 12)
		self.emptyTopSitesHint?.textColor = UIColor.white
        self.emptyTopSitesHint?.applyShadow()
		self.emptyTopSitesHint?.textAlignment = .center
		self.view.addSubview(self.emptyTopSitesHint!)
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cancelActions))
		tapGestureRecognizer.delegate = self
		self.view.addGestureRecognizer(tapGestureRecognizer)
	}

	fileprivate func updateViews() {
		DispatchQueue.main.async {
			if self.dataSource.topSitesCount() > 0 {
				self.emptyTopSitesHint?.isHidden = true
			} else {
				self.emptyTopSitesHint?.isHidden = false
			}
            
            let topSitesHeight = self.getTopSitesHeight()
            
            self.topSitesCollection?.snp.updateConstraints { (make) in
                make.height.equalTo(topSitesHeight)
            }
            
			self.topSitesCollection?.reloadData()
			self.updateViewConstraints()
			self.parent?.updateViewConstraints()
		}
	}

	fileprivate func removeDeletedTopSites() {
		if let cells = self.topSitesCollection?.visibleCells as? [TopSiteViewCell] {
			for cell in cells {
				cell.isDeleteMode = false
			}
		}
	}

}

extension TopSitesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if UIDevice.current.isSmallIphoneDevice() {
			return TopSitesUX.TopSitesCountOnRow
		}
		return self.dataSource.topSitesCount() > TopSitesUX.TopSitesCountOnRow ? 2 * TopSitesUX.TopSitesCountOnRow : TopSitesUX.TopSitesCountOnRow
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopSite", for: indexPath) as! TopSiteViewCell
		cell.tag = -1
		cell.delegate = self
        
		if let topSite = self.dataSource.getTopSite(at: indexPath.row) {
            
			cell.tag = indexPath.row
			let url = topSite.url
            cell.logoContainerView.alpha = 0.0
			LogoLoader.loadLogo(url, completionBlock: { (img, logoInfo, error) in
				if cell.tag == indexPath.row {
					if let img = img {
						cell.logoImageView.image = img
					}
					else if let info = logoInfo {
						let placeholder = LogoPlaceholder(logoInfo: info)
						cell.fakeLogoView = placeholder
						cell.logoContainerView.addSubview(placeholder)
						placeholder.snp.makeConstraints({ (make) in
							make.top.left.right.bottom.equalTo(cell.logoContainerView)
						})
					}
					cell.logoHostLabel.text = logoInfo?.hostName
				}
                UIView.animate(withDuration: 0.1, animations: {
                    cell.logoContainerView.alpha = 1.0
                })
			})
		}
		if cell.gestureRecognizers == nil {
			let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(deleteTopSites(_:)))
			cell.addGestureRecognizer(longPressGestureRecognizer)
		}
		cell.tag = indexPath.row
		return cell
	}
	
	@objc private func deleteTopSites(_ gestureReconizer: UILongPressGestureRecognizer)  {
		let cells = self.topSitesCollection?.visibleCells
		for cell in cells as! [TopSiteViewCell] {
			cell.isDeleteMode = true
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let s = self.dataSource.getTopSite(at: indexPath.row)
		if let urlString = s?.url {
			if let url = URL(string: urlString) {
				self.homePanelDelegate?.homePanel(self, didSelectURL: url, visitType: .link)
                logTopsiteClick(indexPath.row)
			} else if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
				self.homePanelDelegate?.homePanel(self, didSelectURL: url, visitType: .link)
                logTopsiteClick(indexPath.row)
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return TopSitesUX.TopSitesCellSize
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 3.0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(10, sideInset(collectionView), 0, sideInset(collectionView))
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return cellSpacing(collectionView)
	}
	
	func sideInset(_ collectionView: UICollectionView) -> CGFloat {
		//Constraint = cellSpacing should never be negative
		let v = collectionView.frame.size.width - CGFloat(TopSitesUX.TopSitesCountOnRow) * TopSitesUX.TopSitesCellSize.width
		
		if v > 0 {
			let inset = v / 5.0
			return floor(inset)
		}
		
		return 0.0
	}
	
	func cellSpacing(_ collectionView: UICollectionView) -> CGFloat{
		let inset = sideInset(collectionView)
		if inset > 1.0 {
			return inset - 1
		}
		return 0.0
	}
}

extension TopSitesViewController: UIGestureRecognizerDelegate {

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if gestureRecognizer is UITapGestureRecognizer {
			let location = touch.location(in: self.topSitesCollection)
			if let index = self.topSitesCollection?.indexPathForItem(at: location),
				let cell = self.topSitesCollection?.cellForItem(at: index) as? TopSiteViewCell {
				return cell.isDeleteMode
			}
			return true
		}
		return false
	}
}

extension TopSitesViewController: TopSiteCellDelegate {
	
	func hideTopSite(_ index: Int) {
		// TODO: for now after hiding top site the view will be refreshed and wobbling is stopped. In future we should support hiding of multiple topsites
		self.dataSource.hideTopSite(at: index)
	}
}

// extension for telemetry signals
extension TopSitesViewController {
	fileprivate func logTopsiteSignal(action: String, index: Int) {
		//TODO(Refactoring): Should be inluded back during integration
//		let customData: [String: Any] = ["topsite_count": topSites.count, "index": index]
//		self.logFreshTabSignal(action, target: "topsite", customData: customData)
        TelemetryHelper.sendTopSiteClick()
	}
    
    fileprivate func logTopsiteClick(_ index: Int) {
        TelemetryHelper.sendTopSiteClick()
    }
	
	fileprivate func logDeleteTopsiteSignal(_ index: Int) {
		//TODO(Refactoring): Should be inluded back during integration

//		let customData: [String: Any] = ["index": index]
//		self.logFreshTabSignal("click", target: "delete_topsite", customData: customData)
	}
	
	fileprivate func logTopsiteEditModeSignal() {
		//TODO(Refactoring): Should be inluded back during integration

//		let customData: [String: Any] = ["topsite_count": topSites.count, "delete_count": topSitesIndexesToRemove.count, "view": "topsite_edit_mode"]
//		self.logFreshTabSignal("click", target: nil, customData: customData)
	}
}

//
//  TrackersTableViewController.swift
//  BrowserCore
//
//  Created by Tim Palade on 3/19/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

//This is a temporary solution until we build the Ghostery Control Center

let trackerViewDismissedNotification = Notification.Name(rawValue: "TrackerViewDismissed")

struct ControlCenterUI {
	static let separatorGray = UIColor(colorString: "E0E0E0")
	static let textGray = UIColor(colorString: "C7C7CD")
	static let buttonGray = UIColor(colorString: "4A4A4A")
}

class TrackersController: UIViewController {
    
    let headerView = CategoriesHeaderView()

	var type: TableType = .page {
		didSet {
			self.tableView.reloadData()
		}
	}

	weak var dataSource: ControlCenterDSProtocol? {
		didSet {
			updateData()
		}
	}
	weak var delegate: ControlCenterDelegateProtocol?
	
	let observable = BehaviorSubject(value: "")

    let tableView = UITableView()
	var expandedSectionIndex = -1

    var changes = false

    override func viewDidLoad() {
        super.viewDidLoad()
		setupComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if type == .page {
            if self.dataSource?.isGhosteryPaused() == true {
                headerView.actionButton.isEnabled = false
            }
            else {
                headerView.actionButton.isEnabled = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	private func setupComponents() {
		headerView.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
		self.tableView.tableHeaderView = headerView
		self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 80)
		self.tableView.tableHeaderView?.snp.makeConstraints { (make) in
			make.top.left.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalTo(80)
		}

		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(TrackerViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
		view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.top.left.right.bottom.equalToSuperview()
		}
	}

	private func updateData() {
		self.tableView.reloadData()
	}

    @objc private func showActionSheet(_ sender: Any) {
		switch type {
		case .page:
			showPageActionSheet(sender)
			break
		case .global:
			showGlobalActionSheet(sender)
		}
	}

    private func showPageActionSheet(_ sender: Any) {
		let blockTrustAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
        if self.dataSource?.shouldShowBlockAll(tableType: type) == true {
            let blockAll = UIAlertAction(title: NSLocalizedString("Block All", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Block All trackers action title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
                 self?.blockAll()
            })
            blockTrustAlertController.addAction(blockAll)
        }
        
        if self.dataSource?.shouldShowUnblockAll(tableType: type) == true {
            let unblockAll = UIAlertAction(title: NSLocalizedString("Unblock All", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Unblock All trackers action title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
                self?.unblockAll()
            })
            blockTrustAlertController.addAction(unblockAll)
        }
		
        if self.dataSource?.shouldShowUndo(tableType: type) == true {
            let undo = UIAlertAction(title: NSLocalizedString("Undo", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Undo trackers action title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
                self?.undo()
            })
            blockTrustAlertController.addAction(undo)
        }
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Cancel action title"), style: .cancel)
		blockTrustAlertController.addAction(cancelAction)
        
        if let presentation = blockTrustAlertController.popoverPresentationController, let v = sender as? UIView {
            presentation.sourceView = v
            presentation.sourceRect = CGRect(x: v.bounds.width/2, y: v.bounds.height/2 + 16, width: 0, height: 0)
            presentation.canOverlapSourceViewRect = true
            presentation.permittedArrowDirections = .up
            self.present(blockTrustAlertController, animated: true, completion: nil)
        }
        else if UIDevice.current.isiPad() == false { //avoid crash
            self.present(blockTrustAlertController, animated: true, completion: nil)
        }
        
	}

	private func showGlobalActionSheet(_ sender: Any) {
		let blockTrustAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if self.dataSource?.shouldShowBlockAll(tableType: type) == true {
            let blockAll = UIAlertAction(title: NSLocalizedString("Block All", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Block All trackers action title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
                self?.blockAll()
            })
            blockTrustAlertController.addAction(blockAll)
        }
		
        if self.dataSource?.shouldShowUnblockAll(tableType: type) == true {
            let unblockAll = UIAlertAction(title: NSLocalizedString("Unblock All", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Unblock All trackers action title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
                self?.unblockAll()
            })
            blockTrustAlertController.addAction(unblockAll)
        }
        
        if self.dataSource?.shouldShowUndo(tableType: type) == true {
            let undo = UIAlertAction(title: NSLocalizedString("Undo", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Undo trackers action title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
                self?.undo()
            })
            blockTrustAlertController.addAction(undo)
        }
        
        let restore = UIAlertAction(title: NSLocalizedString("Restore Default Settings", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Restore Default Settings trackers action title"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
            self?.restoreDefaultSettings()
        })
        blockTrustAlertController.addAction(restore)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "[ControlCenter - Trackers list] Cancel action title"), style: .cancel)
		blockTrustAlertController.addAction(cancelAction)
        
        if let presentation = blockTrustAlertController.popoverPresentationController, let v = sender as? UIView {
            presentation.sourceView = v
            presentation.sourceRect = CGRect(x: v.bounds.width/2, y: v.bounds.height/2 + 16, width: 0, height: 0)
            presentation.canOverlapSourceViewRect = true
            presentation.permittedArrowDirections = .up
            self.present(blockTrustAlertController, animated: true, completion: nil)
        }
        else if UIDevice.current.isiPad() == false { //avoid crash
            self.present(blockTrustAlertController, animated: true, completion: nil)
        }
	}

	private func blockAll() {
        headerView.showSpinner()
        self.delegate?.blockAll(tableType: type, completion: { [weak self] in
            self?.tableView.reloadData()
            self?.headerView.hideSpinner()
        })
	}

    private func unblockAll() {
        headerView.showSpinner()
        self.delegate?.unblockAll(tableType: type) { [weak self] in
            self?.tableView.reloadData()
            self?.headerView.hideSpinner()
        }
    }

    private func undo() {
        headerView.showSpinner()
        self.delegate?.undoAll(tableType: type) { [weak self] in
            self?.tableView.reloadData()
            self?.headerView.hideSpinner()
        }
    }

    private func restoreDefaultSettings() {
        headerView.showSpinner()
        self.delegate?.restoreDefaultSettings(tableType: type) { [weak self] in
            self?.tableView.reloadData()
            self?.headerView.hideSpinner()
        }
    }

	private func trustAllCategories() {
        headerView.showSpinner()
        self.delegate?.changeAll(state: .trusted, tableType: type, completion: { [weak self] in
            self?.tableView.reloadData()
            self?.headerView.hideSpinner()
        })
	}

	private func restrictAllCategories() {
        headerView.showSpinner()
        self.delegate?.changeAll(state: .restricted, tableType: type, completion: { [weak self] in
            self?.tableView.reloadData()
            self?.headerView.hideSpinner()
        })
	}

}

extension TrackersController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.numberOfSections(tableType: type) ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.expandedSectionIndex == section {
			return self.dataSource?.numberOfRows(tableType: type, section: section) ?? 0
		}
        return 0
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 90
	}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TrackerViewCell

        let touple = self.dataSource?.title(tableType: type, indexPath: indexPath)
        if let title = touple?.0 {
            cell.trackerNameLabel.text = title
        } else if let attrTitle = touple?.1 {
            cell.trackerNameLabel.attributedText = attrTitle
        } else {
            cell.trackerNameLabel.text = ""
        }
        
		cell.selectionStyle = .none
        cell.appId = self.dataSource?.appId(tableType: type, indexPath: indexPath) ?? -1
        cell.statusIcon.image = self.dataSource?.stateIcon(tableType: type, indexPath: indexPath)
        
        if type == .page {
            if dataSource?.isGhosteryPaused() == true {
                cell.statusIcon.alpha = 0.5
            }
            else {
                cell.statusIcon.alpha = 1.0
            }
        }
        
		cell.infoButtonAction = { [weak self] (button, trackerName) in
			var url = "https://whotracks.me/tracker-not-found.html"
			if let t = trackerName {
				if let d = Engine.sharedInstance.getBridge().callAction("mobile-cards:getTrackerDetails", args: [t.lowercased()]) as? [String: Any],
					let result = d["result"] as? [String: String],
					let wtm = result["wtm"] {
					url = "https://whotracks.me/trackers/\(wtm).html"
				}
			}
			self?.observable.on(.next(url))
		}
        return cell
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = CategoryHeaderView()
		header.type = type
		header.tag = section
		header.categoryName = self.dataSource?.title(tableType: type, section: section)
		header.categoryIcon = self.dataSource?.image(tableType: type, section: section) ?? nil
		header.trackersCount = self.dataSource?.trackerCount(tableType: type, section: section) ?? 0
		header.blockedTrackersCount = self.dataSource?.blockedTrackerCount(tableType: type, section: section) ?? 0
		header.statusIcon = self.dataSource?.stateIcon(tableType: type, section: section)
		header.isExpanded = section == expandedSectionIndex
        
        if type == .page {
            self.dataSource?.isGhosteryPaused() == true ? header.lookDeactivated() : header.lookActivated()
        }
        
		let headerTapGesture = UITapGestureRecognizer()
		headerTapGesture.addTarget(self, action: #selector(sectionHeaderTapped(_:)))
		header.addGestureRecognizer(headerTapGesture)
		return header
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let sep = UIView()
		sep.backgroundColor = ControlCenterUI.separatorGray
		return sep
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let appId = self.dataSource?.appId(tableType: type, indexPath: indexPath) ?? -1
		var swipeActions = [UIContextualAction]()
		if let actions = self.dataSource?.actions(tableType: type, indexPath: indexPath) {
			for action in actions {
				switch action {
				case .trust:
					let trustAction = UIContextualAction(style: .normal, title: NSLocalizedString("Trust", tableName: "Cliqz", comment: "[Trackers -> ControlCenter] Trust Action Title")) { [unowned self] (action, view, complHandler) in
                        self.delegate?.changeState(appId: appId, state: .trusted, section: indexPath.section, tableType: self.type)
						self.tableView.beginUpdates()
						tableView.reloadRows(at: [indexPath], with: .none)
						self.tableView.endUpdates()
						complHandler(false)
					}
					trustAction.backgroundColor = UIColor.cliqzGreenLightFunctional
					swipeActions.append(trustAction)
                case .untrust:
                    let untrustAction = UIContextualAction(style: .normal, title: NSLocalizedString("Untrust", tableName: "Cliqz", comment: "[Trackers -> ControlCenter] Untrust Action Title")) { [unowned self] (action, view, complHandler) in
                        self.delegate?.changeState(appId: appId, state: .empty, section: indexPath.section, tableType: self.type)
                        self.tableView.beginUpdates()
                        tableView.reloadRows(at: [indexPath], with: .none)
                        self.tableView.endUpdates()
                        complHandler(false)
                    }
                    untrustAction.backgroundColor = UIColor.cliqzGreenLightFunctional
                    swipeActions.append(untrustAction)
				case .block:
					let blockAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Block", tableName: "Cliqz", comment: "[Trackers -> ControlCenter] Block Action Title")) { [unowned self] (action, view, complHandler) in
						self.delegate?.changeState(appId: appId, state: .blocked, section: indexPath.section, tableType: self.type)
						self.tableView.beginUpdates()
                        tableView.reloadRows(at: [indexPath], with: .none)
						self.tableView.endUpdates()
						complHandler(false)
					}
					blockAction.backgroundColor = UIColor(colorString: "E74055")
					swipeActions.append(blockAction)
				case .unblock:
					let unblockAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Unblock", tableName: "Cliqz", comment: "[Trackers -> ControlCenter] Unblock Action Title")) { [unowned self] (action, view, complHandler) in
						self.delegate?.changeState(appId: appId, state: .empty, section: indexPath.section, tableType: self.type)
						self.tableView.beginUpdates()
						tableView.reloadRows(at: [indexPath], with: .none)
						self.tableView.endUpdates()
						complHandler(false)
					}
					unblockAction.backgroundColor = UIColor(colorString: "E74055")
					swipeActions.append(unblockAction)
				case .restrict:
					let restrictAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Restrict", tableName: "Cliqz", comment: "[Trackers -> ControlCenter] Restrict Action Title")) { [unowned self] (action, view, complHandler) in
						self.delegate?.changeState(appId: appId, state: .restricted, section: indexPath.section, tableType: self.type)
						self.tableView.beginUpdates()
						tableView.reloadRows(at: [indexPath], with: .none)
						self.tableView.endUpdates()
						complHandler(false)
					}
					restrictAction.backgroundColor = UIColor(colorString: "BE4948")
					swipeActions.append(restrictAction)
                case .unrestrict:
                    let unrestrictAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Unrestrict", tableName: "Cliqz", comment: "[Trackers -> ControlCenter] Unrestrict Action Title")) { [unowned self] (action, view, complHandler) in
                        self.delegate?.changeState(appId: appId, state: .empty, section: indexPath.section, tableType: self.type)
                        self.tableView.beginUpdates()
                        tableView.reloadRows(at: [indexPath], with: .none)
                        self.tableView.endUpdates()
                        complHandler(false)
                    }
                    unrestrictAction.backgroundColor = UIColor(colorString: "BE4948")
                    swipeActions.append(unrestrictAction)
				}
			}
		}
		return UISwipeActionsConfiguration(actions: swipeActions)
	}

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TrackerViewCell {
            cell.showSwipeLabel()
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

	@objc private func sectionHeaderTapped(_ sender: UITapGestureRecognizer) {
		let headerView = sender.view
		if let section = headerView?.tag {
			var set = IndexSet()
            
            // Note: This is a temporary solution to the table disappearing after a section is collapsed.
            // The problem seems to be inside the Apple code. One possible solution is to convert this to a UICollectionView.
            // Build indexPaths
            let numberOfRows = self.dataSource?.numberOfRows(tableType: type, section: section) ?? 0
            var indexPaths: [IndexPath] = []
            for i in 0..<numberOfRows {
                let indexPath = IndexPath(row: i, section: section)
                indexPaths.append(indexPath)
            }
            
			if self.expandedSectionIndex == section {
				self.expandedSectionIndex = -1
				set.insert(section)
                
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: indexPaths, with: .fade)
                }) { (finished) in
                    if finished {
                        self.tableView.setContentOffset(CGPoint.zero, animated: true)
                        //self.tableView.scrollRectToVisible(headerView!.frame, animated: true)
                    }
                }
                
			} else {
				if self.expandedSectionIndex != -1 {
					set.insert(self.expandedSectionIndex)
				}
				set.insert(section)
				self.expandedSectionIndex = section
                
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .fade)
                self.tableView.endUpdates()
			}
            
			if set.count > 1 {
				self.tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: false)
			}
		}
	}
}

class TrackerViewCell: UITableViewCell {

    var appId: Int = 0
	let infoButton = UIButton(type: .custom)
	let trackerNameLabel = UILabel()
	let statusIcon = UIImageView()
    private let swipeLabel = UILabel()

	typealias InfoButtonActionType = (UIButton, String?) -> ()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.contentView.addSubview(infoButton)
		self.contentView.addSubview(trackerNameLabel)
		self.contentView.addSubview(statusIcon)
        self.contentView.addSubview(swipeLabel)
		infoButton.setImage(UIImage(named: "info"), for: .normal)
		trackerNameLabel.font = UIFont.systemFont(ofSize: 16)
		trackerNameLabel.textColor = ControlCenterUI.textGray
        
        swipeLabel.font = UIFont.systemFont(ofSize: 16)
        swipeLabel.textColor = UIColor.cliqzBluePrimary
        swipeLabel.text = NSLocalizedString("Swipe", tableName: "Cliqz", comment: "[Trackers -> ControlCenter] Swipe Cell Title")
        swipeLabel.alpha = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	override func layoutSubviews() {
		super.layoutSubviews()
		infoButton.snp.remakeConstraints { (make) in
			make.left.centerY.equalToSuperview()
			make.width.equalTo(40)
		}
		trackerNameLabel.snp.remakeConstraints { (make) in
			make.left.equalTo(infoButton.snp.right).offset(4)
			make.top.centerY.equalToSuperview()
			make.right.equalTo(statusIcon.snp.left)
		}
		statusIcon.snp.remakeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(20)
		}
        swipeLabel.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
	}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.trackerNameLabel.attributedText = nil
        self.trackerNameLabel.text = ""
        self.statusIcon.image = nil
        self.appId = 0
    }
    
    func showSwipeLabel() {
        self.statusIcon.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.swipeLabel.alpha = 1.0
        }) { (finished) in
            if finished {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: { [weak self] in
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.swipeLabel.alpha = 0.0
                        self?.statusIcon.alpha = 1.0
                    })
                })
            }
        }
    }

	var infoButtonAction: InfoButtonActionType? {
		didSet {
			if infoButtonAction != nil {
				infoButton.addTarget(self, action: #selector(infoButtonTapped(_:)), for: .touchUpInside)
			} else {
				infoButton.removeTarget(self, action: #selector(infoButtonTapped(_:)), for: .touchUpInside)
			}
		}
	}
	
	@objc private func infoButtonTapped(_ sender: UIButton) {
		if let handler = infoButtonAction {
			handler(self.infoButton, trackerNameLabel.text)
		}
	}

}

class CategoriesHeaderView: UIControl {

	let categoriesLabel = UILabel()
	let actionButton = UIButton(type: .custom)
	let separator = UIView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

	init() {
		super.init(frame: CGRect.zero)
		self.addSubview(categoriesLabel)
		categoriesLabel.text = NSLocalizedString("Categories", tableName: "Cliqz", comment: "[Trackers -> ControlCenter] Trackers Title")
		self.addSubview(actionButton)
		actionButton.setImage(UIImage(named: "more"), for: .normal)
		self.addSubview(separator)
        self.addSubview(spinner)
        spinner.alpha = 0.0
		setStyles()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setStyles() {
		categoriesLabel.textColor = UIColor.black
		categoriesLabel.font = UIFont.boldSystemFont(ofSize: 24)
		separator.backgroundColor = ControlCenterUI.separatorGray
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.categoriesLabel.snp.remakeConstraints { (make) in
			make.left.equalTo(self).offset(12)
            make.centerY.equalToSuperview()
		}
		self.actionButton.snp.remakeConstraints { (make) in
			make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(50)
		}
		self.separator.snp.remakeConstraints { (make) in
			make.left.right.bottom.equalToSuperview()
			make.height.equalTo(1)
		}
        self.spinner.snp.makeConstraints { (make) in
            make.center.equalTo(actionButton.snp.center)
        }
	}

	override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
		self.actionButton.addTarget(target, action: action, for: controlEvents)
	}
    
    func showSpinner() {
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.actionButton.alpha = 0.0
            self.spinner.alpha = 1.0
            self.spinner.startAnimating()
            self.setNeedsDisplay()
        }
    }
    
    func hideSpinner() {
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.spinner.alpha = 0.0
            self.actionButton.alpha = 1.0
            self.spinner.stopAnimating()
            self.setNeedsDisplay()
        }
    }
}

class CategoryHeaderView: UIView {

	private let iconView = UIImageView()
	private let categoryLabel = UILabel()
	private let statisticsLabel = UILabel()
	private let typeLabel = UILabel()
	private let statusView = UIImageView()
	private let expandedIcon = UIImageView()

	var isExpanded = false {
		didSet {
			if isExpanded {
				expandedIcon.image = UIImage(named: "collapseCategory")
			} else {
				expandedIcon.image = UIImage(named: "expandCategory")
			}
		}
	}

	var categoryName: String? { //= self.dataSource?.title(tableType: .page, section: section)
		didSet {
			categoryLabel.text = categoryName
		}
	}

	var trackersCount = 0 {
		didSet {
			updateStatistics()
		}
	}

	var blockedTrackersCount = 0 {
		didSet {
			updateStatistics()
		}
	}

	var categoryIcon: UIImage? {
		didSet {
			self.iconView.image = categoryIcon
		}
	}

	var statusIcon: UIImage? {
		didSet {
			self.statusView.image = statusIcon
		}
	}

	var type: TableType = .page {
		didSet {
			switch type {
			case .page:
				self.typeLabel.text = NSLocalizedString("On this site", tableName: "Cliqz", comment: "[ControlCenter -> Trackers] category status for the current site")
			case .global:
				self.typeLabel.text = NSLocalizedString("On all sites", tableName: "Cliqz", comment: "[ControlCenter -> Global Trackers] category status fo all sites")
			}
		}
	}

	init() {
		super.init(frame: CGRect.zero)
		self.addSubview(iconView)
		self.addSubview(categoryLabel)
		self.addSubview(statisticsLabel)
		self.addSubview(statusView)
		self.addSubview(typeLabel)
		self.addSubview(expandedIcon)
		self.setStyles()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		iconView.snp.remakeConstraints { (make) in
			make.left.top.equalToSuperview().offset(10)
			make.width.height.equalTo(50)
		}
		categoryLabel.snp.remakeConstraints { (make) in
			make.top.right.equalToSuperview().offset(10)
			make.left.equalTo(iconView.snp.right).offset(10)
			make.height.equalTo(25)
		}
		statisticsLabel.snp.remakeConstraints { (make) in
			make.right.equalToSuperview().offset(10)
			make.top.equalTo(categoryLabel.snp.bottom).offset(0)
			make.left.equalTo(categoryLabel)
			make.height.equalTo(25)
		}
		typeLabel.snp.remakeConstraints { (make) in
			make.left.equalTo(categoryLabel)
			make.top.equalTo(statisticsLabel.snp.bottom)
			make.right.equalToSuperview()
			make.height.equalTo(20)
		}
		expandedIcon.snp.remakeConstraints { (make) in
			make.top.equalTo(statusView.snp.bottom).offset(20)
			make.right.equalToSuperview().inset(15)
		}
		statusView.snp.remakeConstraints { (make) in
			make.centerY.equalToSuperview().offset(-7)
			make.centerX.equalTo(expandedIcon)
		}
	}

	func setStyles() {
		self.backgroundColor = UIColor.white
		categoryLabel.font = UIFont.systemFont(ofSize: 16)
		statisticsLabel.font = UIFont.systemFont(ofSize: 12)
		statisticsLabel.textColor = ControlCenterUI.separatorGray
		typeLabel.textColor = UIColor.black
		typeLabel.font = UIFont.systemFont(ofSize: 10)
	}
    
    func lookDeactivated() {
        let color = UIColor.lightGray
        statisticsLabel.textColor = color
        typeLabel.textColor = color
        categoryLabel.textColor = color
        iconView.alpha = 0.5
        statusView.alpha = 0.5
    }
    
    func lookActivated() {
        statisticsLabel.textColor = ControlCenterUI.separatorGray
        typeLabel.textColor = UIColor.black
        categoryLabel.textColor = UIColor.black
        iconView.alpha = 1.0
        statusView.alpha = 1.0
    }

	private func updateStatistics() {
		statisticsLabel.text = String(format: NSLocalizedString("%d Tracker(s) %d Blocked", tableName: "Cliqz", comment: "[ControlCenter -> Trackers] Detected and Blocked trackers count"), self.trackersCount, self.blockedTrackersCount)
	}
}

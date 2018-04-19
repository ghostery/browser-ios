//
//  TrackersTableViewController.swift
//  BrowserCore
//
//  Created by Tim Palade on 3/19/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit
import SnapKit

//This is a temporary solution until we build the Ghostery Control Center

let AllCategories = ["advertising": "Advertising",
					 "audio_video_player": "Audio/Video Player",
					 "comments": "Comments",
					 "customer_interaction": "Customer Interaction",
					 "essential": "Essential",
					 "pornvertising": "Adult Advertising",
					 "site_analytics": "Site Analytics",
					 "social_media": "Social Media",
					 "uncategorized": "Uncategorized"
]


let trackerViewDismissedNotification = Notification.Name(rawValue: "TrackerViewDismissed")

class TrackersController: UIViewController {
    
    let tableView = UITableView()
    let toolBar = UIToolbar()
    
    var changes = false

    private var _trackers = [String: [TrackerListApp]]()
	fileprivate var categories = [String]()
    var trackers: [String: [TrackerListApp]] {
        set {
            _trackers = newValue
			categories = [String](_trackers.keys)
            self.tableView.reloadData()
        }
        get {
            return _trackers
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        let blockAll = UIBarButtonItem(title: "Block everything", style: .plain, target: self, action: #selector(blockAllPressed))
        let blockNone = UIBarButtonItem(title: "Block none", style: .plain, target: self, action: #selector(blockNonePressed))
        toolBar.setItems([done, blockNone, blockAll], animated: false)
        
        view.addSubview(tableView)
//        view.addSubview(toolBar)
		
//        toolBar.snp.makeConstraints { (make) in
//            make.bottom.left.right.equalToSuperview()
//        }
//
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc func donePressed(_ button: UIBarButtonItem) {
        NotificationCenter.default.post(name: trackerViewDismissedNotification, object: nil, userInfo: ["changes": changes])
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func blockAllPressed(_ button: UIBarButtonItem) {
        TrackerList.instance.blockAllTrackers()
        NotificationCenter.default.post(name: trackerViewDismissedNotification, object: nil, userInfo: ["changes": true])
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func blockNonePressed(_ button: UIBarButtonItem) {
        TrackerList.instance.unblockAllTrackers()
        NotificationCenter.default.post(name: trackerViewDismissedNotification, object: nil, userInfo: ["changes": true])
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TrackersController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.categories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		let c = self.categories[section]
		return trackers[c]?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! CustomCell
        
        // Configure the cell...
		let c = self.categories[indexPath.section]
		if trackers[c]?[indexPath.row].isBlocked ?? false {
			let x = (trackers[c]?[indexPath.row].name)!
			let strokeTextAttributes = [
//				NSAttributedStringKey.strikethroughStyle : UIColor(colorString:  "C7C7CD"),
				NSForegroundColorAttributeName : UIColor(colorString:  "C7C7CD"),
//				NSStrokeWidthAttributeName : -4.0,
				NSFontAttributeName : UIFont.boldSystemFont(ofSize: 16)
				] as [String : Any]
			let str = NSMutableAttributedString(string: x)
			str.addAttributes([NSStrikethroughStyleAttributeName : 1], range: NSMakeRange(0, x.count))
//			str.addAttributes(NSStrikethroughStyleAttributeName, range: NSMakeRange(0, x.count))
			cell.textLabel?.attributedText = str // NSMutableAttributedString(string: x, attributes: strokeTextAttributes)
//			cell.textLabel?.text = trackers[c]?[indexPath.row].name

		} else {
			cell.textLabel?.text = trackers[c]?[indexPath.row].name
		}
		cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
		cell.textLabel?.textColor = UIColor(colorString: "C7C7CD")
		cell.toggle.isOn = trackers[c]?[indexPath.row].isBlocked ?? false
        cell.appId = trackers[c]?[indexPath.row].appId ?? 0
        cell.delegate = self
		cell.statusIcon.image = (trackers[c]?[indexPath.row].isBlocked ?? false ? UIImage(named: "blockTracker") : UIImage(named: "trustTracker"))
//		print("AAAAAA - \(trackers[c]?[indexPath.row].category)")
		
        return cell
    }
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let cat = self.categories[section]
		let title =  AllCategories[cat]
		let header = UIView()
		let titleLbl = UILabel()
		titleLbl.text = title
		header.addSubview(titleLbl)
		let icon = UIImageView()
		header.addSubview(icon)
		icon.snp.makeConstraints { (make) in
			make.left.top.equalToSuperview().offset(10)
			make.width.height.equalTo(50)
		}
		icon.image = UIImage(named: cat ?? "")
		titleLbl.snp.makeConstraints { (make) in
			make.top.right.equalToSuperview().offset(10)
			make.left.equalTo(icon.snp.right).offset(10)
			make.height.equalTo(25)
		}
		titleLbl.font = UIFont.systemFont(ofSize: 16)
		let descLbl = UILabel()
		descLbl.text = "\(self.getTrackersCount(category: cat ?? "")) TRACKERS \(self.getBlockedCount(category: cat ?? "")) Blocked"
		descLbl.font = UIFont.systemFont(ofSize: 12)
		descLbl.textColor = UIColor.gray
		header.addSubview(descLbl)
		descLbl.snp.makeConstraints { (make) in
			make.right.equalToSuperview().offset(10)
			make.top.equalTo(titleLbl.snp.bottom).offset(0)
			make.left.equalTo(icon.snp.right).offset(10)
			make.height.equalTo(25)
		}


		return header
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let sep = UIView()
		sep.backgroundColor = UIColor.gray
		return sep
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		// by default antitracking should be off until user configures manually
		let restrictAction = UIContextualAction(style: .destructive, title: "Restrict") { (action, view, complHandler) in
			print("Restrict")
			let c = self.categories[indexPath.section]
			self.trackers[c]?[indexPath.row].isBlocked = true
			TrackerStore.shared.add(member: (self.trackers[c]?[indexPath.row].appId)!)
			UserPreferences.instance.blockingMode = .selected
			UserPreferences.instance.writeToDisk()

			tableView.beginUpdates()
			
			self.tableView.reloadRows(at: [indexPath], with: .none)
			tableView.endUpdates()
			complHandler(false)
		} //self.contextualDeleteAction(forRowAtIndexPath: indexPath)
		let blockAction = UIContextualAction(style: .destructive, title: "Block") { (action, view, complHandler) in
			print("Block")
			let c = self.categories[indexPath.section]
			self.trackers[c]?[indexPath.row].isBlocked = true
			TrackerStore.shared.add(member: (self.trackers[c]?[indexPath.row].appId)!)
			UserPreferences.instance.blockingMode = .selected
			UserPreferences.instance.writeToDisk()

			tableView.beginUpdates()
			
			self.tableView.reloadRows(at: [indexPath], with: .none)
			tableView.endUpdates()
			complHandler(false)
		}
		let trustAction = UIContextualAction(style: .normal, title: "Trust") { (action, view, complHandler) in
			print("Trust")
			let c = self.categories[indexPath.section]
			self.trackers[c]?[indexPath.row].isBlocked = false
			TrackerStore.shared.remove(member: (self.trackers[c]?[indexPath.row].appId)!)

			tableView.beginUpdates()
			
			self.tableView.reloadRows(at: [indexPath], with: .none)
			tableView.endUpdates()
			complHandler(false)
		}
		trustAction.backgroundColor = UIColor(colorString: "9ECC42")
		blockAction.backgroundColor = UIColor(colorString: "E74055")
		restrictAction.backgroundColor = UIColor(colorString: "BE4948")
		trustAction.image = UIImage(named: "trustAction")
		blockAction.image = UIImage(named: "blockAction")
		restrictAction.image = UIImage(named: "restrictAction")
		let swipeConfig = UISwipeActionsConfiguration(actions: [blockAction,  restrictAction, trustAction])
		return swipeConfig
	}

	private func getBlockedCount(category: String) -> Int {
		var count = 0
		if let t = self.trackers[category] {
			for i in t {
				if i.isBlocked {
					count += 1
				}
			}
		}
		return count
	}

	private func getTrackersCount(category: String) -> Int {
		var count = 0
		if let t = self.trackers[category] {
			count = t.count
		}
		return count
	}

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension TrackersController: CellDelegate {
    func toggled(appId: Int) {
        for category in categories {
			if let t = self.trackers[category] {
				for tracker in t {
					if tracker.appId == appId {
						tracker.isBlocked = !tracker.isBlocked
						break
					}
				}
			}
        }
        changes = true
    }
}

protocol CellDelegate {
    func toggled(appId: Int)
}

class CustomCell: UITableViewCell {
    let toggle = UISwitch()
    var appId: Int = 0
	let statusIcon = UIImageView()
    
    lazy var delegate: CellDelegate? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.contentView.addSubview(toggle)
//        toggle.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.trailing.equalToSuperview().inset(10)
//        }
		self.contentView.addSubview(statusIcon)
		statusIcon.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
		}
        toggle.isOn = false
        toggle.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc func valueChanged(toggle: UISwitch) {
        if toggle.isOn {
            TrackerStore.shared.add(member: self.appId)
            UserPreferences.instance.blockingMode = .selected
            UserPreferences.instance.writeToDisk()
        }
        else {
            TrackerStore.shared.remove(member: self.appId)
        }
        
        delegate?.toggled(appId: self.appId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

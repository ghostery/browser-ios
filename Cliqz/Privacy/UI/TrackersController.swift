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

let trackerViewDismissedNotification = Notification.Name(rawValue: "TrackerViewDismissed")

class TrackersController: UIViewController {
    
    let tableView = UITableView()
    let toolBar = UIToolbar()
    
    var changes = false
    
    private var _trackers: [TrackerListApp] = []
    var trackers: [TrackerListApp] {
        set {
            _trackers = newValue
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
        view.addSubview(toolBar)
        
        toolBar.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.toolBar.snp.top)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return trackers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! CustomCell
        
        // Configure the cell...
        cell.textLabel?.text = trackers[indexPath.row].name
        cell.toggle.isOn = trackers[indexPath.row].isBlocked
        cell.appId = trackers[indexPath.row].appId
        cell.delegate = self
        
        return cell
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
        for tracker in trackers {
            if tracker.appId == appId {
                tracker.isBlocked = !tracker.isBlocked
                break
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
    
    lazy var delegate: CellDelegate? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(toggle)
        toggle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
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

//
//  GlobalTrackersViewController.swift
//  Client
//
//  Created by Sahakyan on 4/17/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

class GlobalTrackersViewController: UIViewController {
	let tableView = UITableView()
	
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
		self.tableView.register(TrackerViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

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

}

extension GlobalTrackersViewController: UITableViewDataSource, UITableViewDelegate {
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TrackerViewCell
		
		// Configure the cell...
		cell.textLabel?.text = trackers[indexPath.row].name
		cell.appId = trackers[indexPath.row].appId
//		cell.delegate = self
		print("AAAAAA - \(trackers[indexPath.row].category)")
		
		return cell
	}

}

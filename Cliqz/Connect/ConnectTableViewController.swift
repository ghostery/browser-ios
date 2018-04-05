//
//  ConnectTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 4/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import RxSwift

class ConnectTableViewController: SubSettingsTableViewController {

    fileprivate var dataSource: ConnectDataSource!
    private var connections = [Connection]()
    private let disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = ConnectDataSource.instance
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionFailed), name: NotifyPairingErrorNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionSucceeded), name: NotifyPairingSuccessNotification, object: nil)
        
        self.dataSource.observable.asObserver().subscribe({ [weak self] value in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NotifyPairingErrorNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NotifyPairingSuccessNotification, object: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataSource.getConnections().count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && dataSource.getConnections().count == 0 {
            return 0.0
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        if indexPath.section == 0 {
            let connection = dataSource.getConnections()[indexPath.row]
            
            if connection.status == ConnectionStatus.Pairing {
                cell = getUITableViewCell("AnimatingDetailCellIdentifier" ,style: .value1)
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                cell.accessoryView = activityIndicator
                activityIndicator.startAnimating()
            } else {
                cell = getUITableViewCell("DetailCellIdentifier" ,style: .value1)
                cell.accessoryType = .detailButton
            }
            
            cell.textLabel?.text = connection.name
            cell.detailTextLabel?.text = connection.status.toString()
            cell.selectionStyle = .none
        } else {
            cell = getUITableViewCell()
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = NSLocalizedString("Add Connection", tableName: "Cliqz", comment: "[Settings -> Connect] Add Connection title")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 0 {
            let connection = dataSource.getConnections()[indexPath.row]
            let editConnectionViewController = EditConnectionViewController(dataSource, connection: connection)
            self.navigationController?.pushViewController(editConnectionViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 1 {
            let addConnectionViewController = AddConnectionViewController(dataSource)
            self.navigationController?.pushViewController(addConnectionViewController, animated: true)
        }
    }
    
    // MARK: - Herlper Methods
    @objc private func connectionFailed() {
        let alertTitle = NSLocalizedString("Connection Failed", tableName: "Cliqz", comment: "[Connect] Connection Failed alert title")
        let alertMessage = NSLocalizedString("Sorry but devices could not be connected. Please try again.", tableName: "Cliqz", comment: "[Connect] Connection Failed alert message")
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "Cancel"), style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Retry", tableName: "Cliqz", comment: "[Connect] Retry button for Connection Failed alert"), style: .default, handler: { [weak self] (_) in
            self?.dataSource.retryLastConnection()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func connectionSucceeded() {
        
        let successfulConnectionKey = "SuccessfulConnection"
        if LocalDataStore.objectForKey(successfulConnectionKey) == nil {
            showFirstSuccessfulConnectionAlert()
            LocalDataStore.setObject(true, forKey: successfulConnectionKey)
        }
    }
    
    private func showFirstSuccessfulConnectionAlert() {
        let alertTitle = NSLocalizedString("Connection successful", tableName: "Cliqz", comment: "[Connect] Connection successful alert title")
        let alertMessage = NSLocalizedString("You connected your first device!\n\nNow you are ready to send websites and YouTube videos from your computer to your mobile device.", tableName: "Cliqz", comment: "[Connect] Connection Successful alert message")
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", tableName: "Cliqz", comment: "Ok"), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

}

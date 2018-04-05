//
//  EditConnectionViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 4/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class EditConnectionViewController: SubSettingsTableViewController {

    fileprivate var dataSource: ConnectDataSource
    fileprivate var connection: Connection
    fileprivate let titles = [NSLocalizedString("Remove Connection", tableName: "Cliqz", comment: "[Settings -> Connect] remove connection"),
                              NSLocalizedString("Rename Connection", tableName: "Cliqz", comment: "[Settings -> Connect] rename connection")]
    
    init(_ dataSource: ConnectDataSource, connection: Connection) {
        self.dataSource = dataSource
        self.connection = connection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.connection.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getUITableViewCell()
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            removeConnection()
        } else {
            renameConnection()
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //MARK: - Private Helpers
    func removeConnection() {
        dataSource.removeConnection(connection)
        self.navigationController?.popViewController(animated: true)
    }
    
    func renameConnection() {
        let message = NSLocalizedString("Prompt description", tableName: "Cliqz", comment: "[Settings -> Connect] rename connection alert message")
        let alertController = UIAlertController(title: titles[1], message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: NSLocalizedString("Ok", tableName: "Cliqz", comment: "Ok"), style: .default) {[weak self] (_) in
            guard let charCount = alertController.textFields?.count, charCount > 0 else {
                return
            }
            let textField = alertController.textFields![0]
            if let newName = textField.text, !newName.isEmpty {
                self?.dataSource.renameConnection(self?.connection, newName: newName)
                self?.connection.name = newName
                self?.title = newName
            }
            
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "Cancel"), style: .cancel) { (_) in }
        alertController.addTextField {[weak self] (textField) in
            textField.text = self?.connection.name
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

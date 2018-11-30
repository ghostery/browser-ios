//
//  LumenAccountSettings.swift
//  Client
//
//  Created by Sahakyan on 11/29/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

class LumenAccountTableViewController: SubSettingsTableViewController {

	// MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = getUITableViewCell()
		
		// Popup:
//		Delete account?	Account löschen?
//		Delete Account (Text)	All running account information and running subscriptions will be lost and cannot be restored.	Alle Kontoinformationen und laufenden Abonnements gehen dabei verloren und können nicht wiederhergestellt werden.
//		Delete Account (CTA)	Delete	Löschen
//
//		Cancel
//
//		Confirm account deletion	Löschen des Kontos bestätigen
//		Delete Account Mail (Text)	We are sorry that you are leaving. Please check your inbox and open the confirmation link to complete account deletion.
//
		//"Open Mail App"
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = NSLocalizedString("Sign Out", tableName: "Cliqz", comment: "Sign Out Settings")
			break
		case 1:
			cell.textLabel?.text = NSLocalizedString("Delete Account", tableName: "Cliqz", comment: "Delete Account Settings")
		default:
			cell.textLabel?.text = ""
		}
		cell.selectionStyle = .none
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			signOut()
			break
		case 1:
			showAlertView()
			break
		default:
			break
		}
	}

	private func showAlertView() {
		let title = NSLocalizedString("Delete account?", tableName: "Cliqz", comment: "Sign Out Settings")
		let msg = NSLocalizedString("All running account information and running subscriptions will be lost and cannot be restored.", tableName: "Cliqz", comment: "Delete account popup")
		let deleteAlert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "[Settings] Cancel account deletion"), style: .cancel)
		deleteAlert.addAction(cancelAction)
		
		let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", tableName: "Cliqz", comment: "Delete action"), style: .default, handler: { [weak self] (alert: UIAlertAction) -> Void in
			self?.deleteAccount()
		})
		deleteAlert.addAction(deleteAction)
		self.present(deleteAlert, animated: true, completion: nil)
	}

	private func deleteAccount() {
		AuthenticationService.shared.deleteAccount { [weak self] (isDeleteSent, errorMsg) in
			if isDeleteSent {
				let next = ConfirmDeletionViewController()
				self?.navigationController?.pushViewController(next, animated: true)
			} else if let msg = errorMsg {
				self?.showErrorMsg(msg)
			}
		}
	}

	private func signOut() {
		AuthenticationService.shared.signOut { [weak self] (isSignedOut, errorMsg) in
			if isSignedOut {
				
			} else if let msg = errorMsg {
				self?.showErrorMsg(msg)
			}
		}
	}

	private func showErrorMsg(_ message: String) {
		
	}
}

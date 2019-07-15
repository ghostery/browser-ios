//
//  LumenSearchEnginePicker.swift
//  Client
//
//  Created by Pavel Kirakosyan on 15.07.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit
import Shared

class LumenSearchEnginePicker: SearchEnginePicker {

    var profile: Profile?
    var searchEnginesUpdated: (() -> Void)?

    // MARK: - Table view data source

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Default Search Engine", comment: "Title for default search engine picker.")
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // 1 engines, 2 create new
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }

        return 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }

        let cell = ThemedTableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = NSLocalizedString("Add Search Engine", comment: "Add search engine setting name")
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return super.tableView(tableView, didSelectRowAt: indexPath)
        }
        let customSearchEngineForm = CustomSearchViewController()
        customSearchEngineForm.profile = self.profile
        customSearchEngineForm.successCallback = { [weak self] in
            guard let window = self?.view.window else { return }
            SimpleToast().showAlertWithText(Strings.ThirdPartySearchEngineAdded, bottomContainer: window)
            self?.searchEnginesUpdated?()
        }
        navigationController?.pushViewController(customSearchEngineForm, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let engine = engines[indexPath.item]
            assert(engine.isCustomEngine, "trying to remove default search engine")
            if engine.isCustomEngine {
                self.profile?.searchEngines.deleteCustomEngine(engine)
                if let index = engines.index(of: engine) {
                    engines.remove(at: index)
                }
                tableView.deleteRows(at: [indexPath], with: .right)
            }
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            let engine = engines[indexPath.item]
            if engine.isCustomEngine && engine.shortName != selectedSearchEngineName {
                return .delete
            }
        }
        return .none
    }

}

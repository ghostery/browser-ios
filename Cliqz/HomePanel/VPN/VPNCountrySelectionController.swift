//
//  VPNCountrySelectionController.swift
//  VPNViews
//
//  Created by Tim Palade on 10/26/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//
#if PAID
import UIKit

// TODO: Send notification when VPNEndPointManager has loaded/updated VPN Countries
// TODO: Listen to said notification

protocol VPNCountrySelectionDelegate: class {
    func didSelectCountry(country: VPNCountry)
}

/// Allows the user to select from a list of VPNCountry instances, reports back to the `delegate`.
class VPNCountrySelectionController: UIViewController {

    // MARK: Delegation
    weak var delegate: VPNCountrySelectionDelegate? = nil

    // MARK: Properties
    private let tableView = UITableView()
    private let backgroundView = BrowserGradientView()
    private let countries = VPNEndPointManager.shared.getAvailableCountries()

    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VPNCountrySelectionCountryCell.self, forCellReuseIdentifier: VPNCountrySelectionCountryCell.reuseIdentifier)

        self.navigationItem.title = NSLocalizedString("Available VPN Locations", tableName: "Lumen", comment: "[VPN] vpn locations") 

        setupSubViews()
        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: View Setup
    private func setupSubViews() {
        view.addSubview(backgroundView)
        view.addSubview(tableView)

        // TODO: Remove snapkit because ugh
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        tableView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.topMargin.equalToSuperview().offset(10)
        }

    }
}

// MARK: - Table View Data Source
extension VPNCountrySelectionController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VPNCountrySelectionCountryCell.reuseIdentifier, for: indexPath) as! VPNCountrySelectionCountryCell
        let country = countries[indexPath.row]

        // TODO: This belongs in the cell class
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.text = country.name
        if country.disabled {
            cell.isUserInteractionEnabled = false
            cell.textLabel?.textColor = Lumen.VPN.countryDisabledTextColor(lumenTheme, .Normal)
        } else {
            cell.isUserInteractionEnabled = true
            cell.textLabel?.textColor = Lumen.VPN.countryTextColor(lumenTheme, .Normal)
        }
        
        //do the setup
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // TODO: This belongs in cellforrowatindexpath
        let country = countries[indexPath.row]
        if country == VPNEndPointManager.shared.selectedCountry {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
		headerView.backgroundColor = UIColor.lumenDeepBlue
        let headerLabel = UILabel()
        headerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        headerLabel.textColor = UIColor.lumenBrightBlue
        headerLabel.numberOfLines = 0
        headerLabel.text = NSLocalizedString("Choose your virtual location. Protection from hackers is on for any location while the VPN is active.", tableName: "Lumen", comment:"VPN locations selection header")
        
        headerView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }
        
        return headerView
    }
}

// MARK: - Table View Delegate
extension VPNCountrySelectionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country = countries[indexPath.row]
        self.delegate?.didSelectCountry(country: country)
        VPNEndPointManager.shared.selectedCountry = country
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
}

// MARK: - Table View Cell
extension VPNCountrySelectionController {
    private class VPNCountrySelectionCountryCell: UITableViewCell {
        static let reuseIdentifier = "VPNCountrySelectionCountryCell"
        let tickView = UIImageView()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(tickView)

            tickView.image = UIImage(named: "checkmark")
            tickView.isHidden = true

            tickView.snp.makeConstraints { (make) in
                make.width.equalTo(19.5)
                make.height.equalTo(15)
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-10)
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            if selected == true {
                tickView.isHidden = false
            }
            else {
                tickView.isHidden = true
            }

            super.setSelected(selected, animated: animated)
        }
    }
}

// MARK: - Themable
extension VPNCountrySelectionController: Themeable {
    func applyTheme() {
        self.navigationController?.navigationBar.tintColor = Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)
        self.navigationController?.navigationBar.barTintColor = Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)]
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = Lumen.VPN.separatorColor(lumenTheme, .Normal)

        self.tableView.reloadData()
    }

}
#endif

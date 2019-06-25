//
//  VPNCountrySelectionController.swift
//  VPNViews
//
//  Created by Tim Palade on 10/26/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//
#if PAID
import UIKit

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
    private var countries = VPNEndPointManager.shared.getAvailableCountries()

    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = UIColor.white
        tableView.register(VPNCountrySelectionCountryCell.self, forCellReuseIdentifier: VPNCountrySelectionCountryCell.reuseIdentifier)

        self.navigationItem.title = NSLocalizedString("Available VPN Locations", tableName: "Lumen", comment: "[VPN] vpn locations")

        NotificationCenter.default.addObserver(self, selector: #selector(receiveUpdatedData),
                                               name: VPNEndPointManager.countriesUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedError(_:)),
                                               name: VPNEndPointManager.countriesUpdateErrorNotification, object: nil)

        tableView.refreshControl?.addTarget(self, action: #selector(beginUpdatingData), for: UIControl.Event.valueChanged)

        setupSubViews()
        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        // Update the VPN Credentials each time we show this view
        VPNEndPointManager.shared.updateVPNCredentials()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLoadingIndicator()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func beginUpdatingData() {
        countries = []
        tableView.reloadData()
        VPNEndPointManager.shared.updateVPNCredentials()
        updateLoadingIndicator()
    }

    @objc private func receiveUpdatedData() {
        countries = VPNEndPointManager.shared.getAvailableCountries()
        tableView.reloadData()
        updateLoadingIndicator()
    }

    @objc private func receivedError(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Error], let error = userInfo["error"] {
            print(error)
        }

        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString(
                "Sorry, there was a problem updating the country list.",
                comment: "Shown in the VPN Country selection when the list of countries cannot be loaded."
            ),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: "Default action"), style: .default, handler: { _ in
            self.beginUpdatingData()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: { _ in

        }))

        self.present(alert, animated: true, completion: nil)
    }

    private func updateLoadingIndicator() {
        // Only show the loading indicator if no data is available in the app
        let newContentOffset = countries.count == 0 ?
            CGPoint(x: 0, y: -(self.tableView.refreshControl?.frame.size.height ?? 0)-15) : CGPoint(x: 0, y: 0)

        UIView.animate(withDuration: 0.25) {
            self.tableView.contentOffset = newContentOffset
        }

        if countries.count == 0 {
            self.tableView.refreshControl?.beginRefreshing()
        } else {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - View Setup
extension VPNCountrySelectionController {
    private func setupSubViews() {
        view.addSubview(backgroundView)
        view.addSubview(tableView)

        self.tableView.refreshControl?.tintColor = UIColor.white

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
        let cell = tableView.dequeueReusableCell(withIdentifier: VPNCountrySelectionCountryCell.reuseIdentifier,
                                                 for: indexPath) as! VPNCountrySelectionCountryCell
        let country = countries[indexPath.row]
        cell.country = country

        if country == VPNEndPointManager.shared.selectedCountry {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderInfoView()
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

// MARK: - Sub Views
extension VPNCountrySelectionController {
    private class VPNCountrySelectionCountryCell: UITableViewCell {
        // MARK: Properties
        static let reuseIdentifier = "VPNCountrySelectionCountryCell"
        var country: VPNCountry? { didSet { update() } }
        private let tickView = UIImageView()

        // MARK: Lifecycle
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: reuseIdentifier)
            setupSubViews()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupSubViews()
        }

        // MARK: View Setup
        private func setupSubViews() {
            selectionStyle = .none
            backgroundColor = .clear

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

        // MARK: Updating
        func update() {
            guard let country = country else { return }
            textLabel?.text = country.name

            if country.disabled {
                isUserInteractionEnabled = false
                textLabel?.textColor = Lumen.VPN.countryDisabledTextColor(lumenTheme, .Normal)
            } else {
                isUserInteractionEnabled = true
                textLabel?.textColor = Lumen.VPN.countryTextColor(lumenTheme, .Normal)
            }
        }

        // MARK: Selection
        override func setSelected(_ selected: Bool, animated: Bool) {
            tickView.isHidden = !selected
            super.setSelected(selected, animated: animated)
        }
    }

    private class HeaderInfoView: UIView {
        // MARK: Life Cycle
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupSubViews()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupSubViews()
        }

        // MARK: Setup
        private func setupSubViews() {
            backgroundColor = UIColor.lumenDeepBlue
            let headerLabel = UILabel()
            headerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            headerLabel.textColor = UIColor.lumenBrightBlue
            headerLabel.numberOfLines = 0
            headerLabel.text = NSLocalizedString(
                "Choose your virtual location. Protection from hackers is on for any location while the VPN is active.",
                tableName: "Lumen", comment:"VPN locations selection header")

            addSubview(headerLabel)
            headerLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(15)
                make.top.bottom.equalToSuperview()
            }
        }
    }
}

// MARK: - Themable
extension VPNCountrySelectionController: Themeable {
    func applyTheme() {
        navigationController?.navigationBar.tintColor = Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)
        navigationController?.navigationBar.barTintColor = Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)]
        tableView.backgroundColor = .clear
        tableView.separatorColor = Lumen.VPN.separatorColor(lumenTheme, .Normal)

        tableView.reloadData()
    }
}
#endif

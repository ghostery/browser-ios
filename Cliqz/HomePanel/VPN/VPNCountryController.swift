//
//  VPNCountryController.swift
//  VPNViews
//
//  Created by Tim Palade on 10/26/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//
#if PAID
import UIKit

protocol VPNCountryControllerProtocol: class {
    func didSelectCountry(shouldReconnect: Bool)
}

class VPNCountryController: UIViewController {
    
    weak var delegate: VPNCountryControllerProtocol? = nil
    
    let tableView = UITableView()
    let gradient = BrowserGradientView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomVPNCountryCell.self, forCellReuseIdentifier: "CountryCell")
        
        view.addSubview(gradient)
        view.addSubview(tableView)
        
        gradient.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.topMargin.equalToSuperview().offset(10)
        }
        
        self.navigationItem.title = NSLocalizedString("Available VPN Locations", tableName: "Lumen", comment: "[VPN] vpn locations") 
        
        setStyling()
    }
    
    func setStyling() {
//        //this fixes the animation for the light theme
//        if lumenTheme == .Light {
//            self.view.backgroundColor = .white
//        }
//        else {
//            self.view.backgroundColor = .clear
//        }
        self.navigationController?.navigationBar.tintColor = Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)
        self.navigationController?.navigationBar.barTintColor = Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : Lumen.VPN.navigationBarTextColor(lumenTheme, .Normal)]
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = Lumen.VPN.separatorColor(lumenTheme, .Normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension VPNCountryController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VPNEndPointManager.shared.countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CustomVPNCountryCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.text = VPNEndPointManager.shared.countries[indexPath.row].name;
        cell.textLabel?.textColor = Lumen.VPN.countryTextColor(lumenTheme, .Normal)
        
        //do the setup
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let country = VPNEndPointManager.shared.countries[indexPath.row]
        if country == VPNEndPointManager.shared.selectedCountry {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
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

extension VPNCountryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country = VPNEndPointManager.shared.countries[indexPath.row]
        self.delegate?.didSelectCountry(shouldReconnect: country != VPNEndPointManager.shared.selectedCountry)
        VPNEndPointManager.shared.selectedCountry = country
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
}

class CustomVPNCountryCell: UITableViewCell {
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

extension VPNCountryController: Themeable {
    func applyTheme() {
        setStyling()
        self.tableView.reloadData()
    }
    
}
#endif

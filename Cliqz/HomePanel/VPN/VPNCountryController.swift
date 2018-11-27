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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomVPNCountryCell.self, forCellReuseIdentifier: "CountryCell")
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.topMargin.equalToSuperview().offset(10)
        }
        
        self.navigationItem.title = NSLocalizedString("Available VPN Locations", tableName: "Lumen", comment: "[VPN] vpn locations") 
        
        setStyling()
    }
    
    func setStyling() {
        self.view.backgroundColor = VPNUX.bgColor
        self.navigationController?.navigationBar.barTintColor = VPNUX.bgColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .black
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
        cell.textLabel?.textColor = .white
        
        //do the setup
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let country = VPNEndPointManager.shared.countries[indexPath.row]
        if country == VPNEndPointManager.shared.selectedCountry {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
}

extension VPNCountryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country = VPNEndPointManager.shared.countries[indexPath.row]
        self.delegate?.didSelectCountry(shouldReconnect: country != VPNEndPointManager.shared.selectedCountry)
        VPNEndPointManager.shared.selectedCountry = country
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigationController?.popViewController(animated: true)
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
#endif

//
//  PaidControlCenterViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 10/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

//TODO: 3 connections

//Tabs and different information
//Start button and protection label text
//VPNButton and VPN view

class PaidControlCenterViewController: ControlCenterViewController {
    
    let controls = CCControlsView()
    let tabs = UISegmentedControl(items: ["Today", "Last 7 Days"])
    let protectionLabel = UILabel()
    
    let dashboard = CCCollectionViewController()
    let cellDataSource = CCDataSource()
    
    let protectionOn = "ULTIMATE PROTECTION: ON"
    let protectionOff = "ULTIMATE PROTECTION: OFF"
    
    let protectionOnColor = CCUX.CliqzBlueGlow
    let protectionOffColor = UIColor.white
    
    override func setupComponents() {
        
        dashboard.dataSource = self
        
        self.addChildViewController(dashboard)
        self.view.addSubview(controls)
        self.view.addSubview(tabs)
        self.view.addSubview(protectionLabel)
        self.view.addSubview(dashboard.view)
        
        protectionLabel.text = protectionOn
        protectionLabel.textColor = protectionOnColor
        protectionLabel.textAlignment = .center
        protectionLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        tabs.selectedSegmentIndex = 0
        tabs.addTarget(self, action: #selector(tabChanged), for: .valueChanged)
        
        controls.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(100)
        }
        
        tabs.snp.makeConstraints { (make) in
            make.top.equalTo(controls.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
        }
        
        protectionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tabs.snp.bottom).offset(12)
            make.trailing.leading.equalToSuperview()
        }
        
        dashboard.view.snp.makeConstraints { (make) in
            make.top.equalTo(protectionLabel.snp.bottom).offset(10)
            make.trailing.leading.bottom.equalToSuperview()
        }
        
        self.view.backgroundColor = .black
    }
    
    @objc func tabChanged(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            CCWidgetManager.shared.update(period: .Today)
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            CCWidgetManager.shared.update(period: .Last7Days)
        }
    }

}

extension PaidControlCenterViewController: CCCollectionDataSourceProtocol {
    func numberOfRows() -> Int {
        return cellDataSource.numberOfCells() - 1
    }
    
    func heightFor(index: Int) -> CGFloat {
        if index == 0 {
            return cellDataSource.heightFor(index: 0)
        }
        return cellDataSource.heightFor(index: index + 1)
    }
    
    func cellFor(index: Int) -> UIView {
        if index == 0 {
            let v = UIStackView()
            
            v.axis = .horizontal
            //v.spacing = 10
            v.distribution = .equalSpacing
            
            let c1 = CCVerticalCell(widgetRatio: CCUX.VerticalContentWidgetRatio, descriptionRatio: 1 - CCUX.VerticalContentWidgetRatio)
            let c2 = CCVerticalCell(widgetRatio: CCUX.VerticalContentWidgetRatio, descriptionRatio: 1 - CCUX.VerticalContentWidgetRatio)
            
            v.addArrangedSubview(c1)
            v.addArrangedSubview(c2)
            
            c1.snp.makeConstraints { (make) in
                make.width.equalToSuperview().dividedBy(2).offset(-5)
                make.height.equalToSuperview()
            }
            
            c2.snp.makeConstraints { (make) in
                make.width.equalToSuperview().dividedBy(2).offset(-5)
                make.height.equalToSuperview()
            }
            
            cellDataSource.configureCell(cell: c1, index: 0)
            cellDataSource.configureCell(cell: c2, index: 1)
            
            return v
        }
        
        let cell = CCHorizontalCell(widgetRatio: CCUX.HorizontalContentWigetRatio,
                                    descriptionRatio: 1 - CCUX.HorizontalContentWigetRatio,
                                    optionalView: cellDataSource.optionalView(index: index + 1),
                                    optionalViewHeight: cellDataSource.optionalViewHeight(index: index + 1))
        
        cellDataSource.configureCell(cell: cell, index: index + 1)
        
        return cell
    }
    
    func cellSpacing() -> CGFloat {
        return 22.0
    }
    
    func horizontalPadding() -> CGFloat {
        return 20
    }
}

protocol CCControlViewProtocol: class {
    func vpnButtonPressed()
    func startButtonPressed()
    func clearButtonPressed()
}

class CCControlsView: UIView {
    
    let vpnButton = UIButton()
    let startButton = UIButton()
    let clearButton = UIButton()
    let stackView = UIStackView()
    
    let startLabel = UILabel()
    let clearLabel = UILabel()
    let vpnLabel = UILabel()
    
    let startContainer = UIView()
    let clearContainer = UIView()
    let vpnContainer = UIView()
    
    func startLabelTitle(isSelected: Bool) -> String {
        if isSelected == false {
            return "Pause"
        }
        else {
            return "Start"
        }
    }
    
    weak var delegate: CCControlViewProtocol? = nil
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addSubview(stackView)
        
        stackView.addArrangedSubview(startContainer)
        stackView.addArrangedSubview(vpnContainer)
        stackView.addArrangedSubview(clearContainer)
        
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        setUpContainer(container: startContainer, button: startButton, label: startLabel)
        setUpContainer(container: vpnContainer, button: vpnButton, label: vpnLabel)
        setUpContainer(container: clearContainer, button: clearButton, label: clearLabel)
        
        startLabel.text = startLabelTitle(isSelected: false)
        vpnLabel.text = "VPN"
        clearLabel.text = "Clear"
        
        startLabel.textColor = CCUX.CliqzBlueGlow
        vpnLabel.textColor = CCUX.CliqzBlueGlow
        clearLabel.textColor = CCUX.CliqzBlueGlow
        
        startLabel.textAlignment = .center
        vpnLabel.textAlignment = .center
        clearLabel.textAlignment = .center
        
        startButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: UILayoutConstraintAxis(rawValue: 1000)!)
        
        vpnButton.setImage(UIImage(named:"CCVPNOff"), for: .normal)
        vpnButton.setImage(UIImage(named: "CCVPNOn"), for: .selected)
        
        startButton.setImage(UIImage(named: "CCPause"), for: .normal)
        startButton.setImage(UIImage(named: "CCStart"), for: .selected)
        
        clearButton.setImage(UIImage(named: "CCClear"), for: .normal)
        
        vpnButton.addTarget(self, action: #selector(vpnPressed), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
    }
    
    func setUpContainer(container: UIView, button: UIButton, label: UILabel) {
        container.addSubview(button)
        container.addSubview(label)
        
        button.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
            make.centerX.equalToSuperview()
        }
        
        label.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        container.snp.makeConstraints { (make) in
            make.width.equalTo(button.snp.width)
        }
    }
    
    @objc func vpnPressed(_ button: UIButton) {
        button.isSelected = !button.isSelected
        delegate?.vpnButtonPressed()
    }
    
    @objc func startPressed(_ button: UIButton) {
        button.isSelected = !button.isSelected
        startLabel.text = startLabelTitle(isSelected: button.isSelected)
        delegate?.startButtonPressed()
    }
    
    @objc func clearPressed(_ button: UIButton) {
        button.isSelected = !button.isSelected
        delegate?.clearButtonPressed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ExpandableView.swift
//  DashboardComponent
//
//  Created by Tim Palade on 8/10/17.
//  Copyright © 2017 Tim Palade. All rights reserved.
//

import UIKit

protocol ExpandableViewProtocol {
    func maxNumCells() -> Int
    func minNumCells() -> Int
    func title(indexPath: IndexPath) -> String
    func url(indexPath: IndexPath) -> String
	func picture(indexPath: IndexPath, completionBlock: @escaping (_ result:UIImage?, _ customView: UIView?) -> Void)
    func cellPressed(indexPath: IndexPath)
}

final class ExpandableView: UITableView {
    
    enum State {
        case collapsed
        case expanded
    }
    
    //for external use
    var height: CGFloat {
        return height(state: currentState)
    }
    
    var currentState: State = .collapsed
    var previousState: State = .collapsed
    
    let header = ExpandableViewHeader()
    
    private var _headerTitleText: String = ""
    
    var minNumCells = 0
    
    var headerTitleText: String {
        set {
            _headerTitleText = newValue
            header.l.text = newValue
        }
        
        get {
            return _headerTitleText
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setUpComponent()
        setStyling()
        setConstraints()
    }
    
    func setUpComponent() {
        self.isScrollEnabled = false
        
        header.delegate = self
        header.btn.setTitle(buttonTitle(state: currentState), for: .normal)
        
        header.l.text = headerTitleText
    }
    
    func setStyling() {
        self.layer.cornerRadius = 10.0
    }
    
    func setConstraints() {
        
    }
    
    func changeState(state: State) {
        guard state != currentState else {
            return
        }
        
        currentState = state
        previousState = currentState
        
        updateUI()
    }
    
    func commuteState() {
        
        if currentState == .collapsed {
            changeState(state: .expanded)
        }
        else {
            changeState(state: .collapsed)
        }
    }
    
    func numCells(state: State) -> Int {
        
        if state == .collapsed {
            return min(minNumCells, self.numberOfRows(inSection: 0))
        }
        else if state == .expanded {
            return self.numberOfRows(inSection: 0)
        }
        
        return 0
    }
    
    func initialHeight() -> CGFloat {
        return height(state: .collapsed)
    }
    
    func height(state: State) -> CGFloat {
        return CGFloat(numCells(state: state)) * self.rowHeight + (self.headerView(forSection: 0)?.bounds.height ?? 0)
    }
    
    func buttonTitle(state: State) -> String {
        if state == .collapsed {
            return NSLocalizedString("More", tableName: "Cliqz", comment: "Text for more button")
        }
        
        return NSLocalizedString("Less", tableName: "Cliqz", comment: "Text for less button")
    }
    
    func updateUI() {
        
        header.btn.setTitle(buttonTitle(state: currentState), for: .normal)
        header.btn.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            self.header.btn.alpha = 1.0
        }
        
        if previousState != currentState {
            let minCells = min(minNumCells, self.numberOfRows(inSection: 0))
            let maxCells = self.numberOfRows(inSection: 0)
            
            var rows: [IndexPath] = []
            
            for i in minCells..<maxCells {
                let indexPath = IndexPath(row: i, section: 0)
                rows.append(indexPath)
            }
            
            self.beginUpdates()
            currentState == .expanded ? self.insertRows(at: rows, with: .none) : self.deleteRows(at: rows, with: .none)
            self.endUpdates()
        }
        
        self.snp.updateConstraints { (make) in
            make.height.equalTo(self.height)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutSubviews()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExpandableView: ExpandableViewHeaderDelegate {
    func showMorePressed() {
        commuteState()
    }
}

protocol ExpandableViewHeaderDelegate {
    func showMorePressed()
}

final class ExpandableViewHeader: UIView {
    
    let l = UILabel()
    let btn = UIButton()
    
    var delegate: ExpandableViewHeaderDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(l)
        self.addSubview(btn)
        
        setUpComponents()
        setStyling()
        setConstraints()
    }
    
    private func setUpComponents() {
        btn.addTarget(self, action: #selector(showMorePressed), for: .touchUpInside)
    }
    
    private func setStyling() {
        
        self.backgroundColor = UIColor.black
        
        l.textColor = UIColor.white
        l.font = UIFont.systemFont(ofSize: 13)
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.titleLabel?.textAlignment = .right
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.contentHorizontalAlignment = .right
    }
    
    private func setConstraints() {
        l.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        
        btn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().inset(6)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func showMorePressed(_ sender: UIButton) {
        self.delegate?.showMorePressed()
    }
    
}


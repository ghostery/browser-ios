//
//  CCViewController.swift
//  Cockpit
//
//  Created by Tim Palade on 10/22/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit

protocol CCCollectionDataSourceProtocol: class {
    func numberOfRows() -> Int
    func heightFor(index: Int) -> CGFloat
    func cellFor(index: Int) -> UIView
    func cellSpacing() -> CGFloat
    func horizontalPadding() -> CGFloat
}

struct CCUX {
    static let HorizontalContentWigetRatio: CGFloat = 272 / 777
    static let VerticalContentWidgetRatio: CGFloat = 378 / 583
    static let CliqzBlueGlow: UIColor = UIColor.init(colorString: "07E6FE")
}

class CCCollectionViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    weak var dataSource: CCCollectionDataSourceProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        stackView.axis = .vertical
        stackView.spacing = self.dataSource?.cellSpacing() ?? 0.0
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.backgroundColor = UIColor.clear
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        
        self.addCells()
    }
    
    func addCells() {
        if let rows = dataSource?.numberOfRows() {
            for i in 0..<rows {
                guard let cell = dataSource?.cellFor(index: i) else { fatalError("cell for index \(i) is nil") }
                stackView.addArrangedSubview(cell)
                
                var cellHeight: CGFloat = 100
                if let height = dataSource?.heightFor(index: i) {
                    cellHeight = height
                }
                
                var horizontalPadding: CGFloat = 0
                if let hpadding = dataSource?.horizontalPadding() {
                    horizontalPadding = hpadding
                }
                
                cell.snp.makeConstraints { [unowned self] (make) in
                    make.height.equalTo(cellHeight)
                    make.width.equalTo(self.scrollView.snp.width).offset(-2*horizontalPadding)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

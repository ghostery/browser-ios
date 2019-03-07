//
//  CCViewController.swift
//  Cockpit
//
//  Created by Tim Palade on 10/22/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//
#if PAID
import UIKit

protocol CCCollectionDataSourceProtocol: class {
    func numberOfRows() -> Int
    func heightFor(index: Int) -> CGFloat
    func cellFor(index: Int) -> UIView
    func cellSpacing() -> CGFloat
    func horizontalPadding() -> CGFloat
}

struct CCUX {
    static let HorizontalContentWigetRatio: CGFloat = 300 / 777
    static let VerticalContentWidgetRatio: CGFloat = 130 / 175
    static let CliqzBlueGlow: UIColor = UIColor.init(colorString: "07E6FE")
}

class CCCollectionViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
	let resetStatsButtons = UIButton(type: .custom)

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
		
		resetStatsButtons.setTitle(NSLocalizedString("Reset statistics", tableName: "Lumen", comment: "[Lumen->Dashboard] Reset statistics button title"), for: .normal)
		resetStatsButtons.setTitleColor(Lumen.Dashboard.darkBlueTitleColor(lumenTheme, lumenDashboardMode), for: .normal)
		resetStatsButtons.titleLabel?.textAlignment = .center
		resetStatsButtons.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		scrollView.addSubview(resetStatsButtons)
		resetStatsButtons.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)

		resetStatsButtons.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.width.equalTo(self.scrollView.snp.width)
			make.height.equalTo(62)
		}

        stackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(20)
			make.bottom.equalToSuperview().inset(70)
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
    
    func update() {
        if let rows = dataSource?.numberOfRows() {
            for i in 0..<rows {
                if let cell = dataSource?.cellFor(index: i) as? UpdateViewProtocol {
                    cell.update()
                }
            }
        }
		resetStatsButtons.setTitleColor(Lumen.Dashboard.darkBlueTitleColor(lumenTheme, lumenDashboardMode), for: .normal)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@objc func clearPressed(_ button: UIButton) {
		func clearDashboardData(_ action: UIAlertAction) {
            LegacyTelemetryHelper.logDashboard(action: "click", target: "reset")
			DispatchQueue.global(qos: .utility).async { [weak self] in
				//print("Will send data for tab = \(tabID) and page = \(String(describing: currentP))")
				Engine.sharedInstance.getBridge().callAction(JSBridge.Action.cleanData.rawValue, args: [], callback: { (result) in
					if let error = result["error"] as? [[String: Any]] {
						debugPrint("Error calling action insights:clearData: \(error)")
						//TODO: What should I do in this case?
					}
					else {
						CCWidgetManager.shared.updateAppearance(dashboard: self)
					}
				})
			}
		}
		
		let alertText = NSLocalizedString("This will delete all your dashboard data and cannot be undone.", tableName: "Lumen", comment: "Lumen Clear Dashboard Data Popup Text")
		let actionTitle = NSLocalizedString("Clear", tableName: "Lumen", comment: "Lumen Clear Dashboard Data Popup Clear Button Text")
		let alert = UIAlertController.alertWithCancelAndAction(text: alertText, actionButtonTitle: actionTitle, isActionDestructive: true,actionCallback: clearDashboardData)
		if let appDel = UIApplication.shared.delegate as? AppDelegate {
			appDel.presentContollerOnTop(controller: alert)
		}
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
#endif

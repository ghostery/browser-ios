//
//  CliqzHomePanelViewController.swift
//  Client
//
//  Created by Tim Palade on 5/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Shared
import SnapKit
import UIKit
import Storage

class CliqzHomePanelViewController: UIViewController, UITextFieldDelegate {
    
    var profile: Profile!
    var notificationToken: NSObjectProtocol!
    var panels: [HomePanelDescriptor]!
    var url: URL?
    weak var delegate: HomePanelViewControllerDelegate?
    
    var selectedPanel: HomePanelType? = nil {
        didSet {
            if oldValue == selectedPanel {
                // Prevent flicker, allocations, and disk access: avoid duplicate view controllers.
                return
            }
            
            hideCurrentPanel()
            
            if let index = selectedPanel?.rawValue {
                
                segmentedControl.selectedSegmentIndex = index
                
                if index < panels.count {
                    let panel = self.panels[index].makeViewController(profile)
                    let accessibilityLabel = self.panels[index].accessibilityLabel
                    if let panelController = panel as? UINavigationController,
                        let rootPanel = panelController.viewControllers.first {
                        setupHomePanel(rootPanel, accessibilityLabel: accessibilityLabel)
                        self.showPanel(panelController)
                    } else {
                        setupHomePanel(panel, accessibilityLabel: accessibilityLabel)
                        self.showPanel(panel)
                    }
                }
            }
        }
    }
    
    fileprivate let backgroundView = UIImageView()
    fileprivate let segmentedControl: UISegmentedControl
    fileprivate let controllerContainerView: UIView = UIView()
    
    enum IndexType {
        case blurred
        case notBlurred
        case notSet
    }
    
    fileprivate var currentIndexType: IndexType = .notSet
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        self.panels = CliqzHomePanels().enabledPanels
        
        let imageNames = ["panelIconTopSites", "panelIconFavorite", "panelIconCliqzHistory", "panelIconOffrz"]
        let images = imageNames.map { (name) -> UIImage in return UIImage.templateImageNamed(name)! }
        segmentedControl =  UISegmentedControl(items: images)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        //Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundView)

        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        view.addSubview(controllerContainerView)
        
        setStyling()
        setInitialConstraints()
        setBackgroundImage()
    }
    
    func setStyling() {
        segmentedControl.tintColor = .white
        controllerContainerView.backgroundColor = .clear
    }
    
    func setInitialConstraints() {
        
        backgroundView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
        }
        
        controllerContainerView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(self.segmentedControl.snp.bottom).offset(10)
        }
    }
    
    func setBackgroundImage() {
        
        func index2type(_ index: Int) -> IndexType {
            return index < 1 ? .notBlurred : .blurred
        }

        let indexType = index2type(segmentedControl.selectedSegmentIndex)

        guard currentIndexType != indexType else { return }
        currentIndexType = indexType
        
        if segmentedControl.selectedSegmentIndex < 1 {
            backgroundView.image = UIImage.cliqzBackgroundImage()
        }
        else {
            backgroundView.image = UIImage.cliqzBackgroundImage(blurred: true)
        }
    }
    
    func dismissKeyboard(_ sender: Any? = nil) {
        view.window?.rootViewController?.view.endEditing(true)
    }
}

extension CliqzHomePanelViewController {
    
    @objc func segmentedControlValueChanged(control: UISegmentedControl) {
        self.dismissKeyboard()
        setBackgroundImage()
        selectedPanel = HomePanelType(rawValue: control.selectedSegmentIndex) //control.selectedSegmentIndex must be between 0 and 3
    }
    
    fileprivate func hideCurrentPanel() {
        if let panel = childViewControllers.first {
            panel.willMove(toParentViewController: nil)
            panel.beginAppearanceTransition(false, animated: false)
            panel.view.removeFromSuperview()
            panel.endAppearanceTransition()
            panel.removeFromParentViewController()
        }
    }
    
    fileprivate func showPanel(_ panel: UIViewController) {
        addChildViewController(panel)
        panel.beginAppearanceTransition(true, animated: false)
        controllerContainerView.addSubview(panel.view)
        panel.endAppearanceTransition()
        panel.view.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        panel.didMove(toParentViewController: self)
    }
    
    func setupHomePanel(_ panel: UIViewController, accessibilityLabel: String) {
        (panel as? HomePanel)?.homePanelDelegate = self
        panel.view.accessibilityNavigationStyle = .combined
        panel.view.accessibilityLabel = accessibilityLabel
    }
}

extension CliqzHomePanelViewController {
    
    @objc func orientationDidChange(_ notification: Notification) {
        setBackgroundImage()
    }
}

extension CliqzHomePanelViewController: HomePanelDelegate {
    
    func homePanelDidRequestToSignIn(_ homePanel: HomePanel) {
        //not supported
    }
    
    func homePanelDidRequestToCreateAccount(_ homePanel: HomePanel) {
        //not supported
    }
    
    func homePanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool) {
        delegate?.homePanelViewControllerDidRequestToOpenInNewTab(url, isPrivate: isPrivate)
    }
    
    func homePanel(_ homePanel: HomePanel, didSelectURL url: URL, visitType: VisitType) {
        // HomePanelViewController does not override init. So initializing it is light.
        // Also, it is not used in the delegate, so passing the "right" value is not important
        delegate?.homePanelViewController(HomePanelViewController(), didSelectURL: url, visitType: visitType)
        dismiss(animated: true, completion: nil)
    }
    
    func homePanel(_ homePanel: HomePanel, didSelectURLString url: String, visitType: VisitType) {
        // If we can't get a real URL out of what should be a URL, we let the user's
        // default search engine give it a shot.
        // Typically we'll be in this state if the user has tapped a bookmarked search template
        // (e.g., "http://foo.com/bar/?query=%s"), and this will get them the same behavior as if
        // they'd copied and pasted into the URL bar.
        // See BrowserViewController.urlBar:didSubmitText:.
        guard let url = URIFixup.getURL(url) ?? profile.searchEngines.defaultEngine.searchURLForQuery(url) else {
            Logger.browserLogger.warning("Invalid URL, and couldn't generate a search URL for it.")
            return
        }
        
        return self.homePanel(homePanel, didSelectURL: url, visitType: visitType)
    }
}

// MARK: UIAppearance
extension CliqzHomePanelViewController: Themeable {
    func applyTheme(_ theme: Theme) {
        return
    }
}

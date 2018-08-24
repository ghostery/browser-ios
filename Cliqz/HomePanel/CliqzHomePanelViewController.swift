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
import RxSwift

class CliqzHomePanelViewController: UIViewController, UITextFieldDelegate {
    
    var profile: Profile!
    var notificationToken: NSObjectProtocol!
    var panels: [HomePanelDescriptor]!
    var url: URL?
	var shouldShowKeyboard = true
    var isPrivate = false {
        didSet {
            self.overlayView?.isHidden = !isPrivate
        }
    }

    weak var delegate: HomePanelViewControllerDelegate?
    private let disposeBag = DisposeBag()
    private let offrzNotificationImage = UIImageView(image: UIImage.circle(diameter: 7.5, color: UIColor.init(colorString: "A10099")))
    
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
    fileprivate var overlayView: UIView!
    fileprivate let segmentedControl: UISegmentedControl
    fileprivate let controllerContainerView: UIView = UIView()
    
    enum IndexType {
        case blurred
        case notBlurred
        case notSet
    }
    
    fileprivate var currentIndexType: IndexType = .notSet
    fileprivate var currentOrientation: DeviceOrientation? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        self.panels = CliqzHomePanels().enabledPanels
        
        let imageNames = ["panelIconFreshtab", "panelIconCliqzHistory", "panelIconOffrz", "panelIconFavorite"]
        let images = imageNames.map { (name) -> UIImage in return UIImage.templateImageNamed(name)! }
        segmentedControl =  UISegmentedControl(items: images)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        //Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: Notification.Name.DeviceOrientationChanged, object: nil)
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
        overlayView = UIView.overlay(frame: UIScreen.main.bounds)
        overlayView.isHidden = !isPrivate
        view.addSubview(overlayView)

        segmentedControl.addSubview(offrzNotificationImage)
        offrzNotificationImage.isHidden = true
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        view.addSubview(controllerContainerView)
		
        setStyling()
        setInitialConstraints()
        setBackgroundImage()
        updateOffrzIcon()
    }
    
    func setStyling() {
        segmentedControl.tintColor = .white
        controllerContainerView.backgroundColor = .clear
    }
    
    func setInitialConstraints() {
        
        backgroundView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        overlayView.snp.makeConstraints { (make) in
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
        let orientation = UIDevice.current.getDeviceAndOrientation().1

        guard currentIndexType != indexType || currentOrientation != orientation else { return }
        currentIndexType = indexType
        currentOrientation = orientation
        
        if segmentedControl.selectedSegmentIndex < 1 {
            backgroundView.image = BackgroundImageManager.shared.getImage()
        }
        else {
            backgroundView.image = BackgroundImageManager.shared.getBlurredImage()
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
        self.updateOffrzIcon()
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
        adjustOffrzNotificationImageConstraints()
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


//MARK: - Offrz notification image
extension CliqzHomePanelViewController {
    fileprivate func updateOffrzIcon() {
        OffrzDataSource.shared.observable.asObserver().subscribe(onNext: {[weak self] value in
            DispatchQueue.main.async {
                self?.offrzNotificationImage.isHidden = !OffrzDataSource.shared.hasUnseenOffrz()
                self?.adjustOffrzNotificationImageConstraints()
                
            }
        }).disposed(by: disposeBag)
        
        OffrzDataSource.shared.loadOffrz()
    }
    
    fileprivate func adjustOffrzNotificationImageConstraints() {
        let segmentWidth = self.segmentedControl.bounds.width / 4
        self.offrzNotificationImage.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(3)
            make.right.equalTo(self.segmentedControl.snp.right).offset(-1.5 * segmentWidth + 13)
        }
    }
}

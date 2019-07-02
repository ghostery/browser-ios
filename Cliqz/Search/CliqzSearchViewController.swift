//
//  CliqzSearchViewController.swift
//  BlurredTemptation
//
//  Created by Bogdan Sulima on 20/11/14.
//  Copyright (c) 2014 Cliqz. All rights reserved.
//

import UIKit
import WebKit
import Shared
import Storage

class HistoryListener {
    var historyResults: Cursor<Site>?
    weak var firefoxSearchController: FirefoxSearchViewController? = nil
    static let shared = HistoryListener()
}

extension HistoryListener: LoaderListener {
    public func loader(dataLoaded data: Cursor<Site>) {
        self.historyResults = data
        firefoxSearchController?.loader(dataLoaded: data)
    }
}

protocol SearchViewDelegate: class {
    func didSelectURL(_ url: URL, searchQuery: String?)
    func autoCompeleteQuery(_ autoCompleteText: String)
	func dismissKeyboard()
}

let OpenUrlSearchNotification = NSNotification.Name(rawValue: "mobile-search:openUrl")
let CopyValueSearchNotification = NSNotification.Name(rawValue: "mobile-search:copyValue")
let HideKeyboardSearchNotification = NSNotification.Name(rawValue: "mobile-search:hideKeyboard")
let CallSearchNotification = NSNotification.Name(rawValue: "mobile-search:call")
let MapSearchNotification = NSNotification.Name(rawValue: "mobile-search:map")
let ShareLocationSearchNotification = NSNotification.Name(rawValue: "mobile-search:share-location")

let SearchEngineChangedNotification = Notification.Name(rawValue: "SearchEngineChangedNotification")

class BackgroundImageManager {
    
    static let shared = BackgroundImageManager()
    
    private var orientationForImage: DeviceOrientation? = nil
    private var orientationForBlurredImage: DeviceOrientation? = nil
    
    private var image: UIImage? = nil
    private var blurredImage: UIImage? = nil
    
    func getImage() -> UIImage? {
        
        let (_, orientation) = UIDevice.current.getDeviceAndOrientation()
        
        if let img = image, orientation == orientationForImage {
            return img
        }
        
        orientationForImage = orientation
        image = UIImage.cliqzBackgroundImage()
        return image
    }
    
    func getBlurredImage() -> UIImage? {
        
        let (_, orientation) = UIDevice.current.getDeviceAndOrientation()
        
        if let img = blurredImage, orientation == orientationForBlurredImage {
            return img
        }
        
        orientationForBlurredImage = orientation
        blurredImage = UIImage.cliqzBackgroundImage(blurred: true)
        return blurredImage
    }
    
    func reset() {
        image = nil
        blurredImage = nil
    }
}

class CliqzSearchViewController : UIViewController, KeyboardHelperDelegate, UIAlertViewDelegate  {
    
    let searchView = Engine.sharedInstance.rootView
    fileprivate let backgroundImage = UIImageView()
    fileprivate let privateModeOverlay = UIView.overlay(frame: CGRect.zero)

    private static let KVOLoading = "loading"
    
    var privateMode = false
    var inSelectionMode = false

	weak var delegate: SearchViewDelegate?
	
    var lastSearchQuery: String? = nil
    
    var searchQuery: String? = nil {
		willSet {
			lastSearchQuery = searchQuery
		}
        didSet {
			Engine.sharedInstance.sendUrlBarInputEvent(newString: searchQuery, lastString: self.lastSearchQuery)
        }
    }
    
    var profile: Profile
    
    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(CliqzSearchViewController.showBlockedTopSites(_:)), name: NSNotification.Name(rawValue: NotificationShowBlockedTopSites), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectUrl), name: OpenUrlSearchNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(copyValue), name: CopyValueSearchNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: HideKeyboardSearchNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(call), name: CallSearchNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openMap), name: MapSearchNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shareLocation), name: ShareLocationSearchNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(autocomplete(_:)), name: AutoCompleteNotification, object: nil)
        
        //TODO: Send notification when search engine is changed
        NotificationCenter.default.addObserver(self, selector: #selector(searchEngineChanged), name: SearchEngineChangedNotification, object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.searchView.backgroundColor = .clear
        self.view.addSubview(backgroundImage)
        self.backgroundImage.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.view.addSubview(searchView)
        self.searchView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

		KeyboardHelper.defaultHelper.addDelegate(self)
//        backgroundImage.image = BackgroundImageManager.shared.getImage()

        NotificationCenter.default.addObserver(self, selector: #selector(showOpenSettingsAlert(_:)), name: NSNotification.Name(rawValue: LocationManager.NotificationShowOpenLocationSettingsAlert), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: Notification.Name.DeviceOrientationChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Engine.updateExtensionPreferences(privateMode: self.privateMode)
        self.updateExtensionSearchEngine()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        Engine.sharedInstance.getBridge().callAction("search:stopSearch", args: [["contextId": "mobile-cards"]])
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LocationManager.NotificationUserLocationAvailable), object: nil)
    }

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
    }

	func isHistoryUptodate() -> Bool {
		return true
	}
    
    func updatePrivateMode(_ privateMode: Bool) {
        if privateMode != self.privateMode {
            self.privateMode = privateMode
            Engine.updateExtensionPreferences(privateMode: privateMode)
            if privateMode && privateModeOverlay.superview == nil {
                backgroundImage.addSubview(privateModeOverlay)
                privateModeOverlay.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
        }
    }

	fileprivate func animateSearchEnginesWithKeyboard(_ keyboardState: KeyboardState) {
        self.view.layoutIfNeeded()
	}

	// Mark Keyboard delegate methods
	func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState) {
		animateSearchEnginesWithKeyboard(state)
	}

	func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState) {
	}
	
	func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState) {
		animateSearchEnginesWithKeyboard(state)
	}
	
    fileprivate func updateExtensionSearchEngine() {
            
        if let profile = (UIApplication.shared.delegate as? AppDelegate)?.profile {
            let searchComps = profile.searchEngines.defaultEngine.searchURLForQuery("queryString")?.absoluteString.components(separatedBy: "=queryString")
            let searchEngineName = profile.searchEngines.defaultEngine.shortName
            let parameters = ["name": searchEngineName, "url": searchComps![0] + "="]//"'\(searchEngineName)', `\(searchComps![0])=`"
            
            Engine.sharedInstance.getBridge().publishEvent("mobile-browser:set-search-engine", args: [parameters])
        }
    }
    
    //MARK: - Reset TopSites
    func showBlockedTopSites(_ notification: Notification) {
        Engine.sharedInstance.getBridge().publishEvent("mobile-browser:restore-blocked-topsites", args: [])
    }
    
    //MARK: - Search Engine
    @objc func searchEngineChanged(_ notification: Notification) {
        self.updateExtensionSearchEngine()
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
//        backgroundImage.image = BackgroundImageManager.shared.getImage()
    }
}


//handle Search Events
extension CliqzSearchViewController {
    
    @objc func didSelectUrl(_ notification: Notification) {
        if let url_str = notification.object as? NSString, let encodedString = url_str.addingPercentEncoding(
            withAllowedCharacters: NSCharacterSet.urlFragmentAllowed), let url = URL(string: encodedString as String) {
            if !inSelectionMode {
                delegate?.didSelectURL(url, searchQuery: self.searchQuery)
            } else {
                inSelectionMode = false
            }
        }
    }
    
    @objc func hideKeyboard(_ notification: Notification) {
        delegate?.dismissKeyboard()
    }

    @objc func copyValue(_ notification: Notification) {
        if let result = notification.object as? String {
            UIPasteboard.general.string = result
        }
    }

    @objc func call(_ notification: Notification) {
        if let number = notification.object as? String {
            self.callPhoneNumber(number)
        }
    }
    
    @objc func openMap(_ notification: Notification) {
        self.didSelectUrl(notification)
    }
    
    @objc func shareLocation(_ notification: Notification) {
        LocationManager.sharedInstance.shareLocation()
    }
    
    fileprivate func callPhoneNumber(_ phoneNumber: String) {
        let trimmedPhoneNumber = phoneNumber.removeWhitespaces()
        if let url = URL(string: "tel://\(trimmedPhoneNumber)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

//MARK: - Autocomplete Notification
extension CliqzSearchViewController {
    @objc func autocomplete(_ notification: Notification) {
        
        if let searchQuery = searchQuery, let lastSearchQuery = lastSearchQuery,  searchQuery.count < lastSearchQuery.count {
            // don't call auto complete if user is backspacing
            return
        }
        
        if let str = notification.object as? String {
            delegate?.autoCompeleteQuery(str)
        }
    }
}

//MARK: - Handle Key Commands
extension CliqzSearchViewController {
    func handleKeyCommands(sender: UIKeyCommand) {
        return //function not supported
    }
}

//MARK: - Util
extension CliqzSearchViewController {
    @objc func showOpenSettingsAlert(_ notification: Notification) {
        var message: String!
        var settingsAction: UIAlertAction!
        
        let settingsOptionTitle = NSLocalizedString("Settings", tableName: "Cliqz", comment: "Settings option for turning on location service")
        
        if let locationServicesEnabled = notification.object as? Bool, locationServicesEnabled == true {
            message = NSLocalizedString("To share your location, go to the settings for the CLIQZ app:\n1.Tap Location\n2.Enable 'While Using'", tableName: "Cliqz", comment: "Alert message for turning on location service when clicking share location on local card")
            settingsAction = UIAlertAction(title: settingsOptionTitle, style: .default) { (_) -> Void in
                if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }
        } else {
            message = NSLocalizedString("To share your location, go to the settings of your smartphone:\n1.Turn on Location Services\n2.Select the CLIQZ App\n3.Enable 'While Using'", tableName: "Cliqz", comment: "Alert message for turning on location service when clicking share location on local card")
            settingsAction = UIAlertAction(title: settingsOptionTitle, style: .default) { (_) -> Void in
                if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }
        }
        
        let title = NSLocalizedString("Turn on Location Services", tableName: "Cliqz", comment: "Alert title for turning on location service when clicking share location on local card")
        
        DispatchQueue.main.async {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
                
                let notNowOptionTitle = NSLocalizedString("Not Now", tableName: "Cliqz", comment: "Not now option for turning on location service")
                let cancelAction = UIAlertAction(title: notNowOptionTitle, style: .default, handler: nil)
                
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                
                //self.present(alertController, animated: true, completion: nil)
                delegate.presentContollerOnTop(controller: alertController)
            }
        }
        
    }
}


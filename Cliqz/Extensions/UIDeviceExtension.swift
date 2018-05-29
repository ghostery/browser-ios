//
//  UIDeviceExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 11/16/15.
//  Copyright © 2015 Cliqz. All rights reserved.
//

import Foundation

public enum DeviceType {
    case iPhone
    case iPhoneX
    case iPad
}

public enum DeviceOrientation {
    case portrait
    case landscape
}

public extension UIDevice {
    
    var modelName: String {
        let identifierKey = "UIDevice.identifier"
        let storedIdentified = LocalDataStore.value(forKey: identifierKey) as? String
        guard storedIdentified == nil  else {
            return storedIdentified!
        }
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        var deviceIdentifier: String
        
        switch identifier {
        case "iPod5,1":                                 deviceIdentifier = "iPod Touch 5"
        case "iPod7,1":                                 deviceIdentifier = "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     deviceIdentifier = "iPhone 4"
        case "iPhone4,1":                               deviceIdentifier = "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  deviceIdentifier = "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  deviceIdentifier = "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  deviceIdentifier = "iPhone 5s"
        case "iPhone7,2":                               deviceIdentifier = "iPhone 6"
        case "iPhone7,1":                               deviceIdentifier = "iPhone 6 Plus"
        case "iPhone8,1":                               deviceIdentifier = "iPhone 6s"
        case "iPhone8,2":                               deviceIdentifier = "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  deviceIdentifier = "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  deviceIdentifier = "iPhone 7 Plus"
        case "iPhone8,4":                               deviceIdentifier = "iPhone SE"
		case "iPhone10,1", "iPhone10,4": 				deviceIdentifier = "iPhone 8"
		case "iPhone10,2", "iPhone10,5": 				deviceIdentifier = "iPhone 8 Plus"
		case "iPhone10,3", "iPhone10,6": 				deviceIdentifier = "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":deviceIdentifier = "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           deviceIdentifier = "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           deviceIdentifier = "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           deviceIdentifier = "iPad Air"
        case "iPad5,3", "iPad5,4":                      deviceIdentifier = "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    deviceIdentifier = "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           deviceIdentifier = "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           deviceIdentifier = "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           deviceIdentifier = "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      deviceIdentifier = "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      deviceIdentifier = "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      deviceIdentifier = "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      deviceIdentifier = "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      deviceIdentifier = "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              deviceIdentifier = "Apple TV"
        case "i386", "x86_64":                          deviceIdentifier = "Simulator"
        default:                                        deviceIdentifier = identifier
        }
        
        LocalDataStore.set(value: deviceIdentifier, forKey: identifierKey)
        return deviceIdentifier
    }

	// Find better name
	func isiPhoneXDevice() -> Bool {
		return modelName.starts(with: "iPhone X")
	}
	
	// Find better name
	func isiPad() -> Bool {
		return userInterfaceIdiom == .pad
	}

    func isSmallIphoneDevice() -> Bool {
		return modelName.starts(with: "iPhone 4") || modelName.starts(with: "iPhone 5") || modelName.starts(with: "iPhone SE")
    }
    
    var isPortrait: Bool {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait, .portraitUpsideDown:
            return true
        case .landscapeLeft, .landscapeRight:
            return false
        default: // unknown or faceUp or FaceDown
            return UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height
        }
    }
    
    func getDeviceAndOrientation() -> (DeviceType, DeviceOrientation) {
        
        let device: DeviceType
        
        if self.isiPad() {
            device = .iPad
        }
        else if self.isiPhoneXDevice() {
            device = .iPhoneX
        }
        else {
            device = .iPhone
        }
        
        var orientation: DeviceOrientation = .portrait
        
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            if window.frame.height < window.frame.width {
                orientation = .landscape
            }
        }
        
        return (device, orientation)
    }
}

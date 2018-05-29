//
//  LocationManager.swift
//  Client
//
//  Created by Sahakyan on 8/28/15.
//  Copyright (c) 2015 Mozilla. All rights reserved.
//

import Foundation
import CoreLocation

open class LocationManager: NSObject, CLLocationManagerDelegate {
    static let NotificationUserLocationAvailable = "NotificationUserLocationAvailable"
    static let NotificationShowOpenLocationSettingsAlert = "NotificationShowOpenLocationSettingsAlert"
    private var enableLocationInProgress = false
    private var permissionCallbacks: [(Bool) -> Void] = []

	fileprivate let manager = CLLocationManager()
    fileprivate var location: CLLocation? {
        didSet {
            if location != nil && enableLocationInProgress {
                NotificationCenter.default.post(name: Notification.Name(rawValue: LocationManager.NotificationUserLocationAvailable), object: nil)
            }
        }
    }
    fileprivate let locationStatusKey = "currentLocationStatus"

	open static let sharedInstance: LocationManager = {
		let m = LocationManager()
		m.manager.delegate = m
		m.manager.desiredAccuracy = 300
		return m
	}()

    open func getUserLocation() -> CLLocation? {
        return self.location
    }
    
    open func askForLocationAccess (callback: ((Bool) -> Void)? = nil) {
        //TelemetryLogger.sharedInstance.logEvent(.LocationServicesStatus("try_show", nil))
        self.manager.requestWhenInUseAuthorization()
        enableLocationInProgress = true
        if callback != nil {
            permissionCallbacks.append(callback!)
        }
    }
    
	open func shareLocation(callback: ((Bool) -> Void)? = nil) {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .denied {
            NotificationCenter.default.post(name: Notification.Name(rawValue: LocationManager.NotificationShowOpenLocationSettingsAlert), object: CLLocationManager.locationServicesEnabled())
            enableLocationInProgress = true
            callback?(false)
        } else if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            self.startUpdatingLocation()
            callback?(true)
        } else if CLLocationManager.locationServicesEnabled() {
            askForLocationAccess(callback: callback)
        }
        
	}
    
    
    open func startUpdatingLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            return
        }
        
        self.manager.startUpdatingLocation()
    }
    
	open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
	}
    
    open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        let permission: Bool
        
        switch status {
        case .denied, .notDetermined, .restricted:
            self.location = nil
            permission = false
        default:
			if let l = self.manager.location {
				self.location = l
			}
            permission = true
            break
        }
        
        //call the callbacks with the permission
        for callback in permissionCallbacks {
            callback(permission)
        }
        
        //empty the array
        permissionCallbacks = []
        
        let currentLocationStatus = LocalDataStore.value(forKey: locationStatusKey)
        if currentLocationStatus == nil || currentLocationStatus as! String != status.stringValue() {
            //TelemetryLogger.sharedInstance.logEvent(.LocationServicesStatus("status_change", status.stringValue()))
            LocalDataStore.set(value: status.stringValue(), forKey: locationStatusKey)
        }
    }
    
    open func isLocationAcessEnabled() -> Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        return authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }

}

extension CLAuthorizationStatus {
	func stringValue() -> String {
		let statuses: [Int: String] = [Int(CLAuthorizationStatus.notDetermined.rawValue) : "NotDetermined",
			Int(CLAuthorizationStatus.restricted.rawValue) : "Restricted",
			Int(CLAuthorizationStatus.denied.rawValue) : "Denied",
			Int(CLAuthorizationStatus.authorizedAlways.rawValue) : "AuthorizedAlways",
			Int(CLAuthorizationStatus.authorizedWhenInUse.rawValue) : "AuthorizedWhenInUse"]
		if let s = statuses[Int(rawValue)] {
			return s
		}
		return "Unknown type"
	}
}

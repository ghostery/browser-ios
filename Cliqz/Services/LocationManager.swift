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
    
    open func askForLocationAccess () {
        //TelemetryLogger.sharedInstance.logEvent(.LocationServicesStatus("try_show", nil))
        self.manager.requestWhenInUseAuthorization()
        enableLocationInProgress = true
    }
    
	open func shareLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .denied {
            NotificationCenter.default.post(name: Notification.Name(rawValue: LocationManager.NotificationShowOpenLocationSettingsAlert), object: CLLocationManager.locationServicesEnabled())
	enableLocationInProgress = true
        } else if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            self.startUpdatingLocation()
            
        } else if CLLocationManager.locationServicesEnabled() {
            askForLocationAccess()
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
        switch status {
        case .denied, .notDetermined, .restricted:
            self.location = nil
        default:
			if let l = self.manager.location {
				self.location = l
			}
            break
        }
        
        let currentLocationStatus = LocalDataStore.objectForKey(locationStatusKey)
        if currentLocationStatus == nil || currentLocationStatus as! String != status.stringValue() {
            //TelemetryLogger.sharedInstance.logEvent(.LocationServicesStatus("status_change", status.stringValue()))
            LocalDataStore.setObject(status.stringValue(), forKey: locationStatusKey)
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

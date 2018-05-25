//
//  TelemetryManager.swift
//  Client
//
//  Created by Tim Palade on 5/25/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class TelemetryHelper: NSObject {
    class func sendFreshTabShow() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [["type": "home", "action": "show"], false, "freshtab.home.show"])
    }
    
    class func sendTopSiteClick() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [["type": "home", "action": "click", "target": "topsite"], false, "freshtab.home.click.topsite"])
    }
    
    class func sendControlCenterShow() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [[:], false, "metrics.controlcenter.show"])
    }
    
    class func sendControlCenterPauseClick() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [[:], false, "metrics.controlcenter.click.pause"])
    }
    
    class func sendControlCenterResumeClick() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [[:], false, "metrics.controlcenter.click.resume"])
    }
    
    class func sendControlCenterTrustClick() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [[:], false, "metrics.controlcenter.click.trustSite"])
    }
    
    class func sendControlCenterRestrictClick() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [[:], false, "metrics.controlcenter.click.restrictSite"])
    }
    
    class func sendFavoriteMigrationSignal(count: Int, rootFolderCount: Int, maxDepth: Int) {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [["count": count, "rootFolderCount": rootFolderCount, "maxDepth": maxDepth], false, "metrics.favorites.migration.folders"])
    }
}

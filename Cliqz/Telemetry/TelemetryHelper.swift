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
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [["type": "home", "action": "show"], false, "freshtab.home.show"])
    }
    
    class func sendTopSiteClick() {
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [["type": "home", "action": "click", "target": "topsite"], false, "freshtab.home.click.topsite"])
    }
    
    class func sendControlCenterShow() {
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [[:], false, "metrics.controlCenter.show"])
    }
    
    class func sendControlCenterPauseClick() {
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [[:], false, "metrics.controlCenter.click.pause"])
    }
    
    class func sendControlCenterResumeClick() {
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [[:], false, "metrics.controlCenter.click.resume"])
    }
    
    class func sendControlCenterTrustClick() {
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [[:], false, "metrics.controlCenter.click.trustSite"])
    }
    
    class func sendControlCenterRestrictClick() {
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [[:], false, "metrics.controlCenter.click.restrictSite"])
    }
    
    class func sendFavoriteMigrationSignal(count: Int, rootFolderCount: Int, maxDepth: Int) {
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [["count": count, "rootFolderCount": rootFolderCount, "maxDepth": maxDepth], false, "metrics.favorites.migration.folders"])
    }
    
    class func sendPageView() {
        Engine.sharedInstance.getBridge().callAction("anolysis:handleTelemetrySignal", args: [["visitsCount": 1], false, "metrics.history.visits.count"])
    }
}

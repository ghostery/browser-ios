//
//  TelemetryManager.swift
//  Client
//
//  Created by Tim Palade on 5/25/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class TelemetryManager: NSObject {
    class func sendFreshTabShown() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [["type": "home", "action": "show"], false, "freshtab.home.show"])
    }
    
    class func sendTopSiteClicked() {
        Engine.sharedInstance.getBridge().callAction("handleTelemetrySignal", args: [["type": "home", "action": "click", "target": "topsite"], false, "freshtab.home.click.topsite"])
    }
}

//
//  ControlCenterDelegate.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

protocol ControlCenterDelegateProtocol {
    func chageSiteState(to: DomainState)
    func pauseGhostery()
    func turnGlobalAntitracking(on: Bool)
    func turnGlobalAdblocking(on: Bool)
    func changeState(appId: Int, state: TrackerStateEnum)
}

class ControlCenterDelegate: ControlCenterDelegateProtocol {
    let domainStr: String
    let domainObj: Domain?
    
    init(domain: String) {
        self.domainStr = domain
        self.domainObj = DomainStore.get(domain: domainStr)
    }
    
    func chageSiteState(to: DomainState) {
        if let domainObj = domainObj {
            DomainStore.changeState(domain: domainObj, state: to)
        }
        else {
            debugPrint("PROBLEM -- domainObj does not exist!")
        }
    }
    
    func pauseGhostery() {
        //dunno
    }
    
    func turnGlobalAntitracking(on: Bool) {
        if on == true {
            UserPreferences.instance.blockingMode = .all
        }
        else {
            UserPreferences.instance.blockingMode = .none
        }
        UserPreferences.instance.writeToDisk()
    }
    
    func turnGlobalAdblocking(on: Bool) {
        //to do
    }
    
    func changeState(appId: Int, state: TrackerStateEnum) {
        if let trakerListApp = TrackerList.instance.apps[appId] {
            TrackerStateStore.change(trackerState: trakerListApp.state, toState: state)
        }
        else {
            debugPrint("PROBLEM -- trackerState does not exist for appId = \(appId)!")
        }
    }
}

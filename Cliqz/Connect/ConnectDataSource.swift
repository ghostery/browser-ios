//
//  ConnectDataSource.swift
//  Client
//
//  Created by Mahmoud Adam on 3/28/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import RxSwift

let SendTabNotification = NSNotification.Name(rawValue: "mobile-pairing:openTab")
let DownloadVideoNotification = NSNotification.Name(rawValue: "mobile-pairing:downloadVideo")
let PushPairingDataNotification = NSNotification.Name(rawValue: "mobile-pairing:pushPairingData")
let NotifyPairingErrorNotification = NSNotification.Name(rawValue: "mobile-pairing:notifyPairingError")
let NotifyPairingSuccessNotification = NSNotification.Name(rawValue: "mobile-pairing:notifyPairingSuccess")

class Connection: NSObject {
    var id: String!
    var name: String?
    var status: ConnectionStatus!
    
}

enum ConnectionStatus {
    case Connected
    case Pairing
    case Disconnected
    
    init(string: String) {
        switch string.lowercased() {
        case "connected": self = .Connected
        case "pairing": self = .Pairing
        case "disconnected": self = .Disconnected
        default: self = .Disconnected
        }
    }
    
    func toString() -> String {
        switch self {
        case .Connected:
            return NSLocalizedString("Online", tableName: "Cliqz", comment: "[Settings -> Connect] Online status")
        case .Pairing:
            return NSLocalizedString("Connecting ...", tableName: "Cliqz", comment: "[Settings -> Connect] Connecting status")
        case .Disconnected:
            return NSLocalizedString("Offline", tableName: "Cliqz", comment: "[Settings -> Connect] Offline status")
        }
    }
}


class ConnectDataSource {
    
    static let instance = ConnectDataSource()
    
    private var connections = [Connection]()
    private var lastScannedQrCode: String?
    
    let observable = BehaviorSubject(value: false)
    
    init() {
        Engine.sharedInstance.requestPairingData()
        NotificationCenter.default.addObserver(self, selector: #selector(loadConnections), name: PushPairingDataNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: PushPairingDataNotification, object: nil)
    }
    
    // MARK: - Public APIs
    
    func getConnections() -> [Connection] {
        return connections
    }
    
    func qrcodeScanned(_ qrCode: String) {
        lastScannedQrCode = qrCode
        Engine.sharedInstance.receiveQRValue(qrCode)
    }
    
    func retryLastConnection() {
        if let lastScannedQrCode = self.lastScannedQrCode {
            qrcodeScanned(lastScannedQrCode)
        }
    }
    
    func removeConnection(_ connection: Connection?) {
        if let connection = connection {
            Engine.sharedInstance.unpairDevice(connection.id)
        }
    }
    
    func renameConnection(_ connection: Connection?, newName: String) {
        if let connection = connection {
            Engine.sharedInstance.renameDevice(connection.id, newName: newName)
        }
    }
    
    func requestPairingData() {
        Engine.sharedInstance.requestPairingData()
    }
    
    @objc private func loadConnections(notification: NSNotification) {
        guard let pairingData = notification.object as? [String: AnyObject], let devices = pairingData["devices"] as? [[String: AnyObject]] else {
            return
        }
        
        var importedConnections = [Connection]()
        
        for device in devices {
            if let id = device["id"] as? String, let status = device["status"] as? String {
                let connection = Connection()
                connection.name = device["name"] as? String ?? NSLocalizedString("Connecting to Desktop", tableName: "Cliqz", comment: "[Settings -> Connect] pending connection title")
                connection.id = id
                connection.status = ConnectionStatus(string: status)
                
                importedConnections.append(connection)
            }
        }
        
        connections.removeAll()
        connections.append(contentsOf: importedConnections)
        
        self.observable.on(.next(true))
    }
}

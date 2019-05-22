//
//  VPN.swift
//  Client
//
//  Created by Pavel Kirakosyan on 29.04.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

import NetworkExtension
import Alamofire

private let maxRetryCount: Int = 1

class VPN {
    
    static let shared = VPN()
    
    var connectDate: Date? {
        return NEVPNManager.shared().connection.connectedDate
    }
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
    }
    
    func checkConnection() {
        guard SubscriptionController.shared.isVPNEnabled() else {
            VPN.disconnectVPN()
            NEVPNManager.shared().removeFromPreferences { (error) in
                if let e = error {
                    print("Could not remove VPN configurations, with the following error: \(e.localizedDescription)")
                } else {
                    // Will clear out the configuration parameters from the NEVPNManager object according to documentation
                    NEVPNManager.shared().loadFromPreferences(completionHandler: {_ in })
                }
            }
            return
        }
        
        if (lastStatus == .connected && status != .connected) {
            VPN.connect2VPN()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var status: NEVPNStatus {
        return NEVPNManager.shared().connection.status
    }
    
    // MARK: Private
    
    private let retryCountKey = "VPNRetryCountKey"
    private var retryCount: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: retryCountKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let value = UserDefaults.standard.value(forKey: retryCountKey) as? Int {
                return value
            }
            return 0 //default
        }
    }
    
    //do a last status, and try to reconnect if the last status is connected.
    private let lastStatusKey = "VPNLastStatusKey"
    private var lastStatus: NEVPNStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: lastStatusKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let statusRaw = UserDefaults.standard.value(forKey: lastStatusKey) as? Int {
                if let status = NEVPNStatus(rawValue: statusRaw) {
                    return status
                }
            }
            
            return .disconnected //default
        }
    }
    
    private var connectedCountry: VPNCountry?
    private var disconnectionBlock: (() -> Void)?
    
    private func shouldReconnect() -> Bool {
        return self.retryCount > 0
    }
    
    @objc private func VPNStatusDidChange(notification: Notification) {
        
        if status == .connected {
            VPN.shared.retryCount = maxRetryCount
        } else if status == .disconnected {
            let vpnConfigurationBecomeValid = (lastStatus == .invalid)
            self.disconnectionBlock?()
            self.disconnectionBlock = nil
            if (self.shouldReconnect() || vpnConfigurationBecomeValid) {
                VPN.reconnectVPN()
            }
        }
        
        //keep button up to date.
        lastStatus = status
    }
    
    // MARK: Static
    static func disconnectVPN(completion: (() -> Void)? = nil) {
        VPN.resetConnection()
        NEVPNManager.shared().connection.stopVPNTunnel()
        
        if VPN.shared.status == .disconnected {
            completion?()
        } else {
            VPN.shared.disconnectionBlock = completion
        }
    }
    
    static func connect2VPN() {
        if NEVPNManager.shared().protocolConfiguration == nil {
            VPN.shared.lastStatus = .invalid
        }
        
        let country = VPNEndPointManager.shared.selectedCountry
        guard let creds = VPNEndPointManager.shared.getCredentials(country: country),
            !country.endpoint.isEmpty else { return }
        
        NEVPNManager.shared().loadFromPreferences { (error) in
            
            NEVPNManager.shared().protocolConfiguration = VPN.createVPNProtocol(credentials: creds, country: country)
            NEVPNManager.shared().isOnDemandEnabled = true
            NEVPNManager.shared().isEnabled = true
            NEVPNManager.shared().saveToPreferences(completionHandler: { error in
                if error == nil {
                    if VPN.startTunnel() {
                        VPN.shared.connectedCountry = country
                    }
                } else {
                    print("error saving vpn preferences - \(error!.localizedDescription)")
                }
            })
        }
    }
    
    static func countryDidChange(country: VPNCountry) {
        if VPN.shared.connectedCountry != nil && VPN.shared.connectedCountry != country {
            VPN.shared.connectedCountry = nil
            VPN.reconnectVPN()
        }
    }
    // MARK: Private static
    
    private static func resetConnection() {
        VPN.shared.retryCount = 0
        VPN.shared.connectedCountry = nil
    }
    
   @discardableResult private static func startTunnel() -> Bool {
        guard VPN.shared.status == .disconnected else {
            return false
        }
        
        do {
            try NEVPNManager.shared().connection.startVPNTunnel()
            return true
        }
        catch (let error) {
            print("VPN Connecttion failed --- \(error)")
            LegacyTelemetryHelper.logVPN(action: "error",
                                         location: VPNEndPointManager.shared.selectedCountry.id,
                                         connectionTime: 0)
            VPN.shared.retryCount = 0
        }
        
        return false
    }
    
    private static func reconnectVPN() {
        VPN.shared.retryCount -= 1
        if NEVPNManager.shared().protocolConfiguration?.serverAddress == VPN.shared.connectedCountry?.endpoint {
            VPN.startTunnel()
        } else {
            VPN.disconnectVPN {
                VPN.connect2VPN()
            }
        }
    }
    
    private static func createVPNProtocol(credentials: Credentials, country: VPNCountry) -> NEVPNProtocolIKEv2 {
        let ikeProtocol = NEVPNProtocolIKEv2()
        ikeProtocol.authenticationMethod = .none
        ikeProtocol.username = credentials.username
        ikeProtocol.passwordReference = credentials.password
        ikeProtocol.serverAddress = country.endpoint
        ikeProtocol.remoteIdentifier = country.remoteID
        ikeProtocol.useExtendedAuthentication = true
        ikeProtocol.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
        ikeProtocol.childSecurityAssociationParameters.integrityAlgorithm = .SHA256
        ikeProtocol.disconnectOnSleep = false
        return ikeProtocol
    }
}

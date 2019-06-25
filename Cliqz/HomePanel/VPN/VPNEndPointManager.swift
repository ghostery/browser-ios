//
//  VPNDataSource.swift
//  Client
//
//  Created by Mahmoud Adam on 4/10/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

struct Credentials {
    let username: String
    let password: Data
}

class VPNCountry: Codable, Equatable {
    /// id from the server
    let id: String

    /// display name
    let name: String

    /// endpoint address
    var endpoint: String

    /// endpoint address
    var remoteID: String
    
    init(id: String, name: String, endpoint: String, remoteID: String) {
        self.id = id
        self.name = name
        self.endpoint = endpoint
        self.remoteID = remoteID
    }
    
    static func == (lhs: VPNCountry, rhs: VPNCountry) -> Bool {
        return lhs.id == rhs.id
    }
    
    private var keyPrefix: String {
        return "\(self.id)|\(self.endpoint)"
    }

    /// Key for saving data about an endpoint into keychain
    var usernameKey: String {
        return "\(self.keyPrefix)|username"
    }

    /// Key for saving data about an endpoint into keychain
    var passwordKey: String {
        return "\(self.keyPrefix)|password"
    }
    
    var disabled: Bool {
        return remoteID.isEmpty
    }
}

class VPNEndPointManager {
    /// Notification that fires when the list of countries is updated
    static let countriesUpdatedNotification = Notification.Name("VPNCountry.countriesUpdatedNotification")

    /// Notification that fires when the list of countries could not be updated due to an error
    ///
    /// Should include an Error instance in the userInfo, key "error"
    static let countriesUpdateErrorNotification = Notification.Name("VPNCountry.countriesUpdateErrorNotification")

    private let SelectedCountryKey = "VPNSelectedCountry"
    private static let countryNameLookupTable = [
        "us" : NSLocalizedString("USA", tableName: "Lumen", comment: "VPN country name for USA"),
        "de" : NSLocalizedString("Germany", tableName: "Lumen", comment: "VPN country name for Germany"),
        "tr" : NSLocalizedString("Turkey", tableName: "Lumen", comment: "VPN country name for Turkey"),
        "pl" : NSLocalizedString("Poland", tableName: "Lumen", comment: "VPN country name for Poland"),
        "it" : NSLocalizedString("Italy", tableName: "Lumen", comment: "VPN country name for Italy"),
        "gr" : NSLocalizedString("Greece", tableName: "Lumen", comment: "VPN country name for Greece"),
        "hu" : NSLocalizedString("Hungary", tableName: "Lumen", comment: "VPN country name for Hungary"),
        "at" : NSLocalizedString("Austria", tableName: "Lumen", comment: "VPN country name for Austria"),
        "es" : NSLocalizedString("Spain", tableName: "Lumen", comment: "VPN country name for Spain"),
        "nl" : NSLocalizedString("Netherlands", tableName: "Lumen", comment: "VPN country name for Netherlands"),
        "fr" : NSLocalizedString("France", tableName: "Lumen", comment: "VPN country name for France"),
        "pt" : NSLocalizedString("Portugal", tableName: "Lumen", comment: "VPN country name for Portugal"),
        "uk" : NSLocalizedString("UK", tableName: "Lumen", comment: "VPN country name for UK"),
        "ca" : NSLocalizedString("Canada", tableName: "Lumen", comment: "VPNcountry name for Canada"),
        "ba" : NSLocalizedString("Bosnia", tableName: "Lumen", comment: "VPN country name for Bosnia"),
        "bg" : NSLocalizedString("Bulgaria", tableName: "Lumen", comment: "VPN country name for Bulgaria"),
        "hr" : NSLocalizedString("Croatia", tableName: "Lumen", comment: "VPN country name for Croatia"),
        "in" : NSLocalizedString("India", tableName: "Lumen", comment: "VPN country name for India"),
        "ro" : NSLocalizedString("Romania", tableName: "Lumen", comment: "VPN country name for Romania"),
        "rs" : NSLocalizedString("Serbia", tableName: "Lumen", comment: "VPN country name for Serbia"),
        "ua" : NSLocalizedString("Ukraine", tableName: "Lumen", comment: "VPN country name for Ukraine")
    ]


    private var countries = [VPNCountry]()
    
    // MARK:- Singleton & Init
    static let shared = VPNEndPointManager()
    
    init() {
        getVPNCredentialsFromServer()
    }
    
    private func getVPNCredentialsFromServer() {
        VPNCredentialsService.getVPNCredentials { [weak self] (credentials, error) in
            guard error == nil, let credentials = credentials else {
                NotificationCenter.default.post(
                    name: VPNEndPointManager.countriesUpdateErrorNotification,
                    object: nil,
                    userInfo: error == nil ? nil : ["error": error!]
                )
                return
            }

            guard let self = self, credentials.count > 0 else { return }
            self.countries.removeAll()
            
            for cred in credentials {
                let id = cred.countryCode.lowercased()
                let name = VPNEndPointManager.countryNameLookupTable[id] ?? cred.country
                let country = VPNCountry(id: id, name: name, endpoint: cred.serverIP, remoteID: cred.remoteID)
                self.countries.append(country)
                self.setCreds(country: country, username: cred.username, password: cred.password)
            }
            
            self.sortCountries()

            NotificationCenter.default.post(name: VPNEndPointManager.countriesUpdatedNotification, object: self)
        }
    }

    private func sortCountries() {
        // Sort countries alphabetically
        self.countries = self.countries.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        // Move Germany & USA to the top
        let topCountries = self.countries.filter {$0.id == "us" || $0.id == "de"}.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        for country in topCountries {
            if let index = self.countries.index(of: country) {
                self.countries.remove(at: index)
                self.countries.insert(country, at: 0)
            }
        }
    }

    //MARK:- Public APIs
    //MARK: Credentials
    func setCreds(country: VPNCountry, username: String, password: String) {
        let keychain = DAKeychain.shared
        keychain[country.usernameKey] = username
        keychain[country.passwordKey] = password
    }
    
    func getCredentials(country: VPNCountry) -> Credentials? {
        let keychain = DAKeychain.shared
        if let username = keychain[country.usernameKey],
            let pass = keychain.load(withKey: country.passwordKey)
        {
            return Credentials(username: username, password: pass)
        }
        //initiate a call to get the credentials?
        getVPNCredentialsFromServer()
        return nil
    }
    
    func clearCredentials() {
        for c in self.countries {
            DAKeychain.shared[c.usernameKey] = nil
            DAKeychain.shared[c.passwordKey] = nil
        }
    }
    
    func updateVPNCredentials() {
        getVPNCredentialsFromServer()
    }
    
    //MARK:- VPN Countries
    var selectedCountry: VPNCountry? {
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: SelectedCountryKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let data = UserDefaults.standard.value(forKey: SelectedCountryKey) as? Data, let country = try? PropertyListDecoder().decode(VPNCountry.self, from: data) {
                return country
            }
            return countries.first
        }
    }
    
    func getAvailableCountries() -> [VPNCountry] {
        return countries
    }
    
}

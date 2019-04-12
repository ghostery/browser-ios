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
    let id: String //id from the server
    let name: String //display name
    var endpoint: String //endpoint address
    var remoteID: String //endpoint address
    
    init(id: String, name: String, endpoint: String, remoteID: String) {
        self.id = id
        self.name = name
        self.endpoint = endpoint
        self.remoteID = remoteID
    }
    
    static func == (lhs: VPNCountry, rhs: VPNCountry) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashPrefix: String {
        return "\(self.id)|\(self.endpoint)"
    }
    
    var usernameHash: String {
        return "\(self.hashPrefix)|username"
    }
    
    var passwordHash: String {
        return "\(self.hashPrefix)|password"
    }
    
    var disabled: Bool {
        return remoteID.isEmpty
    }
}

class VPNEndPointManager {
    private let SelectedCountryKey = "VPNSelectedCountry"
    private let CountriesLookup = [
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
        "gb" : NSLocalizedString("UK", tableName: "Lumen", comment: "VPN country name for UK"),
        "ca" : NSLocalizedString("Canada", tableName: "Lumen", comment: "VPNcountry name for Canada"),
        "ba" : NSLocalizedString("Bosnia", tableName: "Lumen", comment: "VPN country name for Bosnia"),
        "bn" : NSLocalizedString("Bulgaria", tableName: "Lumen", comment: "VPN country name for Bulgaria"),
        "hr" : NSLocalizedString("Croatia", tableName: "Lumen", comment: "VPN country name for Croatia"),
        "in" : NSLocalizedString("India", tableName: "Lumen", comment: "VPN country name for India"),
        "ro" : NSLocalizedString("Romania", tableName: "Lumen", comment: "VPN country name for Romania"),
        "rs" : NSLocalizedString("Serbia", tableName: "Lumen", comment: "VPN country name for Serbia"),
        "ua" : NSLocalizedString("Ukraine", tableName: "Lumen", comment: "VPN country name for Ukraine")
        ]
    
    private var countries = [VPNCountry]()
    
    //MARK:- Singlton & Init
    static let shared = VPNEndPointManager()
    
    init() {
        fillInDummyCountries()
        getVPNCredentialsFromServer()
    }
    
    //TODO: [IP-426] to be removed and get the countries from the backend
    private func fillInDummyCountries() {
        for id in ["us", "de", "ba", "bn", "fr", "gr", "in", "it", "ca", "hr", "nl", "at", "pl", "pt", "ro", "rs", "es", "tr", "ua", "hu", "gb"] {
            if let name = CountriesLookup[id] {
                self.countries.append(VPNCountry(id: id, name: name, endpoint: "", remoteID: ""))
            }
        }
    }
    
    //TODO: [IP-426] replace these two methods with the underneath one to get the countries from the backend
    private func getVPNCredentialsFromServer() {
        VPNCredentialsService.getVPNCredentials { [weak self] (credentials) in
            for cred in credentials {
                if let country = self?.country(id: cred.country.lowercased()) {
                    country.endpoint = cred.serverIP
                    country.remoteID = cred.remoteID
                    self?.setCreds(country: country, username: cred.username, password: cred.password)
                }
            }
        }
    }
    private  func country(id: String) -> VPNCountry? {
        return countries.filter{$0.id == id}.first
    }
    
    /* [IP-426] getting the countries from the backend
    private func getVPNCredentialsFromServer() {
        VPNCredentialsService.getVPNCredentials { [weak self] (credentials) in
            guard let self = self, credentials.count > 0 else { return }
            self.countries.removeAll()
            
            for cred in credentials {
                let id = cred.country.lowercased()
                if let name = self.CountriesLookup[id] {
                    let country = VPNCountry(id: id, name: name, endpoint: cred.serverIP, remoteID: cred.remoteID)
                    self.countries.append(country)
                    self.setCreds(country: country, username: cred.username, password: cred.password)
                }
                self?.observable.on(.next(true))
            }
        }
    }
    */
    
    //MARK:- Public APIs
    //MARK: Credentials
    func setCreds(country: VPNCountry, username: String, password: String) {
        let keychain = DAKeychain.shared
        keychain[country.usernameHash] = username
        keychain[country.passwordHash] = password
    }
    
    func getCredentials(country: VPNCountry) -> Credentials? {
        let keychain = DAKeychain.shared
        if let username = keychain[country.usernameHash],
            let pass = keychain.load(withKey: country.passwordHash)
        {
            return Credentials(username: username, password: pass)
        }
        //initiate a call to get the credentials?
        getVPNCredentialsFromServer()
        return nil
    }
    
    func clearCredentials() {
        for c in self.countries {
            DAKeychain.shared[c.usernameHash] = nil
            DAKeychain.shared[c.passwordHash] = nil
        }
    }
    
    //MARK:- VPN Countries
    var selectedCountry: VPNCountry {
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: SelectedCountryKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let data = UserDefaults.standard.value(forKey: SelectedCountryKey) as? Data, let country = try? PropertyListDecoder().decode(VPNCountry.self, from: data) {
                return country
            }
            return countries.first!
        }
    }
    
    func getAvailableCountries() -> [VPNCountry] {
        return countries
    }
    
}

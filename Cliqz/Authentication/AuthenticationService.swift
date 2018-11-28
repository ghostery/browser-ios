//
//  AuthenticationService.swift
//  Client
//
//  Created by Sahakyan on 11/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import BondAPI

class AuthenticationService {

	enum SubscriptionType {
		case basic
		case trial
		case premium
	}

	private static let registeredEmailKey = "registeredEmail"
	private static let activatedDeviceKey = "deviceActivationState"
	private var subscriptionType: SubscriptionType = .basic

	private let bondService = BondAPIManager.shared.currentBondHandler()
    
    static let shared = AuthenticationService()

    func registerDevice(_ credentials: UserAuth, completion: @escaping (_ isRegistered: Bool, _ errorString: String?) -> Void) {
        let reg = RegisterDeviceRequest()
        reg.auth = credentials
        reg.description_p = "mobile-iOS"
        bondService.registerDevice(with: reg) { (response, err) in
            if let errs = response?.errorArray as? [BondAPI.Error],
				errs.count > 0 {
                for i in errs {	
                    if i.code == BondAPI.ErrorCode.deviceExists {
						self.updateRegisteredEmail(credentials.username)
                        completion(true, nil)
                        print("already registered")
                        break
                    } else {
                        completion(false, "Something went wrong")
                        break
                    }
                }
			} else if err != nil {
                completion(false, "Something went wrong")
            } else {
				self.updateRegisteredEmail(credentials.username)
                completion(true, nil)
            }
        }
    }

    func isDeviceActivated(_ credentials: UserAuth, completion: @escaping (_ isActivated: Bool) -> Void) {
        bondService.isDeviceActivated(withRequest: credentials) { (response, err) in
            if err != nil || response?.errorArray?.count != 0 {
                completion(false)
			} else {
				self.updateDeviceActivationState(true)
				completion(true)
			}
        }
    }

	func isDeviceActivated(_ completion: @escaping (_ isActivated: Bool) -> Void) {
		if let isActivated = self.getDeviceActivationState() {
			completion(isActivated)
		} else {
			completion(false)
		}
	}

	func resendActivationEmail(_ credentials: UserAuth, completion: @escaping (_ isSent: Bool) -> Void) {
		bondService.resendActivationEmail(withRequest: credentials) { (response, error) in
			if error != nil || response?.errorArray?.count != 0 {
				completion(false)
			} else {
				completion(true)
			}
		}
	}

	func updateSubscriptionStatus() {
		if let cred = self.userCredentials() {
			bondService.getSubscriptionWithRequest(cred) { [weak self] (response, error) in
				if let type = response?.subscription.type {
					switch (type) {
					case BondAPI.SubscriptionType.basic:
						self?.subscriptionType = .basic
						break
					case BondAPI.SubscriptionType.trial, BondAPI.SubscriptionType.trialCode:
						self?.subscriptionType = .trial
						break
					case BondAPI.SubscriptionType.premiumMonthly:
						self?.subscriptionType = .premium
						break
					default:
						self?.subscriptionType = .basic
						break
					}
				}
			}
		}
	}
	
	func hasValidSubscription() -> Bool {
		return self.subscriptionType != .basic
	}

	func userCredentials() -> UserAuth? {
		if let email = self.getRegisteredEmail() {
			let cred = UserAuth()
			cred.username = email
			cred.password = self.deviceAuthenticationPass()
			return cred
		}
		return nil
	}

	func generateNewCredentials(_ email: String) -> UserAuth {
		let cred = UserAuth()
		cred.username = email
		cred.password = self.deviceAuthenticationPass()
		return cred
	}

	private func deviceAuthenticationPass() -> String {
		return UIDevice.current.identifierForVendor?.uuidString ?? ""
	}

	private func getRegisteredEmail() -> String? {
		return LocalDataStore.defaults.value(forKey: AuthenticationService.registeredEmailKey) as? String
	}

	func getDeviceActivationState() -> Bool? {
		return LocalDataStore.defaults.value(forKey: AuthenticationService.activatedDeviceKey) as? Bool
	}

	private func updateRegisteredEmail(_ email: String) {
		LocalDataStore.defaults.set(email, forKey: AuthenticationService.registeredEmailKey)
	}

	private func updateDeviceActivationState(_ isActivated: Bool) {
		LocalDataStore.defaults.set(isActivated, forKey: AuthenticationService.activatedDeviceKey)
	}

}

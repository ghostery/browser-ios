//
//  SubscriptionsHandler.swift
//  Client
//
//  Created by Mahmoud Adam on 8/3/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import UIKit

protocol RemoteNotificationDelegate: class {
    func presentViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool)
}


public enum RemoteNotificationType {
    //TODO: Revise how news notification works and refactor the code accordingly
    case newsNotification
    case subscriptoinNotification (String, String, String)
}

public enum SubscriptionType: Int {
    case soccer = 30000
}

class SubscriptionsHandler: NSObject {
    
    //MARK: - Internal Variables & constants
    private let subscriptionsKey = "com.cliqz.subscriptions"
    private var awaitingSubscriptionType: RemoteNotificationType?
    private var subscriptionCompletionHandler: (() -> Void)?
    
    lazy var currentSubscription: [String: [String: [String]]] = {
        return self.loadCurrentSubscriptions()
    }()
    
    //MARK: - Init & Singleton & Constants
    static let sharedInstance = SubscriptionsHandler()
    weak var delegate: RemoteNotificationDelegate?
    
    
    //MARK: - Public APIs
    func configureRemoteNotifications() {
        AWSSNSManager.configureCongnitoPool()
    }
    
    func isSubscribed(withType type: String, subType: String, id: String) -> Bool {
        if let types = currentSubscription[type], let subType = types[subType] {
            return subType.contains(id)
        }
        return false
    }
    
    func subscribeForRemoteNotification(ofType type: RemoteNotificationType, completionHandler: @escaping () -> Void) {
        // prevent to call subscribe multiple times in the same request
        guard awaitingSubscriptionType == nil else {
            return
        }
        
        awaitingSubscriptionType = type
        subscriptionCompletionHandler = completionHandler

        if UIApplication.shared.isRegisteredForRemoteNotifications {
            if isRemoteNotificationEnabled() {
                completeAwatingSubscription()
            } else {
                showEnableNotificationFromSystemAlert()
                self.cancelAwatingSubscription()
                //TelemetryLogger.sharedInstance.logEvent(.Subscription("subscribe", "permission_error",  ["is_success" : false]))
            }
            
        } else {
            showSubscribeAlert()
        }
    }
    
    func unsubscribeForRemoteNotification(ofType type: RemoteNotificationType) {
        switch type {
        case .newsNotification:
            unsubscribeForNewsNotifications()
        case .subscriptoinNotification(let type, let subType, let id):
            deleteSubscription(withType: type, subType: subType, id: id)
            saveCurrentSubscriptions()
        }
    }
    
    func getSubscriptions() -> [String: Any] {
        return currentSubscription
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: String) {

        if #available(iOS 10, *) {
            guard isRemoteNotificationEnabled() else {
                return
            }
        }
        
        showSubscribeHUD()
        AWSSNSManager.createPlatformEndpoint(withDeviceToken: deviceToken,
                                             completionHandler:  { [weak self] (success) -> Void in
            
            FeedbackUI.dismissHUD()
            self?.showSubscribeToast()
            if success {
                self?.completeAwatingSubscription()
            } else {
                self?.showFailedToSubscribeAlert()
                //TelemetryLogger.sharedInstance.logEvent(.Subscription("subscribe", "subscription_error",  ["is_success" : false]))

                print("[RemoteNotifications] Couldn't create plateform endpoint for the current device")
            }
        })
        //TelemetryLogger.sharedInstance.logEvent(.Subscription("click", "permission_alert",  ["target" : "allow"]))
    }
    
    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        self.showFailedToSubscribeAlert()
        //TelemetryLogger.sharedInstance.logEvent(.Subscription("subscribe", "subscription_error",  ["is_success" : false]))
        print("[RemoteNotifications] Couldn't register for remote notificaitons because of the following error: \(error)")
    }
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        //TelemetryLogger.sharedInstance.logEvent(.Notification("silent_receive", "subscription"))
        
        guard let type = userInfo["type"] as? Int, let subscriptionType = SubscriptionType.init(rawValue: type)
            else {
            completionHandler(.failed)
            return
        }
        
        switch subscriptionType {
        case .soccer:
            if let leagueId = userInfo["lid"] as? String,
                let teamIds = userInfo["tids"] as? [String],
                let matchId = userInfo["mid"] as? String,
                let message = userInfo["message"] as? String,
                let url = userInfo["url"] as? String,
                let provider = userInfo["provider"] as? String,
                isSubscribedForSoccerNotification(league: leagueId, teams: teamIds, game: matchId) {
                
                publishLocalNotification(message, url: url, provider: provider)
                completionHandler(.newData)
                
            }
        }
    }
    
    func hasSubscriptions() -> Bool {
        return self.currentSubscription.count > 0
    }
    
    func resetSubscriptions() {
        self.currentSubscription = [String: [String: [String]]]()
        saveCurrentSubscriptions()
    }
    //MARK: - Private Helpers
    
    private func completeAwatingSubscription() {
        guard let subscriptionType = awaitingSubscriptionType, let completionHandler = subscriptionCompletionHandler else {
            return
        }
        
        switch subscriptionType {
        case .newsNotification:
            subscribeForNewsNotifications()
        case .subscriptoinNotification(let type, let subType, let id):
            addSubscription(withType: type, subType: subType, id: id)
        }
        saveCurrentSubscriptions()
        completionHandler()
        
        self.subscriptionCompletionHandler = nil
        self.awaitingSubscriptionType = nil
        //TelemetryLogger.sharedInstance.logEvent(.Subscription("subscribe", nil, ["is_success" : true]))
    }
    
    private func cancelAwatingSubscription() {
        
        self.subscriptionCompletionHandler = nil
        self.awaitingSubscriptionType = nil
    }
    
    private func subscribeForNewsNotifications() {
        //TODO handle subscription for news notification
    }
    
    private func unsubscribeForNewsNotifications() {
        //TODO handle unsubscription for news notification
    }
    
    private func addSubscription(withType type: String, subType: String, id: String) {
        // Step#1: get the data of the corresponding type, i.e. type : soccer
        var types: [String: [String]]! = currentSubscription[type]
        if types == nil {
            types = [String: [String]]()
        }
        
        // Step#2: get the data of the corresponding subType, i.e. subType : game, team, league
        var subTypes: [String]! = types[subType]
        if subTypes == nil {
            subTypes = [String]()
        }
        
        // Step#2: Insert the id into the correct subType object, i.e. id: the id of the game, team, league
        if subTypes.index(of: id) == nil {
            subTypes.append(id)
        }
        
        // update the modified data into the current subscription object
        types[subType] = subTypes
        currentSubscription[type] = types
    }
    
    private func deleteSubscription(withType type: String, subType: String, id: String) {
        guard var types = currentSubscription[type],
            var subTypes = types[subType],
            let index = subTypes.index(of: id) else {
            return
        }
        
        subTypes.remove(at: index)
        
        // update the modified data into the current subscription object
        if subTypes.count == 0 {
            types.removeValue(forKey: subType)
        } else {
            types[subType] = subTypes
        }
        
        if types.count == 0 {
            currentSubscription.removeValue(forKey: type)
        } else {
           currentSubscription[type] = types
        }
        
    }
    
    private func loadCurrentSubscriptions() -> [String: [String: [String]]] {

        if let storedSubscriptions = LocalDataStore.objectForKey(subscriptionsKey) as? [String: [String: [String]]] {
            return storedSubscriptions
        } else {
            return [String: [String: [String]]]()
        }
    }
    
    private func saveCurrentSubscriptions() {
        LocalDataStore.setObject(currentSubscription, forKey: subscriptionsKey)
    }
    
    private func registerForUserNotifications() {
        let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.badge,
                                                                      UIUserNotificationType.sound,
                                                                      UIUserNotificationType.alert],
                                                              categories: nil)
        
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        //TelemetryLogger.sharedInstance.logEvent(.Subscription("show", "permission_alert", nil))
    }

    private func isSubscribedForSoccerNotification(league: String, teams: [String], game: String) -> Bool {

        guard let soccerSubscription = self.currentSubscription["soccer"] else {
            return false
        }
        
        if let leagues = soccerSubscription["league"], leagues.index(of: league) != nil {
            return true
        }
        
        if let subscribedTeams = soccerSubscription["team"] {
            for team in teams {
                if subscribedTeams.index(of: team) != nil {
                    return true
                }
            }
        }
        
        if let games = soccerSubscription["game"], games.index(of: game) != nil {
            return true
        }
        
        return false
    }
    
    private func publishLocalNotification(_ message: String, url: String, provider: String) {
        
        let notification = UILocalNotification()
        notification.fireDate = Date(timeIntervalSinceNow: 1)
        notification.alertBody = "\(message)\n---\npowered by \(provider)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["url": url]
        UIApplication.shared.scheduleLocalNotification(notification)
        
        //TelemetryLogger.sharedInstance.logEvent(.Notification("receive", "subscription"))
    }
    
    private func isRemoteNotificationEnabled() -> Bool {
        let currentUserNotificationSettings = UIApplication.shared.currentUserNotificationSettings
        if let notificationEnabled = currentUserNotificationSettings?.types.contains(.alert) {
            return notificationEnabled
        }
        return false
    }
    
    private func showSubscribeAlert() {
        guard let subscriptionType = awaitingSubscriptionType else {
            return
        }
        
        if case let .subscriptoinNotification(_, subType, _) = subscriptionType {
            
            let parameterizedTitle = NSLocalizedString("Would you like to subscribe to the {1}?", tableName: "Cliqz", comment: "[Subscriptions] Alert title for asking to subscribe for soccer notificaiton")
            let parameterizedMessage = NSLocalizedString("You will be notified about games, goals and important happenings of the {1}.", tableName: "Cliqz", comment: "[Subscriptions] Alert message for asking to subscribe for soccer notificaiton")
            let localizedSubType = NSLocalizedString(subType, tableName: "Cliqz", comment: "[Subscriptions] soccer notification")
            
            let alertTitle = parameterizedTitle.replace("{1}", replacement: localizedSubType)
            let alertMessage = parameterizedMessage.replace("{1}", replacement: localizedSubType)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "Cancel"), style: .default, handler: {[weak self] (_) in
                self?.cancelAwatingSubscription()
                //TelemetryLogger.sharedInstance.logEvent(.Subscription("click", "subscription_alert", ["target" : "cancel"]))
            })
            
            let subscribeAction = UIAlertAction(title: NSLocalizedString("Subscribe", tableName: "Cliqz", comment: "[Subscriptions] Subscribe alert button"), style: .default, handler: {[weak self] (_) in
                
                self?.registerForUserNotifications()
                //TelemetryLogger.sharedInstance.logEvent(.Subscription("click", "subscription_alert", ["target" : "confirm"]))
            })
            displayAlert(alertTitle, message: alertMessage, actions: [cancelAction, subscribeAction])
            //TelemetryLogger.sharedInstance.logEvent(.Subscription("show", "subscription_alert", nil))
        }
        
    }
    
    private func showEnableNotificationFromSystemAlert() {
        
        guard let subscriptionType = awaitingSubscriptionType else {
            return
        }
        
        if case let .subscriptoinNotification(_, subType, _) = subscriptionType {
            
            let parameterizedTitle = NSLocalizedString("Could not subscribe to {1}.", tableName: "Cliqz", comment: "[Subscriptions] Alert title for asking to enable push notificaiton from the system")
            let localizedSubType = NSLocalizedString(subType, tableName: "Cliqz", comment: "[Subscriptions] soccer notification")
            
            let alertTitle = parameterizedTitle.replace("{1}", replacement: localizedSubType)
            
            let alertMessage = NSLocalizedString("Activate push notification to use this feature. Go to settings to allow push notifications then retry.", tableName: "Cliqz", comment: "[Subscriptions] Alert message  for asking to enable push notificaiton from the system")
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "Cancel"), style: .default, handler: {(_) in
                //TelemetryLogger.sharedInstance.logEvent(.Subscription("click", "permission_alert", ["target" : "cancel"]))
            })
            
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", tableName: "Cliqz", comment: "[Subscriptions] Subscribe alert button"), style: .default, handler: {(_) in
                
                if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(settingsUrl)
                }
                //TelemetryLogger.sharedInstance.logEvent(.Subscription("click", "permission_alert", ["target" : "settings"]))
            })
            displayAlert(alertTitle, message: alertMessage, actions: [cancelAction, settingsAction])
            //TelemetryLogger.sharedInstance.logEvent(.Subscription("show", "permission_alert", nil))
        }
    }
    
    private func showFailedToSubscribeAlert() {
        
        guard let subscriptionType = awaitingSubscriptionType else {
            return
        }
        
        if case let .subscriptoinNotification(_, subType, _) = subscriptionType {
            
            let parameterizedTitle = NSLocalizedString("Could not subscribe to {1}.", tableName: "Cliqz", comment: "[Subscriptions] Alert title when failing to subscribe to soccer notification")
            let localizedSubType = NSLocalizedString(subType, tableName: "Cliqz", comment: "[Subscriptions] soccer notification")
            
            let alertTitle = parameterizedTitle.replace("{1}", replacement: localizedSubType)
            
            let alertMessage = NSLocalizedString("Sorry, we encountered some technical difficulties. Please try again", tableName: "Cliqz", comment: "[Subscriptions] Alert message when failing to subscribe to soccer notification")
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "Cancel"), style: .default, handler: {[weak self] (_) in
                self?.cancelAwatingSubscription()
                //TelemetryLogger.sharedInstance.logEvent(.Subscription("click", "subscription_error", ["target" : "cancel"]))
            })
            
            let settingsAction = UIAlertAction(title: NSLocalizedString("Retry", tableName: "Cliqz", comment: "[Subscriptions] Retry alert button"), style: .default, handler: {[weak self] (_) in
                self?.registerForUserNotifications()
                //TelemetryLogger.sharedInstance.logEvent(.Subscription("click", "subscription_error", ["target" : "retry"]))
            })
            displayAlert(alertTitle, message: alertMessage, actions: [cancelAction, settingsAction])
            //TelemetryLogger.sharedInstance.logEvent(.Subscription("show", "subscription_error", nil))
        }
    }
    
    private func displayAlert(_ title: String, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.presentViewController(alertController, animated: true)
        }
        
    }
    
    private func showSubscribeHUD() {
        guard let subscriptionType = awaitingSubscriptionType else {
            return
        }
        
        if case let .subscriptoinNotification(_, subType, _) = subscriptionType {
            
            let parameterizedMessage = NSLocalizedString("Subscribing to {1}.", tableName: "Cliqz", comment: "[Subscriptions] Subscribing HUD")
            let localizedSubType = NSLocalizedString(subType, tableName: "Cliqz", comment: "[Subscriptions] soccer notification")
            let message = parameterizedMessage.replace("{1}", replacement: localizedSubType)
            FeedbackUI.showLoadingHUD(message)
        }
        
    }
    
    private func showSubscribeToast() {
        let message = NSLocalizedString("Currently, push notifications are only received if Cliqz is active.", tableName: "Cliqz", comment: "[Subscriptions] Subscribing Toast")
        FeedbackUI.showToastMessage(message, messageType: .info, timeInterval: 4.0)

    }
}

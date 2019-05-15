//
//  NotificationsManager.swift
//  Client
//
//  Created by Pavel Kirakosyan on 14.05.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import UserNotifications
import Shared

private enum SubscriptionReminderOption: Int, CaseIterable {
    case dayThree = 3
    case daySeven = 7
    case dayNine = 9
    case dayTwenty = 20
    
    func identifier() -> String {
        return String("SubscriptionReminderAtDay\(self.rawValue)")
    }
}

class UserNotificationsManager: NSObject {
    
    private let subscriptionReminderCategoryKey = "cliqz.subscriptionReminderCategory"
    
    func requestAuthorization() {
        if #available(iOS 12.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.provisional, .alert, .sound]) { _,_  in }
            
            self.registerNotificationCategories()
        }
    }
    
    func scheduleNotifications() {
        if #available(iOS 12.0, *) {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { (setting) in
                if setting.authorizationStatus == .provisional || setting.authorizationStatus == .authorized {
                    self.removeAllScheduledNotificaions()
                    self.addNotificationRequests()
                } else {
                    print("notification authorization status - \(setting.authorizationStatus.rawValue)")
                }
            }
        }
    }
    
    func removeAllScheduledNotificaions() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: private methods
    private func addNotificationRequests() {
        let center = UNUserNotificationCenter.current()
        let requests = self.createNotificationReqeusts()
        for request in requests {
            center.add(request) { (error) in
                if let error = error {
                    print("error \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func registerNotificationCategories() {
        let subscriptionReminderCategory = UNNotificationCategory(identifier: self.subscriptionReminderCategoryKey, actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([subscriptionReminderCategory])
    }
    
    private func createNotificationReqeusts() -> [UNNotificationRequest] {
        let currentSubscription = SubscriptionController.shared.getCurrentSubscription()
        switch currentSubscription {
        case .limited, .trial(_):
            return self.createSubscriptionReminderRequests()
        default:
            return []
        }
    }
    
    private func createSubscriptionReminderRequests() -> [UNNotificationRequest] {
        guard let installationDate = DeviceInfo.appInstallationDate() else  {
            return []
        }
        var requests:[UNNotificationRequest] = []
        let subscriptionReminderDays = SubscriptionReminderOption.allCases
        for day in subscriptionReminderDays {
            if let scheduleDate = self.createScheduleDate(byAdding: day.rawValue, to: installationDate), let request = self.createSubscriptionReminderRequest(triggerDate: scheduleDate, option: day) {
                requests.append(request)
            }
        }
        
        return requests
    }
    
    private func createSubscriptionReminderRequest(triggerDate: Date, option: SubscriptionReminderOption) -> UNNotificationRequest? {
        guard triggerDate.compare(Date()) == .orderedDescending else {
            return nil
        }
        
        let content = UNMutableNotificationContent()
        content.body = NSLocalizedString("Limited time offer: 50% off for Lumen protection + VPN. Code: LUMEN2019", tableName: "Lumen", comment: "Local Notification message")
        content.sound = UNNotificationSound.default()

        let timeInterval = triggerDate.timeIntervalSince(Date())
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        return UNNotificationRequest(identifier: option.identifier(), content: content, trigger: trigger)
    }
    
    private func createScheduleDate(byAdding days: Int, to date: Date) -> Date? {
        let calendar = Calendar.current
        let triggerDate = calendar.date(byAdding: .day, value: days, to: date)
        var dateComponent = calendar.dateComponents([.day, .year, .month, .timeZone, .calendar], from: triggerDate!)
        dateComponent.hour = 9
        return calendar.date(from: dateComponent)
    }
}

extension UserNotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        LegacyTelemetryHelper.logPush(action: "click", topic: "discount")
    }
}

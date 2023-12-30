//
//  NotificationsHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/11/23.
//

import Foundation
import UserNotifications

class NotificationsHandler {

    
    static func scheduleNotificationsForRemindingToUpload() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "It's been a minute"
        content.body = "Just a little reminder to come back and upload any new files."
        content.categoryIdentifier = "recall"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 2
        dateComponents.month = 1
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
}

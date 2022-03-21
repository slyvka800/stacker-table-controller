//
//  NotificationService.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 13.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService {
    
    enum NotificationType {
        case goingUp
        case goingDown
    }
    
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    func sendNotification(notificationType: NotificationType) {
        requestAuthorization()
        
        var notificationMessage = ""
        
        switch notificationType {
        case .goingUp:
            notificationMessage = "⚡️ Table is about to go UP!"
        case .goingDown:
            notificationMessage = "💫 Table is about to go DOWN!"
        }
        
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                
                let content = UNMutableNotificationContent()
                content.title = notificationMessage
                content.subtitle = "You can prevent it"
                content.sound = UNNotificationSound.defaultCritical
                content.categoryIdentifier = "skipMovementAction"
                
//                let skip = UNNotificationAction(identifier: "skip", title: "Skip", options: [])
                let postpone = UNNotificationAction(identifier: "postpone", title: "Delay for 5 mins", options: [])
                
                let category = UNNotificationCategory(identifier: "skipMovementAction", actions: [postpone], intentIdentifiers: [], options: [])
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                let id = "timeIsUp"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                self.notificationCenter.setNotificationCategories([category])
                
                self.notificationCenter.add(request, withCompletionHandler: { error in
                    if error != nil { print(error?.localizedDescription as Any) }
                })
            }
        }
    }
    
    private func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
            if authorized {
                print("Notifications are allowed")
            } else if !authorized {
                print("Notifications are prohibited")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
}

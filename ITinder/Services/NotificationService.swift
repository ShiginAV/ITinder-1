//
//  NotificationService.swift
//  ITinder
//
//  Created by Grifus on 30.08.2021.
//

import Foundation
import UserNotifications

class NotificationService {
    
    static func sendNotification(title: String?, message: String, companion: CompanionStruct?, completion: @escaping (_ request: UNNotificationRequest) -> Void) {
        
        let content = UNMutableNotificationContent()
        
        if let title = title {
            content.title = title
        } else if let companion = companion, let name = companion.userName {
            content.title = name
            content.categoryIdentifier = companion.userId
        }
        
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        completion(request)
    }
    
}

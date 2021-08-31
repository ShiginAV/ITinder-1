//
//  NotificationService.swift
//  ITinder
//
//  Created by Grifus on 30.08.2021.
//

import Foundation
import UserNotifications

class NotificationService {
    
    static func sendNotification(companionName: String, message: String, completion: @escaping (_ request: UNNotificationRequest) -> Void) {
        
        let content = UNMutableNotificationContent()
        
        content.title = companionName
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        completion(request)
    }
    
}

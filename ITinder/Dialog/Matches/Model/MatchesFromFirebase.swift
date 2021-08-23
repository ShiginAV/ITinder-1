//
//  MatchesDelegate.swift
//  ITinder
//
//  Created by Grifus on 07.08.2021.
//

import Foundation
import Firebase

protocol MatchesDelegate: AnyObject {
    func reloadTable()
    func sendNotification(request: UNNotificationRequest)
    func setAllVisible()
}

class MatchesFromFirebase {
    
    weak var delegate: MatchesDelegate?
    
    let lock = NSLock()
    let group = DispatchGroup()
    
    var companions = [CompanionStruct]() {
        didSet {
            lock.lock()
            allCompanionsUpdate()
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
                self.lock.unlock()
            }
        }
    }
    
    var newCompanions = [CompanionStruct]()
    
    var oldCompanions = [CompanionStruct]()
    
    var lastMessages = [String: String]() {
        didSet {
            allCompanionsUpdate()
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
            }
        }
    }
    
    var notificationFlag = false
    let startGroup = DispatchGroup()
    
    var downloadedPhoto = [String: UIImage]() {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
            }
        }
    }
    
    init(user: User) {
        let currentUserPhotoUrl = user.imageUrl
        let currentUserId = user.identifier
        
        downloadPhoto(photoUrl: currentUserPhotoUrl, userId: currentUserId)
        
        ConversationService.getConversations(userId: currentUserId) { [weak self] (conversations) in
            
            var conv = conversations
            
            if let notifyFlag = self?.notificationFlag {
                if conv.count > self?.companions.count ?? 0 && notifyFlag {
                    self?.sendNotification(companionName: "Пара!", message: "У вас есть новая пара!")
                }
            }
            
            for index in 0..<conv.count {
                self?.startGroup.enter()
                
                self?.getLastMessage(conv: conv, index: index)
                
                self?.getUserData(conv: conv, index: index) { (user) in
                    conv[index].userName = user.name
                    conv[index].imageUrl = user.imageUrl
                    self?.companions = conv
                    self?.startGroup.leave()
                }
            }
            
            self?.startGroup.notify(queue: .main) {
                self?.notificationFlag = true
                self?.delegate?.setAllVisible()
            }
        }
    }
    // MARK: - Firebase data
    
    private func getLastMessage(conv: [CompanionStruct], index: Int) {
        ConversationService.getLastMessage(conversationId: conv[index].conversationId, completion: { [weak self] (lastMessage) in
            self?.lastMessages[conv[index].conversationId] = lastMessage
        })
    }
    
    private func getUserData(conv: [CompanionStruct], index: Int, completion: @escaping (User) -> Void) {
        
        ConversationService.getUserData(userId: conv[index].userId) { [weak self] (user) in
            
            if let notifyFlag = self?.notificationFlag {
                if !conv[index].lastMessageWasRead && notifyFlag {
                    self?.sendNotification(companionName: user.name, message: "У вас новое сообщение от \(user.name)")
                }
            }

            let userId = conv[index].userId

            self?.downloadPhoto(photoUrl: user.imageUrl, userId: userId)

            completion(user)
        }
    }
    
    private func downloadPhoto(photoUrl: String?, userId: String) {
        guard let photo = photoUrl else { return }
        ConversationService.downloadPhoto(stringUrl: photo, userId: userId) { (data) in
            self.downloadedPhoto[userId] = UIImage(data: data)
        }
    }
    
    func deleteMatch(currentUserId: String, companionId: String, conversationId: String) {
        ConversationService.deleteMatch(currentUserId: currentUserId, companionId: companionId, conversationId: conversationId)
    }
    
    // MARK: - Logic
    
    private func allCompanionsUpdate() {
        var forOldCompanions = [CompanionStruct]()
        var forNewCompanions = [CompanionStruct]()
        for user in companions {
            if lastMessages[user.conversationId] != nil {
                forOldCompanions.append(user)
            } else {
                forNewCompanions.append(user)
            }
        }
        newCompanions = forNewCompanions
        oldCompanions = forOldCompanions
    }
    
    private func sendNotification(companionName: String, message: String) {
        let content = UNMutableNotificationContent()
        
        content.title = companionName
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        delegate?.sendNotification(request: request)
    }
    
}

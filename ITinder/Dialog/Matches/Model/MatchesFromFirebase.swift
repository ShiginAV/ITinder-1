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
    
    let group = DispatchGroup()
    
    var companions = [String: CompanionStruct]() {
        didSet {
            
            if oldValue.count != companions.count {
                ConversationService.removeConversationsObserver()
                
                let group = DispatchGroup()
                companions.forEach { (companion) in
                    let companion = companion.value
                    startNotificationFlag = false
                    
                    if !startNotificationFlag {
                        group.enter()
                    }
                    createLastMessageObserver(companionData: companion, completion: {
                        if !self.startNotificationFlag {
                            group.leave()
                        }
                    })
                }
                
                group.notify(queue: .main) {
                    self.startNotificationFlag = true
                }
                
            }
            
            allCompanionsUpdate()
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
                self.startMatchNotifyFlag = true
            }
        }
    }
    
    var newCompanions = [CompanionStruct]() {
        didSet {
            newCompanions.sort {
                $0.userId > $1.userId
            }
        }
    }
    
    var oldCompanions = [CompanionStruct]() {
        didSet {
            newCompanions.sort {
                $0.userId > $1.userId
            }
        }
    }
    
    var lastMessages = [String: String]() {
        didSet {
            allCompanionsUpdate()
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
            }
        }
    }
    
    var startNotificationFlag = false
    var startMatchNotifyFlag = false
    var allowMessageNotificationOnScreen = true
    
    let startGroup = DispatchGroup()
    
    var downloadedPhoto = [String: UIImage]() {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
            }
        }
    }
    
    init(user: User) {
        downloadPhoto(photoUrl: user.imageUrl, userId: user.identifier)
        
        ConversationService.conversationsObserver(userId: user.identifier) { [weak self] (conversations) in
            
            var conv = [String: CompanionStruct]()
            
            if let notifyFlag = self?.startMatchNotifyFlag {
                if conversations.count > self?.companions.count ?? 0 && notifyFlag {
                    self?.sendNotification(title: "Пара!", message: "У вас есть новая пара!")
                }
            }
            
            conversations.forEach { (companion) in
                var currentCompanion = companion
                
                self?.startGroup.enter()
                
                self?.getUserData(companionId: companion.userId) { (user) in
                    currentCompanion.userName = user.name
                    currentCompanion.imageUrl = user.imageUrl
                    
                    conv[companion.userId] = currentCompanion
                    self?.startGroup.leave()
                }
            }
            
            self?.startGroup.notify(queue: .main) {
                self?.companions = conv
                self?.delegate?.setAllVisible()
            }
        }

    }
    // MARK: - Firebase data
    
    private func createLastMessageObserver(companionData: CompanionStruct, completion: @escaping () -> Void) {
        ConversationService.createLastMessageObserver(conversationId: companionData.conversationId, completion: { [weak self] (lastMessageText) in
            
            self?.lastMessages[companionData.conversationId] = lastMessageText
            
            guard let lastMessageText = lastMessageText else {
                completion()
                return }
            
            guard let startNotifyFlag = self?.startNotificationFlag else { return }
            guard let screenNotifyFlag = self?.allowMessageNotificationOnScreen else { return }
            if startNotifyFlag && screenNotifyFlag {
                self?.sendNotification(companion: companionData, message: lastMessageText)
            }
            completion()
        })
    }
    
    private func getUserData(companionId: String, completion: @escaping (User) -> Void) {
        
        UserService.getUserBy(id: companionId) { [weak self] (user) in
            guard let user = user else { return }
            self?.downloadPhoto(photoUrl: user.imageUrl, userId: companionId)
            completion(user)
        }
    }
    
    private func downloadPhoto(photoUrl: String?, userId: String) {
        guard let photo = photoUrl, photoUrl != "" else { return }
        ConversationService.downloadPhoto(stringUrl: photo) { (data) in
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
        for user in companions.values {
            if lastMessages[user.conversationId] != nil {
                forOldCompanions.append(user)
            } else {
                forNewCompanions.append(user)
            }
        }
        newCompanions = forNewCompanions
        oldCompanions = forOldCompanions
    }
    
    func sendNotification(title: String, message: String) {
        NotificationService.sendNotification(title: title, message: message, companion: nil) { (request) in
            self.delegate?.sendNotification(request: request)
        }
    }
    
    func sendNotification(companion: CompanionStruct, message: String) {
        NotificationService.sendNotification(title: nil, message: message, companion: companion) { (request) in
            self.delegate?.sendNotification(request: request)
        }
    }

}

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
            
            if oldValue.count != companions.count {
                ConversationService.removeConversationsObserver()
                startNotificationFlag = false
                let group = DispatchGroup()
                companions.forEach { (companion) in
                    
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
    
    var startNotificationFlag = false
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
        
        ConversationService.getConversations(userId: user.identifier) { [weak self] (conversations) in
            
            var conv = conversations
            
            if let notifyFlag = self?.startNotificationFlag {
                if conv.count > self?.companions.count ?? 0 && notifyFlag {
                    self?.sendNotification(companionName: "Пара!", message: "У вас есть новая пара!")
                }
            }
            
            for index in 0..<conv.count {
                
                self?.startGroup.enter()
                
                self?.getUserData(conv: conv, index: index) { (user) in
                    conv[index].userName = user.name
                    conv[index].imageUrl = user.imageUrl
                    
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
                self?.sendNotification(companionName: companionData.userName ?? "", message: lastMessageText)
            }
            completion()
        })
    }
    
    private func getUserData(conv: [CompanionStruct], index: Int, completion: @escaping (User) -> Void) {
        
        UserService.getUserBy(id: conv[index].userId) { [weak self] (user) in
            guard let user = user else { return }
            let userId = conv[index].userId
            self?.downloadPhoto(photoUrl: user.imageUrl, userId: userId)
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
    
    func sendNotification(companionName: String, message: String) {
        
        let content = UNMutableNotificationContent()
        
        content.title = companionName
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        delegate?.sendNotification(request: request)
    }
    
}

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
        willSet {
//            lock.lock()
//            lock.unlock()
        }
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
    
    init(currentUserPhotoUrl: String, currentUserId: String) {
        
        downloadPhoto(photoUrl: currentUserPhotoUrl, userId: currentUserId)
        
        FirebaseService.getConversations(userId: currentUserId) { [weak self] (conversations) in
            
            var conv = conversations
            
            if let notifyFlag = self?.notificationFlag {
                if conv.count > self?.companions.count ?? 0 && notifyFlag {
                    print("You have a new match")
                    self?.sendNotification(companionName: "Match!", message: "You have a new match!")
                }
            }
            
            for index in 0..<conv.count {
                self?.startGroup.enter()
                
                self?.getLastMessage(conv: conv, index: index)
                
                self?.getUserData(conv: conv, index: index) { (name, photoUrl) in
                    conv[index].userName = name
                    conv[index].imageUrl = photoUrl
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
    
    func getLastMessage(conv: [CompanionStruct], index: Int) {
        FirebaseService.getLastMessage(conversationId: conv[index].conversationId, completion: { [weak self] (lastMessage) in
            self?.lastMessages[conv[index].conversationId] = lastMessage
        })
    }
    
    func getUserData(conv: [CompanionStruct], index: Int, completion: @escaping (String?, String?) -> Void) {
        FirebaseService.getUserData(userId: conv[index].userId) { [weak self] (name, photoUrl) in
            
            if let notifyFlag = self?.notificationFlag {
                if !conv[index].lastMessageWasRead && notifyFlag {
                    print("was not read")
                    self?.sendNotification(companionName: name!, message: "You have a massage from \(name!)")
                }
            }
            
            let userId = conv[index].userId
            
            self?.downloadPhoto(photoUrl: photoUrl, userId: userId)
            
            completion(name, photoUrl)
        }
    }
    
    func downloadPhoto(photoUrl: String?, userId: String) {
        guard let photo = photoUrl else { return }
        FirebaseService.downloadPhoto(stringUrl: photo, userId: userId) { (data) in
            self.downloadedPhoto[userId] = UIImage(data: data)
        }
    }
    
    func deleteMatch(currentUserId: String, companionId: String, conversationId: String) {
        FirebaseService.deleteMatch(currentUserId: currentUserId, companionId: companionId, conversationId: conversationId)
    }
    
    // MARK: - Logic
    
    func allCompanionsUpdate() {
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

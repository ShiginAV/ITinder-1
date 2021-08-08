//
//  MatchesDelegate.swift
//  ITinder
//
//  Created by Grifus on 07.08.2021.
//

import Foundation
import Firebase

struct CompanionStruct {
    var userName: String?
    var userId: String
    var conversationId: String
    var imageUrl: String?
}

protocol MatchesDelegate: AnyObject {
    func reloadTable()
}

class MatchesFromFirebase {
    
    weak var delegate: MatchesDelegate?
    
    var companions = [CompanionStruct]() {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
            }
        }
    }
    
    var lastMessages = [String: String]() {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
            }
        }
    }
    
    var downloadedPhoto = [String: UIImage]() {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.reloadTable()
            }
        }
    }
    
    init(currentUserPhotoUrl: String, currentUserId: String) {
        
        downloadPhoto(stringUrl: currentUserPhotoUrl, userId: currentUserId)
        
        getConversations(userId: currentUserId) { [weak self] (conversations) in
            var conv = conversations
            for index in 0..<conv.count {
                
                self?.getLastMessage(conversationId: conv[index].conversationId, completion: { (lastMessage) in
                    self?.lastMessages[conv[index].conversationId] = lastMessage
                })
                
                self?.getUserData(userId: conv[index].userId) { (name, photoUrl) in
                    conv[index].userName = name
                    conv[index].imageUrl = photoUrl
                    self?.companions.append(conv[index])
                    self?.downloadPhoto(stringUrl: photoUrl!, userId: conv[index].userId)
                }
            }
        }
    }
    
    func downloadPhoto(stringUrl: String, userId: String) {
        let reference = Storage.storage().reference(forURL: stringUrl)
        let megaBytes = Int64(1024 * 1024 * 10)
        reference.getData(maxSize: megaBytes) { (data, _) in
            guard let data = data else { return }
            self.downloadedPhoto[userId] = UIImage(data: data)
        }
    }
    
    func getConversations(userId: String, completion: @escaping ([CompanionStruct]) -> Void) {
        Database.database().reference().child("users").child(userId).child("conversations").observe(.value) { (snapshot) in
            var conversations = [CompanionStruct]()
            for conversation in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = conversation.key
                let convId = conversation.value as! String
                conversations.append(CompanionStruct(userId: userId, conversationId: convId))
            }
            completion(conversations)
        }
    }
    
    func getUserData(userId: String, completion: @escaping (_ name: String?, _ photoUrl: String?) -> Void) {
        Database.database().reference().child("users").getData { (error, snapshot) in
            let userDataSnap = snapshot.childSnapshot(forPath: userId).childSnapshot(forPath: "data")
            
            let name = userDataSnap.childSnapshot(forPath: "name").value as? String
            let photoUrl = userDataSnap.childSnapshot(forPath: "photoUrl").value as? String
            completion(name, photoUrl)
        }
    }
    
    func getLastMessage(conversationId: String, completion: @escaping (String) -> Void) {
        Database.database().reference().child("conversations").child(conversationId).observe(.value) { (snapshot) in
            guard let lastMessageId = snapshot.childSnapshot(forPath: "lastMessage").value as? String else { return }
            guard let lastMessageText = snapshot.childSnapshot(forPath: "messages").childSnapshot(forPath: lastMessageId).childSnapshot(forPath: "text").value as? String else { return }
            completion(lastMessageText)
        }
    }
}

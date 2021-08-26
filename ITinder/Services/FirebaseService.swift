//
//  ConversationDatabaseService.swift
//  ITinder
//
//  Created by Grifus on 11.08.2021.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ConversationService {
    
    static func getCurrentUser(completion: @escaping (User) -> Void ) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        getUserData(userId: currentUserId) { (user) in
            completion(user)
        }
    }
    
    static func getConversations(userId: String, completion: @escaping ([CompanionStruct]) -> Void) {
        Database.database().reference().child("users").child(userId).child("conversations").observe(.value) { (snapshot) in
            var conversations = [CompanionStruct]()
            guard let dialogs = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for conversation in dialogs {
                let userId = conversation.key
                guard let convId = conversation.childSnapshot(forPath: "conversationId").value as? String else { return }
                guard let lastMessageWasRead = conversation.childSnapshot(forPath: "lastMessageWasRead").value as? Bool else { return }
                conversations.append(CompanionStruct(userId: userId, conversationId: convId, lastMessageWasRead: lastMessageWasRead))
            }
            completion(conversations)
        }
    }
    
    static func downloadPhoto(stringUrl: String, completion: @escaping (Data) -> Void) {
        let reference = Storage.storage().reference(forURL: stringUrl)
        let megaBytes = Int64(1024 * 1024 * 10)
        reference.getData(maxSize: megaBytes) { (data, error) in
            guard let data = data else { return }
            completion(data)
        }
    }
    
    static func getUserData(userId: String, completion: @escaping (User) -> Void) {
        Database.database().reference().getData { (error, snapshot) in
            if error != nil { return }
            let userDataSnap = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: userId)
            
            guard let userData = userDataSnap.value as? [String: Any] else { return }
            let user = User(dictionary: userData)
            completion(user)
        }
    }
    
    static func getLastMessage(conversationId: String, completion: @escaping (String?) -> Void) {
        Database.database().reference().child("conversations").child(conversationId).observe(.value) { (snapshot) in
            let lastMessageId = snapshot.childSnapshot(forPath: "lastMessage").value as? String
            let lastMessageText = snapshot.childSnapshot(forPath: "messages").childSnapshot(forPath: lastMessageId ?? "1").childSnapshot(forPath: "text").value as? String
            completion(lastMessageText)
        }
    }
    
    static func deleteMatch(currentUserId: String, companionId: String, conversationId: String) {
        Database.database().reference().child("users").child(currentUserId).child("conversations").child(companionId).setValue(nil)
        Database.database().reference().child("users").child(companionId).child("conversations").child(currentUserId).setValue(nil)
        Database.database().reference().child("conversations").child(conversationId).setValue(nil)
    }
    
    static func createMessage(convId: String, text: String, selfSender: Sender, companionId: String) {
        let messageId = UUID()
        let referenceConversation = Database.database().reference().child("conversations")
        
        let date = convertStringFromDate()
        
        referenceConversation.child(convId).child("messages").child(messageId.uuidString).updateChildValues(["date": date,
                                                                                                             "messageId": messageId.uuidString,
                                                                                                             "sender": selfSender.senderId,
                                                                                                             "messageType": "text",
                                                                                                             "text": text])
        referenceConversation.child(convId).child("lastMessage").setValue(messageId.uuidString)
        Database.database().reference().child("users").child(companionId).child("conversations").child(selfSender.senderId).child("lastMessageWasRead").setValue(false)
    }
    
    static func createMessage(convId: String, image: UIImage, selfSender: Sender, companionId: String) {
        
        let messageId = UUID()
        let referenceConversation = Database.database().reference().child("conversations")
        
        let date = convertStringFromDate()
        
        guard let image = image.jpegData(compressionQuality: 0.5) else { return }
        
        let metadata1 = StorageMetadata()
        metadata1.contentType = "image/jpeg"
        
        let ref = Storage.storage().reference().child(convId).child(messageId.uuidString).child("Attachment")
        
        ref.putData(image, metadata: metadata1) { (metadata, _) in
            ref.downloadURL { (url, _) in
                referenceConversation.child(convId).child("messages").child(messageId.uuidString).updateChildValues(["date": date,
                                                                                                                     "messageId": messageId.uuidString,
                                                                                                                     "sender": selfSender.senderId,
                                                                                                                     "messageType": "photo",
                                                                                                                     "attachment": url?.absoluteString ?? "",
                                                                                                                     "text": "Вложение"])
                
                referenceConversation.child(convId).child("lastMessage").setValue(messageId.uuidString)
                Database.database().reference().child("users").child(companionId).child("conversations").child(selfSender.senderId).child("lastMessageWasRead").setValue(false)
            }
        }
    }
    
    static func messagesFromConversations(conversationId: String, messagesComplition: @escaping () -> ([String: Message]), completion: @escaping ([String: Message]) -> Void) {
        
        Database.database().reference().child("conversations").child(conversationId).child("messages").observe(.value) { (snapshot) in
            
            guard snapshot.exists() else { return }
            
            var messagesFromFirebase = messagesComplition()
            
            let internetMessages = snapshot
            
            var senders = [String: Sender]()
            let group = DispatchGroup()
            
            guard let messages = internetMessages.children.allObjects as? [DataSnapshot] else { return }
            
            for oneMessage in messages {
                
                guard let oneMessage = oneMessage.value as? [String: Any] else { return }
                let message = MessageStruct(dictionary: oneMessage)
                
                guard let date = convertStringToDate(stringDate: message.date) else { return }
                
                if messagesFromFirebase[message.messageId] != nil { continue }
                
                let senderId = message.sender
                
                if senders[senderId] == nil {
                    group.enter()
                    getUserData(userId: senderId) { (user) in
                        
                        senders[senderId] = Sender(photoUrl: user.imageUrl, senderId: user.identifier, displayName: user.name)
                        group.leave()
                    }
                }
                group.wait()
                
                var currentMessage: Message!
                if message.messageType == "text" {
                    
                    currentMessage = Message(sender: senders[senderId]!,
                                             messageId: message.messageId,
                                             sentDate: date,
                                             kind: .text(message.text))
                    messagesFromFirebase[currentMessage.messageId] = currentMessage
                    completion(messagesFromFirebase)
                    
                } else if message.messageType == "photo" {
                    
                    messagesFromFirebase[message.messageId] = Message(
                        sender: senders[senderId]!,
                        messageId: message.messageId,
                        sentDate: date,
                        kind: .photo(MyMedia(image: UIImage(named: "birth_date_icon") ?? UIImage(), placeholderImage: UIImage(), size: CGSize(width: 150, height: 150))))
                    
                    downloadPhoto(stringUrl: message.attachment) { (data) in
                        let media = MyMedia(image: UIImage(data: data) ?? UIImage(), placeholderImage: UIImage(named: "birth_date_icon") ?? UIImage(), size: CGSize(width: 150, height: 150))
                        
                        currentMessage = Message(sender: senders[senderId]!,
                                                 messageId: message.messageId,
                                                 sentDate: date,
                                                 kind: .photo(media))
                        messagesFromFirebase[message.messageId] = currentMessage
                        completion(messagesFromFirebase)
                    }
                }
            }
        }
    }
    
    static func setLastMessageWasRead(currentUserId: String, companionId: String) {
        Database.database().reference().child("users").child(currentUserId).child("conversations").child(companionId).child("lastMessageWasRead").setValue(true)
    }
    
    static private func convertStringFromDate() -> String {
        let date = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
        return dateFormater.string(from: date)
    }
    
    static private func convertStringToDate(stringDate: String) -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "en_US_POSIX")
        dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
        guard let date = dateFormater.date(from: stringDate) else { return nil }
        return date
    }
    
    static func createMatchConversation(currentUserId: String, companionId: String) {
        let newConversationId = UUID().uuidString
        let currentUserRef = Database.database().reference().child("users").child(currentUserId).child("conversations").child(companionId)
        
        let group = DispatchGroup()
        
        var escape = false
        
        group.enter()
        currentUserRef.getData { (error, snapshot) in
            if snapshot.exists() {
                escape = true
            }
            group.leave()
        }
        
        group.wait()
        if escape {
            return
        }
        
        currentUserRef.child("conversationId").setValue(newConversationId)
        currentUserRef.child("lastMessageWasRead").setValue(true)
        
        let companionUserRef = Database.database().reference().child("users").child(companionId).child("conversations").child(currentUserId)
        
        companionUserRef.child("conversationId").setValue(newConversationId)
        companionUserRef.child("lastMessageWasRead").setValue(true)
    }
    
}

//
//  ConversationDatabaseService.swift
//  ITinder
//
//  Created by Grifus on 11.08.2021.
//

import Foundation
import Firebase

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
            for conversation in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = conversation.key
                let convId = conversation.childSnapshot(forPath: "conversationId").value as! String
                let lastMessageWasRead = conversation.childSnapshot(forPath: "lastMessageWasRead").value as! Bool
                conversations.append(CompanionStruct(userId: userId, conversationId: convId, lastMessageWasRead: lastMessageWasRead))
            }
            completion(conversations)
        }
    }
    
    static func downloadPhoto(stringUrl: String, userId: String, completion: @escaping (Data) -> Void) {
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
            let name = userDataSnap.childSnapshot(forPath: "name").value as? String
            let photoUrl = userDataSnap.childSnapshot(forPath: "imageUrl").value as? String

            guard let userDataTest = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: userId).value as? [String: Any] else { return }
            let user = User(dictionary: userDataTest)
            print(user)
            completion(user)
//            completion(name, photoUrl)
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
        
        referenceConversation.child(convId).child("messages").child(messageId.uuidString).updateChildValues(["date": date, "messageId": messageId.uuidString, "sender": selfSender.senderId, "text": text])
        referenceConversation.child(convId).child("lastMessage").setValue(messageId.uuidString)
        Database.database().reference().child("users").child(companionId).child("conversations").child(selfSender.senderId).child("lastMessageWasRead").setValue(false)
    }
    
    static func messagesFromConversations(conversationId: String, completion: @escaping ([Message]) -> Void) {
        Database.database().reference().observe(.value) { (snapshot) in
            guard snapshot.exists() else { return }
            var messagesFromFirebase = [Message]()
            
            let internetMessages = snapshot.childSnapshot(forPath: "conversations").childSnapshot(forPath: conversationId).childSnapshot(forPath: "messages")
            
            for message in internetMessages.children.allObjects as! [DataSnapshot] {
                let senderData = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: message.childSnapshot(forPath: "sender").value as! String)
                
                let senderName = senderData.childSnapshot(forPath: "name").value as! String
                let senderPhotoUrl = senderData.childSnapshot(forPath: "imageUrl").value as! String
                let senderId = message.childSnapshot(forPath: "sender").value as! String
                
                let sender = Sender(photoUrl: senderPhotoUrl, senderId: senderId, displayName: senderName)
                
                let messageId = message.childSnapshot(forPath: "messageId").value as! String
                let text = message.childSnapshot(forPath: "text").value as! String
                let stringDate = message.childSnapshot(forPath: "date").value as! String
                
                let date = convertStringToDate(stringDate: stringDate)
                
                let currentMessage = Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(text))
                messagesFromFirebase.append(currentMessage)
            }
            completion(messagesFromFirebase)
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
    
    static private func convertStringToDate(stringDate: String) -> Date {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "en_US_POSIX")
        dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
        let date = dateFormater.date(from: stringDate)!
        return date
    }
    
}

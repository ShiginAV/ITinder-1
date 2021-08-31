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
    
    static private var messagesReference: DatabaseReference!
    static private var conversationsReference = [DatabaseReference]()
    
    static func conversationsObserver(userId: String, completion: @escaping ([CompanionStruct]) -> Void) {
        Database.database().reference().child(usersRefKey).child(userId).child(conversationsKey).observe(.value) { (snapshot) in
            var conversations = [CompanionStruct]()
            guard let dialogs = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(conversations)
                return }
            for conversation in dialogs {
                let userId = conversation.key
                guard let convId = conversation.childSnapshot(forPath: conversationIdKey).value as? String else { return }
                guard let lastMessageWasRead = conversation.childSnapshot(forPath: lastMessageWasReadKey).value as? Bool else { return }
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
    
    static func createLastMessageObserver(conversationId: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference().child(conversationsKey).child(conversationId)
        conversationsReference.append(reference)
        
        reference.observe(.value) { (snapshot) in
            let lastMessageId = snapshot.childSnapshot(forPath: lastMessageKey).value as? String
            let lastMessageText = snapshot.childSnapshot(forPath: messagesKey).childSnapshot(forPath: lastMessageId ?? "1").childSnapshot(forPath: textKey).value as? String
            completion(lastMessageText)
        }
    }
    
    static func deleteMatch(currentUserId: String, companionId: String, conversationId: String) {
        let selfUserReference = Database.database().reference().child(usersRefKey).child(currentUserId)
        selfUserReference.child(conversationsKey).child(companionId).setValue(nil)
        selfUserReference.child(statusListKey).child(companionId).setValue(nil)
        
        Database.database().reference().child(conversationsKey).child(conversationId).setValue(nil)
        deleteImagesFromStorage(conversationId: conversationId)
        
        let companionUserReference = Database.database().reference().child(usersRefKey).child(companionId)
        companionUserReference.child(conversationsKey).child(currentUserId).setValue(nil)
        companionUserReference.child(statusListKey).child(currentUserId).setValue(nil)
    }
    
    static func deleteImagesFromStorage(conversationId: String) {
        let ref = Storage.storage().reference()
        ref.child("\(conversationId)/").listAll { (list, error) in
            list.items.forEach { (image) in
                ref.child(image.fullPath).delete()
            }
        }
    }
    
    static func createMessage(message: Message, date: String, convId: String, text: String, companionId: String) {
        let referenceConversation = Database.database().reference().child(conversationsKey)
        
        referenceConversation.child(convId).child(messagesKey).child(message.messageId).updateChildValues([
                                                                                                    dateKey: date,
                                                                                                    messageIdKey: message.messageId,
                                                                                                    senderKey: message.sender.senderId,
                                                                                                    messageTypeKey: "text",
                                                                                                    textKey: text])
        referenceConversation.child(convId).child(lastMessageKey).setValue(message.messageId)
        Database.database().reference().child(usersRefKey).child(companionId).child(conversationsKey).child(message.sender.senderId).child(lastMessageWasReadKey).setValue(false)
    }
    
    static func createMessage(message: Message, date: String, convId: String, image: UIImage, companionId: String) {
        let referenceConversation = Database.database().reference().child(conversationsKey)
        
        guard let image = image.jpegData(compressionQuality: 0.5) else { return }
        
        let metadata1 = StorageMetadata()
        metadata1.contentType = "image/jpeg"
        
        let ref = Storage.storage().reference().child(convId).child(message.messageId)
        
        ref.putData(image, metadata: metadata1) { (metadata, _) in
            ref.downloadURL { (url, _) in
                referenceConversation.child(convId).child(messagesKey).child(message.messageId).updateChildValues([dateKey: date,
                                                                                                          messageIdKey: message.messageId,
                                                                                                          senderKey: message.sender.senderId,
                                                                                                          messageTypeKey: "photo",
                                                                                                          attachmentKey: url?.absoluteString ?? "",
                                                                                                          textKey: "Вложение"])
                
                referenceConversation.child(convId).child(lastMessageKey).setValue(message.messageId)
                Database.database().reference().child(usersRefKey).child(companionId).child(conversationsKey).child(message.sender.senderId).child(lastMessageWasReadKey).setValue(false)
            }
        }
    }
    
    static func messagesFromConversationsObserver(conversationId: String, messagesCompletion: @escaping () -> ([String: Message]), completion: @escaping ([String: Message]?) -> Void) {
        
        messagesReference = Database.database().reference().child(conversationsKey).child(conversationId).child(messagesKey)
        messagesReference.observe(.value) { (snapshot) in
            
            let cashedMessages = messagesCompletion()
            var messagesFromFirebase = [String : Message]()
            
            guard snapshot.exists() else {
                completion(messagesFromFirebase)
                return }
            
            let internetMessages = snapshot
            
            var senders = [String: Sender]()
            let senderGroup = DispatchGroup()
            let group = DispatchGroup()
            
            guard let messages = internetMessages.children.allObjects as? [DataSnapshot] else { return }
            
            for oneMessage in messages {
                
                guard let oneMessage = oneMessage.value as? [String: Any] else { return }
                let message = MessageStruct(dictionary: oneMessage)
                
                guard let date = convertStringToDate(stringDate: message.date) else { return }
                
                if let currentMessage = cashedMessages[message.messageId] {
                    messagesFromFirebase[message.messageId] = currentMessage
                    continue }
                
                group.enter()
                
                let senderId = message.sender
                
                if senders.count != 2 {
                    senderGroup.enter()
                    senders[senderId] = Sender(photoUrl: "", senderId: "", displayName: "")
                    
                    UserService.getUserBy(id: senderId) { (user) in
                        guard let user = user else { return }
                        
                        senders[senderId] = Sender(photoUrl: user.imageUrl, senderId: user.identifier, displayName: user.name)
                        senderGroup.leave()
                    }
                }
                
                senderGroup.notify(queue: .main) {
                    
                    if message.messageType == "text" {
                        
                        messagesFromFirebase[message.messageId] = createTextMessage(sender: senders[senderId]!, messageId: message.messageId, sentDate: date, text: message.text)
                        
                        group.leave()
                        
                    } else if message.messageType == "photo" {
                        
                        messagesFromFirebase[message.messageId] = createEmptyPhotoMessage(sender: senders[senderId]!, messageId: message.messageId, sentDate: date)
                        completion(messagesFromFirebase)
                        group.leave()
                        
                        createPhotoMessage(sender: senders[senderId]!, messageId: message.messageId, sentDate: date, imageUrl: message.attachment) { (message) in
                            messagesFromFirebase[message.messageId] = message
                            completion(messagesFromFirebase)
                        }
                    }
                }
                
            }
            
            group.notify(queue: .main) {
                completion(messagesFromFirebase)
            }
            
        }
    }
    
    static func removeMessagesFromConversationsObserver() {
        messagesReference.removeAllObservers()
    }
    
    static func removeConversationsObserver() {
        conversationsReference.forEach { (conversation) in
            conversation.removeAllObservers()
        }
        conversationsReference = [DatabaseReference]()
    }
    
    static func setLastMessageWasRead(currentUserId: String, companionId: String) {
        Database.database().reference().child(usersRefKey).child(currentUserId).child(conversationsKey).child(companionId).child(lastMessageWasReadKey).setValue(true)
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
        let currentUserRef = Database.database().reference().child(usersRefKey).child(currentUserId).child(conversationsKey).child(companionId)
            
            currentUserRef.child(conversationIdKey).setValue(newConversationId)
            currentUserRef.child(lastMessageWasReadKey).setValue(true)
            
            let companionUserRef = Database.database().reference().child(usersRefKey).child(companionId).child(conversationsKey).child(currentUserId)
            
            companionUserRef.child(conversationIdKey).setValue(newConversationId)
            companionUserRef.child(lastMessageWasReadKey).setValue(true)
    }
    
    static private func createTextMessage(sender: Sender, messageId: String, sentDate: Date, text: String) -> Message {
        Message(sender: sender,
                messageId: messageId,
                sentDate: sentDate,
                kind: .text(text))
    }
    
    static private func createPhotoMessage(sender: Sender, messageId: String, sentDate: Date, imageUrl: String, completion: @escaping (Message) -> Void) {
        
        downloadPhoto(stringUrl: imageUrl) { (data) in
            let media = MediaForMessage(image: UIImage(data: data) ?? UIImage(),
                                        placeholderImage: UIImage(named: "birth_date_icon") ?? UIImage(),
                                        size: CGSize(width: 150, height: 150))
            
            let currentMessage = Message(sender: sender,
                                         messageId: messageId,
                                         sentDate: sentDate,
                                         kind: .photo(media))
            
            completion(currentMessage)
        }
    }
    
    static private func createEmptyPhotoMessage(sender: Sender, messageId: String, sentDate: Date) -> Message {
        
        let media = MediaForMessage(image: UIImage(named: "birth_date_icon") ?? UIImage(),
                                    placeholderImage: UIImage(named: "birth_date_icon") ?? UIImage(),
                                    size: CGSize(width: 150, height: 150))
        
        return Message(sender: sender,
                                     messageId: messageId,
                                     sentDate: sentDate,
                                     kind: .photo(media))
    }
    
    static func checkIfConversationNoExists(currentUserId: String, companionId: String, completion: @escaping () -> Void) {
        Database.database().reference().child(usersRefKey).child(currentUserId).child(conversationsKey).child(companionId).getData { (error, snapshot) in
            if !snapshot.exists() {
                completion()
            }
        }
    }
    
}

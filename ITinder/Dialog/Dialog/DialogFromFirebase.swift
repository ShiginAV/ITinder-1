//
//  DialogFromFirebase.swift
//  ITinder
//
//  Created by Grifus on 07.08.2021.
//

import Foundation
import Firebase

protocol DialogDelegate: AnyObject {
    func reloadMessages()
}

class DialogFromFirebase {
    
    weak var delegate: DialogDelegate?
    
    let referenceConversation = Database.database().reference().child("conversations")
    
    var messages = [Message]() {
        didSet {
            messages.sort { (one, two) -> Bool in
                one.sentDate < two.sentDate
            }
            delegate?.reloadMessages()
        }
    }
    
    init(conversationId: String) {
        messagesFromConversations(conversationId: conversationId)
    }
    
    func createMessage(convId: String, text: String, selfSender: Sender) {
        let messageId = UUID()
        
        let date = convertStringFromDate()
        
        referenceConversation.child(convId).child("messages").child(messageId.uuidString).updateChildValues(["date": date, "messageId": messageId.uuidString, "sender": selfSender.senderId, "text": text])
        referenceConversation.child(convId).child("lastMessage").setValue(messageId.uuidString)
    }
    
    func messagesFromConversations(conversationId: String) {
        Database.database().reference().observe(.value) { (snapshot) in
            guard snapshot.exists() else { return }
            var messagesFromFirebase = [Message]()
            
            let internetMessages = snapshot.childSnapshot(forPath: "conversations").childSnapshot(forPath: conversationId).childSnapshot(forPath: "messages")
            
            for message in internetMessages.children.allObjects as! [DataSnapshot] {
                let senderData = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: message.childSnapshot(forPath: "sender").value as! String).childSnapshot(forPath: "data")
                
                let senderName = senderData.childSnapshot(forPath: "name").value as! String
                let senderPhotoUrl = senderData.childSnapshot(forPath: "photoUrl").value as! String
                let senderId = message.childSnapshot(forPath: "sender").value as! String
                
                let sender = Sender(photoUrl: senderPhotoUrl, senderId: senderId, displayName: senderName)
                
                let messageId = message.childSnapshot(forPath: "messageId").value as! String
                let text = message.childSnapshot(forPath: "text").value as! String
                let stringDate = message.childSnapshot(forPath: "date").value as! String
                
                let date = self.convertStringToDate(stringDate: stringDate)
                
                let currentMessage = Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(text))
                messagesFromFirebase.append(currentMessage)
            }
            self.messages = messagesFromFirebase
        }
    }
    
    func convertStringFromDate() -> String {
        let date = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
        return dateFormater.string(from: date)
    }
    
    func convertStringToDate(stringDate: String) -> Date {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "en_US_POSIX")
        dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
        let date = dateFormater.date(from: stringDate)!
        return date
    }
    
}

extension DialogFromFirebase {
    
    func isPreviousMessageSameSender(indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false}
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }
    
    func isNextMessageSameSender(indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false}
        return messages[indexPath.section].sender.senderId == messages[indexPath.section + 1].sender.senderId
    }
    
}

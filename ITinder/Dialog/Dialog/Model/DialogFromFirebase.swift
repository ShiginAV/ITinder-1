//
//  DialogFromFirebase.swift
//  ITinder
//
//  Created by Grifus on 07.08.2021.
//

import Foundation
import Firebase
import MessageKit

protocol DialogDelegate: AnyObject {
    func reloadMessages()
    func getCompanionsId() -> [String: String]
    func resetMessageInputBarText()
}

class DialogFromFirebase {
    
    weak var delegate: DialogDelegate?
    
    var messagesDict = [String: Message]() {
        didSet {
            
            var messagesArray = [Message]()
            messagesDict.values.forEach { (message) in
                messagesArray.append(message)
            }
            messages = messagesArray
        }
    }
    
    var messages = [Message]() {
        didSet {
            messages.sort { (one, two) -> Bool in
                one.sentDate < two.sentDate
            }
            delegate?.reloadMessages()
            let companionsId = delegate?.getCompanionsId()
            guard let currentUserId = companionsId?["currentUserId"] else { return }
            guard let companionId = companionsId?["companionId"] else { return }
            
            if messages.count != 0 {
                ConversationService.setLastMessageWasRead(currentUserId: currentUserId, companionId: companionId)
            }
        }
    }
    
    init(conversationId: String) {
        
        ConversationService.messagesFromConversationsObserver(conversationId: conversationId) {  [weak self]  () -> ([String : Message]) in
            return (self?.messagesDict ?? [String: Message]())
        } completion: { [weak self] (internetMessages) in
            guard let internetMessages = internetMessages else {
                return
            }
            self?.messagesDict = internetMessages
        } photoCompletion: { [weak self] (message) in
            self?.messagesDict[message.messageId] = message
        }
    }
    
    deinit {
        ConversationService.removeMessagesFromConversationsObserver()
    }
    
    func sendTextMessage(conversationId: String, text: String, selfSender: Sender, companionId: String) {
        let messageId = UUID().uuidString
        let date = Date()
        let stringDate = convertStringFromDate(date: date)
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: date,
                              kind: .text(text))
        messagesDict[messageId] = message
        
        ConversationService.createMessage(message: message, date: stringDate, convId: conversationId, text: text, companionId: companionId)
        delegate?.resetMessageInputBarText()
    }
    
    func sendImageMessage(conversationId: String, selfSender: Sender, photo: UIImage, companionId: String) {
        let messageId = UUID().uuidString
        let date = Date()
        let stringDate = convertStringFromDate(date: date)
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: date,
                              kind: .photo(MediaForMessage(image: photo,
                                                           placeholderImage: UIImage(),
                                                           size: CGSize(width: 150, height: 150))))
        messagesDict[messageId] = message
        
        ConversationService.createMessage(message: message, date: stringDate, convId: conversationId, image: photo, companionId: companionId)
        delegate?.resetMessageInputBarText()
    }
    
    private func convertStringFromDate(date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
        return dateFormater.string(from: date)
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

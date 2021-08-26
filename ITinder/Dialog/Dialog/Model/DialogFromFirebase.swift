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
            ConversationService.setLastMessageWasRead(currentUserId: currentUserId, companionId: companionId)
        }
    }
    
    init(conversationId: String) {
        ConversationService.messagesFromConversations(conversationId: conversationId) { [weak self] () -> ([String : Message]) in
            return (self?.messagesDict ?? [String: Message]())
        } completion: { [weak self] (internetMessages) in
//            var messagesArray = [Message]()
            //            internetMessages.values.forEach { (message) in
            //                messagesArray.append(message)
            //            }
            //            self?.messages = messagesArray
            self?.messagesDict = internetMessages
        }
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

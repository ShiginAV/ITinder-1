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
    func getCompanionsId() -> [String: String]
}

class DialogFromFirebase {
    
    weak var delegate: DialogDelegate?
    
    var messages = [Message]() {
        didSet {
            messages.sort { (one, two) -> Bool in
                one.sentDate < two.sentDate
            }
            delegate?.reloadMessages()
            let companionsId = delegate?.getCompanionsId()
            guard let currentUserId = companionsId?["currentUserId"] else { return }
            guard let companionId = companionsId?["companionId"] else { return }
            FirebaseService.setLastMessageWasRead(currentUserId: currentUserId, companionId: companionId)
        }
    }
    
    init(conversationId: String) {
        FirebaseService.messagesFromConversations(conversationId: conversationId) { [weak self] (internetMessages) in
            self?.messages = internetMessages
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

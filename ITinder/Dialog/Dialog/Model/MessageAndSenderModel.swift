//
//  MessageModel.swift
//  ITinder
//
//  Created by Grifus on 11.08.2021.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoUrl: String
    var senderId: String
    var displayName: String
}

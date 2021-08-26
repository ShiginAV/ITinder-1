//
//  Message.swift
//  ITinder
//
//  Created by Grifus on 24.08.2021.
//

import Foundation

struct MessageStruct {
    let date: String
    let messageId: String
    let messageType: String
    let sender: String
    let text: String
    var attachment: String
}

extension MessageStruct {
    init(dictionary: [String: Any]) {
        date = dictionary["date"] as? String ?? ""
        messageId = dictionary["messageId"] as? String ?? ""
        messageType = dictionary["messageType"] as? String ?? ""
        sender = dictionary["sender"] as? String ?? ""
        text = dictionary["text"] as? String ?? ""
        attachment = dictionary["attachment"] as? String ?? ""
    }
}

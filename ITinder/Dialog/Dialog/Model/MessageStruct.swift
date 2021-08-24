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
    
    let attachmentCount: Int?
    var attachment: [String]?
}

extension MessageStruct {
    init(dictionary: [String: Any]) {
        date = dictionary["date"] as? String ?? ""
        messageId = dictionary["messageId"] as? String ?? ""
        messageType = dictionary["messageType"] as? String ?? ""
        sender = dictionary["sender"] as? String ?? ""
        text = dictionary["text"] as? String ?? ""
        
        attachmentCount = dictionary["attachmentCount"] as? Int ?? 0
        guard let count = attachmentCount else { return }
        attachment = [String]()
        for number in 0..<count {
            attachment?.append(dictionary["attachment\(number)"] as? String ?? "")
        }
    }
}

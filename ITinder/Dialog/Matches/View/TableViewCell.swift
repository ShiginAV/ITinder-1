//
//  TableViewCell.swift
//  ITinder
//
//  Created by Grifus on 07.08.2021.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var unreadMessageIndicator: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nameLable: UILabel!
    
    @IBOutlet weak var lastMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImage.backgroundColor = .lightGray
        avatarImage.layer.cornerRadius = avatarImage.bounds.height / 2
        
        unreadMessageIndicator.backgroundColor = .systemBlue
        unreadMessageIndicator.layer.cornerRadius = unreadMessageIndicator.bounds.width / 2
    }
    
    func fill(avatarImage: UIImage?, name: String?, lastMessage: String?, lastMessageWasRead: Bool) {
        self.avatarImage.image = avatarImage
        nameLable.text = name
        self.lastMessage.text = lastMessage
        unreadMessageIndicator.isHidden = lastMessageWasRead
    }
}

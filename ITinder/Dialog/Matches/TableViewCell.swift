//
//  TableViewCell.swift
//  ITinder
//
//  Created by Grifus on 07.08.2021.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nameLable: UILabel!
    
    @IBOutlet weak var lastMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  CollectionViewCell.swift
//  ITinder
//
//  Created by Grifus on 10.08.2021.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nameLable: UILabel!

    @IBOutlet weak var noNewMatchesLable: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImage.backgroundColor = .lightGray
        avatarImage.layer.cornerRadius = avatarImage.bounds.height / 2
    }
}

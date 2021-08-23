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
    
    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImage.backgroundColor = .lightGray
        avatarImage.layer.cornerRadius = avatarImage.bounds.height / 2
    }
    
    func fill(avatarImage: UIImage?, name: String?) {
        self.avatarImage.image = avatarImage
        nameLable.text = name
        setIndicator()
    }
    
    private func setIndicator() {
        if self.avatarImage.image == nil {
            imageIndicator.isHidden = false
            imageIndicator.startAnimating()
        } else {
            avatarImage.isHidden = false
            imageIndicator.isHidden = true
            imageIndicator.stopAnimating()
        }
    }
}

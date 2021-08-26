//
//  MediaForMessage.swift
//  ITinder
//
//  Created by Grifus on 26.08.2021.
//

import Foundation
import MessageKit

struct MediaForMessage: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage, placeholderImage: UIImage, size: CGSize) {
        self.image = image
        self.placeholderImage = placeholderImage
        self.size = size
    }
}

//
//  SwipeCardModel.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

struct SwipeCardModel {
    let userId: String
    let imageUrl: String
    let name: String
    let position: String
    let description: String?

    init(from user: User) {
        userId = user.identifier
        imageUrl = user.imageUrl
        name = user.name
        position = user.position
        description = user.description
    }
}

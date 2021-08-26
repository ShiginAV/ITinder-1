//
//  User.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import Foundation

struct User {
    let identifier: String
    let email: String
    var imageUrl: String
    var name: String
    var position: String
    var description: String?
    var birthDate: String?
    var city: String?
    var education: String?
    var company: String?
    var employment: String?
    var likes: [String]
    var matches: [String]
}

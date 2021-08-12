//
//  UserService.swift
//  ITinder
//
//  Created by Alexander on 08.08.2021.
//

import Foundation

class UserService {
    static let shared = UserService()
    private init() { }
    
    let users = [
        "1": User(identifier: "1",
                  isOwner: true,
                  email: "",
                  imageUrl: "",
                  name: "mr. PINK",
                  position: "Developer",
                  description: "Swift, Xcode, умение работать со встроенными инструментами IDE, unit и UI тесты для iOS, работа с Git, CocoaPods, Realm",
                  birthDate: "21.12.2021",
                  city: "London",
                  education: "NNGASU",
                  company: "EPAM",
                  employment: "full"),
        "2": User(identifier: "2",
                  isOwner: false,
                  email: "",
                  imageUrl: "",
                  name: "mr. BLUE",
                  position: "Developer",
                  description: "Swift, Xcode, умение работать со встроенными инструментами IDE, unit и UI тесты для iOS, работа с Git, CocoaPods, Realm",
                  birthDate: "21.12.2021",
                  city: nil,
                  education: nil,
                  company: nil,
                  employment: "full"),
        "3": User(identifier: "3",
                  isOwner: false,
                  email: "",
                  imageUrl: "",
                  name: "ms. YELLOW",
                  position: "Developer",
                  description: "Swift, Xcode, умение работать со встроенными инструментами IDE, unit и UI тесты для iOS, работа с Git, CocoaPods, Realm",
                  city: "London",
                  education: "NNGASU",
                  company: "EPAM",
                  employment: "full"),
        "4": User(identifier: "4",
                  isOwner: false,
                  email: "",
                  imageUrl: "",
                  name: "mr. GREY",
                  position: "Developer",
                  description: "Swift, Xcode, умение работать со встроенными инструментами IDE, unit и UI тесты для iOS, работа с Git, CocoaPods, Realm",
                  city: "",
                  education: "NNGASU",
                  company: "EPAM",
                  employment: "")
    ]
    
    func getUserBy(id: String) -> User? {
        return users[id]
    }
    
    func persist(_ user: User) {
        
    }
}

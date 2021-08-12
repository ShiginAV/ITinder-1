//
//  UserService.swift
//  ITinder
//
//  Created by Alexander on 08.08.2021.
//

import Foundation
import Firebase

class UserService {
    static let shared = UserService()
    private init() { }
    
    private let usersDatabase = Database.database().reference().child("users")
    private var lastUserId = "1"
    
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
    
    func getUserBy(id: String, completion: @escaping (User?) -> Void) {
        usersDatabase.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.childSnapshot(forPath: id).value as? [String: Any] else {
                assertionFailure()
                completion(nil)
                return
            }
            let user = User(identifier: value["identifier"] as? String ?? "",
                            isOwner: value["isOwner"] as? Bool ?? false,
                            email: value["email"] as? String ?? "",
                            imageUrl: value["imageUrl"] as? String ?? "",
                            name: value["name"] as? String ?? "",
                            position: value["position"] as? String ?? "",
                            description: value["description"] as? String ?? "",
                            birthDate: value["birthDate"] as? String ?? "",
                            city: value["city"] as? String ?? "",
                            education: value["education"] as? String ?? "",
                            company: value["company"] as? String ?? "",
                            employment: value["employment"] as? String ?? "")
            completion(user)
        } withCancel: { _ in
            assertionFailure()
            completion(nil)
        }
    }
    
    func getNextUsers(usersCount: Int, completion: @escaping ([User]?) -> Void) {
        let query = usersDatabase.queryOrderedByKey().queryStarting(afterValue: lastUserId)
        
        query.queryLimited(toFirst: UInt(usersCount)).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { assertionFailure(); return }
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                assertionFailure()
                completion(nil)
              return
            }
            
            var users = [User]()
            
            children.forEach {
                if let value = $0.value as? [String: Any] {
                    let user = User(identifier: value["identifier"] as? String ?? "",
                                    isOwner: value["isOwner"] as? Bool ?? false,
                                    email: value["email"] as? String ?? "",
                                    imageUrl: value["imageUrl"] as? String ?? "",
                                    name: value["name"] as? String ?? "",
                                    position: value["position"] as? String ?? "",
                                    description: value["description"] as? String ?? "",
                                    birthDate: value["birthDate"] as? String ?? "",
                                    city: value["city"] as? String ?? "",
                                    education: value["education"] as? String ?? "",
                                    company: value["company"] as? String ?? "",
                                    employment: value["employment"] as? String ?? "")
                    users.append(user)
                }
            }
            
            guard let lastValue = children.last?.value as? [String: Any],
                  let lastUserId = lastValue["identifier"] as? String else {
                completion(nil)
                return
            }
            self.lastUserId = lastUserId
            completion(users)
        } withCancel: { _ in
            completion(nil)
        }

    }
    
    func persist(_ user: User) {
        let userDict: [String: Any] = [
            "identifier": user.identifier,
            "isOwner": user.isOwner,
            "email": user.email,
            "imageUrl": user.imageUrl,
            "name": user.name,
            "position": user.position,
            "description": user.description ?? "",
            "birthDate": user.birthDate ?? "",
            "city": user.city ?? "",
            "education": user.education ?? "",
            "company": user.company ?? "",
            "employment": user.employment ?? ""
        ]
        usersDatabase.child(user.identifier).setValue(userDict)
    }
}

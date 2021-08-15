//
//  UserService.swift
//  ITinder
//
//  Created by Alexander on 08.08.2021.
//

import UIKit
import Firebase

class UserService {
    static let shared = UserService()
    private init() { }
    
    private let usersDatabase = Database.database().reference().child("users")
    private var lastUserId = ""
    
    private let imageStorage = Storage.storage().reference().child("Avatars")

    func getUserBy(id: String, completion: @escaping (User?) -> Void) {
        usersDatabase.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.childSnapshot(forPath: id).value as? [String: Any] else {
                assertionFailure()
                completion(nil)
                return
            }
            completion(User(dictionary: value))
        } withCancel: { _ in
            assertionFailure()
            completion(nil)
        }
    }
    
    func getNextUsers(usersCount: Int, completion: @escaping ([User]?) -> Void) {
        var query = usersDatabase.queryOrderedByKey()
        if lastUserId != "" {
            query = query.queryStarting(afterValue: lastUserId)
        }
        
        query.queryLimited(toFirst: UInt(usersCount)).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else {
                assertionFailure()
                completion(nil)
                return
            }
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                assertionFailure()
                completion(nil)
              return
            }
            
            var users = [User]()
            
            children.forEach {
                if let value = $0.value as? [String: Any] {
                    users.append(User(dictionary: value))
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
    
    func persist(user: User, withImage: UIImage?, completion: @escaping ((User?) -> Void)) {
        guard let image = withImage else {
            persist(user) { user in
                completion(user)
            }
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageStorage.child("\(user.identifier).jpg").putData(imageData, metadata: metadata) { [weak self] _, error in
            guard error == nil,
                  let self = self else {
                completion(nil)
                return
            }
            
            self.imageStorage.child("\(user.identifier).jpg").downloadURL { [weak self] url, error in
                guard error == nil,
                      let self = self,
                      let urlString = url?.absoluteString else {
                    completion(nil)
                    return
                }
                
                var newUser = user
                newUser.imageUrl = urlString
                self.persist(newUser) { user in
                    completion(user)
                }
            }
        }
    }
    
    private func persist(_ user: User, completion: @escaping ((User?) -> Void)) {
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
            "employment": user.employment ?? "",
            "likes": user.likes,
            "matches": user.matches
        ]
        usersDatabase.child(user.identifier).setValue(userDict) { error, _ in
            guard error == nil else {
                completion(nil)
                return
            }
            completion(user)
        }
    }
}

extension User {
    init(dictionary: [String: Any]) {
        identifier = dictionary["identifier"] as? String ?? ""
        isOwner = dictionary["isOwner"] as? Bool ?? false
        email = dictionary["email"] as? String ?? ""
        imageUrl = dictionary["imageUrl"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        position = dictionary["position"] as? String ?? ""
        description = dictionary["description"] as? String
        birthDate = dictionary["birthDate"] as? String
        city = dictionary["city"] as? String
        education = dictionary["education"] as? String
        company = dictionary["company"] as? String
        employment = dictionary["employment"] as? String
        likes = dictionary["likes"] as? [String] ?? []
        matches = dictionary["matches"] as? [String] ?? []
    }
}

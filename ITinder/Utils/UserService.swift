//
//  UserService.swift
//  ITinder
//
//  Created by Alexander on 08.08.2021.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class UserService {
    private static let imageStorage = Storage.storage().reference().child(kAvatarsRef)
    private static let usersDatabase = Database.database().reference().child(kUsersRef)
    private static var lastUserId = ""
    
    static var currentUserId: String? {
        "4"//Auth.auth().currentUser.map { $0.uid }
    }
    
    static func getUserBy(id: String, completion: @escaping (User?) -> Void) {
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
    
    static func getCurrentUser(completion: @escaping (User?) -> Void) {
        guard let currentUserId = currentUserId else {
            assertionFailure()
            completion(nil)
            return
        }
        getUserBy(id: currentUserId) { user in
            completion(user)
        }
    }
    
    static func getNextUsers(usersCount: Int, completion: @escaping ([User]?) -> Void) {
        var query = usersDatabase.queryOrderedByKey()
        
        if lastUserId != "" {
            query = query.queryEnding(beforeValue: lastUserId)
        }
        
        query.queryLimited(toLast: UInt(usersCount)).observeSingleEvent(of: .value) { snapshot in
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
            
            guard let lastUserId = users.first?.identifier else {
                completion(nil)
                return
            }
            Self.lastUserId = lastUserId
            users.reverse()
            
            let filterdUsers = filtered(users)
            
            if filterdUsers.isEmpty {
                getNextUsers(usersCount: usersCount) { user in
                    completion(user)
                }
            } else {
                completion(filterdUsers)
            }
        } withCancel: { _ in
            completion(nil)
        }
    }
    
    private static func filtered(_ users: [User]) -> [User] {
        return users.filter { user in
            if user.identifier != currentUserId && !user.likes.contains(currentUserId ?? "") {
                return true
            } else {
                return false
            }
        }
    }
    
    static func persist(user: User, withImage: UIImage?, completion: @escaping ((User?) -> Void)) {
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
        
        imageStorage.child("\(user.identifier).jpg").putData(imageData, metadata: metadata) { _, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            imageStorage.child("\(user.identifier).jpg").downloadURL { url, error in
                guard error == nil, let urlString = url?.absoluteString else {
                    completion(nil)
                    return
                }
                
                var newUser = user
                newUser.imageUrl = urlString
                persist(newUser) { user in
                    completion(user)
                }
            }
        }
    }
    
    private static func persist(_ user: User, completion: @escaping ((User?) -> Void)) {
        let userDict: [String: Any] = [
            kIdentifier: user.identifier,
            kEmail: user.email,
            kImageUrl: user.imageUrl,
            kName: user.name,
            kPosition: user.position,
            kDescription: user.description ?? "",
            kBirthDate: user.birthDate ?? "",
            kCity: user.city ?? "",
            kEducation: user.education ?? "",
            kCompany: user.company ?? "",
            kEmployment: user.employment ?? "",
            kLikes: user.likes,
            kMatches: user.matches,
            kRegisteredDate: user.registeredDate
        ]
        usersDatabase.child(user.identifier).setValue(userDict) { error, _ in
            guard error == nil else {
                completion(nil)
                return
            }
            completion(user)
        }
    }
    
    static func set(like: String, forUserId: String, completion: @escaping ((User?) -> Void)) {
        guard let currentUserId = currentUserId else {
            assertionFailure()
            completion(nil)
            return
        }
        
        getUserBy(id: forUserId) { user in
            guard var user = user else {
                assertionFailure()
                completion(nil)
                return
            }
            user.likes.append(currentUserId)
            
            usersDatabase.child(forUserId).updateChildValues([kLikes: user.likes]) { error, _ in
                guard error == nil else {
                    completion(nil)
                    return
                }
                completion(user)
            }
        }
    }
    
    static func setMatchIfNeededWith(likedUser: User?, completion: @escaping ((User?) -> Void)) {
        guard var likedUser = likedUser else {
            completion(nil)
            return
        }
        getCurrentUser { user in
            guard var currentUser = user else {
                assertionFailure()
                completion(nil)
                return
            }
            
            if currentUser.likes.contains(likedUser.identifier) {
                currentUser.matches.append(likedUser.identifier)
                likedUser.matches.append(currentUser.identifier)
                
                usersDatabase.child(currentUser.identifier).updateChildValues([kMatches: currentUser.matches]) { error, _ in
                    guard error == nil else {
                        completion(nil)
                        return
                    }
                    usersDatabase.child(likedUser.identifier).updateChildValues([kMatches: likedUser.matches]) { error, _ in
                        guard error == nil else {
                            completion(nil)
                            return
                        }
                        completion(likedUser)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
}

extension User {
    init(dictionary: [String: Any]) {
        identifier = dictionary[kIdentifier] as? String ?? ""
        email = dictionary[kEmail] as? String ?? ""
        imageUrl = dictionary[kImageUrl] as? String ?? ""
        name = dictionary[kName] as? String ?? ""
        position = dictionary[kPosition] as? String ?? ""
        description = dictionary[kDescription] as? String
        birthDate = dictionary[kBirthDate] as? String
        city = dictionary[kCity] as? String
        education = dictionary[kEducation] as? String
        company = dictionary[kCompany] as? String
        employment = dictionary[kEmployment] as? String
        likes = dictionary[kLikes] as? [String] ?? []
        matches = dictionary[kMatches] as? [String] ?? []
        registeredDate = dictionary[kRegisteredDate] as? String ?? ""
    }
}

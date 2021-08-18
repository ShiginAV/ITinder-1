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
    static let shared = UserService()
    private init() { }
    
    private let usersDatabase = Database.database().reference().child("users")
    private var lastUserId = ""
    
    private let imageStorage = Storage.storage().reference().child("Avatars")
    
    var currentUserId: String? {
        "4"//Auth.auth().currentUser.map { $0.uid }
    }
    
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
            query = query.queryEnding(beforeValue: lastUserId)
        }
        query.queryLimited(toLast: UInt(usersCount)).observeSingleEvent(of: .value) { [weak self] snapshot in
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
            
            guard let lastUserId = users.first?.identifier else {
                completion(nil)
                return
            }
            self.lastUserId = lastUserId
            users.reverse()
            
            let filterdUsers = self.filtered(users)
            
            if filterdUsers.isEmpty {
                self.getNextUsers(usersCount: usersCount) { user in
                    completion(user)
                }
            } else {
                completion(filterdUsers)
            }
        } withCancel: { _ in
            completion(nil)
        }
    }
    
    private func filtered(_ users: [User]) -> [User] {
        return users.filter { user in
            if user.identifier != self.currentUserId && !user.likes.contains(self.currentUserId ?? "") {
                return true
            } else {
                return false
            }
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
    
    func set(like: String, forUserId: String, completion: @escaping ((User?) -> Void)) {
        guard let currentUserId = UserService.shared.currentUserId else { return }
        
        getUserBy(id: forUserId) { user in
            guard var user = user else {
                assertionFailure()
                completion(nil)
                return
            }
            user.likes.append(currentUserId)
            
            let dict: [String: Any] = [
                "likes": user.likes
            ]
            
            self.usersDatabase.child(forUserId).updateChildValues(dict) { error, _ in
                guard error == nil else {
                    completion(nil)
                    return
                }
                completion(user)
            }
        }
    }
    
    func set(match: String) {
        
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

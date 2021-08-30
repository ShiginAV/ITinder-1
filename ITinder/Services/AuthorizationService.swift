//
//  AuthorizationService.swift
//  ITinder
//
//  Created by Daria Tokareva on 19.08.2021.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthorizationService {
    
    static func createUserInFiresore( email: String, password: String, vc: UIViewController) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                vc.showAlert(title: "Ошибка регистрации пользователя", message: error?.localizedDescription)
            } else {
                // User was created sucessfully, store uid and email in database
                let ref = Database.database().reference()
                if let result = result {
                    let uid = result.user.uid
                    ref.child("users/" + uid + "/email").setValue(email)
                    ref.child("users/" + uid + "/identifier").setValue(uid)
                    
                    Router.transitionToCreatingUserInfoVC(view: vc.view, storyboard: vc.storyboard, uid: uid)
                } else {
                    vc.showAlert(title: "Ошибка регистрации пользователя", message: error?.localizedDescription)
                }
            }
        }
    }
    
    static func signInUserInFirebase(email: String, password: String, vc: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                vc.showAlert(title: "Ошибка входа", message: error?.localizedDescription)
            } else {
                Router.transitionToMainTabBar(view: vc.view, storyboard: vc.storyboard)
            }
        }
    }
    
    static func signInWithGivenCredential(credential: AuthCredential, vc: UIViewController) {
        Auth.auth().signIn(with: credential) { result, error in
            if error != nil {
                vc.showAlert(title: "Ошибка", message: error?.localizedDescription)
                return
            } else {
                //create user or login
                guard let uid = result?.user.uid else {
                    print("uid = nil")
                    return
                }
                // check user exist
                let usersDatabase = Database.database().reference().child("users")
                usersDatabase.observeSingleEvent(of: .value) { snapshot in
                    guard let _ = snapshot.childSnapshot(forPath: uid).value as? [String: Any] else {
                        // create new user with uid and email
                        let ref = Database.database().reference()
                        let email = result?.user.email
                        ref.child("users/" + uid + "/email").setValue(email)
                        ref.child("users/" + uid + "/identifier").setValue(uid)
                        
                        //transition to sign in screen
                        Router.transitionToCreatingUserInfoVC(view: vc.view, storyboard: vc.storyboard, uid: uid)
                        
                        return
                    }
                    // user already in database
                    Router.transitionToMainTabBar(view: vc.view, storyboard: vc.storyboard)
                }
            }
        }
    }
}

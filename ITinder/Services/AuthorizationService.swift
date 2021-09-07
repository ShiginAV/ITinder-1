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
    
    static func signInUserInFirebase(email: String, password: String, vc: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                vc.showAlert(title: "Ошибка входа", message: error?.localizedDescription)
            } else {
                Router.transitionToMainTabBar(view: vc.view)
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
                        Router.transitionToCreatingUserInfoVC(view: vc.view)
                        
                        return
                    }
                    // user already in database
                    Router.transitionToMainTabBar(view: vc.view)
                }
            }
        }
    }
}

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
                    
                    Transitor.transitionToCreatingUserInfoVC(view: vc.view, storyboard: vc.storyboard, uid: uid)
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
                Transitor.transitionToMainTabBar(view: vc.view, storyboard: vc.storyboard)
            }
        }
    }
}

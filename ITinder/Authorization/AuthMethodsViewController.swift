//
//  AuthMethodsViewController.swift
//  ITinder
//
//  Created by Daria Tokareva on 12.08.2021.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase

class AuthMethodsViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleImageView: UIImageView!
    
    let signInConfig = GIDConfiguration.init(clientID: "572025486763-l8q1t2jh5a5ntjperccufpt9ne4lcipp.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleImageTapped()
    }

    private func googleImageTapped() {
        
        let googleTap = UITapGestureRecognizer(target: self, action: #selector(loginWithGoogle))
        googleImageView.isUserInteractionEnabled = true
        googleImageView.addGestureRecognizer(googleTap)
    }
    
    @objc func loginWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            // get credentials
            let authentication = user.authentication
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
            
            // sign in with given credentials
            Auth.auth().signIn(with: credential) { result, error in
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
                        Transitor.transitionToCreatingUserInfoVC(view: self.view, storyboard: self.storyboard, uid: uid)
                        
                        return
                    }
                    // user already in database
                    Transitor.transitionToMainTabBar(view: self.view, storyboard: self.storyboard)
                }
            }
          }
    }
    
    override func viewDidLayoutSubviews() {
        Utilities.stylePrimaryButton(loginButton)
        Utilities.styleSecondaryButton(signUpButton)
    }
}

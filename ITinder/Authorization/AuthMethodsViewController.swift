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
import FacebookCore
import FacebookLogin

class AuthMethodsViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleImageView: UIImageView!
    @IBOutlet weak var facebookImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleImageTapped()
        facebookImageTapped()
    }
    
    // reset user defaults to review onboarding
    @IBAction func resetUser(_ sender: Any) {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
        defaults.removeObject(forKey: key)
        }
    }
    
    private func googleImageTapped() {
        let googleTap = UITapGestureRecognizer(target: self, action: #selector(loginWithGoogle))
        googleImageView.isUserInteractionEnabled = true
        googleImageView.addGestureRecognizer(googleTap)
    }
    
    private func facebookImageTapped() {
        let facebookTap = UITapGestureRecognizer(target: self, action: #selector(loginWithFacebook(_:)))
        facebookImageView.isUserInteractionEnabled = true
        facebookImageView.addGestureRecognizer(facebookTap)
    }
    
    @objc func loginWithFacebook(_ sender: Any) {
        print("Facebook tapped")
        let loginManager = LoginManager()
        
        //try to sign in with facebook
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { result in
            switch result {
            case .success(granted: _, declined: _, token: _):
                self.signIntoFirebaseWithFacebook()
            case .failed(let err):
                print(err)
            case .cancelled:
                print("canceled")
            }
        }
    }
    
    private func signIntoFirebaseWithFacebook() {
        // get credential
        guard let accessToken = AccessToken.current?.tokenString else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        //try to auth with this credential
        AuthorizationService.signInWithGivenCredential(credential: credential, vc: self)
    }
    
    @objc func loginWithGoogle(_ sender: Any) {
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            // get credentials
            let authentication = user.authentication
            guard let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            AuthorizationService.signInWithGivenCredential(credential: credential, vc: self)
          }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Utilities.stylePrimaryButton(loginButton)
        Utilities.styleSecondaryButton(signUpButton)
    }
}

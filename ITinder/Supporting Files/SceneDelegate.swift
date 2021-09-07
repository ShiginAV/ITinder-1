//
//  SceneDelegate.swift
//  ITinder
//
//  Created by Daria Tokareva on 03.08.2021.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene as? UIWindowScene) != nil else { return }
        
        // check show onboarding
        if !OnboardingManager.shared.isNewUser() {
            let myStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let authVC = myStoryboard.instantiateViewController(identifier: "AuthMethodsViewController")
            
            // checking that the user is already logged in
//            if Auth.auth().currentUser == nil {
                window?.rootViewController = authVC
//            } else {
//                let myStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let mainTabVC = myStoryboard.instantiateViewController(identifier: "TabBarController")
//                window?.rootViewController = mainTabVC
//            }
            
        } else {
            window?.rootViewController = OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
                    window?.makeKeyAndVisible()
        }
        
    }
}

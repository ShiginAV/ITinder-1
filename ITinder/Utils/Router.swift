//
//  Router.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

final class Router {
    static func showUserProfile(user: User?, parent: UIViewController) {
        let userProfileVC = UserProfileViewController(user: user)
        parent.present(userProfileVC, animated: true, completion: nil)
    }
    
    static func showEditUserProfile(parent: UIViewController, user: User) {
        let editProfileVC = EditUserProfileViewController(user: user)
        editProfileVC.modalPresentationStyle = .fullScreen
        parent.present(editProfileVC, animated: true, completion: nil)
    }
    
    static func transitionToCreatingUserInfoVC(view: UIView, storyboard: UIStoryboard?, uid: String) {
        let creatingUserInfoVC = (storyboard?.instantiateViewController(identifier: "CreatingUserInfoViewController"))! as CreatingUserInfoViewController
        creatingUserInfoVC.userID = uid
        
        view.window?.rootViewController = creatingUserInfoVC
        view.window?.makeKeyAndVisible()
    }
    
    static func transitionToMainTabBar(view: UIView, storyboard: UIStoryboard?) {
        let creatingUserInfoVC = storyboard?.instantiateViewController(identifier: "TabBarController")
        view.window?.rootViewController = creatingUserInfoVC
        view.window?.makeKeyAndVisible()
    }
}

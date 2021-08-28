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
    
    static func showMatch(user: User, parent: UIViewController) {
        let matchVC = MatchViewController(user: user)
        matchVC.modalPresentationStyle = .fullScreen
        matchVC.modalTransitionStyle = .flipHorizontal
        parent.present(matchVC, animated: true, completion: nil)
    }
}

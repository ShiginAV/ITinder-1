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
    
    static func showDialogViewController(storyboard: UIStoryboard?, navigationController: UINavigationController?, currentUser: User, companion: CompanionStruct, avatars: [String: UIImage]) {
        guard let dialogViewController = storyboard?.instantiateViewController(withIdentifier: "Dialog") as? DialogViewController else { return }
        
        let companionId = companion.userId
        let convId = companion.conversationId
        
        dialogViewController.companion = companion
        dialogViewController.companionPhoto = avatars[companionId]
        
        dialogViewController.messageViewController.currentUser = currentUser
        dialogViewController.messageViewController.conversationId = convId
        
        dialogViewController.messageViewController.downloadedPhoto[currentUser.identifier] = avatars[currentUser.identifier]
        dialogViewController.messageViewController.downloadedPhoto[companionId] = avatars[companionId]
        
        dialogViewController.messageViewController.companionId = companionId
        
        navigationController?.pushViewController(dialogViewController, animated: true)
    }
    
    static func openPhoneSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}

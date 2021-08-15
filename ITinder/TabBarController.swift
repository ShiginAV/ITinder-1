//
//  TabBarController.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

final class TabBarController: UITabBarController {
    let currentUserId = "4" //TODO: get current user id
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUserProfileViewController()
    }
    
    private func addUserProfileViewController() {
        guard var viewControllers = viewControllers else { return }
        
        let userProfileVC = UserProfileViewController(user: nil)
        viewControllers.append(userProfileVC)
        self.viewControllers = viewControllers
        
        UserService.shared.getUserBy(id: currentUserId) { user in
            userProfileVC.user = user
        }
    }
}

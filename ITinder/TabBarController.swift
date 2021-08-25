//
//  TabBarController.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = Colors.primary
        addUserProfileViewController()
    }
    
    private func addUserProfileViewController() {
        guard var viewControllers = viewControllers else { return }
        
        let userProfileVC = UserProfileViewController(user: nil)
        viewControllers.append(userProfileVC)
        self.viewControllers = viewControllers
        
        UserService.getCurrentUser { user in
            userProfileVC.user = user
        }
    }
}

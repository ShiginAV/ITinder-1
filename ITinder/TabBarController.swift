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
        addUserProfileViewController()
    }
    
    private func addUserProfileViewController() {
        guard var viewControllers = viewControllers else { return }
        
        let userProfileVC = UserProfileViewController(user: nil)
        viewControllers.append(userProfileVC)
        self.viewControllers = viewControllers
        
        let currentUserId = "4" //guard let currentUserId = UserService.shared.getCurrentUserId() else { return }
        UserService.shared.getUserBy(id: currentUserId) { user in
            userProfileVC.user = user
        }
    }
}

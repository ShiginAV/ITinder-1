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
        
        viewControllers?.forEach({
            if let navigationVC = $0 as? UINavigationController {
                navigationVC.viewControllers.forEach { _ = $0.view }
            }
        })
    }
    
    private func addUserProfileViewController() {
        guard var viewControllers = viewControllers else { return }
        
        let userProfileVC = UserProfileViewController(user: nil)
        viewControllers.append(userProfileVC)
        self.viewControllers = viewControllers
        
        guard let currentUserId = UserService.shared.currentUserId else { return }
        UserService.shared.getUserBy(id: currentUserId) { user in
            userProfileVC.user = user
        }
    }
}

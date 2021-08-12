//
//  TabBarController.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

final class TabBarController: UITabBarController {
    let currentUserId = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUserProfileViewController()
    }
    
    private func addUserProfileViewController() {
        guard var viewControllers = viewControllers else { return }
        
        let userProfileVC = createUserProfileViewController(user: nil)
        viewControllers.append(userProfileVC)
        self.viewControllers = viewControllers
        
        UserService.shared.getUserBy(id: currentUserId) { [weak self] user in
            guard let self = self else { return }
            let userProfileVC = self.createUserProfileViewController(user: user)
            viewControllers[2] = userProfileVC
            self.viewControllers = viewControllers
        }
    }
    
    private func createUserProfileViewController(user: User?) -> UserProfileViewController {
        let userProfileVC = UserProfileViewController(user: user)
        userProfileVC.title = "Profile"
        userProfileVC.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        return userProfileVC
    }
}

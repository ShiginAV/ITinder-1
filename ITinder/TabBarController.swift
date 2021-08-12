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
        guard let user = UserService.shared.getUserBy(id: "1") else { assertionFailure(); return }
        
        let userProfileVC = UserProfileViewController(user: user)
        userProfileVC.title = "Profile"
        userProfileVC.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        
        viewControllers.append(userProfileVC)
        self.viewControllers = viewControllers
    }
}

//
//  Transitor.swift
//  ITinder
//
//  Created by Daria Tokareva on 19.08.2021.
//

import Foundation
import UIKit

// for transitions between view controllers
class Transitor {
    
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

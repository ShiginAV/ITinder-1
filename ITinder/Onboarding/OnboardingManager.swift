//
//  OnboardingManager.swift
//  ITinder
//
//  Created by Daria Tokareva on 06.09.2021.
//

import Foundation

class OnboardingManager {
    
    static let shared = OnboardingManager()
    
    private init() {}
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}

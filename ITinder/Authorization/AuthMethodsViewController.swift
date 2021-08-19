//
//  AuthMethodsViewController.swift
//  ITinder
//
//  Created by Daria Tokareva on 12.08.2021.
//

import UIKit

class AuthMethodsViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        Utilities.stylePrimaryButton(loginButton)
        Utilities.styleSecondaryButton(signUpButton)
    }

}

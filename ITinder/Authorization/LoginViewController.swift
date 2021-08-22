//
//  LoginViewController.swift
//  ITinder
//
//  Created by Daria Tokareva
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var toSignUpLabel: UILabel!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        signUpLabelTapped()
    }
    
    private func signUpLabelTapped() {
        let signUpLabelTap = UITapGestureRecognizer(target: self, action: #selector(transitionToSignUpScreen))
        toSignUpLabel.isUserInteractionEnabled = true
        toSignUpLabel.addGestureRecognizer(signUpLabelTap)
    }
    
    @objc func transitionToSignUpScreen(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as?  SignUpViewController else { return }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }

    override func viewDidLayoutSubviews() {
        Utilities.stylePrimaryButton(loginButton)
        Utilities.styleCaptionLabel(toSignUpLabel)
        Utilities.styleCaptionLabel(forgotPasswordLabel)
        Utilities.stylePrimaryTextField(emailTextField)
        Utilities.stylePrimaryTextField(passwordTextField)
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        AuthorizationService.signInUserInFirebase(email: email, password: password, vc: self)
    }
    
}

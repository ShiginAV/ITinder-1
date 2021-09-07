//
//  SignUpViewController.swift
//  ITinder
//
//  Created by Daria Tokareva
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatedPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var toLoginLabel: UILabel!
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        loginLabelTapped()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        scrollView.contentSize.height = view.bounds.height + 100
    }
    private func loginLabelTapped() {
        let loginLabelTap = UITapGestureRecognizer(target: self, action: #selector(transitionToLoginScreen))
        toLoginLabel.isUserInteractionEnabled = true
        toLoginLabel.addGestureRecognizer(loginLabelTap)
    }
    @objc func transitionToLoginScreen(_ sender: Any) {
        Router.transitionToLoginVC(parent: self)
    }
    
    override func viewDidLayoutSubviews() {
        Utilities.stylePrimaryButton(signUpButton)
        Utilities.stylePrimaryTextField(emailTextField)
        Utilities.stylePrimaryTextField(passwordTextField)
        Utilities.stylePrimaryTextField(repeatedPasswordTextField)
        Utilities.styleCaptionLabel(toLoginLabel)
        Utilities.styleCaptionLabel(helperLabel)
        helperLabel.text = "Пароль должен содержать не менее 6 символов, буквы или цифры"
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        // Validate the fields
        let errorMessage = validateFields()
        if errorMessage != nil {
            showAlert(title: "Ошибка регистрации", message: errorMessage)
        } else {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // pass email, password and go to the user creation screen
            let creatingUserInfoVC = (storyboard?.instantiateViewController(identifier: "CreatingUserInfoViewController"))! as CreatingUserInfoViewController
            creatingUserInfoVC.userEmail = email
            creatingUserInfoVC.userPassword = password
            
            view.window?.rootViewController = creatingUserInfoVC
            view.window?.makeKeyAndVisible()
        }
    }
    
    private func validateFields() -> String? {
        if (emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            repeatedPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Пожалуйста, заполните все поля регистрации"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false || cleanedPassword.count < 6 {
            return "Пожалуйста, убедитесь, что пароль содержит не менее 6 символов, буквы или цифры"
        }
        
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let repeatedPassword = repeatedPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if password != repeatedPassword {
            return "Пароли не совпадают"
        }
        return nil
    }
}

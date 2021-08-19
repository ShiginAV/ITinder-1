//
//  SignUpViewController.swift
//  ITinder
//
//  Created by Daria Tokareva
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatedPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var toLoginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        Utilities.stylePrimaryButton(signUpButton)
        Utilities.stylePrimaryTextField(emailTextField)
        Utilities.stylePrimaryTextField(passwordTextField)
        Utilities.stylePrimaryTextField(repeatedPasswordTextField)
        Utilities.styleCaptionLabel(toLoginLabel)
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        // Validate the fields
        let errorMessage = validateFields()
        if errorMessage != nil {
            showAlert(title: "Ошибка регистрации", message: errorMessage)
        } else {
            // Create the user
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            AuthorizationService.createUserInFiresore(email: email, password: password, vc: self)
        }
    }
    
    private func validateFields() -> String? {
        if (emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            repeatedPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Пожалуйста, заполните все поля регистрации"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Пожалуйста, убедитесь, что пароль содержит не менее 5 символов"
        }
        
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let repeatedPassword = repeatedPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if password != repeatedPassword {
            return "Пароли не совпадают"
        }
        return nil
    }
}

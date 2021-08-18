//
//  SignUpViewController.swift
//  ITinder
//
//  Created by Daria Tokareva
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatedPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        Utilities.stylePrimaryButton(signUpButton)
        Utilities.stylePrimaryTextField(emailTextField)
        Utilities.stylePrimaryTextField(passwordTextField)
        Utilities.stylePrimaryTextField(repeatedPasswordTextField)
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
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if error != nil {
                    self.showAlert(title: "Ошибка регистрации пользователя", message: nil)
                } else {
                    // clean data
                    let email = self.emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    let uid = result?.user.uid
                    
                    // User was created sucessfully, store uid and email in database
                    let ref = Database.database().reference()
                    ref.child("users/" + result!.user.uid + "/email").setValue(email)
                    ref.child("users/" + result!.user.uid + "/identifier").setValue(uid)
                    
                    self.transitionToNextScreen(uid: (result?.user.uid)!)
                }
            }
        }
    }
    
    private func transitionToNextScreen(uid: String) {
        let creatingUserInfoVC = (storyboard?.instantiateViewController(identifier: "CreatingUserInfoViewController"))! as CreatingUserInfoViewController
        creatingUserInfoVC.userID = uid
        view.window?.rootViewController = creatingUserInfoVC
        view.window?.makeKeyAndVisible()
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

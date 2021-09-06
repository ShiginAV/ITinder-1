//
//  ForgotPasswordViewController.swift
//  ITinder
//
//  Created by Daria Tokareva on 02.09.2021.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let emailTextField = UITextField()
    let sendButton = UIButton()
    let backToAuthLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        style()
        layout()
        sendButtonTapped()
        backLabelTapped()
    }
    
    private func sendButtonTapped() {
        sendButton.addTarget(self, action: #selector(resetPassword(_:)), for: .touchUpInside)
    }
    
    @objc func resetPassword(_ sender: UIButton) {
        guard let cleanedPassword = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        Auth.auth().sendPasswordReset(withEmail: cleanedPassword) { error in
            if error != nil {
                self.showAlert(title: "Ошибка", message: error?.localizedDescription)
                return
            }
            self.showAlert(title: "Готово!", message: "Ссылка для востановления пароля отправлена на ваш электронный адрес")
        }
    }
    
    private func backLabelTapped() {
        backToAuthLabel.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(transitionToAuthScreen(_:)))
        backToAuthLabel.addGestureRecognizer(backTap)
    }
    
    @objc func transitionToAuthScreen(_ sender: Any) {
        Router.transitionToAuthScreen(parent: self)
    }
    
    private func style() {
        view.backgroundColor = .systemBackground
        
        imageView.image = UIImage(named: "lock_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.text = "Не удается выполнить вход?"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        Utilities.styleTitleLabel(titleLabel)
        
        subtitleLabel.text = "Введите адрес электронной почты,\nи мы отправим вам ссылку\n для восстановления доступа к аккаунту."
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        Utilities.styleGrayBodyText(subtitleLabel)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = " Электронный адрес"
        Utilities.stylePrimaryTextField(emailTextField)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTextField.frame.height))
        emailTextField.leftView = paddingView
        emailTextField.leftViewMode = .always
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("отправить", for: .normal)
        Utilities.stylePrimaryButton(sendButton)
        
        backToAuthLabel.translatesAutoresizingMaskIntoConstraints = false
        backToAuthLabel.text = "Вернуться к входу"
        Utilities.styleCaptionLabel(backToAuthLabel)
    }
    
    private func layout() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(sendButton)
        view.addSubview(backToAuthLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/9),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 48),
            emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.449275),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            
            backToAuthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backToAuthLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12)
        ])
    }
}

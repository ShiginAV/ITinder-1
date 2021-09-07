//
//  Utilities.swift
//  ITinder
//
//  Created by Daria Tokareva
//

import Foundation
import UIKit

struct Utilities {
    
    static func stylePrimaryButton(_ button: UIButton) {
        button.backgroundColor = Colors.blueItinderColor
        button.setBackgroundColor(color: UIColor.black.withAlphaComponent(0.2), forState: .highlighted)
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Source Sans Pro", size: 14)
        
        button.setTitle(button.titleLabel?.text?.uppercased(), for: .normal)
        button.layer.cornerRadius = 3
    }

    static func styleSecondaryButton(_ button: UIButton) {
        button.backgroundColor = UIColor.white
        button.tintColor = Colors.blueItinderColor
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.blueItinderColor.cgColor
        button.titleLabel?.font = UIFont(name: "Source Sans Pro", size: 14)
        button.setTitle(button.titleLabel?.text?.uppercased(), for: .normal)
        button.layer.cornerRadius = 3
    }
    
    static func stylePrimaryTextField(_ textField: UITextField) {
        textField.layer.borderColor = Colors.grayItinderColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 3
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    static func stylePrimaryTextView(_ textView: UITextView) {
        textView.layer.borderColor = Colors.grayItinderColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 3
        
    }
    
    static func stylePlaceholderLabel(_ label: UILabel) {
        label.textColor = Colors.lightGrayItinderColor
        label.font = UIFont(name: "Noto Sans Kannada", size: 14)
    }
    
    static func styleCaptionLabel(_ label: UILabel) {
        label.textColor = Colors.grayItinderColor
        label.font = UIFont(name: "Noto Sans Kannada", size: 12)
    }
    
    static func styleOnboardingHeaderText(_ label: UILabel) {
        label.font = UIFont(name: "Noto Sans Kannada", size: 24)
        label.textColor = Colors.blueItinderColor
    }
    
    static func styleOnboardingBodyText(_ label: UILabel) {
        label.textColor = Colors.grayItinderColor
        label.font = UIFont(name: "Noto Sans Kannada", size: 16)
    }
    
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*?[а-яА-Яa-zA-Z0-9]).{5,}$")
        return passwordTest.evaluate(with: password)
    }
    
    static func styleTitleLabel(_ label: UILabel) {
        label.font = UIFont(name: "Noto Sans Kannada", size: 18)
        label.textColor = .black
    }
    
    static func styleGrayBodyText(_ label: UILabel) {
        label.textColor = Colors.grayItinderColor
        label.font = UIFont(name: "Noto Sans Kannada", size: 14)
    }
}

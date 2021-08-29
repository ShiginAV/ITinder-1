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
        button.backgroundColor = #colorLiteral(red: 0.3843137255, green: 0.4823529412, blue: 0.9764705882, alpha: 1)
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Source Sans Pro", size: 14)
        
        button.setTitle(button.titleLabel?.text?.uppercased(), for: .normal)
        button.layer.cornerRadius = 3
    }

    static func styleSecondaryButton(_ button: UIButton) {
        button.backgroundColor = UIColor.white
        button.tintColor = #colorLiteral(red: 0.3843137255, green: 0.4823529412, blue: 0.9764705882, alpha: 1)
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.3843137255, green: 0.4823529412, blue: 0.9764705882, alpha: 1)
        button.titleLabel?.font = UIFont(name: "Source Sans Pro", size: 14)
        button.setTitle(button.titleLabel?.text?.uppercased(), for: .normal)
        button.layer.cornerRadius = 3
    }
    
    static func stylePrimaryTextField(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0.5764705882, green: 0.5843137255, blue: 0.5921568627, alpha: 1)
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 3
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    static func stylePrimaryTextView(_ textView: UITextView) {
        textView.layer.borderColor = #colorLiteral(red: 0.5764705882, green: 0.5843137255, blue: 0.5921568627, alpha: 1)
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 3
        
    }
    
    static func stylePlaceholderLabel(_ label: UILabel) {
        label.textColor = #colorLiteral(red: 0.6943192482, green: 0.6901938915, blue: 0.6974917054, alpha: 1)
        label.font = UIFont(name: "Noto Sans Kannada", size: 14)
    }
    
    static func styleCaptionLabel(_ label: UILabel) {
        label.textColor = #colorLiteral(red: 0.5764705882, green: 0.5843137255, blue: 0.5921568627, alpha: 1)
        label.font = UIFont(name: "Noto Sans Kannada", size: 12)
    }
    
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*?[а-яА-Яa-zA-Z0-9]).{5,}$")
        return passwordTest.evaluate(with: password)
    }
}

//
//  CreatingUserInfoViewController.swift
//  ITinder
//
//  Created by Daria Tokareva
//

import UIKit
import Firebase
import FirebaseStorage

class CreatingUserInfoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var userInfoTextView: UITextView!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    var userID = "default"
    var photoSelectedFlag = false
    let userEmail = Auth.auth().currentUser?.email
    private var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        userInfoTextView.delegate = self
        
        profileImageTapped()
    }
    
    private func validateFields() -> String? {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                surnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                dateOfBirthTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                positionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                userInfoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Пожалуйста, заполните все поля регистрации"
        }
        if photoSelectedFlag == false {
            return "Пожалуйста, выберите фото профиля"
        }
        return nil
    }
    
    private func profileImageTapped() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.clipsToBounds = true
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    @objc func openImagePicker(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let errorMessage = validateFields()
        if errorMessage != nil {
            showAlert(title: "Ошибка регистрации", message: errorMessage)
        } else {
            createUserData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        Utilities.stylePrimaryButton(signUpButton)
        Utilities.stylePrimaryTextField(nameTextField)
        Utilities.stylePrimaryTextField(surnameTextField)
        Utilities.stylePrimaryTextField(dateOfBirthTextField)
        Utilities.stylePrimaryTextField(positionTextField)
        Utilities.stylePrimaryTextView(userInfoTextView)
        Utilities.styleCaptionLabel(captionLabel)
        Utilities.stylePlaceholderLabel(userInfoLabel)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
    }
    
    private func createUserData() {
        let ref = Database.database().reference()
        let cleanedName = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSurname = surnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBirthday = dateOfBirthTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPosition = positionTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedUserInfo = userInfoTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines) as NSString

        self.upload( photo: profileImageView.image!) { url in
            ref.child("users/" + self.userID + "/name").setValue(cleanedName + " " + cleanedSurname)
            ref.child("users/" + self.userID + "/birthDate").setValue(cleanedBirthday)
            ref.child("users/" + self.userID + "/position").setValue(cleanedPosition)
            ref.child("users/" + self.userID + "/description").setValue(cleanedUserInfo)
            ref.child("users/" + self.userID + "/imageUrl").setValue(url?.absoluteString ?? "defaultURL")
        }
        
        Router.transitionToMainTabBar(view: view, storyboard: storyboard) // в комплешн
        // тут дергать сервис узерсервис, в комплишне транзитор
    }
    
    func upload(photo: UIImage, completion: @escaping ((_ url:URL?) -> Void)) {
        if photoSelectedFlag == true {
            let ref = Storage.storage().reference().child("Avatars").child(userID)
            
            guard let imageData = profileImageView.image?.jpegData(compressionQuality: 0.5) else { return }
            let metadata1 = StorageMetadata()
            metadata1.contentType = "image/jpeg"
            
            ref.putData(imageData, metadata: metadata1) { metadata, _ in
                guard metadata != nil else {
                    completion(nil)
                    return
                }
                ref.downloadURL { url, _ in
                    guard let url = url else {
                        completion(nil)
                        return
                    }
                    completion(url)
                }
            }
        }
        completion(nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        userInfoLabel.isHidden = !textView.text.isEmpty
    }
}

extension CreatingUserInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = pickedImage
            photoSelectedFlag = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

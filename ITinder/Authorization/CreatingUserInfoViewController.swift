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
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    let dataPicker = UIDatePicker()
    let activityView = UIActivityIndicatorView(style: .medium)
    var userID = "default"
    var userEmail = "default"
    var userPassword = "default"
    var photoSelectedFlag = false
    private var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userInfoTextView.delegate = self
        
        profileImageTapped()
        self.hideKeyboardWhenTappedAround()
        createDataPickerView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        scrollView.contentSize.height = view.bounds.height + 150
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
        signUpButton.isEnabled = false
        let errorMessage = validateFields()
        if errorMessage != nil {
            showAlert(title: "Ошибка регистрации", message: errorMessage)
            signUpButton.isEnabled = true
        } else {
            self.showActivityIndicatory()
            
            // authorize in firebase authentication
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { result, error in
                if error != nil {
                    self.showAlert(title: "Ошибка регистрации пользователя", message: error?.localizedDescription)
                    self.signUpButton.isEnabled = true
                    self.stopShowActivityIndicatory()
                    return
                } else {
                    // User was created sucessfully, store uid and email in database
                    let ref = Database.database().reference()
                    if let result = result {
                        self.userID = result.user.uid
                        ref.child("users/" + self.userID + "/email").setValue(self.userEmail)
                        ref.child("users/" + self.userID + "/identifier").setValue(self.userID)
                        
                        // create a user structure, fill it with data
                        let cleanedName = self.nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanedSurname = self.surnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanedBirthday = self.dateOfBirthTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanedPosition = self.positionTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanedUserInfo = self.userInfoTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines) as NSString
                        let itinderUser = User(identifier: result.user.uid,
                                               email: result.user.email!,
                                               imageUrl: "",
                                               name: cleanedName,
                                               position: cleanedPosition,
                                               description: cleanedUserInfo as String,
                                               birthDate: cleanedBirthday,
                                               city: nil,
                                               education: nil,
                                               company: nil,
                                               employment: nil,
                                               statusList: [:])
                        
                        UserService.persist(user: itinderUser, withImage: self.profileImageView.image) { user in
                            // add user to firebase realtime
                            let ref = Database.database().reference()
                            let url = user?.imageUrl
                            ref.child("users/" + self.userID + "/name").setValue(cleanedName + " " + cleanedSurname)
                            ref.child("users/" + self.userID + "/birthDate").setValue(cleanedBirthday)
                            ref.child("users/" + self.userID + "/position").setValue(cleanedPosition)
                            ref.child("users/" + self.userID + "/description").setValue(cleanedUserInfo)
                            ref.child("users/" + self.userID + "/imageUrl").setValue(url ?? "defaultURL")
                            
                            self.signUpButton.isEnabled = true
                            self.stopShowActivityIndicatory()
                            Router.transitionToMainTabBar(view: self.view, storyboard: self.storyboard)
                        }
                    } else {
                        self.signUpButton.isEnabled = true
                        self.stopShowActivityIndicatory()
                        self.showAlert(title: "Ошибка регистрации пользователя", message: error?.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    private func showActivityIndicatory() {
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    private func createDataPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonInDatapickerTapped(_:)))
        doneButton.tintColor = Utilities.blueItinderColor
        toolBar.setItems([doneButton], animated: true)
        dateOfBirthTextField.inputAccessoryView = toolBar
        dateOfBirthTextField.inputView = dataPicker
        dataPicker.datePickerMode = .date
        if #available(iOS 14, *) {
            dataPicker.preferredDatePickerStyle = .wheels
        }
    }
    
    @objc func doneButtonInDatapickerTapped(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        dateOfBirthTextField.text = formatter.string(from: dataPicker.date)
        self.view.endEditing(true)
    }
    
    private func stopShowActivityIndicatory() {
        activityView.stopAnimating()
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
        backButton.setTitle("назад", for: .normal)
        backButton.setTitleColor(Utilities.blueItinderColor, for: .normal)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
    }
    
    func textViewDidChange(_ textView: UITextView) {
        userInfoLabel.isHidden = !textView.text.isEmpty
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        Router.transitionToSignUpVC(parent: self, storyboard: storyboard)
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

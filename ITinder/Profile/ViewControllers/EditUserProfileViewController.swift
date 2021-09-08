//
//  EditUserProfileViewController.swift
//  ITinder
//
//  Created by Alexander on 09.08.2021.
//

import UIKit

final class EditUserProfileViewController: UIViewController {
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        notifications?.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        hideKeyboardWhenTappedAround()
        addKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private var user: User
    private var characteristicsDict = [String: Any]()
    private let padding: CGFloat = 20
    private var isImageChanged = false
    private var scrollViewBottomC: NSLayoutConstraint?
    private var notifications: [NSObjectProtocol]?
    private let descriptionPlaceholder = "Добавить информацию о себе"
    
    private lazy var loaderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        
        let spinner = UIActivityIndicatorView()
        spinner.frame.origin = self.view.center
        spinner.color = .white
        spinner.startAnimating()
        view.addSubview(spinner)
        return view
    }()
    
    private lazy var profileImageView: CustomImageView = {
        let view = CustomImageView()
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        let gr = UITapGestureRecognizer(target: self, action: #selector(profileImageDidTap))
        view.addGestureRecognizer(gr)
        view.loadImage(from: URL(string: user.imageUrl))
        return view
    }()
    
    private lazy var characteristicsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private lazy var descriptionView: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.text = descriptionPlaceholder
        view.textColor = .lightGray
        view.delegate = self
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .white
        view.alwaysBounceVertical = true
        
        view.gestureRecognizers?.forEach {
            $0.delaysTouchesBegan = true
            $0.cancelsTouchesInView = false
        }
        return view
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(Colors.primary, for: .normal)
        button.setTitleColor(Colors.primary.withAlphaComponent(0.5), for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(Colors.primary, for: .normal)
        button.setTitleColor(Colors.primary.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private func configure() {
        view.backgroundColor = .white
        [cancelButton, doneButton, scrollView, loaderView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        [profileImageView, characteristicsStackView, descriptionView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }
        
        NSLayoutConstraint.activate([
            loaderView.topAnchor.constraint(equalTo: view.topAnchor),
            loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            
            scrollView.topAnchor.constraint(equalTo: doneButton.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 160),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            characteristicsStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: padding * 2),
            characteristicsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            characteristicsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            characteristicsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding * 2),
            
            descriptionView.heightAnchor.constraint(equalToConstant: 150)
        ])
        scrollViewBottomC = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        scrollViewBottomC?.isActive = true
        addCharacteristicsToStack()
    }
    
    private func addCharacteristicsToStack() {
        СharacteristicType.allCases.forEach { type in
            let characteristic = EditСharacteristicView(type: type)
            characteristic.delegate = self
            characteristicsStackView.addArrangedSubview(characteristic)
            fill(characteristic, by: type)
        }
        characteristicsStackView.addArrangedSubview(descriptionView)
    }
    
    private func fill(_ characteristic: EditСharacteristicView, by type: СharacteristicType) {
        switch type {
        case .name:
            characteristic.text = user.name
        case .position:
            characteristic.text = user.position
        case .birthDate:
            characteristic.text = user.birthDate
        case .company:
            characteristic.text = user.company
        case .education:
            characteristic.text = user.education
        case .city:
            characteristic.text = user.city
        case .employment:
            characteristic.text = user.employment
        }
        if let description = user.description, description != "" {
            descriptionView.text = user.description
            descriptionView.textColor = .black
        }
    }
    
    private func showImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func addKeyboardNotifications() {
        let keyboardDidShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                                                             object: nil,
                                                                             queue: nil) { [weak self] notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self?.scrollViewBottomC?.constant = -keyboardHeight
            self?.view.layoutIfNeeded()
        }
        let keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                                                              object: nil,
                                                                              queue: nil) { [weak self] _ in
            self?.scrollViewBottomC?.constant = 0
        }
        notifications = [keyboardDidShowObserver, keyboardWillHideObserver]
    }
    
    @objc private func doneButtonDidTap() {
        view.endEditing(true)
        
        loaderView.isHidden = false
        let image = isImageChanged ? profileImageView.image : nil
        
        UserService.update(by: characteristicsDict, withImage: image) { [weak self] newUser in
            guard let self = self else { return }
            guard let newUser = newUser else {
                self.loaderView.isHidden = true
                return
            }
            
            guard let tabBarController = self.presentingViewController as? UITabBarController else { return }
            guard let userProfileVC = tabBarController.viewControllers?.last as? UserProfileViewController else { return }
            userProfileVC.user = newUser
            
            self.dismiss(animated: true)
        }
    }
    
    @objc private func cancelButtonDidTap() {
        dismiss(animated: true)
    }
    
    @objc private func profileImageDidTap() {
        showImagePicker()
    }
}

extension EditUserProfileViewController: EditСharacteristicDelegate {
    func textDidChange(type: СharacteristicType, text: String?) {
        switch type {
        case .name, .position:
            doneButton.isEnabled = (text != nil && text != "")
        case .birthDate, .company, .education, .city, .employment:
            doneButton.isEnabled = true
        }
    }
    
    func textDidEndEditing(type: СharacteristicType, text: String?) {
        switch type {
        case .name:
            guard let text = text, text != "" else { return }
            characteristicsDict[nameKey] = text
        case .position:
            guard let text = text, text != "" else { return }
            characteristicsDict[positionKey] = text
        case .birthDate:
            characteristicsDict[birthDateKey] = text
        case .company:
            characteristicsDict[companyKey] = text
        case .education:
            characteristicsDict[educationKey] = text
        case .city:
            characteristicsDict[cityKey] = text
        case .employment:
            characteristicsDict[employmentKey] = text
        }
    }
}

extension EditUserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        profileImageView.image = image
        isImageChanged = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditUserProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        doneButton.isEnabled = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = descriptionPlaceholder
            textView.textColor = .lightGray
        } else {
            characteristicsDict[descriptionKey] = textView.text
        }
    }
}

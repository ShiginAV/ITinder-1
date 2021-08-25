//
//  UserProfileViewController.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

final class UserProfileViewController: UIViewController {
    
    var user: User? {
        didSet { fill() }
    }
    
    init(user: User?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        title = "Profile"
        tabBarItem.image = UIImage(systemName: "person.crop.circle")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fill()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private var isLoading: Bool = false {
        didSet { loaderView.isHidden = !isLoading }
    }
    
    private var isOwner: Bool = false {
        didSet {
            characteristicStackTopC?.isActive = isOwner
            characteristicStackNoOwnerTopC?.isActive = !isOwner
            
            settingsButton.isHidden = !isOwner
            settingsLabel.isHidden = !isOwner
            editButton.isHidden = !isOwner
            editLabel.isHidden = !isOwner
        }
    }
    
    private let padding: CGFloat = 40
    private var characteristicStackTopC: NSLayoutConstraint?
    private var characteristicStackNoOwnerTopC: NSLayoutConstraint?
    
    private var characteristics = [СharacteristicType: ProfileCharacteristicView]()
    
    private lazy var loaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        let spinner = UIActivityIndicatorView()
        spinner.frame.origin = self.view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        return view
    }()
    
    private let profileImageView: CustomImageView = {
        let view = CustomImageView()
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let settingsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.text = "настройки"
        return label
    }()
    
    private let editLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.text = "изменить"
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(UserProfileIcons.settingsButton.image, for: .normal)
        button.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UserProfileIcons.editButton.image, for: .normal)
        button.addTarget(self, action: #selector(editButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let characteristicStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let descriptionView: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.isEditable = false
        return view
    }()
    
    private func configure() {
        view.backgroundColor = .white
        
        addCharacteristics()
        
        [profileImageView,
         settingsButton,
         settingsLabel,
         editButton,
         editLabel,
         nameLabel,
         characteristicStack,
         descriptionView,
         loaderView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        
        NSLayoutConstraint.activate([
            loaderView.topAnchor.constraint(equalTo: view.topAnchor),
            loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 160),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            settingsButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            settingsButton.widthAnchor.constraint(equalToConstant: 60),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            
            settingsLabel.topAnchor.constraint(equalTo: settingsButton.bottomAnchor),
            settingsLabel.centerXAnchor.constraint(equalTo: settingsButton.centerXAnchor),
            
            editButton.topAnchor.constraint(equalTo: settingsButton.topAnchor),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            editButton.widthAnchor.constraint(equalToConstant: 60),
            editButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            
            editLabel.topAnchor.constraint(equalTo: editButton.bottomAnchor),
            editLabel.centerXAnchor.constraint(equalTo: editButton.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: settingsButton.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: settingsButton.bottomAnchor),
            
            characteristicStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            characteristicStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            descriptionView.topAnchor.constraint(equalTo: characteristicStack.bottomAnchor, constant: 40),
            descriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            descriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            descriptionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        characteristicStackTopC = characteristicStack.topAnchor.constraint(equalTo: settingsLabel.bottomAnchor, constant: 40)
        characteristicStackNoOwnerTopC = characteristicStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 40)
    }
    
    private func fill() {
        guard let user = user else {
            isLoading = true
            return
        }
        isLoading = false
        
        profileImageView.loadImage(from: URL(string: user.imageUrl))
        nameLabel.text = user.name
        descriptionView.text = user.description
        fillCharacteristics()
        isOwner = user.identifier == UserService.currentUserId
        view.layoutIfNeeded()
    }
    
    private func addCharacteristics() {
        СharacteristicType.allCases.forEach { type in
            let characteristic = ProfileCharacteristicView(type: type)
            characteristicStack.addArrangedSubview(characteristic)
            characteristics[type] = characteristic
        }
    }
    
    private func fillCharacteristics() {
        guard let user = user else { return }
        СharacteristicType.allCases.forEach { type in
            switch type {
            case .name:
                characteristics[type]?.text = nil
            case .position:
                characteristics[type]?.text = user.position
            case .birthDate:
                characteristics[type]?.text = user.birthDate ?? ""
            case .company:
                characteristics[type]?.text = user.company ?? ""
            case .education:
                characteristics[type]?.text = user.education ?? ""
            case .city:
                characteristics[type]?.text = user.city ?? ""
            case .employment:
                characteristics[type]?.text = user.employment ?? ""
            }
        }
    }
    
    @objc private func settingsButtonDidTap() {
        
    }
    
    @objc private func editButtonDidTap() {
        guard let user = user else { return }
        Router.showEditUserProfile(parent: self, user: user)
    }
}

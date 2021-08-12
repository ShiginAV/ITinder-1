//
//  UserProfileViewController.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

final class UserProfileViewController: UIViewController {
    
    init(user: User?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fill()
        isOwner = user?.isOwner ?? false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private let user: User?
    
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
    
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .systemPink
        return image
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
    
    private func fill() {
        nameLabel.text = user?.name
        descriptionView.text = user?.description
    }
    
    private func configure() {
        view.backgroundColor = .white
        
        [profileImageView,
         settingsButton,
         settingsLabel,
         editButton,
         editLabel,
         nameLabel,
         characteristicStack,
         descriptionView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        
        NSLayoutConstraint.activate([
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
            
            descriptionView.topAnchor.constraint(equalTo: characteristicStack.bottomAnchor, constant: 10),
            descriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            descriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            descriptionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        characteristicStackTopC = characteristicStack.topAnchor.constraint(equalTo: settingsLabel.bottomAnchor, constant: 40)
        characteristicStackNoOwnerTopC = characteristicStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 40)
        
        addAndFillCharacteristics()
    }
    
    private func addAndFillCharacteristics() {
        guard let user = user else { return }
        СharacteristicType.allCases.forEach { type in
            let label = UILabel()
            let title = type.text + ": "
            var subtitle: String = ""
            
            switch type {
            case .name:
                return
            case .position:
                guard user.position != "" else { return }
                subtitle = user.position
            case .birthDate:
                guard let birthDate = user.birthDate, birthDate != "" else { return }
                subtitle = birthDate
            case .company:
                guard let company = user.company, company != "" else { return }
                subtitle = company
            case .education:
                guard let education = user.education, education != "" else { return }
                subtitle = education
            case .city:
                guard let city = user.city, city != "" else { return }
                subtitle = city
            case .employment:
                guard let employment = user.employment, employment != "" else { return }
                subtitle = employment
            }
            let titleAttrStr = NSMutableAttributedString(string: title,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                      .foregroundColor: UIColor.darkGray])
            let subtitleAttrStr = NSMutableAttributedString(string: subtitle,
                                                            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                         .foregroundColor: UIColor.black])
            titleAttrStr.append(subtitleAttrStr)
            label.attributedText = titleAttrStr
            characteristicStack.addArrangedSubview(label)
        }
    }
    
    @objc private func settingsButtonDidTap() {
        
    }
    
    @objc private func editButtonDidTap() {
        guard let user = user else { return }
        Router.showEditUserProfile(parent: self, user: user)
    }
}

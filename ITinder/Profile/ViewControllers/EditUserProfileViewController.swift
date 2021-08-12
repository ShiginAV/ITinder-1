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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private var isDoneButtonEnabled: Bool = false {
        didSet {
            doneButton.isUserInteractionEnabled = isDoneButtonEnabled
            let titleColor = isDoneButtonEnabled ? UIColor.systemBlue : .lightGray
            doneButton.setTitleColor(titleColor, for: .normal)
        }
    }
    
    private var user: User
    private let padding: CGFloat = 20
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.alwaysBounceVertical = true
        return view
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(Colors.blue, for: .normal)
        button.setTitleColor(Colors.blue.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private func configure() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        [doneButton, stackView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            doneButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            stackView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: padding),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        addCharacteristicsToStack()
    }
    
    private func addCharacteristicsToStack() {
        СharacteristicType.allCases.forEach {
            let characteristic = EditСharacteristicView(type: $0)
            characteristic.delegate = self
            stackView.addArrangedSubview(characteristic)
            fill(characteristic, by: $0)
        }
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
    }
    
    @objc private func doneButtonDidTap() {
        UserService.shared.persist(user)
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditUserProfileViewController: EditСharacteristicDelegate {
    func textDidChange(type: СharacteristicType, text: String?) {
        switch type {
        case .name, .position:
            isDoneButtonEnabled = (text != nil && text != "")
        case .birthDate, .company, .education, .city, .employment:
            isDoneButtonEnabled = true
        }
    }
    
    func textDidEndEditing(type: СharacteristicType, text: String?) {
        switch type {
        case .name:
            guard let text = text, text != "" else { return }
            user.name = text
        case .position:
            guard let text = text, text != "" else { return }
            user.position = text
        case .birthDate:
            user.birthDate = text
        case .company:
            user.company = text
        case .education:
            user.education = text
        case .city:
            user.city = text
        case .employment:
            user.employment = text
        }
    }
}

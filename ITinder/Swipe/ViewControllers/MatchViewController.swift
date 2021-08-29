//
//  MatchViewController.swift
//  ITinder
//
//  Created by Alexander on 27.08.2021.
//

import UIKit

final class MatchViewController: UIViewController {
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileGradientLayer.frame = profileGradientView.bounds
    }
    
    private let user: User?
    
    private lazy var profileImageView: CustomImageView = {
        let view = CustomImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .lightGray
        view.loadImage(from: URL(string: user?.imageUrl ?? ""))
        return view
    }()
    
    private let profileGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.2, 0.4, 1]
        gradient.colors = [Colors.primary.withAlphaComponent(0).cgColor,
                           Colors.primary.cgColor,
                           Colors.primary.cgColor,
                           UIColor.black.withAlphaComponent(0.3).cgColor]
        return gradient
    }()
    
    private lazy var profileGradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.addSublayer(profileGradientLayer)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "У ВАС НОВЫЙ"
        return label
    }()
    
    private let matchLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        let font = UIFont(name: "Arial-BoldMT", size: 64) ?? UIFont.systemFont(ofSize: 64, weight: .bold)
        let attrStr = NSAttributedString(string: "MATCH!",
                                         attributes: [.strokeColor: UIColor.white,
                                                      .foregroundColor: UIColor.clear,
                                                      .strokeWidth: -2.0,
                                                      .font: font])
        label.attributedText = attrStr
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "\(user?.name ?? "") тоже выбрал вас"
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(SwipeCardIcons.closeButton.image, for: .normal)
        button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private func configure() {
        view.backgroundColor = Colors.primary
        
        [profileImageView, profileGradientView, titleLabel, matchLabel, nameLabel, closeButton].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            profileGradientView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -100),
            profileGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: profileGradientView.topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            matchLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            matchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            matchLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            nameLabel.topAnchor.constraint(greaterThanOrEqualTo: matchLabel.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor)
        ])
    }
    
    @objc private func closeButtonDidTap() {
        dismiss(animated: true)
    }
}

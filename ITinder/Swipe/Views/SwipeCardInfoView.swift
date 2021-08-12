//
//  SwipeCardInfoView.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

final class SwipeCardInfoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var infoButtonDidTap: (() -> Void)?
    
    func fill(_ card: SwipeCardModel) {
        nameLabel.text = card.name
        positionLabel.text = card.position
        descriptionView.text = card.description
    }
    
    private let padding: CGFloat = 40
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private let positionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionView: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.isEditable = false
        return view
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(SwipeCardIcons.infoButton.image, for: .normal)
        button.addTarget(self, action: #selector(onInfoButtonTap), for: .touchUpInside)
        return button
    }()
    
    private func configure() {
        backgroundColor = .clear
        
        [infoButton, nameLabel, positionLabel, descriptionView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
        }
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding + 10),
            infoButton.widthAnchor.constraint(equalToConstant: 44),
            infoButton.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor),
            
            positionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            positionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            positionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionView.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 4),
            descriptionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            descriptionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            descriptionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func onInfoButtonTap() {
        infoButtonDidTap?()
    }
}

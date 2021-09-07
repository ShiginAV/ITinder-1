//
//  SwipeButtonsView.swift
//  ITinder
//
//  Created by Alexander on 06.09.2021.
//

import UIKit

protocol SwipeButtonsViewDelegate: AnyObject {
    func likeDidTap()
    func dislikeDidTap()
    func returnDidTap()
}

final class SwipeButtonsView: UIView {
    weak var delegate: SwipeButtonsViewDelegate?
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var returnButtonIsHidden: Bool = true {
        didSet { returnButton.isHidden = returnButtonIsHidden }
    }
    
    var isButtonsEnabled: Bool = false {
        didSet {
            returnButton.isEnabled = isButtonsEnabled
            dislikeButton.isEnabled = isButtonsEnabled
            likeButton.isEnabled = isButtonsEnabled
        }
    }
    
    private let returnButton: UIButton = {
        let button = UIButton()
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium)
        let image = UIImage(systemName: "arrowshape.turn.up.backward.fill", withConfiguration: config)

        button.setImage(image, for: .normal)
        button.tintColor = Colors.primary
        button.addTarget(self, action: #selector(returnDidTap), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let dislikeButton: UIButton = {
        let button = UIButton()
        button.setImage(SwipeCardIcons.dislikeButton.image, for: .normal)
        button.setImage(SwipeCardIcons.dislikeButtonActive.image, for: .highlighted)
        button.addTarget(self, action: #selector(dislikeDidTap), for: .touchUpInside)
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(SwipeCardIcons.likeButton.image, for: .normal)
        button.setImage(SwipeCardIcons.likeButtonActive.image, for: .highlighted)
        button.addTarget(self, action: #selector(likeDidTap), for: .touchUpInside)
        return button
    }()
    
    private func configure() {
        [returnButton, dislikeButton, likeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            returnButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            returnButton.centerYAnchor.constraint(equalTo: dislikeButton.centerYAnchor),
            
            dislikeButton.topAnchor.constraint(equalTo: topAnchor),
            dislikeButton.leadingAnchor.constraint(equalTo: returnButton.trailingAnchor, constant: 20),
            dislikeButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            likeButton.topAnchor.constraint(equalTo: topAnchor),
            likeButton.leadingAnchor.constraint(equalTo: dislikeButton.trailingAnchor, constant: 44),
            likeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -57),
            likeButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func returnDidTap() {
        delegate?.returnDidTap()
    }
    
    @objc private func dislikeDidTap() {
        delegate?.dislikeDidTap()
    }
    
    @objc private func likeDidTap() {
        delegate?.likeDidTap()
    }
}

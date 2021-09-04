//
//  SwipeProfileContainerView.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

final class SwipeProfileContainerView: UIView {
    
    weak var delegate: SwipeCardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(_ cards: [SwipeCardModel]) {
        cards.forEach { add(card: $0) }
    }
    
    func addToFirst(card: SwipeCardModel) {
        let cardView = SwipeCardView()
        cardView.layer.frame = bounds
        cardView.delegate = self
        cardView.fill(card)
        
        addSubview(cardView)
        loadedCards.insert(cardView, at: 0)
        
        layoutIfNeeded()
    }
    
    private var isButtonsEnabled: Bool = false {
        didSet {
            likeButton.isEnabled = isButtonsEnabled
            dislikeButton.isEnabled = isButtonsEnabled
        }
    }
    
    private var loadedCards = [SwipeCardView]()
    
    private let buttonsStakView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 44
        return stack
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(SwipeCardIcons.likeButton.image, for: .normal)
        button.setImage(SwipeCardIcons.likeButtonActive.image, for: .highlighted)
        button.addTarget(self, action: #selector(likeDidTap), for: .touchUpInside)
        return button
    }()
    
    private let dislikeButton: UIButton = {
        let button = UIButton()
        button.setImage(SwipeCardIcons.dislikeButton.image, for: .normal)
        button.setImage(SwipeCardIcons.dislikeButtonActive.image, for: .highlighted)
        button.addTarget(self, action: #selector(dislikeDidTap), for: .touchUpInside)
        return button
    }()
    
    private func configure() {
        buttonsStakView.addArrangedSubview(dislikeButton)
        buttonsStakView.addArrangedSubview(likeButton)
        buttonsStakView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonsStakView)
        NSLayoutConstraint.activate([
            buttonsStakView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsStakView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func add(card: SwipeCardModel) {
        let cardView = SwipeCardView()
        cardView.layer.frame = bounds
        cardView.delegate = self
        cardView.fill(card)
        
        insertSubview(cardView, at: 0)
        loadedCards.append(cardView)
        
        layoutIfNeeded()
    }
    
    @objc private func likeDidTap() {
        isButtonsEnabled = false
        guard let cardView = loadedCards.first else { return }
        cardView.swipeCardToRight()
    }
    
    @objc private func dislikeDidTap() {
        isButtonsEnabled = false
        guard let cardView = loadedCards.first else { return }
        cardView.swipeCradToLeft()
    }
}

extension SwipeProfileContainerView: SwipeCardDelegate {
    func profileInfoDidTap() {
        delegate?.profileInfoDidTap()
    }
    
    func swipeDidEnd(type: SwipeCardType) {
        delegate?.swipeDidEnd(type: type)
        loadedCards.removeFirst()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isButtonsEnabled = true
        }
    }
}

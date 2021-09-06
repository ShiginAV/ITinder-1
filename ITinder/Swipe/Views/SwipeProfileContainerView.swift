//
//  SwipeProfileContainerView.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

protocol SwipeProfileContainerViewDelegate: SwipeCardDelegate {
    func returnButtonDidTap()
}

final class SwipeProfileContainerView: UIView {
    
    weak var delegate: SwipeProfileContainerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var returnButtonIsHidden: Bool = true {
        didSet { swipeButtonsView.returnButtonIsHidden = returnButtonIsHidden }
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
        
        bringSubviewToFront(swipeButtonsView)
        layoutIfNeeded()
    }
    
    func removeAllCards() {
        loadedCards.forEach { $0.removeFromSuperview() }
        loadedCards.removeAll()
    }
    
    private var loadedCards = [SwipeCardView]()
    
    private lazy var swipeButtonsView: SwipeButtonsView = {
        let view = SwipeButtonsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private func configure() {
        addSubview(swipeButtonsView)
        
        NSLayoutConstraint.activate([
            swipeButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            swipeButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor)
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
}

extension SwipeProfileContainerView: SwipeCardDelegate {
    func profileInfoDidTap() {
        delegate?.profileInfoDidTap()
    }
    
    func swipeDidEnd(type: SwipeCardType) {
        delegate?.swipeDidEnd(type: type)
        loadedCards.removeFirst()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.swipeButtonsView.isButtonsEnabled = true
        }
    }
}

extension SwipeProfileContainerView: SwipeButtonsViewDelegate {
    func returnDidTap() {
        delegate?.returnButtonDidTap()
    }
    
    func dislikeDidTap() {
        swipeButtonsView.isButtonsEnabled = false
        guard let cardView = loadedCards.first else { return }
        cardView.swipeCradToLeft()
    }
    
    func likeDidTap() {
        swipeButtonsView.isButtonsEnabled = false
        guard let cardView = loadedCards.first else { return }
        cardView.swipeCardToRight()
    }
}

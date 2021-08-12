//
//  SwipeViewController.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

class SwipeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addCards()
    }
    
    private let cardsLimit = 3
    private var cards = [SwipeCardModel]()
    private var lastUserId = "1"
    
    private lazy var profileContainerView: SwipeProfileContainerView = {
        let view = SwipeProfileContainerView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func configure() {
        view.backgroundColor = .white
        
        view.addSubview(profileContainerView)
        NSLayoutConstraint.activate([
            profileContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addCards() {
        UserService.shared.getNextUsers(usersCount: cardsLimit) { [weak self] users in
            guard let self = self else { return }
            guard let users = users else {
                // TODO: show empty shimmer "new users not found"
                return
            }
            
            var colors = [UIColor.systemBlue, .systemYellow, .systemGray] // for debug
            let cardModels = users
                .compactMap { $0 }
                .map { SwipeCardModel(from: $0, color: colors.removeFirst()) }
            
            self.profileContainerView.fill(cardModels)
            self.cards.append(contentsOf: cardModels)
        }
    }
}

extension SwipeViewController: SwipeCardDelegate {
    func profileInfoDidTap() {
        guard let currentUserId = cards.first?.userId else { return }
        UserService.shared.getUserBy(id: currentUserId) { user in
            Router.showUserProfile(user: user, parent: self)
        }
    }
    
    func swipeDidEnd() {
        cards.removeFirst()
        
        if cards.count < cardsLimit - 1 {
            addCards()
        }
    }
}

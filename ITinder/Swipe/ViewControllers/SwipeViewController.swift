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
        addMatchesObserver()
    }
    
    private let cardsLimit = 3
    private var cards = [SwipeCardModel]()
    
    private var shownUserId: String? {
        cards.first?.userId
    }
    
    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                loaderView.startAnimating()
            } else {
                loaderView.stopAnimating()
            }
        }
    }
    
    private let loaderView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    private let emptyShimmerView: EmptyShimmerView = {
        let view = EmptyShimmerView()
        view.isHidden = true
        return view
    }()
    
    private lazy var profileContainerView: SwipeProfileContainerView = {
        let view = SwipeProfileContainerView()
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("reset", for: .normal)
        button.setTitleColor(Colors.primary, for: .normal)
        button.setTitleColor(Colors.primary.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(resetButtonDidTap), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private func configure() {
        view.backgroundColor = .white
        
        [loaderView, profileContainerView, emptyShimmerView, resetButton].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        NSLayoutConstraint.activate([
            loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            profileContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyShimmerView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyShimmerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyShimmerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyShimmerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            resetButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func addCards() {
        isLoading = true
        UserService.getNextUsers(usersCount: cardsLimit) { [weak self] users in
            guard let self = self else { return }
            
            guard let users = users else {
                self.isLoading = false
                self.showEmptyShimmer()
                return
            }
            
            let cardModels = users
                .compactMap { $0 }
                .map { SwipeCardModel(from: $0) }
            
            self.profileContainerView.fill(cardModels)
            self.cards.append(contentsOf: cardModels)
            self.isLoading = false
            self.profileContainerView.isHidden = false
        }
    }
    
    private func showEmptyShimmer() {
        if cards.isEmpty {
            emptyShimmerView.isHidden = false
            profileContainerView.isHidden = true
            resetButton.isHidden = false
        }
    }
    
    @objc private func resetButtonDidTap() {
        UserService.resetUsers { [weak self] isDone in
            guard isDone, let self = self else { return }
            self.addCards()
            self.resetButton.isHidden = true
            self.emptyShimmerView.isHidden = true
        }
    }
}

extension SwipeViewController: SwipeCardDelegate {
    func profileInfoDidTap() {
        guard let shownUserId = shownUserId else { return }
        UserService.getUserBy(id: shownUserId) { user in
            Router.showUserProfile(user: user, parent: self)
        }
    }
    
    func swipeDidEnd(type: SwipeCardType) {
        setLikeAndMatchIfNeeded(type: type)
        
        cards.removeFirst()
        
        if !isLoading && cards.count < cardsLimit {
            addCards()
        }
    }
    
    private func setLikeAndMatchIfNeeded(type: SwipeCardType) {
        if type == .like {
            guard let currentUserId = UserService.currentUserId else { return }
            guard let shownUserId = shownUserId else { return }
            
            UserService.set(like: currentUserId, forUserId: shownUserId) { user in
                UserService.setMatchIfNeededWith(likedUser: user) { user in
                    guard let user = user else { return }
                    Router.showMatch(user: user, parent: self)
                }
            }
        }
    }
    
    private func addMatchesObserver() {
        UserService.observeMatches { user in
            guard let user = user else { return }
            //Router.showMatch(user: user, parent: self)
            print("show top notification banner for - \(user.identifier)")
        }
    }
}

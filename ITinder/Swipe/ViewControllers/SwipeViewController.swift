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
    
    func resetCardsStatuses() {
        UserService.resetUsers { [weak self] isDone in
            guard isDone, let self = self else { return }
            
            self.dislikedUserIds.removeAll()
            self.cards.removeAll()
            self.profileContainerView.removeAllCards()
            self.addCards()
            
            self.resetButton.isHidden = true
            self.emptyShimmerView.isHidden = true
        }
    }
    
    private let cardsLimit = 3
    private var cards = [SwipeCardModel]()
    private var dislikedUserIds = [String]() {
        didSet { profileContainerView.returnButtonIsHidden = dislikedUserIds.isEmpty }
    }
    
    private var shownUserId: String? {
        cards.first?.userId
    }
    
    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                spinnerView.startAnimating()
            } else {
                spinnerView.stopAnimating()
            }
        }
    }
    
    private let spinnerView: UIActivityIndicatorView = {
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
    
    private lazy var loaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.frame = self.view.frame
        
        let spinner = UIActivityIndicatorView()
        spinner.frame.origin = self.view.center
        spinner.color = .white
        spinner.startAnimating()
        view.addSubview(spinner)
        return view
    }()
    
    private func configure() {
        view.backgroundColor = .white
        
        [spinnerView, profileContainerView, emptyShimmerView, resetButton].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            profileContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyShimmerView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyShimmerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyShimmerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyShimmerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            resetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
            
            self.profileContainerView.add(cardModels)
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
    
    private func returnDislikedUser() {
        let userId = dislikedUserIds.removeLast()
        view.addSubview(loaderView)
        
        UserService.set(status: nil, forUserId: userId) { [weak self] user in
            guard let self = self, let user = user else {
                self?.loaderView.removeFromSuperview()
                return
            }
            
            let cardModel = SwipeCardModel(from: user)
            self.cards.insert(cardModel, at: 0)
            self.profileContainerView.addToFirst(card: cardModel)
            
            self.loaderView.removeFromSuperview()
        }
    }
    
    @objc private func resetButtonDidTap() {
        resetCardsStatuses()
    }
}

extension SwipeViewController: SwipeProfileContainerViewDelegate {
    func profileInfoDidTap() {
        guard let shownUserId = shownUserId else { return }
        UserService.getUserBy(id: shownUserId) { user in
            Router.showUserProfile(user: user, parent: self)
        }
    }
    
    func swipeDidEnd(type: SwipeCardType) {
        setLikeAndMatchIfNeeded(type)
        saveDislikedUser(type)
        cards.removeFirst()
        
        if !isLoading && cards.count < cardsLimit {
            addCards()
        }
    }
    
    func returnButtonDidTap() {
        returnDislikedUser()
    }
    
    private func saveDislikedUser(_ type: SwipeCardType) {
        if type == .like {
            dislikedUserIds.removeAll()
        } else if type == .dislike, let userId = cards.first?.userId {
            if dislikedUserIds.count == cardsLimit {
                dislikedUserIds.removeFirst()
            }
            dislikedUserIds.append(userId)
        }
    }
    
    private func setLikeAndMatchIfNeeded(_ type: SwipeCardType) {
        guard let currentUserId = UserService.currentUserId else { return }
        guard let shownUserId = shownUserId else { return }
        
        let status: User.Status
        switch type {
        case .like: status = .like
        case .dislike, .neutral: status = .dislike
        }
        UserService.set(status: status, forUserId: shownUserId) { user in
            guard let user = user, user.statusList[currentUserId] == User.Status.match.rawValue else { return }
            Router.showMatch(user: user, parent: self)
        }
    }
}

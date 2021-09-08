//
//  SettingsViewController.swift
//  ITinder
//
//  Created by Alexander on 04.09.2021.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private let padding: CGFloat = 40
    
    private let pushNotificationsView = SettingView(title: "Настройка пуш уведомлений", buttonTitle: "Перейти") {
        Router.openPhoneSettings()
    }
    private lazy var resetView = SettingView(title: "Сбросить лайки и дизлайки", buttonTitle: "Сбросить") { [weak self] in
        self?.resetCardsStatuses()
        self?.dismiss(animated: true)
    }
    private lazy var exitView = SettingView(title: "Выйти из аккаунта", buttonTitle: "Выйти") {
        AuthorizationService.signOutUser()
        Router.transitionToAuthScreen(parent: self)
    }
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    private func configure() {
        view.backgroundColor = .white
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(pushNotificationsView)
        stackView.addArrangedSubview(resetView)
        stackView.addArrangedSubview(exitView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
    }
    
    private func resetCardsStatuses() {
        guard let window = UIApplication.shared.windows.first else { return }
        guard let tabBarController = window.rootViewController as? UITabBarController else { return }
        guard let swipeVC = tabBarController.viewControllers?.first as? SwipeViewController else { return }
        swipeVC.resetCardsStatuses()
    }
}

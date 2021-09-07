//
//  SettingView.swift
//  ITinder
//
//  Created by Alexander on 04.09.2021.
//

import UIKit

final class SettingView: UIView {
    init(title: String, buttonTitle: String, action: @escaping () -> Void) {
        self.title = title
        self.buttonTitle = buttonTitle
        self.action = action
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let title: String
    private let buttonTitle: String
    private let action: (() -> Void)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = title
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        Utilities.stylePrimaryButton(button)
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        return button
    }()
    
    private func configure() {
        [titleLabel, actionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            actionButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            actionButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 90),
            actionButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    @objc private func buttonDidTap() {
        action()
    }
}

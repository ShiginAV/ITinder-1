//
//  EmptyShimmerView.swift
//  ITinder
//
//  Created by Alexander on 13.08.2021.
//

import UIKit

final class EmptyShimmerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView = UIImageView(image: SwipeCardIcons.emptyShimmer.image)
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "На данный момент вы просмотрели всех пользователей"
        return label
    }()
    
    private func configure() {
        [imageView, textLabel].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
        }
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalToConstant: 371),
            imageView.heightAnchor.constraint(equalToConstant: 303),
            
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 58),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -58)
        ])
    }
}

//
//  ProfileCharacteristicView.swift
//  ITinder
//
//  Created by Alexander on 14.08.2021.
//

import UIKit

final class ProfileCharacteristicView: UIView {
    
    var text: String? {
        didSet {
            isHidden = (text == nil || text == "")
            descriptionLabel.text = text
        }
    }
    
    init(type: СharacteristicType) {
        self.type = type
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let type: СharacteristicType
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.text = type.text + ": "
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private func configure() {
        [titleLabel, descriptionLabel].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}

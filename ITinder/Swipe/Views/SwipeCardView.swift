//
//  SwipeCardView.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

protocol SwipeCardDelegate: AnyObject {
    func swipeDidEnd(type: SwipeCardType)
    func profileInfoDidTap()
}

enum SwipeCardType {
    case neutral
    case like
    case dislike
}

final class SwipeCardView: UIView {
    
    weak var delegate: SwipeCardDelegate?
    
    var type: SwipeCardType = .neutral {
        didSet {
            switch type {
            case .neutral:
                profileImageOverlayView.backgroundColor = .clear
            case .like:
                profileImageOverlayView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
            case .dislike:
                profileImageOverlayView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
        addGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageOverlayView.frame = profileImageView.frame
        cardGradientLayer.frame = cardGradientView.bounds
    }
    
    func fill(_ card: SwipeCardModel) {
        profileImageView.loadImage(from: URL(string: card.imageUrl))
        profileInfoView.fill(card)
    }
    
    func swipeCradToLeft() {
        let duration: Double = 0.5
        let directionPoint = CGPoint(x: -80, y: 0)
        animateCardStateBy(type: .dislike, duration: duration, directionPoint: directionPoint)
        animateCardMovementBy(type: .dislike, duration: duration, directionPoint: directionPoint)
    }
    
    func swipeCardToRight() {
        let duration: Double = 0.5
        let directionPoint = CGPoint(x: 80, y: 0)
        animateCardStateBy(type: .like, duration: duration, directionPoint: directionPoint)
        animateCardMovementBy(type: .like, duration: duration, directionPoint: directionPoint)
    }
    
    private let profileImageOverlayView = UIView()
    
    private lazy var profileImageView: CustomImageView = {
        let view = CustomImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let cardGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.locations = [0, 1]
        gradient.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        return gradient
    }()
    
    private lazy var cardGradientView: UIView = {
        let view = UIView()
        view.layer.addSublayer(cardGradientLayer)
        return view
    }()
    
    private lazy var profileInfoView: SwipeCardInfoView = {
        let profileInfo = SwipeCardInfoView()
        profileInfo.infoButtonDidTap = { [weak self] in
            self?.delegate?.profileInfoDidTap()
        }
        return profileInfo
    }()
    
    private func configure() {
        backgroundColor = .white
        
        [profileImageView, profileImageOverlayView, cardGradientView, profileInfoView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
        }
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            profileImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            
            cardGradientView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            cardGradientView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cardGradientView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            cardGradientView.heightAnchor.constraint(equalToConstant: 50),
            
            profileInfoView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            profileInfoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileInfoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            profileInfoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70)
        ])
    }
    
    private func addGestures() {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
    }
    
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        guard let parent = superview else { return }
        let translation = sender.translation(in: self)
        let parentCenter = CGPoint(x: parent.frame.width / 2, y: parent.frame.height / 2)
        let offset: CGFloat = 130
        
        center = CGPoint(x: parentCenter.x + translation.x, y: parentCenter.y + translation.y)
        
        switch sender.state {
        case .changed:
            if center.x > parentCenter.x + offset {
                animateCardStateBy(type: .like, duration: 0, directionPoint: translation)
            } else if center.x < parentCenter.x - offset {
                animateCardStateBy(type: .dislike, duration: 0, directionPoint: translation)
            } else {
                animateCardStateBy(type: .neutral, duration: 0, directionPoint: translation)
            }
        case .ended:
            if center.x > parentCenter.x + offset {
                animateCardMovementBy(type: .like, duration: 0.4, directionPoint: translation)
                return
            } else if center.x < parentCenter.x - offset {
                animateCardMovementBy(type: .dislike, duration: 0.4, directionPoint: translation)
                return
            }
            
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.center = CGPoint(x: parent.frame.width / 2, y: parent.frame.height / 2)
            }
        default:
            break
        }
    }
    
    private func animateCardStateBy(type: SwipeCardType, duration: Double, directionPoint: CGPoint) {
        UIView.animate(withDuration: duration) {
            self.type = type
            let rotation = tan(directionPoint.x / (self.frame.width * 2.0))
            self.transform = CGAffineTransform(rotationAngle: rotation)
        }
    }
    
    private func animateCardMovementBy(type: SwipeCardType, duration: Double, directionPoint: CGPoint) {
        guard let parent = superview else { return }
        let parentCenter = CGPoint(x: parent.frame.width / 2, y: parent.frame.height / 2)
        let directionOffsetByX: CGFloat
        switch type {
        case .neutral:
            directionOffsetByX = 0
        case .like:
            directionOffsetByX = 300
        case .dislike:
            directionOffsetByX = -300
        }
        
        UIView.animate(withDuration: duration) {
            self.center = CGPoint(x: parentCenter.x + directionPoint.x + directionOffsetByX,
                                  y: parentCenter.y + directionPoint.y + 75)
            self.alpha = 0.5
        } completion: { _ in
            self.delegate?.swipeDidEnd(type: type)
            self.removeFromSuperview()
        }
    }
}

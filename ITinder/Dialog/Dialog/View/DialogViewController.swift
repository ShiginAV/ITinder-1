//
//  DialogViewController.swift
//  ITinder
//
//  Created by Grifus on 11.08.2021.
//

import UIKit
import MapKit

class DialogViewController: UIViewController {

    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var topEmptyView: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var companionName: UILabel!
    
    let messageViewController = MessageViewController()
    
    var companion: CompanionStruct!
    var companionPhoto: UIImage!
    
    var rootViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        rootViewController = navigationController?.viewControllers.first
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        addChild(messageViewController)
        
        view.addSubview(messageViewController.view)
        self.view.bringSubviewToFront(bannerView)
        self.view.bringSubviewToFront(topEmptyView)
        
        companionName.text = companion.userName
        avatarImage.image = companionPhoto
        
        gestureRecognizerForImage()
        
        allowNotificationOnScreen(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.height / 2
        avatarImage.backgroundColor = .lightGray
        
        let yPosition = bannerView.bounds.height + bannerView.frame.minY
        messageViewController.view.frame = CGRect(x: 0, y: yPosition, width: view.bounds.width, height: view.bounds.height - yPosition)
        
        bannerView.layer.shadowRadius = 10
        bannerView.layer.shadowOpacity = 1
    }
    
    override var canBecomeFirstResponder: Bool {
        return messageViewController.canBecomeFirstResponder
    }
    
    override var inputAccessoryView: UIView? {
        return messageViewController.inputAccessoryView
    }
    
    func gestureRecognizerForImage() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToCompamionProfile))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func goToCompamionProfile(tapGestureRecognizer: UITapGestureRecognizer) {
        print("goToCompamionProfile")
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func allowNotificationOnScreen(_ allow: Bool) {
        let rootVC = rootViewController as? MatchesViewController
        rootVC?.model.allowMessageNotificationOnScreen = allow
    }
    
    deinit {
        allowNotificationOnScreen(true)
    }
    
}

extension DialogViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
}

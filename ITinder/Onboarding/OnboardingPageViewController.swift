//
//  OnboardingPageViewController.swift
//  ITinder
//
//  Created by Daria Tokareva on 30.08.2021.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {

    let nextButton = UIButton()
    let skipButton = UIButton()
    let pageControl = UIPageControl()
    let initialPage = 0
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    func setup() {
        dataSource = self
        delegate = self
        
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
        
        let page1 = PageOnboardingViewController(image: OnboardingImages.onboardingImage1.image!,
                                                 titleText: "Добро пожаловать  в ITinder!",
                                                 subtitleText: "Данное приложение поможет вам \nнайти коллег для работы в команде и \nвашего проекта.")
        let page2 = PageOnboardingViewController(image: OnboardingImages.onboardingImage2.image!,
                                                 titleText: "Свайп вправо если подходит",
                                                 subtitleText: "Доступ к чату откроется в том случае, \nесли оба пользователя \nвыберут друг друга")
        let page3 = PageOnboardingViewController(image: OnboardingImages.onboardingImage3.image!,
                                                 titleText: "Свайп влево если не подходит",
                                                 subtitleText: "Если пользователь не подходит \nдля вашей команды, \nсделайте свайп влево")
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)

        // set initial viewController to be displayed
        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
    }
    
    // swiping by clicking on pageControl
    @objc func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true, completion: nil)
    }
    
    func style() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = Colors.blueItinderColor
        pageControl.pageIndicatorTintColor = Colors.lightGrayItinderColor
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage
        
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitleColor(Colors.blueItinderColor, for: .normal)
        skipButton.setTitle("скрыть", for: .normal)
        skipButton.addTarget(self, action: #selector(skipButtonTapped(_:)), for: .primaryActionTriggered)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitleColor(Colors.blueItinderColor, for: .normal)
        nextButton.setTitle("далее", for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .primaryActionTriggered)
    }
    
    // transition to authentication screen
    @objc func skipButtonTapped(_ sender: UIButton) {
        OnboardingManager.shared.setIsNotNewUser()
        Router.transitionToAuthScreen(parent: self)
    }
    
    // page flipping onboarding
    @objc func nextButtonTapped(_ sender: UIButton) {
        if pageControl.currentPage == 2 {
            OnboardingManager.shared.setIsNotNewUser()
            Router.transitionToAuthScreen(parent: self)
        }
        pageControl.currentPage += 1
        guard let currentPage = viewControllers?[0] else { return }
        guard let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentPage) else { return }
        setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
    }

    func layout() {
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            pageControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            view.trailingAnchor.constraint(equalTo: nextButton.trailingAnchor, constant: 40),
            
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: skipButton.bottomAnchor, multiplier: 2),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: nextButton.bottomAnchor, multiplier: 2),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 2)
        ])
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        if currentIndex == 0 {
            return nil
        } else {
            return pages[currentIndex - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        if currentIndex < pages.count - 1 {
            return pages[currentIndex + 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }
        pageControl.currentPage = currentIndex
    }
}

//
//  Icons.swift
//  ITinder
//
//  Created by Alexander on 07.08.2021.
//

import UIKit

public protocol Imageable {
    var image: UIImage? { get }
}

enum SwipeCardIcons: String, Imageable {
    case likeButton = "like_button"
    case likeButtonActive = "like_button_active"
    case dislikeButton = "dislike_button"
    case dislikeButtonActive = "dislike_button_active"
    case infoButton = "info_button"
}

enum UserProfileIcons: String, Imageable {
    case settingsButton = "settings_button"
    case editButton = "edit_button"
    case nameIcon = "name_icon"
    case birthDateIcon = "birth_date_icon"
    case positionIcon = "position_icon"
    case companyIcon = "company_icon"
    case educationIcon = "education_icon"
    case cityIcon = "city_icon"
    case employmentIcon = "employment_icon"
}

private class BundleClass { }
private let bundle = Bundle(for: BundleClass.self)

extension Imageable where Self: RawRepresentable, Self.RawValue == String {
    public var image: UIImage? {
        return UIImage(named: self.rawValue, in: bundle, compatibleWith: nil)
    }
}

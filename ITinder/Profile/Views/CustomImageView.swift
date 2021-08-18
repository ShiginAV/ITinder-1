//
//  CustomImageView.swift
//  ITinder
//
//  Created by Alexander on 14.08.2021.
//

import UIKit

var imageCache = NSCache<NSString, AnyObject>()

final class CustomImageView: UIImageView {
    private let spinner = UIActivityIndicatorView()
    private var task: URLSessionDataTask?
    
    func loadImage(from url: URL?) {
        guard let url = url else { return }
        
        image = nil
        addSpinner()
        
        if let task = task {
            task.cancel()
        }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            image = cachedImage
            removeSpinner()
            return
        }
        
        task = URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil { return }
            guard let data = data, let newImage = UIImage(data: data) else { return }
            
            imageCache.setObject(newImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = newImage
                self.removeSpinner()
            }
        }
        task?.resume()
    }
    
    private func addSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        spinner.startAnimating()
    }
    
    private func removeSpinner() {
        spinner.removeFromSuperview()
    }
}

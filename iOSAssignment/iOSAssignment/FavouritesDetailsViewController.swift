//
//  FavouritesDetailsViewController.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 21/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import UIKit

class FavouritesDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize =
            imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    fileprivate var imageView = UIImageView()
    
    fileprivate var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize =
                imageView.frame.size
            print("imageView: height \(imageView.frame.size.height) x width \(imageView.frame.size.width)")
            
        }
    }
}

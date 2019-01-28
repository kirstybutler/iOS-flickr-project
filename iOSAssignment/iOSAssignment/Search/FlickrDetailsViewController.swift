//
//  FlickrDetailsViewController.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 13/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import UIKit
class FlickrDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBAction func share(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        }
    
    //Dislaying a confirmation alert
    @IBAction func saveToFavourites(_ sender: Any) {
       let alert = UIAlertController(title: "Photo saved to favourites", message: "Find it in the favourties tab.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        //Saving to favourites
        let toSave = self.imageView.image
        favouritePhotos.append(toSave!)
        
        print(favouritePhotos)
    }

    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    fileprivate func fetchImage() {
        if let url = imageURL {
            //start animation of spinner
            spinner?.startAnimating()
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        print("ignored data returned from url \(url)")
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    fileprivate var imageView = UIImageView()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    fileprivate var image: UIImage? {
        get {
            return imageView.image
        }
        //animate spinner while image is still loading
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            print("imageView: height \(imageView.frame.size.height) x width \(imageView.frame.size.width)")
            spinner?.stopAnimating()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting the default values for the labels before content fills them.
        dateLabel.text = " "
        userLabel.text = " "
        nameLabel.text = " "
        
        dateLabel.sizeToFit()
        userLabel.sizeToFit()
        nameLabel.sizeToFit()
        
        scrollView.addSubview(imageView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

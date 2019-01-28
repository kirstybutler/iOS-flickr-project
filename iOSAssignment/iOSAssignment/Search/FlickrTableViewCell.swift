//
//  FlickrTableViewCell.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 12/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import UIKit

class FlickrTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flickrMiniatureImageView: UIImageView!
    @IBOutlet weak var flickrTitleLabel: UILabel!
    @IBOutlet weak var flickrMiniatureSpinner: UIActivityIndicatorView!
    
    var flickrPhoto: FlickrPhoto? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        //If there is an image already there, replace it
        flickrMiniatureImageView?.image = nil
        flickrTitleLabel?.text = nil
        
        //If there are new images, replace them
        if let flickrPhoto = self.flickrPhoto {
            flickrTitleLabel?.text = flickrPhoto.title
            
            flickrMiniatureSpinner?.startAnimating()
            fetchImage()
        }
    }
    
    fileprivate func fetchImage() {
        if let url = flickrPhoto?.photoSquareUrl {
            flickrMiniatureSpinner?.startAnimating()
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.flickrPhoto?.photoSquareUrl {
                        if let imageData = contentsOfURL {
                            self.flickrMiniatureImageView?.image = UIImage(data: imageData)
                            self.flickrMiniatureSpinner?.stopAnimating()
                        } else {
                            self.flickrMiniatureSpinner?.stopAnimating()
                        }
                    } else {
                        print("ignored data returned from url \(url)")
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

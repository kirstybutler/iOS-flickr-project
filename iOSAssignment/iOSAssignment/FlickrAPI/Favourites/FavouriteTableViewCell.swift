//
//  FavouriteTableViewCell.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 18/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var miniImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var flickrPhoto: FlickrPhoto? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        miniImage?.image = nil
        titleLabel?.text = nil
    
        if let flickrPhoto = self.flickrPhoto {
            titleLabel?.text = flickrPhoto.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

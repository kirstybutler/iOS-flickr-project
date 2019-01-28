//
//  FavouritesViewController.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 17/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import UIKit
var favouritePhotos = [UIImage]()

class FavouritesViewController: UITableViewController {
    @IBOutlet var favTableView: UITableView!
    
    let sections = ["This Month"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       favTableView.delegate = self
       favTableView.dataSource = self
        self.title = "My Favourites"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        favTableView.reloadData()
    }
    
    private struct Storyboard {
        static let ShowDetailsSegue = "Show Details"
        static let FavouritesTableViewCellIdentifier = "FavouriteTableViewCell"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     return sections[section]
   }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favouritePhotos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let savedImages = favouritePhotos[indexPath.row]
        let cell = favTableView.dequeueReusableCell(withIdentifier: "cell") as! FavouriteTableViewCell
        
        cell.imageView?.image = savedImages
        let indexPath = IndexPath(row: favouritePhotos.count - 1, section: 0)
        favTableView.beginUpdates()
        favTableView.insertRows(at: [indexPath], with: .automatic)
        favTableView.endUpdates()

        // Return the configured cell
        return cell
    }
    
    //Swipe to delete functionality - finding the cell that was swiped upon and removing it from the array.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action: UIAlertAction!) in
            if (editingStyle == .delete) {
                favouritePhotos.remove(at: indexPath.row)
                tableView.reloadData()
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
       
}
}

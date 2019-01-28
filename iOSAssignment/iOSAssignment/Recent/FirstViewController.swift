//
//  FirstViewController.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 12/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import UIKit

class FirstViewController: UITableViewController {

    var recentFlickrPhotos = [Array<FlickrPhoto>]() {
        didSet {
            tableView.reloadData()
        }
    }
    @IBOutlet var recentTableView: UITableView!
    
    fileprivate var activeRequest = false
    
    private struct Storyboard {
        static let ShowDetailsSegue = "Show Details"
        static let RecentTableViewCellIdentifier = "RecentTableViewCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recentTableView.delegate = self
        self.recentTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recentFlickrPhotos.removeAll()
        title = ""
    }
    
     func getPhotos(section: Int) {
        if !activeRequest {
            print("Getting recent photos")
            activeRequest = true
                GetFlickrData.getRecentPhotos(section: section, onCompletion: { (error: DataProviderError?, flickrPhotos: [FlickrPhoto]?) -> Void in
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    if error == nil {
                        if flickrPhotos!.isEmpty && self.recentFlickrPhotos.isEmpty {
                            let alert = UIAlertController(
                                title: "Oops",
                                message: "Couldn't gather any images",
                                preferredStyle: UIAlertController.Style.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            
                            
                            DispatchQueue.main.async { [unowned unownedSelf = self] in
                                unownedSelf.present(alert, animated: true, completion: nil)
                            }
                        } else {
                           
                            DispatchQueue.main.async { [unowned unownedSelf = self] in
                                unownedSelf.recentFlickrPhotos.append(flickrPhotos!)
                            }
                        }
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.tableView.reloadData()
                        }
                    } else {
                        if case let DataProviderError.fetching(flickrFail) = error! {
                            let alert = UIAlertController(
                                title: "Oops",
                                message: flickrFail.message,
                                preferredStyle: UIAlertController.Style.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            
                            DispatchQueue.main.async { [unowned unownedSelf = self] in
                                unownedSelf.present(alert, animated: true, completion: nil)
                            }
                        }
                        if case let DataProviderError.network(errorMessage) = error! {
                            let alert = UIAlertController(
                                title: "Oops",
                                message: errorMessage,
                                preferredStyle: UIAlertController.Style.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            
                            DispatchQueue.main.async { [unowned unownedSelf = self] in
                                unownedSelf.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    self.activeRequest = false
                })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return recentFlickrPhotos.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentFlickrPhotos[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Storyboard.RecentTableViewCellIdentifier, for: indexPath as IndexPath)
        
        let flickrPhoto = recentFlickrPhotos[indexPath.section][indexPath.row]
        
        if let flickrCell = cell as? RecentTableViewCell {
            flickrCell.flickrPhoto = flickrPhoto
        }
        
        currentPage = indexPath.section + 1
        return cell
    }
    
    fileprivate var currentPage = 0
    fileprivate var lastPage: Int {
        return recentFlickrPhotos.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ShowDetailsSegue {
            if let dest = segue.destination as? FlickrDetailsViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    dest.imageURL = recentFlickrPhotos[selectedIndexPath.section][selectedIndexPath.row].photoLargeUrl
                    dest.title = recentFlickrPhotos[selectedIndexPath.section][selectedIndexPath.row].title
                        GetFlickrData.getDetails(forPhoto: recentFlickrPhotos[selectedIndexPath.section][selectedIndexPath.row], onCompletion:  { (error: DataProviderError?, flickrPhotoDetail: FlickrPhotoDetail?) -> Void in
                        
                        if error == nil {
                            DispatchQueue.main.async {
                                dest.photoDateTakenLabel.text = flickrPhotoDetail?.datetaken
                                dest.photoUserNameLabel.text = flickrPhotoDetail?.username
                                dest.photoRealNameLabel.text = flickrPhotoDetail?.realname
                            }
                        } else {
                            if case let DataProviderError.fetching(flickrFail) = error! {
                                let alert = UIAlertController(
                                    title: "Oops",
                                    message: flickrFail.message,
                                    preferredStyle: UIAlertController.Style.alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default){UIAlertAction in
                                    NSLog("OK Pressed")})
                                
                                DispatchQueue.main.async { [unowned unownedSelf = self] in
                                    unownedSelf.present(alert, animated: true, completion: nil)
                                }
                            }
                            if case let DataProviderError.network(errorMessage) = error! {
                                let alert = UIAlertController(
                                    title: "Oops",
                                    message: errorMessage,
                                    preferredStyle: UIAlertController.Style.alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                
                                DispatchQueue.main.async { [unowned unownedSelf = self] in
                                    unownedSelf.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    })
                }
            }
        }
    
    }
}

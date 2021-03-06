//
//  FlickrCollectionViewController.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 13/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import UIKit

class FlickrCollectionViewController: UICollectionViewController, UISearchBarDelegate {
    
    // MARK: - Model
    
    // Our model: an array of an array of pictures - Why? To be able to fetch data per section.
    var photosModel = [Array<FlickrPhoto>]() {
        didSet {
            collectionView.reloadData() // if model is set, we need to display it (i.e. fill the table view)
        }
    }
    
    var searchText: String? { // also part of the model
        didSet {
            photosModel.removeAll()
            search(forText: searchText!, section: 1)
            title = searchText
        }
    }
    
    @IBOutlet var flickrCollectionView: UICollectionView!
    
    // MARK: - Search
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
    }
    
    fileprivate var activeRequest = false
    
    /*public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
     searchBar.resignFirstResponder()
     searchText = nil
     }*/
    
    // MARK: - Storyboard
    
    private struct Storyboard {
        static let ShowDetailsSegue = "Show Details"
        static let FlickrTableViewCellIdentifier = "FlickrTableViewCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        photosModel.removeAll()
        title = "Search again"
    }
    
    fileprivate func search(forText textToSearch: String, section: Int) {
        if !activeRequest {
            print("searching for \(textToSearch)")
            activeRequest = true
            FlickrDataProvider.fetchPhotos(searchText: textToSearch, section: section, onCompletion: { (error: DataProviderError?, flickrPhotos: [FlickrPhoto]?) -> Void in
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if error == nil {
                    if flickrPhotos!.isEmpty && self.photosModel.isEmpty {
                        let alert = UIAlertController(
                            title: "Oops",
                            message: "Your search for '\(textToSearch)' didn't return any results.",
                            preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        // User interaction, so back to the main queue
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        // Appending photos will trigger a screen update -> user interaction, so back to the main queue
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.photosModel.append(flickrPhotos!)
                        }
                    }
                    DispatchQueue.main.async { [unowned unownedSelf = self] in
                        unownedSelf.title = textToSearch
                        unownedSelf.collectionView.reloadData()
                    }
                } else {
                    if case let DataProviderError.fetching(flickrFail) = error! {
                        let alert = UIAlertController(
                            title: "Oops",
                            message: flickrFail.message,
                            preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        // User interaction, so back to the main queue
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
                        
                        // User interaction, so back to the main queue
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                self.activeRequest = false
            })
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photosModel.count // Number of rows represents number of sections
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosModel[section].count // Number of pictures in a section
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.FlickrTableViewCellIdentifier, for: indexPath as IndexPath)
        
        let flickrPhoto = photosModel[indexPath.section][indexPath.row]
        
        if let flickrCell = cell as? FlickrTableViewCell {
            flickrCell.flickrPhoto = flickrPhoto
        }
        
        //print("configure cell at [\(indexPath.section)][\(indexPath.row)]")
        
        currentPage = indexPath.section + 1
        
        return cell
    }
    
    fileprivate var currentPage = 0
    fileprivate var lastPage: Int {
        return photosModel.count
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height
        
        if currentOffset > maximumOffset - scrollView.frame.size.height {
            if currentPage == lastPage {
                if searchText != nil {
                    search(forText: searchText!, section: currentPage + 1)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Storyboard.ShowDetailsSegue { // check identifier first
            if let fdvc = segue.destination as? FlickrDetailsViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // Possible improvement: pass one FlickrPhoto object to the FlickrDetailsViewController
                    fdvc.imageURL = photosModel[selectedIndexPath.section][selectedIndexPath.row].photoLargeUrl
                    fdvc.title = photosModel[selectedIndexPath.section][selectedIndexPath.row].title
                    FlickrDataProvider.getDetails(forPhoto: photosModel[selectedIndexPath.section][selectedIndexPath.row], onCompletion:  { (error: DataProviderError?, flickrPhotoDetail: FlickrPhotoDetail?) -> Void in
                        
                        if error == nil {
                            // User interaction, so back to the main queue
                            DispatchQueue.main.async {
                                fdvc.photoDateTakenLabel.text = flickrPhotoDetail?.datetaken
                                fdvc.photoUserNameLabel.text = flickrPhotoDetail?.username
                                fdvc.photoDescriptionLabel.text = flickrPhotoDetail?.description
                                fdvc.photoRealNameLabel.text = flickrPhotoDetail?.realname
                            }
                        } else {
                            if case let DataProviderError.fetching(flickrFail) = error! {
                                let alert = UIAlertController(
                                    title: "Oops",
                                    message: flickrFail.message,
                                    preferredStyle: UIAlertController.Style.alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default){UIAlertAction in
                                    NSLog("OK Pressed")})
                                
                                // User interaction, so back to the main queue
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
                                
                                // User interaction, so back to the main queue
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

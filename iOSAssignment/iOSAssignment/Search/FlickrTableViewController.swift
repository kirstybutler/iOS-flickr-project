//
//  TableViewController.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 13/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    //Initialise an array for the photos gathered from Flickr to be saved to.
    var photos = [Array<FlickrPhoto>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //Getting the search term that was entered and setting it to equal the title
    var searchText: String? {
        didSet {
            photos.removeAll()
            search(forText: searchText!, section: 1)
            title = searchText
        }
    }
    
    @IBOutlet var flickrTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }
    //When enter is pressed on the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
    }
    
    fileprivate var activeRequest = false
    
    private struct Storyboard {
        static let ShowDetailsSegue = "Show Details"
        static let FlickrTableViewCellIdentifier = "FlickrTableViewCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Enabling a refreshControl for the search page
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(TableViewController.populate), for: .valueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        photos.removeAll()
        title = "Search again"
    }
    //Use search term entered to search flickr's API for the term, and returning the relevant images
    func search(forText textToSearch: String, section: Int) {
        if !activeRequest {
            print("searching for \(textToSearch)")
            activeRequest = true
                //Using the search term, and return a image of type Photo which gets the info of the image too
                GetFlickrData.fetchPhotos(searchText: textToSearch, section: section, onCompletion: { (error: DataProviderError?, flickrPhotos: [FlickrPhoto]?) -> Void in
                //Performing this task along with what is already running.
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                //Adding clauses for error catching
                if error == nil {
                    if flickrPhotos!.isEmpty && self.photos.isEmpty {
                        //Displaying an alert if necessary
                        let alert = UIAlertController(
                            title: "Oops",
                            message: "Your search for '\(textToSearch)' didn't return any results.",
                            preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        //When the user has interacted with the alert, run the main queue again
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        //If the search returned any results, return to the main queue again
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.photos.append(flickrPhotos!)
                        }
                    }
                    DispatchQueue.main.async { [unowned unownedSelf = self] in
                        unownedSelf.title = textToSearch
                        unownedSelf.tableView.reloadData()
                    }
                } else {
                    //Displaying an appropriate error message if the images cannot be retreived
                    if case let DataProviderError.fetching(flickrFail) = error! {
                        let alert = UIAlertController(
                            title: "Oops",
                            message: flickrFail.message,
                            preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        // Returning to the main queue
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
    //Setting the dynamic view of images
    override func numberOfSections(in tableView: UITableView) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Giving the cell a reuse identifier so the display is repeated for each image that is returned
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Storyboard.FlickrTableViewCellIdentifier, for: indexPath as IndexPath)
        
        let flickrPhoto = photos[indexPath.section][indexPath.row]
        
        if let flickrCell = cell as? FlickrTableViewCell {
            flickrCell.flickrPhoto = flickrPhoto
        }
        
        currentPage = indexPath.section + 1
        return cell
    }
    //Add new data when refresh is triggered
    @objc func populate () {
        for i in [Array<FlickrPhoto>]()
        {
            photos.append(i)
        }
        
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    fileprivate var currentPage = 0
    fileprivate var lastPage: Int {
        return photos.count
    }
    //Setting the scroll view within the image
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller.
        // Pass the selected image to the new view controller to display.
        if segue.identifier == Storyboard.ShowDetailsSegue {
            //Check that the destination is correct for the current class
            if let dest = segue.destination as? FlickrDetailsViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    //Send the info for that image to the destination using segue
                    //Gather the larger image than the thumbnail from Flickr using the dedicated URL
                    dest.imageURL = photos[selectedIndexPath.section][selectedIndexPath.row].photoLargeUrl
                    dest.title = photos[selectedIndexPath.section][selectedIndexPath.row].title
                    //Getting informaton from each image
                    GetFlickrData.getDetails(forPhoto: photos[selectedIndexPath.section][selectedIndexPath.row], onCompletion:  { (error: DataProviderError?, flickrPhotoDetail: FlickrPhotoDetail?) -> Void in
                        
                        if error == nil {
                            // User interaction, so back to the main queue
                            DispatchQueue.main.async {
                                dest.dateLabel.text = flickrPhotoDetail?.datetaken
                                dest.userLabel.text = flickrPhotoDetail?.username
                                dest.nameLabel.text = flickrPhotoDetail?.realname
                            }
                        } else {
                            if case let DataProviderError.fetching(flickrFail) = error! {
                                let alert = UIAlertController(
                                    title: "Oops",
                                    message: flickrFail.message,
                                    preferredStyle: UIAlertController.Style.alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default){UIAlertAction in
                                    NSLog("OK Pressed")})
                                
                                // Returning to main queue
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

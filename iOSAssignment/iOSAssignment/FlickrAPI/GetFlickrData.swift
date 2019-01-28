//
//  GetFlickrData.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 12/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import Foundation
//Initialising error clauses
enum DataProviderError: Error {
    case serialization(String)
    case network(String)
    case fetching(FlickrFail)
}

class GetFlickrData {
    
    static let myKey = "83bdf8f9c8cdb2ab775943eb5c9a8274"
    
    typealias FlickrResponse = (DataProviderError?, [FlickrPhoto]?) -> Void
    typealias FlickrDetailResponse = (DataProviderError?, FlickrPhotoDetail?) -> Void
    
    class func fetchPhotos(searchText: String, section page: Int, onCompletion: @escaping FlickrResponse) {
        // formatting search text
        let replacement = searchText.replacingOccurrences(of: " ", with: "+")
        let escapedSearchText: String = replacement.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)!
        // formatting URL
        let urlSearchString: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(myKey)&tags=\(escapedSearchText)&per_page=25&page=\(page)&format=json&nojsoncallback=1"
        print("\(urlSearchString)")
        let url: URL = URL(string: urlSearchString)!
    
        // performing the search
        let searchTask = URLSession.shared.dataTask(with: url) {data, response, error in
            
            if error != nil {
                print("Error fetching photos: \(error!.localizedDescription)")
                onCompletion(DataProviderError.network(error!.localizedDescription), nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                guard let results = json else { return }
                
                if let stat = results["stat"] as? String {
                    switch stat {
                    case "ok":
                        var flickrPhotos2: [FlickrPhoto] = []
                        
                        guard let photosContainerJSON = results["photos"] as? [String: Any] else { print("photosjson faild"); return }
                        
                        if let photosContainer2 = photosContainerJSON["photo"] as? [Any]
                        {
                            for case let photo in photosContainer2 {
                                if let flickrPhoto = try FlickrPhoto(json: (photo as? [String : Any])!) as FlickrPhoto?
                                {
                                    flickrPhotos2.append(flickrPhoto)
                                }
                            }
                            onCompletion(nil, flickrPhotos2)
                            
                        }
                        
                    //The search could not be completed
                    default:
                        print("search fail")
                        let flickrError = try FlickrFail(json: json!)
                        onCompletion(DataProviderError.fetching(flickrError), nil)
                        return
                    }
                }
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(DataProviderError.network("unkown error"), nil)
                return
            }
            
        }
        searchTask.resume()
    }
    
    //Method for returning the recent photos
   class func getRecentPhotos(section page: Int, onCompletion: @escaping FlickrResponse) {
        let urlRecentString: String = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(myKey)) &format=json&nojsoncallback=1&extras=url_m&per_page=10"
        print("\(urlRecentString)")
        let recentUrl: URL = URL(string: urlRecentString)!
        
        let recentTask = URLSession.shared.dataTask(with: recentUrl) {data, response, error in
            
            if error != nil {
                print("Error fetching photos: \(error!.localizedDescription)")
                onCompletion(DataProviderError.network(error!.localizedDescription), nil)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                guard let results = json else { return }
                
                if let stat = results["stat"] as? String {
                    switch stat {
                    case "ok":
                        var flickrPhotos2: [FlickrPhoto] = []
                        
                        guard let photosContainerJSON = results["photos"] as? [String: Any] else { print("photosjson faild"); return }
                        
                        if let photosContainer2 = photosContainerJSON["photo"] as? [Any]
                        {
                            for case let photo in photosContainer2 {
                                if let flickrPhoto = try FlickrPhoto(json: (photo as? [String : Any])!) as FlickrPhoto?
                                {
                                    flickrPhotos2.append(flickrPhoto)
                                }
                            }
                            onCompletion(nil, flickrPhotos2)
                            
                        }
                        
                    default:
                        print("Error getting image")
                        let flickrError = try FlickrFail(json: json!)
                        onCompletion(DataProviderError.fetching(flickrError), nil)
                        return
                    }
                }
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(DataProviderError.network("unkown error"), nil)
                return
            }
            
        }
        recentTask.resume()
    }

   class func getDetails(forPhoto: FlickrPhoto, onCompletion: @escaping FlickrDetailResponse) {
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(myKey)&photo_id=\(forPhoto.id)&secret=\(forPhoto.secret)&format=json&nojsoncallback=1"
        let url = URL(string: urlString)!
        
        let searchTask = URLSession.shared.dataTask(with: url) {data, response, error in
            
            if error != nil {
                print("Error fetching details: \(error!.localizedDescription)")
                onCompletion(DataProviderError.network(error!.localizedDescription), nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                guard let results = json else { return }
                
                if let stat = results["stat"] as? String {
                    switch stat {
                    case "ok":
                        guard let photosContainerJSON = results["photo"] as? [String: Any] else { print("photosjson faild"); return }
                        
                        let flickrPhotoDetail = try! FlickrPhotoDetail(json: photosContainerJSON)
                        
                        onCompletion(nil, flickrPhotoDetail)
                        
                    default:
                        print("search fail")
                        let flickrError = try FlickrFail(json: json!)
                        onCompletion(DataProviderError.fetching(flickrError), nil)
                        return
                    }
                }
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(DataProviderError.network("unkown error"), nil)
                return
            }
            
        }
        searchTask.resume()
    }
}

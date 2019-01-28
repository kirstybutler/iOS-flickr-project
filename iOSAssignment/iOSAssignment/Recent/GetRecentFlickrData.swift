//
//  GetRecentFlickrData.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 14/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import Foundation

enum ProviderError: Error {
    case serialization(String)
    case network(String)
    case fetching(FlickrFail)
}

class GetRecentFlickrData {
    
    typealias FlickrResponse = (ProviderError?, [FlickrPhoto]?) -> Void
    typealias FlickrDetailResponse = (ProviderError?, FlickrPhotoDetail?) -> Void

    class func fetchPhotos(section page: Int, onCompletion: @escaping FlickrResponse) {
        
        // formatting URL
        let urlRecentString: String = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(GetFlickrData.myKey)&format=json&nojsoncallback=1&extras=url_m&per_page=10"
        print("\(urlRecentString)")
        let recentUrl: URL = URL(string: urlRecentString)!
        
        // performing the search
        let recentTask = URLSession.shared.dataTask(with: recentUrl) {data, response, error in
            
            if error != nil {
                print("Error fetching photos: \(error!.localizedDescription)")
                onCompletion(ProviderError.network(error!.localizedDescription), nil)
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
                        print("fail")
                        let flickrError = try FlickrFail(json: json!)
                        onCompletion(ProviderError.fetching(flickrError), nil)
                        return
                    }
                }
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(ProviderError.network("unkown error"), nil)
                return
            }
            
        }
        recentTask.resume()
    }
    
    class func getDetails(forPhoto: FlickrPhoto, onCompletion: @escaping FlickrDetailResponse) {
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(GetFlickrData.myKey)&photo_id=\(forPhoto.id)&secret=\(forPhoto.secret)&format=json&nojsoncallback=1"
        let url = URL(string: urlString)!
        let recentTask = URLSession.shared.dataTask(with: url) {data, response, error in
            
            if error != nil {
                print("Error fetching details: \(error!.localizedDescription)")
                onCompletion(ProviderError.network(error!.localizedDescription), nil)
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
                        onCompletion(ProviderError.fetching(flickrError), nil)
                        return
                    }
                }
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(ProviderError.network("unkown error"), nil)
                return
            }
            
        }
        recentTask.resume()
        
    }
}

//
//  FlickrPhoto.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 12/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import Foundation
//initialising photo details to be fetched
struct FlickrPhoto {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Bool
    
    //Small thumbnail for tableView
    var photoSquareUrl: URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")!
    }
    //Enlarged image for detailed view
    var photoLargeUrl: URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg")!
    }
}
//Declaring the image details
extension FlickrPhoto {
    init(json: [String: Any]) throws {
        guard let id = json["id"] as? String else {
            throw SerializationError.missing("id")
        }
        guard let owner = json["owner"] as? String else {
            throw SerializationError.missing("owner")
        }
        guard let secret = json["secret"] as? String else {
            throw SerializationError.missing("secret")
        }
        guard let server = json["server"] as? String else {
            throw SerializationError.missing("server")
        }
        guard let farm = json["farm"] as? Int else {
            throw SerializationError.missing("farm")
        }
        guard let title = json["title"] as? String else {
            throw SerializationError.missing("title")
        }
        guard let isPublic = json["ispublic"] as? Bool else {
            throw SerializationError.missing("isPublic")
        }
        
        // Set properties
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.isPublic = isPublic
    }
}
//Initialise error messages when retieving images
struct FlickrFail {
    let stat: String
    let code: Int
    let message: String
}
//
enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

extension FlickrFail {
    init(json: [String: Any]) throws {
        // Get stat
        guard let stat = json["stat"] as? String else {
            throw SerializationError.missing("stat")
        }
        // Get code
        guard let code = json["code"] as? Int else {
            throw SerializationError.missing("code")
        }
        // Get message
        guard let message = json["message"] as? String else {
            throw SerializationError.missing("message")
        }
        // Initialize properties
        self.stat = stat
        self.code = code
        self.message = message
    }
}
//Initialise image details for retrieval
struct FlickrPhotoDetail {
    let id: String
    let secret: String
    let username: String
    let realname: String
    let title: String
    let description: String
    let datetaken: String
}
//Get image details
extension FlickrPhotoDetail {
    init(json: [String : Any]) throws {
        // Get id
        guard let id = json["id"] as? String else {
            throw SerializationError.missing("id")
        }
        
        // Get secret
        guard let secret = json["secret"] as? String else {
            throw SerializationError.missing("secret")
        }
        
        // Get username and realname
        guard let ownerJSON = json["owner"] as? [String : Any],
            let username = ownerJSON["username"] as? String,
            let realname = ownerJSON["realname"] as? String
            else {
                throw SerializationError.missing("owner")
        }
        
        // Get title
        guard let titleJSON = json["title"] as? [String : Any],
            let title = titleJSON["_content"] as? String
            else {
                throw SerializationError.missing("title")
        }
        
        // Get description
        guard let descriptionJSON = json["description"] as? [String : Any],
            let description = descriptionJSON["_content"] as? String
            else {
                throw SerializationError.missing("description")
        }
        
        // Get datetaken
        guard let datesJSON = json["dates"] as? [String : Any],
            let datetaken = datesJSON["taken"] as? String
            else {
                throw SerializationError.missing("dates.taken")
        }
        
        // Initialise properties
        self.id = id
        self.secret = secret
        self.username = username
        self.realname = realname
        self.title = title
        self.description = description
        self.datetaken = datetaken
    }
}

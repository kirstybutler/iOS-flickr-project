//
//  GetRecentData.swift
//  iOSAssignment
//
//  Created by Kirsty Samantha Butler on 18/12/2018.
//  Copyright © 2018 Kirsty Samantha Butler. All rights reserved.
//

import Foundation

enum DataProviderError: Error {
    
    case serialization(String)
    case network(String)
    case fetching(FlickrFail)
}

class GetRecentData {
    typealias FlickrResponse = (DataProviderError?, [FlickrPhoto]?) -> Void
    typealias FlickrDetailResponse = (DataProviderError?, FlickrPhotoDetail?) -> Void
}

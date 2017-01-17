//
//  ParseAPIConstants.swift
//  On the map
//
//  Created by Nitish on 26/12/16.
//  Copyright © 2016 Nitish. All rights reserved.
//

import Foundation
extension ParseAPIClient{               //constants for parse api
    struct ParseAPIConstants{
        static let results = "results"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    struct ParseAPIKeyConstants{
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes/StudentLocation"
        static let ApplicationJson = "application/json"
        static let applicationKeyHeader = "X-Parse-Application-Id"
        static let apiKeyHeader = "X-Parse-REST-API-Key"
        static let contentType = "Content-Type"
    }
    
    struct ParseAPIParameterKeys{
        static let limit = "limit"
        static let skip = "skip"
        static let order = "order"
        static let whereis = "where"
    }
}

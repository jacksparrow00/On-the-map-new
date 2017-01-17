//
//  ParseModel.swift
//  On the map
//
//  Created by Nitish on 27/12/16.
//  Copyright © 2016 Nitish. All rights reserved.
//

import Foundation
extension ParseAPIClient{
    struct ParseModel{          //parameters required for students locations
        var firstName : String
        var lastName : String
        var objectId : String
        var uniqueKey : String
        var mapString : String
        var mediaURL : String
        var latitude : Double
        var longitude : Double
    
        init?(dictionary: [String:AnyObject]){          //initialize them
            guard let firstname = dictionary[ParseAPIClient.ParseAPIConstants.firstName] as? String else{
                return nil
            }
            firstName = firstname
            
            guard let lastname = dictionary[ParseAPIClient.ParseAPIConstants.lastName] as? String else{
                return nil
            }
            lastName = lastname
            
            guard let objectid = dictionary[ParseAPIClient.ParseAPIConstants.objectId] as? String else{
                return nil
            }
            objectId = objectid
            
            guard let uniquekey = dictionary[ParseAPIClient.ParseAPIConstants.uniqueKey] as? String else{
                return nil
            }
            uniqueKey = uniquekey
            
            guard let mapstring = dictionary[ParseAPIClient.ParseAPIConstants.mapString] as? String else{
                return nil
            }
            mapString = mapstring
            
            guard let mediaurl = dictionary[ParseAPIClient.ParseAPIConstants.mediaURL] as? String else{
                return nil
            }
            mediaURL = mediaurl
            
            guard let lat = dictionary[ParseAPIClient.ParseAPIConstants.latitude] as? Double else{
                return nil
            }
            latitude = lat
            
            guard let long = dictionary[ParseAPIClient.ParseAPIConstants.longitude] as? Double else{
                return nil
            }
            longitude = long
        }
    
        static func studentInformationFromResults(results: [[String:AnyObject]]) -> [ParseModel]{           //add them into an array
            var students = [ParseModel]()
            
            for student in results{
                if let eachStudent = ParseModel(dictionary: student){
                    students.append(eachStudent)
                }
            }
            return students
        }
    }
    
    /*class func sharedInstance() -> ParseAPIClient{
        struct Singleton{
            static var sharedInstance = ParseAPIClient()
        }
        return Singleton.sharedInstance
    }*/
}

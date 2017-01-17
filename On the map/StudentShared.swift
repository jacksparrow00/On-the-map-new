//
//  StudentShared.swift
//  On the map
//
//  Created by Nitish on 18/01/17.
//  Copyright © 2017 Nitish. All rights reserved.
//

import Foundation

class StudentShared {
    var students : [ParseAPIClient.ParseModel] = []
    static let sharedInstance = StudentShared()
}

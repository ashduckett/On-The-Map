//
//  UserMode.swift
//  OnTheMap
//
//  Created by Ash Duckett on 08/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation

class UserModel {
    
    var firstName: String!
    var lastName: String!
    var uniqueKey: String!
    var latestObjectId: String!
    
    // Default value with possibility of changing later
    var userHasPosted: Bool! = false
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    init(firstName: String, lastName: String, uniqueKey: String, latestObjectId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.uniqueKey = uniqueKey
        self.latestObjectId = latestObjectId
    }
    
    // Allow instances to be created with no data
    init() {
        
    }

    // Globally accessible logged in user
    static var user: UserModel!

}

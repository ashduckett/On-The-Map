//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Ash Duckett on 04/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    var firstName: String = ""
    var lastName: String = ""
    var mediaURL: String = ""
    var lat: Double = 0.0
    var lng: Double = 0.0
    var uniqueKey = ""
    var objectId = ""
    var annotation: MKPointAnnotation?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }

    init(studentInfo: [String:AnyObject]) {
        if let firstName = studentInfo["firstName"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = studentInfo["lastName"] as? String {
            self.lastName = lastName
        }
        
        if let latitude = studentInfo["latitude"] as? Double {
            self.lat = latitude
        }
        
        if let longitude = studentInfo["longitude"] as? Double {
            self.lng = longitude
        }
        
        if let mediaURL = studentInfo["mediaURL"] as? String {
            self.mediaURL = mediaURL
        }
        
        if let uniqueKey = studentInfo["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        }
        
        if let objectId = studentInfo["objectId"] as? String {
            self.objectId = objectId
        }
    }

}

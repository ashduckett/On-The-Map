//
//  ParseAPIConvenience.swift
//  OnTheMap
//
//  Created by Ash Duckett on 07/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation
import UIKit

class ParseAPIConvenience {
    
    static func updateStudentPost(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ) {
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(appDelegate.objectId!)"
        let uniqueKey = appDelegate.loggedInStudent.uniqueKey
        let firstName = appDelegate.loggedInStudent.firstName
        let lastName = appDelegate.loggedInStudent.lastName
        
        let httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        print(httpBody)
        ParseAPIClient.performParsePUTRequest(baseURL: urlString, httpBody: httpBody, completionHandler: {(success, errorString, results, response) in
            if !success {
                completionHandler(false, "Could not update student.")
            } else {
                completionHandler(true, nil)
            }
        })
        
    }
    
    
    // Parse specific code
    static func getStudentData(completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result: [String:AnyObject]?) -> Void) {
        
        // These should be constants
        let baseUrl = "https://parse.udacity.com/parse/classes/StudentLocation"
        let pathExtension = "?limit=100&order=-updatedAt"
        
        
        // In this case we don't need to worry about passing in the URL stuff. We know we want student data. Better to pass it in from getStudentData.
        ParseAPIClient.performParseGETRequest(baseUrl: baseUrl, pathExtension: pathExtension, completionHandler: {(success, errorString, result, response) in
            
            
            if !success {
                completionHandler(success, "Could not load student data.", nil)
            } else {
                completionHandler(success, nil, result)
            }
        })
    }
    
    // Parse specific code
    static func postNewStudentLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result: [String:AnyObject]?) -> Void) {
        
        ParseAPIClient.performParsePOSTRequest(baseURL: "https://parse.udacity.com/parse/classes/StudentLocation", pathExtension: "", httpBody: "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}", completionHandler: {(success, errorString, result, response) in
            
            if !success {
                completionHandler(false, errorString, result)
            } else {
                completionHandler(true, errorString, result)
            }
            
            
            
        })
    }
}

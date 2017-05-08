//
//  UdacityAPIConvenience.swift
//  OnTheMap
//
//  Created by Ash Duckett on 07/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation

class UdacityAPIConvenience {
    // This is step 1.
    // The completion handler passed in should have: success: Bool, results: [String:AnyObject]
    static func getSessionId(username: String, password: String, completionHandler: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ errorString: String?) -> Void) {
        
        let baseUrl = "https://www.udacity.com/api"
        let pathExtension = "/session"
        let httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}" // pass in username and pw
        
        UdacityAPIClient.performPOSTRequest(baseURL: baseUrl, pathExtension: pathExtension, httpBody: httpBody, completionHandler: {(success, errorString, result, response) in
            
            
            // Check for a bad HTTP response. Can this be improved? Maybe pass back the status code instead of the full response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                let httpResponse = (response as? HTTPURLResponse)?.statusCode
                
                // If user unauthorized/isn't a registered user.
                if httpResponse == 403 {
                    completionHandler(false, nil, "User not recognised. Check and try again.")
                } else {
                    completionHandler(false, nil, "Please check your Internet connection.")
                }
                return
            }
            completionHandler(true, result, nil)
        })
    }
    
    static func getLoggedInUserData(userId: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result: [String:AnyObject]?) -> Void) {
        UdacityAPIClient.performGETRequest(baseUrl: "https://www.udacity.com/api/", pathExtension: "users/\(userId)",
            completionHandler: {(success, errorString, results, response) in
                
                guard let user = results!["user"],
                    let firstName = user["first_name"] as? String,
                    let lastName = user["last_name"] as? String,
                    let uniqueKey = user["key"] as? String else {
                        completionHandler(false, "Could not get user information", nil)
                        return
                }
                
                UserModel.user = UserModel()
                UserModel.user.firstName = firstName
                UserModel.user.lastName = lastName
                UserModel.user.uniqueKey = uniqueKey
                
                // If we get this far, we have successfully got the data out
                completionHandler(true, nil, user as? [String:AnyObject])
        })

    }
}

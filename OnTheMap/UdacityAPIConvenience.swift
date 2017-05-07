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
                    completionHandler(false, nil, "Server error.")
                }
                return
            }
            completionHandler(true, result, nil)
        })
    }

}

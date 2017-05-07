//
//  UdacityAPIClient.swift
//  OnTheMap
//
//  Created by Ash Duckett on 07/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation

class UdacityAPIClient {
    
    static func performGETRequest(baseUrl: String, pathExtension: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ results: [String:AnyObject]?, _ response: URLResponse?) -> Void) {
        
        // At this point we should grab user data
        let request = NSMutableURLRequest(url: URL(string: baseUrl + pathExtension)!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            // Check to see if error is not nil
            guard error == nil else {
                completionHandler(false, "Server Error during POST: \(error!)", nil, response)
                return
            }
           
            // Check for a bad HTTP response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "Non-2xx status code response.", nil, response)
                return
            }
            
            // Make sure we actually got some data
            guard let data = data else {
                print("No data returned")
                completionHandler(false, "There was an error getting data from the server", nil, response)
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            // Now let's parse the data, see what we see
            
            let parsedUserData: [String:AnyObject]
            
            do {
                parsedUserData = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Couldn't parse")
                return
                
            }
            completionHandler(true, nil, parsedUserData, response)
        }
        task.resume()
        
    }
    
    static func performPOSTRequest(baseURL: String, pathExtension: String, httpBody: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result: [String:AnyObject]?, _ response: URLResponse?) -> Void) {
        // Step 1 is to build a request.
        let request = NSMutableURLRequest(url: URL(string: baseURL + pathExtension)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            // Check to see if error is not nil
            guard error == nil else {
                completionHandler(false, "Server Error during POST: \(error!)", nil, response)
                return
            }
            
            // Check for a bad HTTP response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "Non-2xx status code response.", nil, response)
                return
            }
            
            // Make sure we actually got some data
            guard let data = data else {
                completionHandler(false, "There was an error getting data from the server", nil, response)
                return
            }
            
            // Snip off some data as instructed by Udacity
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            var parsedResult: [String:AnyObject]?
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as? [String:AnyObject]
            } catch {
                print("Error parsing JSON")
            }
            
            completionHandler(true, nil, parsedResult, response)
        }
        
        task.resume()
    }

    
    
    
    // Udacity specific function for logging out
    static func deleteUdacitySession(baseURL: String, pathExtension: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        let pathExtension = "session"
        let method = "DELETE"
        
        let request = NSMutableURLRequest(url: URL(string: baseURL + pathExtension)!)
        request.httpMethod = method
        var xsrfCookie: HTTPCookie? = nil
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            if error != nil {
                completionHandler(false, "Error Logging Out")
                return
            }
            
            // No error
            completionHandler(true, nil)
            
        }
        task.resume()
    }

}

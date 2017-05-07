//
//  APIClient.swift
//  OnTheMap
//
//  Created by Ash Duckett on 04/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation
import UIKit

class APIClient {
    static let baseURL = "https://www.udacity.com/api/"

    
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
    
    
    
    
    
    
    // You need to make this more generic. It makes no sense in many instances to have credentials fail in a post request.
    static func performPOSTRequest(baseURL: String, pathExtension: String, httpBody: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result: [String:AnyObject]?, _ response: URLResponse?) -> Void) {
        // Step 1 is to build a request.
        let request = NSMutableURLRequest(url: URL(string: baseURL + pathExtension)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let session = appDelegate.session

        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            // Check to see if error is not nil
            guard error == nil else {
                print("error not nil")
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
    
    // Udacity specific post request code
    static func performGETRequest(baseUrl: String, pathExtension: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ results: [String:AnyObject]?, _ response: URLResponse?) -> Void) {

        // At this point we should grab user data
        let request = NSMutableURLRequest(url: URL(string: baseUrl + pathExtension)!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            // Check to see if error is not nil
            guard error == nil else {
                print("error not nil")
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
    
    
    // Out of the below method, you should store the error, response and data. Error strings should only be applicable in less generic methods,
    // such as login.
    
    
    // This is step 1.
    // The completion handler passed in should have: success: Bool, results: [String:AnyObject]
    static func getSessionId(completionHandler: @escaping (_ success: Bool, _ results: [String:AnyObject]?, _ errorString: String?) -> Void) {
        
        let baseUrl = "https://www.udacity.com/api"
        let pathExtension = "/session"
        let httpBody = "{\"udacity\": {\"username\": \"ash.duckett@outlook.com\", \"password\": \"Visualstudio2010.\"}}" // pass in username and pw
        
        performPOSTRequest(baseURL: baseUrl, pathExtension: pathExtension, httpBody: httpBody, completionHandler: {(success, errorString, result, response) in
            
            
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
 
    static func performParseGETRequest(baseUrl: String, pathExtension: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ results: [String:AnyObject]?, _ response: URLResponse?) -> Void) {

        
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest){(data, response, error) in
            guard error == nil else {
                print("There was an error")
                completionHandler(false, "ParseAPIClient: Error getting data.", nil, response)
                return
            }
            
            // Check for a bad HTTP response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "ParseAPIClient: Your request returned a status code other than 2xx!", nil, response)
                return
            }
            
            guard let data = data else {
                completionHandler(false, "No data returned", nil, response)
                return
            }
            
            var parsedResult = [String:AnyObject]()
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(false, "ParseAPIClient: Could not read data from server.", nil, response)
            }
            
            completionHandler(true, nil, parsedResult, response)
            
        }
        task.resume()
    }
    
    static func performParsePOSTRequest(baseURL: String, pathExtension: String, httpBody: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result: [String:AnyObject]?, _ response: URLResponse?) -> Void) {
                    
            let request = NSMutableURLRequest(url: URL(string: baseURL)!)
            request.httpMethod = "POST"
            
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody.data(using: String.Encoding.utf8)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest){(data, response, error) in
                
                guard error == nil else {
                    print("Error not nil!")
                    completionHandler(false, "Error getting student data.", nil, response)
                    return
                }
                
                // Check for a bad HTTP response
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    completionHandler(false, "Your request returned a status code other than 2xx!", nil, response)
                    print("Bad status code!")
                    return
                }
                
                var parsedResult = [String:AnyObject]()
                
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    completionHandler(false, "Could not read data from server.", nil, response)
                }
                
                // Success!
                completionHandler(true, nil, parsedResult, response)
            }
            
            task.resume()
        }
    
    
    // PARSE PUT
    static func performParsePUTRequest(baseURL: String, httpBody: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result: [String:AnyObject]?, _ response: URLResponse?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "PUT"
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard error == nil else {
                print("Error not nil!")
                completionHandler(false, "Error getting student data.", nil, response)
                return
            }
            
            // Check for a bad HTTP response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "Your request returned a status code other than 2xx!", nil, response)
                return
            }
            
            var parsedResult = [String:AnyObject]()
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(false, "Could not read data from server.", nil, response)
            }
            
            // Success!
            completionHandler(true, nil, parsedResult, response)
        }
        
        task.resume()
    }
    
    
    
    static func updateStudentPost(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ) {
        print("Update student post method called")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(appDelegate.objectId!)"
        let uniqueKey = appDelegate.loggedInStudent.uniqueKey
        let firstName = appDelegate.loggedInStudent.firstName
        let lastName = appDelegate.loggedInStudent.lastName

        let httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}"
    
        performParsePUTRequest(baseURL: urlString, httpBody: httpBody, completionHandler: {(success, errorString, results, response) in
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
        performParseGETRequest(baseUrl: baseUrl, pathExtension: pathExtension, completionHandler: {(success, errorString, result, response) in
          
            
            if !success {
                completionHandler(success, "Could not load student data.", nil)
            } else {
                completionHandler(success, nil, result)
            }
        })
    }
    
    // Parse specific code
    static func postNewStudentLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result: [String:AnyObject]?) -> Void) {
        
        performParsePOSTRequest(baseURL: "https://parse.udacity.com/parse/classes/StudentLocation", pathExtension: "", httpBody: "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}", completionHandler: {(success, errorString, result, response) in
            
            if !success {
                completionHandler(false, errorString, result)
            } else {
                completionHandler(true, errorString, result)
            }
        
        
        
        })
    }
}

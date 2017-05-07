//
//  ParseAPIClient.swift
//  OnTheMap
//
//  Created by Ash Duckett on 07/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation

class ParseAPIClient {
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

}

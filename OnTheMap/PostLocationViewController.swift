//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Ash Duckett on 05/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PostLocationViewController: UIViewController {
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    
    //var lastPlacemark
    
    // We need a mapview on this view controller that can be set before displaying the modal!
    var mapView: MKMapView!
    var overwriting: Bool!
    
    @IBAction func submitLocation(_ sender: Any) {
        let geocoder = CLGeocoder()
        let address = addressField.text!
        let url = urlField.text!
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        // Maybe we could set a map view here
        
        // You need to be able to get a reference to the map however, this view is set.
        // This could be part of a constructor?
        
        // How about we call this with a second completion handler. We can't, it has to be fired from here.
        // On dismissing this
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) in
            if error != nil {
                print("There's been an error. What do we need to handle here?")
            } else {
                if let placemark = placemarks?.first {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let coordinate = placemark.location!.coordinate
                    
                    let annotation = MKPointAnnotation()
                    
                    let title = appDelegate.loginName
                    
                    annotation.title = title
                    
                    // Subtitle I think is the URL
                    annotation.subtitle = url
                    
                    annotation.coordinate = coordinate
                    
                    // Add the new pin
                    self.mapView.addAnnotation(annotation)
                    
                    // Before dismissing, we should make the post to the API so it's stored in the cloud.
                    
                    
                    // mapString comes straight out of the location text box
                    // close window
          
                    // We should be creating a new pin here...Cardiff!
                   // self.overwriting = false
                    
                    if !self.overwriting {
                        APIClient.postNewStudentLocation(uniqueKey: appDelegate.uniqueKey, firstName: appDelegate.firstName, lastName: appDelegate.lastName, mapString: self.addressField.text!, mediaURL: self.urlField.text!, latitude: coordinate.latitude, longitude: coordinate.longitude, completionHandler: {(success, error, response) in
                        
                            // What should happen when the post is complete?
                        
                        
                        
                            // Assuming all went well, we should close the window
                            // UI update code
                            DispatchQueue.main.async {
                                // Close the post map view
                                self.dismiss(animated: true, completion: nil)
                            

                            
                                // You also should move a lot of the information for the logged in user,
                                // if not all of it, into a StudentInformation object.
                            
                                // Zoom into the pin that was just added
                                let span = MKCoordinateSpanMake(0.075, 0.075)
                                let region = MKCoordinateRegion(center: coordinate, span: span)
                                self.mapView.setRegion(region, animated: true)
                            
                            }
                        
                        })
                    
                        // We need to get it working out if you've added a pin already!
                    
                        // When you initially retrieve the student location data, if the logged in user
                        // has a user id in that data, you know you've posted before
                    
                    } else {
                        
                        print("Starting update code")
                        // Otherwise we're overwriting and should do an update!
                        
                        // We need a current objectId. This should go in the studentcollection eventually.
                        
                        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(appDelegate.objectId!)"
                        
                        print("URL constructed")
                        
                        let url = URL(string: urlString)
                        let request = NSMutableURLRequest(url: url!)
                        
                        request.httpMethod = "PUT"
                        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
                        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
                        
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        let uniqueKey = appDelegate.uniqueKey!
                        let firstName = appDelegate.firstName!
                        let lastName = appDelegate.lastName!
                        let mapString = self.addressField.text!
                        let mediaURL = self.urlField.text!
                        let latitude = coordinate.latitude
                        let longitude = coordinate.longitude
                        
                        
                        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
                        
                        let session = URLSession.shared
                        
                        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, respnse, error) in
                            if error != nil {
                                print("Error updating location!")
                                return
                            }
                        
                        // Repeated!
                        
                            DispatchQueue.main.async {
                                // Close the post map view
                                self.dismiss(animated: true, completion: nil)
                                
                                
                                
                                // You also should move a lot of the information for the logged in user,
                                // if not all of it, into a StudentInformation object.
                                
                                // Zoom into the pin that was just added
                                let span = MKCoordinateSpanMake(0.075, 0.075)
                                let region = MKCoordinateRegion(center: coordinate, span: span)
                                self.mapView.setRegion(region, animated: true)
                                
                            }

                        
                        
                        
                        
                        })
                        
                        task.resume()
                        
                        
                        print("Updating object \(urlString)")
                    }
                    
                    
                }
                
                else {
                    print("Could not find location")
                }
            }
        })
    
    }
}

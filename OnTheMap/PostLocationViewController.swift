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
    
    var mapView: MKMapView!
    var overwriting: Bool!
    
    @IBAction func submitLocation(_ sender: Any) {
        let geocoder = CLGeocoder()
        let address = addressField.text!
        let url = urlField.text!
                
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) in
            if error != nil {
                // Alert box here to say it can't find the location
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
                    
                    if !self.overwriting {
                        APIClient.postNewStudentLocation(uniqueKey: appDelegate.uniqueKey, firstName: appDelegate.firstName, lastName: appDelegate.lastName, mapString: self.addressField.text!, mediaURL: self.urlField.text!, latitude: coordinate.latitude, longitude: coordinate.longitude, completionHandler: {(success, error, response) in
                        
                         
                            // Assuming all went well, we should close the window and zoom into the location added
                            DispatchQueue.main.async {
                                // Close the post map view
                                self.dismiss(animated: true, completion: nil)
                            
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
                        
                        let mapString = self.addressField.text!
                        let mediaURL = self.urlField.text!
                        let latitude = coordinate.latitude
                        let longitude = coordinate.longitude
                        
                        APIClient.updateStudentPost(mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude, completionHandler: {(success, errorString) in
                            if !success {
                                print(errorString!)
                            } else {
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
                            }
                        })
                    }
                }
            }
        })
    }
}

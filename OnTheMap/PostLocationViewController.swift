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
    
    @IBOutlet weak var addLocationButton: UIButton!
    var mapView: MKMapView!
    var overwriting: Bool!
    
    
    func displayAlert(title: String, message: String) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController()
            alertController.title = title
            alertController.message = message
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {(action) in
                self.addLocationButton.isEnabled = true
                self.addLocationButton.setTitle("Add Location", for: .disabled)
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }

    
    
    @IBAction func submitLocation(_ sender: Any) {
        let geocoder = CLGeocoder()
        //let address = addressField.text!
        
        let url = urlField.text!
        // First of all, make sure something is in each box
        guard let address = addressField.text, address.isEmpty == false,
            let email = urlField.text, email.isEmpty == false else {
                displayAlert(title: "Error", message: "You need to enter both a location and a URL")
                return
        }
        
        
        
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) in
            
            self.addLocationButton.isEnabled = false
            self.addLocationButton.setTitle("Sending...", for: .disabled)
            
            if error != nil {
                // Alert box here to say it can't find the location

                self.displayAlert(title: "Error", message: "Cannot find that location")
                
                

            } else {
                if let placemark = placemarks?.first {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let coordinate = placemark.location!.coordinate
                    
                    let annotation = MKPointAnnotation()
                    
                    let title = appDelegate.loggedInStudent.fullName
                    
                    annotation.title = title
                    
                    // Subtitle I think is the URL
                    annotation.subtitle = url
                    print("Applying \(url)")
                    annotation.coordinate = coordinate
                    
                    // Add the new pin
                    // Might be able to delete this
                    self.mapView.addAnnotation(annotation)
                    
                    if !self.overwriting {
                    
                        ParseAPIConvenience.postNewStudentLocation(uniqueKey: appDelegate.uniqueKey, firstName: appDelegate.firstName, lastName: appDelegate.lastName, mapString: self.addressField.text!, mediaURL: self.urlField.text!, latitude: coordinate.latitude, longitude: coordinate.longitude, completionHandler: {(success, error, response) in
                        
                         
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
                        print("We are overwriting")
                        let mapString = address
                        let mediaURL = url
                        let latitude = coordinate.latitude
                        let longitude = coordinate.longitude
                        
                        ParseAPIConvenience.updateStudentPost(mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude, completionHandler: {(success, errorString) in
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

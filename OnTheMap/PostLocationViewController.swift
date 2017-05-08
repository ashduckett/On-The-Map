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
    @IBOutlet weak var mapView: MKMapView!
    
    var students: StudentInformationModel!

    @IBOutlet weak var addLocationButton: UIButton!
    //var mapView: MKMapView!
    var overwriting: Bool!
    var currentAnnotation: MKPointAnnotation!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        addLocationButton.isEnabled = true
        print("Post new location view sees \(self.students.studentCollection.count) items.")
    }
    
    func displayAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController()
            alertController.title = title
            alertController.message = message
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {(action) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    
    @IBAction func findMeButtonClicked(_ sender: Any) {
        let geocoder = CLGeocoder()
        
        // Ensure we have both the URL and location for the preview
        guard let address = addressField.text, address.isEmpty == false,
              let url = urlField.text, url.isEmpty == false else {
                self.displayAlert(title: "Error", message: "You need to enter both a location and a URL")
            return
        }

        activityIndicator.startAnimating()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) in

            if error != nil {
                self.displayAlert(title: "Error", message: "Cannot find that location")
            } else {
                if let placemark = placemarks?.first {
                    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let coordinate = placemark.location!.coordinate
                    let annotation = MKPointAnnotation()
                    //let title = appDelegate.loggedInStudent.fullName
                    let title = UserModel.user.fullName
                    
                    
                    annotation.title = title
                    annotation.subtitle = url
                    annotation.coordinate = coordinate
                    
                    DispatchQueue.main.async {
                        // If there's already an annotation, remove it
                        if let currentAnnotation = self.currentAnnotation {
                            self.mapView.removeAnnotation(currentAnnotation)
                        }
                        
                        
                        
                        self.mapView.addAnnotation(annotation)
                        self.currentAnnotation = annotation
                        self.activityIndicator.stopAnimating()
                    
                        let span = MKCoordinateSpanMake(0.075, 0.075)
                        let region = MKCoordinateRegion(center: coordinate, span: span)
                        self.mapView.setRegion(region, animated: true)
                        self.addLocationButton.isEnabled = true
                    }
                    
                    
                }
            }
        })
    }
    
  

    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func submitLocation(_ sender: Any) {
        
        
        let address = addressField.text!
        let url = urlField.text!
        
        // This can explode
        let coordinate = self.currentAnnotation.coordinate
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
        if !self.overwriting {
            
            ParseAPIConvenience.postNewStudentLocation(uniqueKey: UserModel.user.uniqueKey, firstName: UserModel.user.firstName, lastName: UserModel.user.lastName, mapString: self.addressField.text!, mediaURL: self.urlField.text!, latitude: coordinate.latitude, longitude: coordinate.longitude, completionHandler: {(success, error, response) in
                        
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        } else {
            ParseAPIConvenience.updateStudentPost(mapString: address, mediaURL: url, latitude: coordinate.latitude, longitude: coordinate.longitude, completionHandler: {(success, errorString) in
                
                DispatchQueue.main.async {
                    if !success {
                        self.displayAlert(title: "Error", message: "Could not update post.")
                    } else {
                        
                        // Otherwise, locate the item in the model and remove it so it won't display on the map without having to do another trip
                        // to the server
                        
                        for (index, item) in self.students.studentCollection.enumerated() {
                            print("Unique key of student location: \(item.uniqueKey). Index: \(index)")
                            
                            // How am I going to get hold of the latest of my own student location info?
                            // It might be an idea to start with the right model and do this in the StudentInformationModelClass
                            
                        
                        }

                        
                        // Remove all of my own previous pin entries
                        let filtered = self.students.studentCollection.filter( { (item) in
                            return item.uniqueKey != UserModel.user.uniqueKey
                        })
                        
                        self.students.studentCollection = filtered
                        
                        //let firstName = appDelegate.loggedInStudent.firstName
                        let firstName = UserModel.user.firstName
                        
                        //let lastName = appDelegate.loggedInStudent.lastName
                        let lastName = UserModel.user.lastName
                        
                        let latitude = self.currentAnnotation.coordinate.latitude
                        let longitude = self.currentAnnotation.coordinate.longitude
                        let mediaURL = self.urlField.text!
                        //let uniqueKey = appDelegate.uniqueKey
                        let uniqueKey = UserModel.user.uniqueKey
                        
                        var student = StudentInformation()
                        student.firstName = firstName!
                        student.lastName = lastName!
                        student.lat = latitude
                        student.lng = longitude
                        student.mediaURL = mediaURL
                        student.uniqueKey = uniqueKey!
                        
                        // Update the model
                        self.students.studentCollection.append(student)
                        
                        // Display map and update the view
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
}

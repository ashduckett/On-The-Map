//
//  ViewController.swift
//  OnTheMap
//
//  Created by Ash Duckett on 03/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: LocationDisplayViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // Store a reference for the superclass. Don't know how to have an inherited outlet,
        // plus, we don't need direct interaction with the map for all subclasses.
        map = mapView
        
        // Now let's see if we can access the map values
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        // Iterate over the studentCollection and extract information for pins
        for item in appDelegate.studentCollection {
       
            let lat = CLLocationDegrees(item.lat)
            let lng = CLLocationDegrees(item.lng)
            let title = item.fullName
            let subtitle = item.mediaURL
        
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotation.title = title
            annotation.subtitle = subtitle
            self.mapView.addAnnotation(annotation)
        }
        

        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .purple
            
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    // Respond to bubble clicks. Only open a URL if one is there.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen) {
                    app.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}


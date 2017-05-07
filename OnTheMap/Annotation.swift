//
//  Annotation.swift
//  OnTheMap
//
//  Created by Ash Duckett on 07/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MyAnnotation: MKPinAnnotationView, MKAnnotation
{
    let identifier : String
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    //let pinTintColor: MKPinAnnotationColor
    
    
    init(identifier: String, title: String, subtitle: String, coordinate: CLLocationCoordinate2D, color: MKPinAnnotationColor)
    {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
      //  self.color = color
        
        super.init()
    }
    
    func mapItem() -> MKMapItem
    {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}

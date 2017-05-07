//
//  LocationDisplayViewController.swift
//  OnTheMap
//
//  Created by Ash Duckett on 04/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationDisplayViewController: UIViewController {
    // How are we going to set this?
    var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pin", style: .plain, target: self, action: #selector(pin))
    }
    
    func disableUI(enabled: Bool) {
        self.navigationItem.leftBarButtonItem?.isEnabled = enabled
        self.navigationItem.rightBarButtonItem?.isEnabled = enabled
    }

    func logout() {
        disableUI(enabled: false)
        self.navigationItem.leftBarButtonItem?.title = "Logging Out"
        UdacityAPIClient.deleteUdacitySession(baseURL: "https://www.udacity.com/api/", pathExtension: "session", completionHandler: {(success, error) in
            if success == true {
                // Maybe do something with the UI as things are logging out, AND THEN!
                
                let controller: UIViewController
                controller = (self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController"))!
                self.present(controller, animated: true, completion: nil)
            } else {
                self.disableUI(enabled: true)
                self.navigationItem.leftBarButtonItem?.title = "Log Out"
            }
        
        })
    }
    
    func pin() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // If the user has already posted display alert with cancel or overrwrite buttons

        // If the user has already posted, show the popup asking if they're happy to overwrite
        if appDelegate.userHasPosted {

            let alertController = UIAlertController()
            alertController.title = "Confirm"
            alertController.message = "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?"
            
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .default) {(action) in
                
                // Construct controller, and tell it we're overwriting
              let controller: PostLocationViewController
                controller = (self.storyboard?.instantiateViewController(withIdentifier: "PostLocationViewController")) as! PostLocationViewController
                
                // Keep a reference so we can talk to the map!
                controller.overwriting = true
                controller.mapView = self.map
                
                self.present(controller, animated: true, completion: nil)
                
                alertController.dismiss(animated: true, completion: nil)
            }
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action) in
                // Leaving this blank will close the alert
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(overwriteAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            // If we're not updating an old post, then just procede as normal
        
            let controller: PostLocationViewController
            controller = (self.storyboard?.instantiateViewController(withIdentifier: "PostLocationViewController")) as! PostLocationViewController
        
            // Keep a reference so we can talk to the map!
            controller.mapView = map
            controller.overwriting = false
            self.present(controller, animated: true, completion: nil)
        
        }
    }
}

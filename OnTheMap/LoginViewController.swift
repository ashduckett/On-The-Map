//
//  ViewController.swift
//  OnTheMap
//
//  Created by Ash Duckett on 03/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func displayAlert(title: String, message: String) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController()
            alertController.title = title
            alertController.message = message
        
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {(action) in
                self.dismiss(animated: true, completion: nil)
            }
        
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        // Let's only start the connection attempt if both a username and a password have been entered
        guard let emailText = emailField.text, !emailText.isEmpty, let passwordText = passwordField.text,
            !passwordText.isEmpty else {
            self.displayAlert(title: "Validation", message: "Missing email or password.")
            return
        }
        
        APIClient.getSessionId(completionHandler: {(success, result, errorString) in
            // If unsuccessful login, tell the user
            if let errorString = errorString {
                // Alert error string. Might be bad credentials, might be bad connection.
                self.displayAlert(title: "Error", message: errorString)
            } else {
                // If we were successful, then the user exists
                let session = result!["session"] as! [String:String]
                
                // Get a user id for later
                guard let account = result!["account"] as? [String:AnyObject], let userId = account["key"] as? String else {
                    print("bad result")
                    return
                }
  
                
                // Now we have a user id, we can do yet another post request
                if let _ = session["id"] {
                    APIClient.getStudentData(url: "", completionHandler: {(success, error, result) in
                        if let error = error {
                            // Alert the error here!
                            self.displayAlert(title: "Error", message: error)
                        } else {
                            // Otherwise we have no error, we can compile the results and display the map/list tabbed view controller
                            let arrayOfStudentInfos = result!["results"] as! [[String:AnyObject]]
                    
                            for studentInfoItem in arrayOfStudentInfos {
                                let student = StudentInformation(studentInfo: studentInfoItem)
                        
                                // You might not need this here as well as above
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.studentCollection.append(student)
                            }
                            
                            APIClient.performGETRequest(baseUrl: "https://www.udacity.com/api/", pathExtension: "users/\(userId)",
                                completionHandler: {(success, errorString, results, response) in
                                    
                                    guard let user = results!["user"],
                                        let firstName = user["first_name"] as? String,
                                        let lastName = user["last_name"] as? String,
                                        let uniqueKey = user["key"] as? String else {
                                            print("Missing data from response")
                                            return
                                    }
                                    
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.loginName = "\(firstName) \(lastName)"
                                    
                                    // This should work.
                                    appDelegate.uniqueKey = uniqueKey // same as user id
                                    appDelegate.firstName = firstName
                                    appDelegate.lastName = lastName
                                    
                                    for student in appDelegate.studentCollection {
                                        if appDelegate.uniqueKey == student.uniqueKey {
                                            
                                            appDelegate.userHasPosted = true
                                            
                                            // Grab the matching object id (the first)
                                            appDelegate.objectId = student.objectId
                                            break
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        let controller: UITabBarController
                                        controller = self.storyboard?.instantiateViewController(withIdentifier: "ListMapSelectionView") as! UITabBarController
                                        self.present(controller, animated: true, completion: nil)
                                    }
                                })
    
                            // Update the UI by displaying the tabbed controller
                            
                        }
                    })
                }
            }
        })
    }
}


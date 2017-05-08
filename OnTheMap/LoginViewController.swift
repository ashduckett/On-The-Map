//
//  ViewController.swift
//  OnTheMap
//
//  Created by Ash Duckett on 03/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var students: StudentInformationModel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        emailField.text = ""
        passwordField.text = ""
        loginButton.setTitle("Log In", for: .normal)
        loginButton.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y =  -getKeyboardHeight(notification: notification)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func displayAlert(title: String, message: String) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController()
            alertController.title = title
            alertController.message = message
        
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {(action) in
                self.dismiss(animated: true, completion: nil)
            
                self.loginButton.isEnabled = true
                self.loginButton.setTitle("Log In", for: .disabled)
            
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
        
        // Before starting the API call, disable the button and let the user know what's going on
        loginButton.isEnabled = false
        loginButton.setTitle("Logging in", for: .disabled)
        
        activityIndicator.startAnimating()
        UdacityAPIConvenience.getSessionId(username: emailText, password: passwordText, completionHandler: {(success, result, errorString) in
            // If unsuccessful login, tell the user
            if let errorString = errorString {
                // Alert error string. Might be bad credentials, might be bad connection.
            
                DispatchQueue.main.async {
                    self.displayAlert(title: "Error", message: errorString)
                    self.activityIndicator.stopAnimating()
                }
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
                    ParseAPIConvenience.getStudentData(completionHandler: {(success, error, result) in
                        if let error = error {
                            // Alert the error here!
                            self.displayAlert(title: "Error", message: error)
                        } else {
                            // Otherwise we have no error, we can compile the results and display the map/list tabbed view controller
                            
                            self.students = StudentInformationModel(students: result!["results"] as! [[String:AnyObject]])
                            
                            UdacityAPIConvenience.getLoggedInUserData(userId: userId, completionHandler: {(success, errorString, results) in
                                
                                guard error == nil else {
                                    print(errorString!)
                                    return
                                }
                                
                                for student in (self.students?.studentCollection)! {
                                    if UserModel.user.uniqueKey == student.uniqueKey {
                                        
                                        // If the user's unique key is already there, we know we've posted before
                                        UserModel.user.userHasPosted = true
                                        
                                        // Grab the matching object id. Since items are already sorted, this should be the latest of mine.
                                        UserModel.user.latestObjectId = student.objectId
                                        break
                                    }
                                }
                                
                                // Filter out everything that's not mine, or if it is mine, make sure it's the latest.
                                let filtered = self.students.studentCollection.filter({(item) in
                                    return item.uniqueKey != UserModel.user.uniqueKey || (item.objectId == UserModel.user.latestObjectId)
                                })
                                
                                self.students.studentCollection = filtered
                                
                                // Here we are displaying the tab bar controller
                                DispatchQueue.main.async {
                                    
                                    self.activityIndicator.stopAnimating()
                                    let controller: MapListTabBarController
                                    
                                    controller = self.storyboard?.instantiateViewController(withIdentifier: "ListMapSelectionView") as! MapListTabBarController
                                    controller.students = self.students
                                    self.present(controller, animated: true, completion: nil)
                                }
                            })
                        }
                    })
                }
            }
        })
    }
}

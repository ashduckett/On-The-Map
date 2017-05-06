//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Ash Duckett on 04/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: LocationDisplayViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    
    // What should happen when you press a cell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
        // Tidy this up
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        cell.textLabel?.text = appDelegate.studentCollection[indexPath.row].fullName
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.studentCollection.count
        
        
    }
}

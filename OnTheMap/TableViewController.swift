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
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
        cell.textLabel?.text = students.studentCollection[indexPath.row].fullName
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.studentCollection.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toOpen = students.studentCollection[indexPath.row].mediaURL
        let app = UIApplication.shared
        
        if let url = URL(string: toOpen) {
            app.open(url, options: [:], completionHandler: nil)
        }
        
        // Deselect row after opening url
        tableView.deselectRow(at: indexPath, animated: true)
    
    }
}

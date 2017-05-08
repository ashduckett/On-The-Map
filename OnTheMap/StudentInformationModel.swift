//
//  StudentInformationModel.swift
//  OnTheMap
//
//  Created by Ash Duckett on 08/05/2017.
//  Copyright © 2017 Ash Duckett. All rights reserved.
//

import Foundation

class StudentInformationModel {
    var studentCollection = [StudentInformation]()
    
    // Enable initialising with an array of students after parsing data from server.
    init(students: [[String:AnyObject]]) {
        for student in students {
            let student = StudentInformation(studentInfo: student)
            studentCollection.append(student)
        }
    }
    
    func addNewStudent(student: StudentInformation) {
        studentCollection.append(student)
    }
}


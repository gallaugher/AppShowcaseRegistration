//
//  Students.swift
//  AppShowcaseRegistration
//
//  Created by John Gallaugher on 4/24/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Students {
    var studentArray: [Student] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("students").addSnapshotListener { (querySnapshot, error) in
            self.studentArray = []
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            // there are querySnapshot!.documents.count documents
            for document in querySnapshot!.documents {
                let student = Student(dictionary: document.data())
                student.documentID = document.documentID
                self.studentArray.append(student)
            }
            completed()
        }
    }
}

//
//  Student.swift
//  AppShowcaseRegistration
//
//  Created by John Gallaugher on 4/24/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Student  {
    var firstName: String
    var lastName: String
    var appName: String
    var appDescription: String
    var coordinate: CLLocationCoordinate2D
    var postingUserID: String
    var imageID: String
    var documentID: String
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var dictionary: [String: Any] {
        return ["firstName": firstName, "lastName": lastName, "appName": appName,
                "appDescription": appDescription, "longitude": longitude, "latitude": latitude,  "postingUserID": postingUserID, "imageID": imageID]
    }
    
    init(firstName: String, lastName: String,
         appName: String, appDescription: String, coordinate: CLLocationCoordinate2D, postingUserID: String, imageID: String, documentID: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.appName = appName
        self.appDescription = appDescription
        self.coordinate = coordinate
        self.postingUserID = postingUserID
        self.imageID = imageID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(firstName: "", lastName: "", appName: "", appDescription: "", coordinate: CLLocationCoordinate2D(), postingUserID: "", imageID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let firstName = dictionary["firstName"] as! String? ?? ""
        let lastName = dictionary["lastName"] as! String? ?? ""
        let appName = dictionary["appName"] as! String? ?? ""
        let appDescription = dictionary["appDescription"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let imageID = dictionary["imageID"] as! String? ?? ""
        self.init(firstName: firstName, lastName: lastName, appName: appName, appDescription: appDescription, coordinate: coordinate, postingUserID: postingUserID, imageID: imageID, documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab the userID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completed(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("students").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: updating document \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document updated with ref ID \(ref.documentID)")
                    self.documentID = ref.documentID
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil // Let firestore create the new documentID
            ref = db.collection("students").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("*** ERROR: creating new document \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ new document created with ref ID \(ref?.documentID ?? "unknown")")
                    self.documentID = ref!.documentID
                    completed(true)
                }
            }
        }
    }

}

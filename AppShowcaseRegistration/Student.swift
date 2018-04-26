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
    var image: UIImage
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
         appName: String, appDescription: String, coordinate: CLLocationCoordinate2D, postingUserID: String, imageID: String, image: UIImage, documentID: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.appName = appName
        self.appDescription = appDescription
        self.coordinate = coordinate
        self.postingUserID = postingUserID
        self.imageID = imageID
        self.image = image
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(firstName: "", lastName: "", appName: "", appDescription: "", coordinate: CLLocationCoordinate2D(), postingUserID: "", imageID: "", image: UIImage(), documentID: "")
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
        self.init(firstName: firstName, lastName: lastName, appName: appName, appDescription: appDescription, coordinate: coordinate, postingUserID: postingUserID, imageID: imageID,image: UIImage(), documentID: "")
    }
    
    func loadImage(completed: @escaping () -> ()) {
        let storage = Storage.storage()
        // Create a ref to hold the new photo that we're loading
        let storageRef =
            storage.reference().child(self.imageID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { data, error in
            if let error = error {
                print("An error occurred while reading data from file ref: \(storageRef), error \(error.localizedDescription)")
                completed()
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                completed()
            }
        }
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        // Create a unique doc name - since we're not doing "addDocument() for the image, we need to use UUID().uuidString to give us a unique value that we'll use as the image's file name.
        imageID = UUID().uuidString
        
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
                    // completed(true)
                    // Commented out because we are adding an image and we're not yet done
                }
            }
        }
        
        // Create a storage instance, just like db
        let storage = Storage.storage()
        // Convert image to type Data so it can be saved to Storage
        guard let photoData = UIImageJPEGRepresentation(self.image, 0.5) else {
            print("*** ERROR: creating imageData from JPEGRepresentation")
            return completed(false)
        }
        let storageRef =
            storage.reference().child(self.imageID)
        // Save it & check the result
        let uploadTask = storageRef.putData(photoData)
        
        // If .success, all is good
        uploadTask.observe(.success) { snapshot in // Report if update is successful
            completed(true)
        }
        
        // If .failure, completed is false
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("*** ERROR: Could not upload image w/imageID: \(self.imageID), \(error.localizedDescription)")
                completed(false)
            }
        }
    }
}

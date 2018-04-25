//
//  DetailTableViewController.swift
//  AppShowcaseRegistration
//
//  Created by John Gallaugher on 4/24/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var appNameTextField: UITextField!
    @IBOutlet weak var appDescriptionTextView: UITextView!
    var student: Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if student == nil {
            student = Student()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        firstNameTextField.text = student.firstName
        lastNameTextField.text = student.lastName
        appNameTextField.text = student.appName
        appDescriptionTextView.text = student.appDescription
    }
    
    func leaveViewController() {
        let isPrestingInAddMode = presentingViewController is UINavigationController
        if isPrestingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        student.firstName = firstNameTextField.text!
        student.lastName = lastNameTextField.text!
        student.appName = appNameTextField.text!
        student.appDescription = appDescriptionTextView.text!
        student.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn’t saved.")
            }
        }
    }

}

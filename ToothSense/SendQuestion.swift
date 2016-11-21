//
//  SendQuestion.swift
//  ToothSense
//
//  Created by Dillon Murphy on 11/19/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit

class SendQuestion : UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var emailInfoField: ImageTextField!
    
    @IBOutlet weak var userInput: UITextView!
    
    @IBOutlet weak var SendInputButton: UIButton!
    
    override func viewDidLoad() {
        view.backgroundColor = AppConfiguration.backgroundColor
        self.title = "ToothSense"
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedDismiss)))
        self.SendInputButton.addTarget(self, action: #selector(self.SentComment), forControlEvents: .TouchUpInside)
        
        addBackButton()
    }
    
    override func tappedBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tappedDismiss(sender: UITapGestureRecognizer) {
        if emailInfoField.isFirstResponder() {
            emailInfoField.resignFirstResponder()
        } else if userInput.isFirstResponder() {
            userInput.resignFirstResponder()
        }
    }
    
    func SentComment(sender: UIButton) {
        if self.emailInfoField.text != nil {
            if !self.emailInfoField.text!.isEmpty {
                let object: PFObject = PFObject(className: "SupportRequests")
                object["email"] = self.emailInfoField.text!
                object["Description"] = self.userInput.text!
                object.saveInBackgroundWithBlock({ (success, error) in
                    if error == nil {
                        ProgressHUD.showSuccess("Comment Sent")
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        ProgressHUD.showError("Error Sending Please Try Again Later.")
                    }
                })
            } else {
                ProgressHUD.showError("Email field empty please enter your email address and try again.")
            }
        } else {
            ProgressHUD.showError("Email field empty please enter your email address and try again.")
        }
    }
    
}

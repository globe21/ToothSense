//
//  RatingViewController.swift
//  PopupDialog
//
//  Created by Martin Wildfeuer on 11.07.16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class PopupTextViewController: UIViewController {


    @IBOutlet weak var emailTextField: ImageTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func endEditing() {
        view.endEditing(true)
    }
}

extension PopupTextViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}


class PopupReportTextViewController: UIViewController {
    
    
    @IBOutlet weak var reportTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        reportTextView.layer.borderColor = AppConfiguration.navColor.CGColor
        reportTextView.layer.borderWidth = 2.0
        reportTextView.layer.cornerRadius = 3.0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func endEditing() {
        view.endEditing(true)
    }
}


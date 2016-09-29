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

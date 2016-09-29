//
//  ViewController.swift
//  Swifty
//
//  Created by Jamal Kharrat on 7/13/14.
//  Copyright (c) 2014 Jamal Designs. All rights reserved.
//

import UIKit
import QuartzCore
import Parse
import ParseUI
//import BEMCheckBox

class LoginViewController: UIViewController, UITextFieldDelegate, NavgationTransitionable, BEMCheckBoxDelegate {
    
    //MARK: Outlets for UI Elements.
    @IBOutlet weak var usernameField:   ImageTextField!
    @IBOutlet weak var imageView:       UIImageView!
    @IBOutlet weak var passwordField:   ImageTextField!
    @IBOutlet weak var loginButton:     UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var customCheckbox: BEMCheckBox!
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func settingupView() {
        view.backgroundColor = AppConfiguration.backgroundColor
        if defaults.valueForKey("userEmail") != nil {
            usernameField.text = defaults.valueForKey("userEmail") as? String
            customCheckbox.on = true
        }
        removeBack()
        usernameField.alpha = 0
        passwordField.alpha = 0
        loginButton.alpha   = 0
        signupButton.alpha   = 0
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.usernameField.alpha = 1.0
            self.passwordField.alpha = 1.0
            self.loginButton.alpha   = 0.9
            self.signupButton.alpha   = 0.9
            }, completion: nil)
        
        // Notifiying for Changes in the textFields
        
        usernameField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
        passwordField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
        signupButton.addTarget(self, action: #selector(LoginViewController.signupPressed), forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.addTarget(self, action: #selector(LoginViewController.buttonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        forgotButton.addTarget(self, action: #selector(LoginViewController.forgotPressed), forControlEvents: UIControlEvents.TouchUpInside)
        /*
        // Visual Effect View for background
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) as UIVisualEffectView
        visualEffectView.frame = self.view.frame
        visualEffectView.alpha = 0.5
        view.insertSubview(visualEffectView, belowSubview: self.view)
        //insertSubview(visualEffectView, atIndex: 0)
        */
        self.loginButton(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingupView()
    }
    
    
    func didTapCheckBox(checkBox:BEMCheckBox) {
    }
    
    func animationDidStopForCheckBox(checkBox:BEMCheckBox) {
    
    }
    
    func loginsignupEmailSaveCheck() {
        if customCheckbox.on == true {
            defaults.setValue(PFUser.currentUser()!.email!, forKey: "userEmail")
        } else {
            defaults.removeObjectForKey("userEmail")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func loginButton(enabled: Bool) -> () {
        func enable(){
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.loginButton.backgroundColor = UIColor.init(hex: "33CC00")
                self.signupButton.backgroundColor = UIColor.init(hex: "33CC00")
                }, completion: nil)
            loginButton.enabled = true
            signupButton.enabled = true
        }
        func disable(){
            loginButton.enabled = false
            signupButton.enabled = false
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.loginButton.backgroundColor = UIColor.init(hex: "333333")
                self.signupButton.backgroundColor = UIColor.init(hex: "333333")
                }, completion: nil)
        }
        return enabled ? enable() : disable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldDidChange() {
        if usernameField.text!.isEmpty || passwordField.text!.isEmpty {
            self.loginButton(false)
        } else {
            self.loginButton(true)
        }
    }
    
    func buttonPressed(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(self.usernameField.text!, password:self.passwordField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if error == nil {
                let mainVcIntial = kConstantObj.SetIntialMainViewController()
                appDelegate.window?.rootViewController = mainVcIntial
                self.loginsignupEmailSaveCheck()
            } else {
                self.usernameField.shake()
                self.passwordField.shake()
                self.loadView()
                self.settingupView()
                //ProgressHUD.showError("Incorrect Username/Password")
                ProgressHUD.showError(error?.localizedDescription)
            }
        }
    }
    
    func signupPressed(sender: AnyObject) {
        let user = PFUser()
        user.username = self.usernameField.text
        user.password = self.passwordField.text
        user.email = self.usernameField.text
        user.signUpInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                self.usernameField.shake()
                self.passwordField.shake()
                self.loadView()
                self.settingupView()
                ProgressHUD.showError(error?.localizedDescription)
            } else {
                let mainVcIntial = kConstantObj.SetIntialMainViewController()
                appDelegate.window?.rootViewController = mainVcIntial
                self.loginsignupEmailSaveCheck()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let ViewController:BuildViewController = storyboard.instantiateViewControllerWithIdentifier("BuildViewController") as! BuildViewController
                let ProfileImage: PFImageView = PFImageView()
                ProfileImage.file = PFUser.currentUser()!.getProfPic()
                ProfileImage.loadInBackground({ (image, error) in
                    if error == nil {
                        ViewController.profileImage = image!
                        ViewController.fullname = PFUser.currentUser()!.Fullname()
                        ViewController.age = PFUser.currentUser()!.getBirthday()
                        sideMenuNavigationController!.pushViewController(ViewController, animated: true)
                    } else {
                        sideMenuNavigationController!.pushViewController(ViewController, animated: true)
                    }
                })
            }
        })
    }
    
    
    func forgotPressed(sender: AnyObject) {
        let popVC = PopupTextViewController(nibName: "PopupTextViewController", bundle: nil)
        let popup = PopupDialog(viewController: popVC, transitionStyle: .BounceUp, buttonAlignment: .Horizontal, gestureDismissal: true)
        let buttonCancel = CancelButton(title: "CANCEL") {
        }
        let buttonTwo = DefaultButton(title: "SEND") {
            print(popVC.emailTextField.text)
            if popVC.emailTextField.text == nil {
                popVC.emailTextField.shake()
            } else {
                let text: String = popVC.emailTextField.text!
                PFUser.requestPasswordResetForEmailInBackground(text, block: { (success, error) in
                    if error == nil {
                        let popup2 = PopupDialog(title: "Email Sent!", message: "We've sent an email to \(text) with instructions on how to reset your password.", image: nil)
                        let buttonCancel = CancelButton(title: "OK") {
                        }
                        popup2.addButtons([buttonCancel])
                        self.presentViewController(popup2, animated: true, completion: nil)
                    } else {
                        let popup2 = PopupDialog(title: "Email Failed To Send!", message: error!.localizedDescription, image: nil)
                        let buttonCancel = CancelButton(title: "OK") {
                        }
                        popup2.addButtons([buttonCancel])
                        self.presentViewController(popup2, animated: true, completion: nil)
                    }
                })
            }
        }
        popup.addButtons([buttonCancel, buttonTwo])
        self.presentViewController(popup, animated: true, completion: nil)
    }
    
    
}


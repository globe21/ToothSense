//
//  BuidlProfile.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/25/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//
//  ViewController.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Foundation
import UserNotifications
import UserNotificationsUI

class BuildViewController : FormViewController, NavgationTransitionable {
    
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    
    var buildFontBold: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 25)!
    var buildFont: UIFont = UIFont(name: "AmericanTypewriter", size: 20)!
    var buildFontSmall: UIFont = UIFont(name: "AmericanTypewriter", size: 15)!
    
    var fullname: String = "Username"
    var age: NSDate?
    var profileImage: UIImage = UIImage(named: "ProfileIcon")!
    var AvgBrushTime = 0.0
    var TimesBrushed = 0
    var AMChanged: Bool = false
    var PMChanged: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        //removeBack()
        addHamMenu()
        addBackButton()
    }
    
    override func viewWillDisappear(animated: Bool) {
        AMChanged = false
        PMChanged = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = AppConfiguration.backgroundColor
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            self.view.frame = CGRect(x: 0, y: 44, width: 414, height: 643)
            buildFontBold = UIFont(name: "AmericanTypewriter-Bold", size: 25)!
            buildFont = UIFont(name: "AmericanTypewriter", size: 20)!
            buildFontSmall = UIFont(name: "AmericanTypewriter", size: 15)!
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            buildFontBold = UIFont(name: "AmericanTypewriter-Bold", size: 20)!
            buildFont = UIFont(name: "AmericanTypewriter", size: 15)!
            buildFontSmall = UIFont(name: "AmericanTypewriter", size: 11)!
            self.view.frame = CGRect(x: 0, y: 44, width: 375, height: 574)
        } else {
            buildFontBold = UIFont(name: "AmericanTypewriter-Bold", size: 20)!
            buildFont = UIFont(name: "AmericanTypewriter", size: 15)!
            buildFontSmall = UIFont(name: "AmericanTypewriter", size: 11)!
            self.view.frame = CGRect(x: 0, y: 44, width: 320, height: 475)
        }
        title = "Build Your Profile"
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 40
            cell.accessoryView?.layer.borderWidth = 3.0
            cell.accessoryView?.layer.borderColor = AppConfiguration.tealColor.CGColor
            cell.accessoryView?.frame = CGRectMake(0, 0, 80, 80)
            cell.textLabel?.font = self.buildFont
            cell.height = { return 100 }
        }
        
        
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            
            form =
                Section() {
                    $0.header = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
                }
                +++ ImageRow("Profile"){
                    $0.title = "Pick a Profile Picture"
                    $0.value = profileImage
                }
                <<< NameRow(){
                    $0.title = "Enter Your Username"
                    $0.placeholder = fullname
                    $0.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                    })
                    $0.onChange({ (row) in
                        self.fullname = row.cell.textField.text!//row.value
                    })
                }
                <<< DateInlineRow("Enter Your Birthday"){
                    $0.title = $0.tag
                    if self.age != nil {
                        $0.value = self.age!
                    } else {
                        $0.value = NSDate()
                    }
                    $0.maximumDate = NSDate()
                    }.onChange{ (date) in
                        self.age = date.value!
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Date
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                    })
                
                +++ TimeInlineRow("Morning Brush Reminder") {
                    $0.title = $0.tag
                    if defaults.valueForKey("AMReminder") != nil {
                        $0.value = defaults.valueForKey("AMReminder") as? NSDate
                    } else {
                        $0.value = NSDate().change(nil, month: nil, day: nil, hour: 10, minute: 0, second: 0)
                    }
                    }.onChange { [weak self] row in
                        self!.AMChanged = true
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Time
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                    })
                <<< TimeInlineRow("Evening Brush Reminder"){
                    $0.title = $0.tag
                    if defaults.valueForKey("PMReminder") != nil {
                        $0.value = defaults.valueForKey("PMReminder") as? NSDate
                    } else {
                        $0.value = NSDate().change(nil, month: nil, day: nil, hour: 18, minute: 0, second: 0)
                    }
                    }.onChange { [weak self] row in
                        self!.PMChanged = true
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Time
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                    })
                <<< ButtonRow(){ row in
                    row.title = "Reset Alarms"
                    row.cellSetup({ (cell, row) in
                        cell.contentView.backgroundColor = AppConfiguration.darkGrayColor
                        //UIColor.init(hex: "333333")
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let AMRow: TimeInlineRow! = self.form.rowByTag("Morning Brush Reminder")
                        let PMRow: TimeInlineRow! = self.form.rowByTag("Evening Brush Reminder")
                        AMRow.value = NSDate().change(nil, month: nil, day: nil, hour: 10, minute: 0, second: 0)
                        AMRow.updateCell()
                        PMRow.value = NSDate().change(nil, month: nil, day: nil, hour: 18, minute: 0, second: 0)
                        PMRow.updateCell()
                        if #available(iOS 10.0, *) {
                            Notifycenter.removeAllPendingNotificationRequests()
                            Notifycenter.removeAllDeliveredNotifications()
                        } else {
                            UIApplication.sharedApplication().cancelLocalNotification(AMNotification)
                            UIApplication.sharedApplication().cancelLocalNotification(PMNotification)
                        }
                        defaults.setValue(nil, forKey: "AMReminder")
                        defaults.setValue(nil, forKey: "PMReminder")
                    })
                }
                +++ ButtonRow(){ row in
                    row.title = "Done"
                    row.cellSetup({ (cell, row) in
                        cell.height = { return 60 }
                        cell.contentView.backgroundColor = AppConfiguration.tealColor
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFontBold
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let AMRow: TimeInlineRow! = self.form.rowByTag("Morning Brush Reminder")
                        let PMRow: TimeInlineRow! = self.form.rowByTag("Evening Brush Reminder")
                        if #available(iOS 10.0, *) {
                            if self.AMChanged == true {
                                defaults.setValue(AMRow.value, forKey: "AMReminder")
                                self.setAlarm(AMRow.value!.hour, Min: AMRow.value!.minute, AM: true)
                            }
                            if self.PMChanged == true {
                                defaults.setValue(PMRow.value, forKey: "PMReminder")
                                self.setAlarm(PMRow.value!.hour, Min: PMRow.value!.minute, AM: false)
                            }
                        } else {
                            if self.AMChanged == true {
                                defaults.setValue(AMRow.value, forKey: "AMReminder")
                                self.setAlarm(AMRow.value!.hour, Min: AMRow.value!.minute, AM: true)
                            }
                            if self.PMChanged == true {
                                defaults.setValue(PMRow.value, forKey: "PMReminder")
                                self.setAlarm(PMRow.value!.hour, Min: PMRow.value!.minute, AM: false)
                            }
                        }
                        let imageRow: ImageRow! = self.form.rowByTag("Profile")
                        var image: UIImage = (imageRow.cell.accessoryView as! UIImageView).image!
                        if image.size.width > 280 {
                            image = Images.resizeImage(image, width: 280, height: 280)!
                        }
                        let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
                        pictureFile!.saveInBackground()
                        PFUser.currentUser()!["profPic"] = pictureFile
                        if self.age != nil {
                            PFUser.currentUser()!["Birthday"] = self.age
                        }
                        PFUser.currentUser()!["fullname"] = self.fullname
                        PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) in
                            if error == nil {
                                ProgressHUD.showSuccess("Updated Profile Info")
                                let mainVcIntial = kConstantObj.SetIntialMainViewController()
                                appDelegate.window?.rootViewController = mainVcIntial
                            }
                        })
                    })
            }
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            
            form =
                Section() {
                    $0.header = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
                }
                <<< ImageRow("Profile"){
                    $0.title = "Pick a Profile Picture"
                    $0.value = profileImage
                }
                <<< NameRow(){
                    $0.title = "Enter Your Username"
                    $0.placeholder = fullname
                    $0.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                    $0.onChange({ (row) in
                        self.fullname = row.cell.textField.text!//row.value
                    })
                }
                <<< DateInlineRow("Enter Your Birthday"){
                    $0.title = $0.tag
                    if self.age != nil {
                        $0.value = self.age!
                    }else {
                        $0.value = NSDate()
                    }
                    $0.maximumDate = NSDate()
                    }.onChange{ (date) in
                        self.age = date.value!
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Date
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                    })
                <<< TimeInlineRow("Morning Brush Reminder") {
                    $0.title = $0.tag
                    if defaults.valueForKey("AMReminder") != nil {
                        $0.value = defaults.valueForKey("AMReminder") as? NSDate
                    } else {
                        $0.value = NSDate().change(nil, month: nil, day: nil, hour: 10, minute: 0, second: 0)
                    }
                    }.onChange { [weak self] row in
                        self!.AMChanged = true
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Time
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                <<< TimeInlineRow("Evening Brush Reminder"){
                    $0.title = $0.tag
                    if defaults.valueForKey("PMReminder") != nil {
                        $0.value = defaults.valueForKey("PMReminder") as? NSDate
                    } else {
                        $0.value = NSDate().change(nil, month: nil, day: nil, hour: 18, minute: 0, second: 0)
                    }
                    }.onChange { [weak self] row in
                        self!.PMChanged = true
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Time
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                <<< ButtonRow(){ row in
                    row.title = "Reset Alarms"
                    row.cellSetup({ (cell, row) in
                        cell.contentView.backgroundColor = AppConfiguration.darkGrayColor
                        //UIColor.init(hex: "333333")
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let AMRow: TimeInlineRow! = self.form.rowByTag("Morning Brush Reminder")
                        let PMRow: TimeInlineRow! = self.form.rowByTag("Evening Brush Reminder")
                        AMRow.value = NSDate().change(nil, month: nil, day: nil, hour: 10, minute: 0, second: 0)
                        AMRow.updateCell()
                        PMRow.value = NSDate().change(nil, month: nil, day: nil, hour: 18, minute: 0, second: 0)
                        PMRow.updateCell()
                        if #available(iOS 10.0, *) {
                            Notifycenter.removeAllPendingNotificationRequests()
                            Notifycenter.removeAllDeliveredNotifications()
                        } else {
                            UIApplication.sharedApplication().cancelLocalNotification(AMNotification)
                            UIApplication.sharedApplication().cancelLocalNotification(PMNotification)
                        }
                        defaults.setValue(nil, forKey: "AMReminder")
                        defaults.setValue(nil, forKey: "PMReminder")
                    })
                }
                +++ ButtonRow(){ row in
                    row.title = "Done"
                    row.cellSetup({ (cell, row) in
                        cell.height = { return 60 }
                        cell.contentView.backgroundColor = AppConfiguration.tealColor
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFontBold
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let AMRow: TimeInlineRow! = self.form.rowByTag("Morning Brush Reminder")
                        let PMRow: TimeInlineRow! = self.form.rowByTag("Evening Brush Reminder")
                        if #available(iOS 10.0, *) {
                            if self.AMChanged == true {
                                defaults.setValue(AMRow.value, forKey: "AMReminder")
                                self.setAlarm(AMRow.value!.hour, Min: AMRow.value!.minute, AM: true)
                            }
                            if self.PMChanged == true {
                                defaults.setValue(PMRow.value, forKey: "PMReminder")
                                self.setAlarm(PMRow.value!.hour, Min: PMRow.value!.minute, AM: false)
                            }
                        } else {
                            if self.AMChanged == true {
                                defaults.setValue(AMRow.value, forKey: "AMReminder")
                                self.setAlarm(AMRow.value!.hour, Min: AMRow.value!.minute, AM: true)
                            }
                            if self.PMChanged == true {
                                defaults.setValue(PMRow.value, forKey: "PMReminder")
                                self.setAlarm(PMRow.value!.hour, Min: PMRow.value!.minute, AM: false)
                            }
                        }
                        let imageRow: ImageRow! = self.form.rowByTag("Profile")
                        var image: UIImage = (imageRow.cell.accessoryView as! UIImageView).image!
                        if image.size.width > 280 {
                            image = Images.resizeImage(image, width: 280, height: 280)!
                        }
                        let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
                        pictureFile!.saveInBackground()
                        (imageRow.cell.accessoryView as! UIImageView).image = image
                        PFUser.currentUser()!["profPic"] = pictureFile
                        if self.age != nil {
                            PFUser.currentUser()!["Birthday"] = self.age
                        }
                        PFUser.currentUser()!["fullname"] = self.fullname
                        PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) in
                            if error == nil {
                                ProgressHUD.showSuccess("Updated Profile Info")
                                let mainVcIntial = kConstantObj.SetIntialMainViewController()
                                appDelegate.window?.rootViewController = mainVcIntial
                            }
                        })
                    })
            }
        } else {
            
            form =
                Section() {
                    $0.header = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
                }
                <<< ImageRow("Profile"){
                    $0.title = "Pick a Profile Picture"
                    $0.value = profileImage
                }
                <<< NameRow(){
                    $0.title = "Enter Your Username"
                    $0.placeholder = fullname
                    $0.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                    $0.onChange({ (row) in
                        self.fullname = row.cell.textField.text!//row.value
                    })
                }
                <<< DateInlineRow("Enter Your Birthday"){
                    $0.title = $0.tag
                    if self.age != nil {
                        $0.value = self.age!
                    }else {
                        $0.value = NSDate()
                    }
                    $0.maximumDate = NSDate()
                    }.onChange{ (date) in
                        self.age = date.value!
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Date
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                    })
                <<< TimeInlineRow("Morning Brush Reminder") {
                    $0.title = $0.tag
                    if defaults.valueForKey("AMReminder") != nil {
                        $0.value = defaults.valueForKey("AMReminder") as? NSDate
                    } else {
                        $0.value = NSDate().change(nil, month: nil, day: nil, hour: 10, minute: 0, second: 0)
                    }
                    }.onChange { [weak self] row in
                        self!.AMChanged = true
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Time
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                <<< TimeInlineRow("Evening Brush Reminder"){
                    $0.title = $0.tag
                    if defaults.valueForKey("PMReminder") != nil {
                        $0.value = defaults.valueForKey("PMReminder") as? NSDate
                    } else {
                        $0.value = NSDate().change(nil, month: nil, day: nil, hour: 18, minute: 0, second: 0)
                    }
                    }.onChange { [weak self] row in
                        self!.PMChanged = true
                    }.onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .Time
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                    }.cellSetup({ (cell, row) in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                <<< ButtonRow(){ row in
                    row.title = "Reset Alarms"
                    row.cellSetup({ (cell, row) in
                        cell.contentView.backgroundColor = AppConfiguration.darkGrayColor
                        //UIColor.init(hex: "333333")
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let AMRow: TimeInlineRow! = self.form.rowByTag("Morning Brush Reminder")
                        let PMRow: TimeInlineRow! = self.form.rowByTag("Evening Brush Reminder")
                        AMRow.value = NSDate().change(nil, month: nil, day: nil, hour: 10, minute: 0, second: 0)
                        AMRow.updateCell()
                        PMRow.value = NSDate().change(nil, month: nil, day: nil, hour: 18, minute: 0, second: 0)
                        PMRow.updateCell()
                        if #available(iOS 10.0, *) {
                            Notifycenter.removeAllPendingNotificationRequests()
                            Notifycenter.removeAllDeliveredNotifications()
                        } else {
                            UIApplication.sharedApplication().cancelLocalNotification(AMNotification)
                            UIApplication.sharedApplication().cancelLocalNotification(PMNotification)
                        }
                        defaults.setValue(nil, forKey: "AMReminder")
                        defaults.setValue(nil, forKey: "PMReminder")
                    })
                }
                
                <<< ButtonRow(){ row in
                    row.title = "Done"
                    row.cellSetup({ (cell, row) in
                        cell.height = { return 60 }
                        cell.contentView.backgroundColor = AppConfiguration.tealColor
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFontBold
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let AMRow: TimeInlineRow! = self.form.rowByTag("Morning Brush Reminder")
                        let PMRow: TimeInlineRow! = self.form.rowByTag("Evening Brush Reminder")
                        if #available(iOS 10.0, *) {
                            if self.AMChanged == true {
                                defaults.setValue(AMRow.value, forKey: "AMReminder")
                                self.setAlarm(AMRow.value!.hour, Min: AMRow.value!.minute, AM: true)
                            }
                            if self.PMChanged == true {
                                defaults.setValue(PMRow.value, forKey: "PMReminder")
                                self.setAlarm(PMRow.value!.hour, Min: PMRow.value!.minute, AM: false)
                            }
                        } else {
                            if self.AMChanged == true {
                                defaults.setValue(AMRow.value, forKey: "AMReminder")
                                self.setAlarm(AMRow.value!.hour, Min: AMRow.value!.minute, AM: true)
                            }
                            if self.PMChanged == true {
                                defaults.setValue(PMRow.value, forKey: "PMReminder")
                                self.setAlarm(PMRow.value!.hour, Min: PMRow.value!.minute, AM: false)
                            }
                        }
                        let imageRow: ImageRow! = self.form.rowByTag("Profile")
                        var image: UIImage = (imageRow.cell.accessoryView as! UIImageView).image!
                        if image.size.width > 280 {
                            image = Images.resizeImage(image, width: 280, height: 280)!
                        }
                        let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
                        pictureFile!.saveInBackground()
                        (imageRow.cell.accessoryView as! UIImageView).image = image
                        PFUser.currentUser()!["profPic"] = pictureFile
                        if self.age != nil {
                            PFUser.currentUser()!["Birthday"] = self.age
                        }
                        PFUser.currentUser()!["fullname"] = self.fullname
                        PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) in
                            if error == nil {
                                ProgressHUD.showSuccess("Updated Profile Info")
                                let mainVcIntial = kConstantObj.SetIntialMainViewController()
                                appDelegate.window?.rootViewController = mainVcIntial
                            }
                        })
                    })
                }
                +++ TextRow()
        }
    }
    
    
    func setAlarm(hour: Int, Min: Int, AM: Bool) {
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.hour = hour
        dateComponents.minute = Min
        if #available(iOS 10.0, *) {
            let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatchingComponents: dateComponents, repeats: true)
            let path: String = NSBundle.mainBundle().pathForResource("timer_6", ofType:"mp4")!
            let fileURL = NSURL.init(fileURLWithPath: path)
            let content: UNMutableNotificationContent = UNMutableNotificationContent()
            content.title = "Hey \(PFUser.currentUser()!["fullname"] as! String)!"
            content.sound = UNNotificationSound.defaultSound()
            do {
                let attachment = try UNNotificationAttachment(identifier: "image", URL: fileURL, options: nil)
                content.attachments = [ attachment ]
            } catch {
                
            }
            /// 4. update application icon badge number
            let badgeNum = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
            content.badge = NSNumber(integerLiteral: badgeNum)
            var request: UNNotificationRequest!
            if AM == true {
                Notifycenter.removeDeliveredNotificationsWithIdentifiers(["AMAlarm"])
                Notifycenter.removePendingNotificationRequestsWithIdentifiers(["AMAlarm"])
                content.body = "Don't forget to brush this morning.."
                request = UNNotificationRequest(identifier: "AMAlarm", content: content, trigger: trigger)
            } else {
                Notifycenter.removeDeliveredNotificationsWithIdentifiers(["PMAlarm"])
                Notifycenter.removePendingNotificationRequestsWithIdentifiers(["PMAlarm"])
                content.body = "Don't forget to brush before Bed!"
                request = UNNotificationRequest(identifier: "PMAlarm", content: content, trigger: trigger)
            }
            //Notifycenter.removeAllDeliveredNotifications()
            Notifycenter.addNotificationRequest(request) { (error) in
                if (error == nil) {
                    print("Created Alarm")//: \(dateComponents.date!))")
                }
            }
        } else {
            if AM == true {
                UIApplication.sharedApplication().cancelLocalNotification(AMNotification)
                AMNotification.fireDate = NSDate().change(nil, month: nil, day: nil, hour: hour, minute: Min, second: nil)
                AMNotification.alertBody = "Hey \(PFUser.currentUser()!["fullname"] as! String)!"
                AMNotification.alertAction = "Don't forget to brush this morning.."
                AMNotification.soundName = UILocalNotificationDefaultSoundName
                AMNotification.repeatInterval = .Day
                UIApplication.sharedApplication().scheduleLocalNotification(AMNotification)
            } else {
                UIApplication.sharedApplication().cancelLocalNotification(PMNotification)
                PMNotification.fireDate = NSDate().change(nil, month: nil, day: nil, hour: hour, minute: Min, second: nil)
                PMNotification.alertBody = "Hey \(PFUser.currentUser()!["fullname"] as! String)!"
                PMNotification.alertAction = "Don't forget to brush before Bed!"
                PMNotification.soundName = UILocalNotificationDefaultSoundName
                PMNotification.repeatInterval = .Day
                UIApplication.sharedApplication().scheduleLocalNotification(PMNotification)
            }
        }
    }
}

class EurekaLogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: 100)
        self.frame = frame
        let imageView = UIImageView(image: UIImage(named: "Tooth"))
        imageView.frame = CGRect(x: frame.midX - (frame.height/2), y: frame.midY - (frame.height/2), width: frame.height, height: frame.height)
        imageView.autoresizingMask = .FlexibleWidth
        imageView.contentMode = .ScaleAspectFit
        self.backgroundColor = AppConfiguration.tealColor
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ManualEntry.swift
//  ToothSense
//
//  Created by Dillon Murphy on 9/15/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications
import UserNotificationsUI

class ManualEntry : FormViewController, NavgationTransitionable {
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    
    var buildFontBold: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 25)!
    var buildFont: UIFont = UIFont(name: "AmericanTypewriter", size: 20)!
    var buildFontSmall: UIFont = UIFont(name: "AmericanTypewriter", size: 15)!
    
    var Flossed = false
    var AMBrush = false
    
    override func viewWillAppear(animated: Bool) {
        removeBack()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = "Entering Brushing"
        sideMenuNavigationController!.tr_popToRootViewController()
        Flossed = false
        AMBrush = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            eurekaImageView.alpha = 1.0
            eurekaImageView.image = UIImage(named: "Tooth")!
        }, completion:  nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppConfiguration.backgroundColor
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            self.view.frame = CGRect(x: 0, y: 44, width: 414, height: 643)
            buildFontBold = UIFont(name: "AmericanTypewriter-Bold", size: 25)!
            buildFont = UIFont(name: "AmericanTypewriter", size: 20)!
            buildFontSmall = UIFont(name: "AmericanTypewriter", size: 15)!
            form =
                Section() {
                    $0.header = HeaderFooterView<EurekaBrushView>(HeaderFooterProvider.Class)
                }
                +++ PickerInlineRow<CGFloat>("Enter Brush Time") { (row : PickerInlineRow<CGFloat>) -> Void in
                    row.title = "Enter Brush Time"
                    row.options = []
                    row.value = 0.0
                    for i in 0..<151 {
                        row.options.append(CGFloat(i))
                    }
                    row.displayValueFor = { (rowValue: CGFloat?) in
                        return rowValue?.toMinSecLong()
                    }
                    row.onChange({ (picker) in
                        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: screenBounds.width, dy: 0)
                            }, completion: { _ in
                                switch Int(picker.value!) {
                                case 0:
                                    eurekaImageView.image = UIImage(named: "Tooth")!
                                    self.title = "Enter Brush Time"
                                case 1...45:
                                    eurekaImageView.image = AppConfiguration.ToothBadge1
                                    self.title = "Cavity Maker"
                                case 46...75:
                                    eurekaImageView.image = AppConfiguration.ToothBadge2
                                    self.title = "Sugar Bug"
                                case 76...105:
                                    eurekaImageView.image = AppConfiguration.ToothBadge3
                                    self.title = "Tooth Protector!"
                                default:
                                    eurekaImageView.image = AppConfiguration.ToothBadge4
                                    self.title = "Tooth Hero!"
                                }
                                eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: -2 * screenBounds.width, dy: 0)
                                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: screenBounds.width, dy: 0)
                                    }, completion: nil)
                        })
                    })
                    row.cellSetup({ (cell, row) in
                        cell.detailTextLabel?.font = self.buildFontSmall
                        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                }
                +++ DateInlineRow("Enter Date of Brushing"){
                    $0.title = $0.tag
                    $0.value = NSDate()
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
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                +++ SwitchRow("AM or PM?"){ row in      // initializer
                    row.title = "AM or PM?"
                    }.onChange { row in
                        row.title = (row.value ?? false) ? "AM" : "PM"
                        self.AMBrush = row.value!
                        row.updateCell()
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                }
                +++ SwitchRow("Did you remember to Floss?"){ row in      // initializer
                    row.title = "Did you remember to Floss?"
                    }.onChange { row in
                        row.title = (row.value ?? false) ? "Great Job Flossing!" : "Don't forget to Floss!"
                        self.Flossed = row.value!
                        row.updateCell()
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                }
                +++ ButtonRow(){ row in
                    row.title = "Save Brush Entry"
                    row.cellSetup({ (cell, row) in
                        cell.height = { return 60 }
                        cell.contentView.backgroundColor = AppConfiguration.navColor
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFontBold
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let brushDateRow: DateInlineRow! = self.form.rowByTag("Enter Date of Brushing")
                        let timeRow: PickerInlineRow<CGFloat>! = self.form.rowByTag("Enter Brush Time")
                        let smile: PFObject = PFObject(className: "SmilesClub")
                        smile["User"] = PFUser.currentUser()!
                        smile["userPic"] = PFUser.currentUser()!.getProfPic()
                        smile["Name"] = PFUser.currentUser()!.Fullname()
                        smile["Age"] = "AGE: \(PFUser.currentUser()!.getAge())"
                        smile["brushTime"] = timeRow.value!
                        smile["Flosser"] = self.Flossed
                        let formatter:NSDateFormatter = NSDateFormatter()
                        formatter.dateFormat = "a"
                        if self.AMBrush == false {
                            let dater: NSDate = brushDateRow.value!.change(nil, month: nil, day: nil, hour: 6, minute: nil, second: nil)
                            smile["brushDate"] = dater
                            smile["AMPM"] = formatter.stringFromDate(dater)
                        } else {
                            let dater: NSDate = brushDateRow.value!.change(nil, month: nil, day: nil, hour: 18, minute: nil, second: nil)
                            smile["brushDate"] = dater
                            smile["AMPM"] = formatter.stringFromDate(dater)
                        }
                        let flossSwitchRow: SwitchRow! = self.form.rowByTag("Did you remember to Floss?")
                        flossSwitchRow.title = "Did you remember to Floss?"
                        flossSwitchRow.value = false
                        flossSwitchRow.updateCell()
                        let amSwitchRow: SwitchRow! = self.form.rowByTag("AM or PM?")
                        amSwitchRow.title = "AM or PM?"
                        amSwitchRow.value = false
                        amSwitchRow.updateCell()
                        brushDateRow.title = "Enter Date of Brushing"
                        brushDateRow.value = NSDate()
                        brushDateRow.updateCell()
                        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            eurekaImageView.alpha = 0.05
                            }, completion: nil)
                        self.title = "Entering Brushing"
                        PFUser.query()?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error == nil || object != nil {
                                UIView.animateWithDuration(0.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    eurekaImageView.image = UIImage(named: "Tooth")!
                                    }, completion: nil)
                                (object as! PFUser).addBrushTime(timeRow.value!)
                                timeRow.title = "Enter Brush Time"
                                timeRow.options = []
                                timeRow.value = 0.0
                                for i in 0..<151 {
                                    timeRow.options.append(CGFloat(i))
                                }
                                timeRow.displayValueFor = { (rowValue: CGFloat?) in
                                    return rowValue?.toMinSecLong()
                                }
                                timeRow.updateCell()
                                smile.saveInBackground()
                            }
                        })
                    })
            }
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            buildFontBold = UIFont(name: "AmericanTypewriter-Bold", size: 20)!
            buildFont = UIFont(name: "AmericanTypewriter", size: 15)!
            buildFontSmall = UIFont(name: "AmericanTypewriter", size: 11)!
            self.view.frame = CGRect(x: 0, y: 44, width: 375, height: 574)
            form =
                Section() {
                    $0.header = HeaderFooterView<EurekaBrushView>(HeaderFooterProvider.Class)
                }
                +++ PickerInlineRow<CGFloat>("Enter Brush Time") { (row : PickerInlineRow<CGFloat>) -> Void in
                    row.title = "Enter Brush Time"
                    row.options = []
                    row.value = 0.0
                    for i in 0..<151 {
                        row.options.append(CGFloat(i))
                    }
                    row.displayValueFor = { (rowValue: CGFloat?) in
                        return rowValue?.toMinSecLong()
                    }
                    row.onChange({ (picker) in
                        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: screenBounds.width, dy: 0)
                            }, completion: { _ in
                                switch Int(picker.value!) {
                                case 0:
                                    eurekaImageView.image = UIImage(named: "Tooth")!
                                    self.title = "Enter Brush Time"
                                case 1...45:
                                    eurekaImageView.image = AppConfiguration.ToothBadge1
                                    self.title = "Cavity Maker"
                                case 46...75:
                                    eurekaImageView.image = AppConfiguration.ToothBadge2
                                    self.title = "Sugar Bug"
                                case 76...105:
                                    eurekaImageView.image = AppConfiguration.ToothBadge3
                                    self.title = "Tooth Protector!"
                                default:
                                    eurekaImageView.image = AppConfiguration.ToothBadge4
                                    self.title = "Tooth Hero!"
                                }
                                eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: -2 * screenBounds.width, dy: 0)
                                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: screenBounds.width, dy: 0)
                                    }, completion: nil)
                        })
                    })
                    row.cellSetup({ (cell, row) in
                        cell.detailTextLabel?.font = self.buildFontSmall
                        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                }
                +++ DateInlineRow("Enter Date of Brushing"){
                    $0.title = $0.tag
                    $0.value = NSDate()
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
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                +++ SwitchRow("AM or PM?"){ row in      // initializer
                    row.title = "AM or PM?"
                    }.onChange { row in
                        row.title = (row.value ?? false) ? "AM" : "PM"
                        self.AMBrush = row.value!
                        row.updateCell()
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                }
                +++ SwitchRow("Did you remember to Floss?"){ row in      // initializer
                    row.title = "Did you remember to Floss?"
                    }.onChange { row in
                        row.title = (row.value ?? false) ? "Great Job Flossing!" : "Don't forget to Floss!"
                        self.Flossed = row.value!
                        row.updateCell()
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                }
                +++ ButtonRow(){ row in
                    row.title = "Save Brush Entry"
                    row.cellSetup({ (cell, row) in
                        cell.height = { return 60 }
                        cell.contentView.backgroundColor = AppConfiguration.navColor
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFontBold
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let brushDateRow: DateInlineRow! = self.form.rowByTag("Enter Date of Brushing")
                        let timeRow: PickerInlineRow<CGFloat>! = self.form.rowByTag("Enter Brush Time")
                        let smile: PFObject = PFObject(className: "SmilesClub")
                        smile["User"] = PFUser.currentUser()!
                        smile["userPic"] = PFUser.currentUser()!.getProfPic()
                        smile["Name"] = PFUser.currentUser()!.Fullname()
                        smile["Age"] = "AGE: \(PFUser.currentUser()!.getAge())"
                        smile["brushTime"] = timeRow.value!
                        smile["Flosser"] = self.Flossed
                        let formatter:NSDateFormatter = NSDateFormatter()
                        formatter.dateFormat = "a"
                        if self.AMBrush == false {
                            let dater: NSDate = brushDateRow.value!.change(nil, month: nil, day: nil, hour: 6, minute: nil, second: nil)
                            smile["brushDate"] = dater
                            smile["AMPM"] = formatter.stringFromDate(dater)
                        } else {
                            let dater: NSDate = brushDateRow.value!.change(nil, month: nil, day: nil, hour: 18, minute: nil, second: nil)
                            smile["brushDate"] = dater
                            smile["AMPM"] = formatter.stringFromDate(dater)
                        }
                        let flossSwitchRow: SwitchRow! = self.form.rowByTag("Did you remember to Floss?")
                        flossSwitchRow.title = "Did you remember to Floss?"
                        flossSwitchRow.value = false
                        flossSwitchRow.updateCell()
                        let amSwitchRow: SwitchRow! = self.form.rowByTag("AM or PM?")
                        amSwitchRow.title = "AM or PM?"
                        amSwitchRow.value = false
                        amSwitchRow.updateCell()
                        brushDateRow.title = "Enter Date of Brushing"
                        brushDateRow.value = NSDate()
                        brushDateRow.updateCell()
                        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            eurekaImageView.alpha = 0.05
                            }, completion: nil)
                        self.title = "Entering Brushing"
                        PFUser.query()?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error == nil || object != nil {
                                UIView.animateWithDuration(0.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    eurekaImageView.image = UIImage(named: "Tooth")!
                                    }, completion: nil)
                                (object as! PFUser).addBrushTime(timeRow.value!)
                                timeRow.title = "Enter Brush Time"
                                timeRow.options = []
                                timeRow.value = 0.0
                                for i in 0..<151 {
                                    timeRow.options.append(CGFloat(i))
                                }
                                timeRow.displayValueFor = { (rowValue: CGFloat?) in
                                    return rowValue?.toMinSecLong()
                                }
                                timeRow.updateCell()
                                smile.saveInBackground()
                            }
                        })
                    })
            }
        } else {
            
            buildFontBold = UIFont(name: "AmericanTypewriter-Bold", size: 20)!
            buildFont = UIFont(name: "AmericanTypewriter", size: 15)!
            buildFontSmall = UIFont(name: "AmericanTypewriter", size: 11)!
            self.view.frame = CGRect(x: 0, y: 44, width: 320, height: 475)
            form =
                Section() {
                    $0.header = HeaderFooterView<EurekaBrushView>(HeaderFooterProvider.Class)
                }
                <<< PickerInlineRow<CGFloat>("Enter Brush Time") { (row : PickerInlineRow<CGFloat>) -> Void in
                    row.title = "Enter Brush Time"
                    row.options = []
                    row.value = 0.0
                    for i in 0..<151 {
                        row.options.append(CGFloat(i))
                    }
                    row.displayValueFor = { (rowValue: CGFloat?) in
                        return rowValue?.toMinSecLong()
                    }
                    row.onChange({ (picker) in
                        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: screenBounds.width, dy: 0)
                            }, completion: { _ in
                                switch Int(picker.value!) {
                                case 0:
                                    eurekaImageView.image = UIImage(named: "Tooth")!
                                    self.title = "Enter Brush Time"
                                case 1...45:
                                    eurekaImageView.image = AppConfiguration.ToothBadge1
                                    self.title = "Cavity Maker"
                                case 46...75:
                                    eurekaImageView.image = AppConfiguration.ToothBadge2
                                    self.title = "Sugar Bug"
                                case 76...105:
                                    eurekaImageView.image = AppConfiguration.ToothBadge3
                                    self.title = "Tooth Protector!"
                                default:
                                    eurekaImageView.image = AppConfiguration.ToothBadge4
                                    self.title = "Tooth Hero!"
                                }
                                eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: -2 * screenBounds.width, dy: 0)
                                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    eurekaImageView.frame = eurekaImageView.frame.offsetBy(dx: screenBounds.width, dy: 0)
                                    }, completion: nil)
                        })
                    })
                    row.cellSetup({ (cell, row) in
                        cell.detailTextLabel?.font = self.buildFontSmall
                        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                }
                <<< DateInlineRow("Enter Date of Brushing"){
                    $0.title = $0.tag
                    $0.value = NSDate()
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
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                    })
                
                <<< SwitchRow("AM or PM?"){ row in      // initializer
                    row.title = "AM or PM?"
                    }.onChange { row in
                        row.title = (row.value ?? false) ? "AM" : "PM"
                        self.AMBrush = row.value!
                        row.updateCell()
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                }
                <<< SwitchRow("Did you remember to Floss?"){ row in      // initializer
                    row.title = "Did you remember to Floss?"
                    }.onChange { row in
                        row.title = (row.value ?? false) ? "Great Job Flossing!" : "Don't forget to Floss!"
                        self.Flossed = row.value!
                        row.updateCell()
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = self.buildFont
                        cell.textLabel?.adjustsFontSizeToFitWidth = true
                }
                +++ ButtonRow(){ row in
                    row.title = "Save Brush Entry"
                    row.cellSetup({ (cell, row) in
                        cell.height = { return 60 }
                        cell.contentView.backgroundColor = AppConfiguration.navColor
                        cell.tintColor = .whiteColor()
                        cell.textLabel?.font = self.buildFontBold
                        cell.textLabel?.tintColor = .whiteColor()
                        cell.textLabel?.textColor = .whiteColor()
                    })
                    row.onCellSelection({ (cell, row) in
                        let brushDateRow: DateInlineRow! = self.form.rowByTag("Enter Date of Brushing")
                        let timeRow: PickerInlineRow<CGFloat>! = self.form.rowByTag("Enter Brush Time")
                        let smile: PFObject = PFObject(className: "SmilesClub")
                        smile["User"] = PFUser.currentUser()!
                        smile["userPic"] = PFUser.currentUser()!.getProfPic()
                        smile["Name"] = PFUser.currentUser()!.Fullname()
                        smile["Age"] = "AGE: \(PFUser.currentUser()!.getAge())"
                        smile["brushTime"] = timeRow.value!
                        smile["Flosser"] = self.Flossed
                        let formatter:NSDateFormatter = NSDateFormatter()
                        formatter.dateFormat = "a"
                        if self.AMBrush == false {
                            let dater: NSDate = brushDateRow.value!.change(nil, month: nil, day: nil, hour: 6, minute: nil, second: nil)
                            smile["brushDate"] = dater
                            smile["AMPM"] = formatter.stringFromDate(dater)
                        } else {
                            let dater: NSDate = brushDateRow.value!.change(nil, month: nil, day: nil, hour: 18, minute: nil, second: nil)
                            smile["brushDate"] = dater
                            smile["AMPM"] = formatter.stringFromDate(dater)
                        }
                        let flossSwitchRow: SwitchRow! = self.form.rowByTag("Did you remember to Floss?")
                        flossSwitchRow.title = "Did you remember to Floss?"
                        flossSwitchRow.value = false
                        flossSwitchRow.updateCell()
                        let amSwitchRow: SwitchRow! = self.form.rowByTag("AM or PM?")
                        amSwitchRow.title = "AM or PM?"
                        amSwitchRow.value = false
                        amSwitchRow.updateCell()
                        brushDateRow.title = "Enter Date of Brushing"
                        brushDateRow.value = NSDate()
                        brushDateRow.updateCell()
                        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            eurekaImageView.alpha = 0.05
                            }, completion: nil)
                        self.title = "Entering Brushing"
                        PFUser.query()?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error == nil || object != nil {
                                UIView.animateWithDuration(0.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    eurekaImageView.image = UIImage(named: "Tooth")!
                                    }, completion: nil)
                                (object as! PFUser).addBrushTime(timeRow.value!)
                                timeRow.title = "Enter Brush Time"
                                timeRow.options = []
                                timeRow.value = 0.0
                                for i in 0..<151 {
                                    timeRow.options.append(CGFloat(i))
                                }
                                timeRow.displayValueFor = { (rowValue: CGFloat?) in
                                    return rowValue?.toMinSecLong()
                                }
                                timeRow.updateCell()
                                smile.saveInBackground()
                            }
                        })
                    })
            }

        }
        title = "Enter Brushing"
        removeBack()
        addHamMenu()
    }
}

public var eurekaImageView = UIImageView(image: UIImage(named: "Tooth"))

class EurekaBrushView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: 150)
        self.frame = frame
        eurekaImageView.frame = CGRect(x: frame.midX - 60, y: frame.midY - 60, width: 120, height: 120)
        eurekaImageView.autoresizingMask = .FlexibleWidth
        eurekaImageView.contentMode = .ScaleAspectFit
        self.backgroundColor = AppConfiguration.navColor
        self.addSubview(eurekaImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


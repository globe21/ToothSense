//
//  BrushAlong.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/28/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation


extension PFImageView {
    func setProfPic(color: UIColor?) {
        self.image = UIImage(named: "ProfileIcon")
        if  PFUser.currentUser() != nil {
            let userQuery = PFUser.query()
            userQuery?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) in
                if error == nil {
                    if  PFUser.currentUser()!["profPic"] != nil {
                        self.file = PFUser.currentUser()!["profPic"] as? PFFile
                        self.loadInBackground()
                    }
                }
            })
        }
        self.layer.cornerRadius = (self.frame.height) / 2
        if color != nil {
            self.layer.borderColor = color!.CGColor
        } else {
            self.layer.borderColor = UIColor.wheatColor().CGColor
        }
        self.layer.borderWidth = 4.0
    }
    
    func setProfPicOfUser(user: PFUser, color: UIColor?) {
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(user.objectId!, block: { (object, error) in
            if error == nil {
                let user = object as! PFUser
                if  user["thumbnail"] != nil {
                    self.file = user["thumbnail"] as? PFFile
                    self.loadInBackground()
                } else {
                    self.image = UIImage(named: "ProfileIcon")
                }
            }
        })
        self.layer.cornerRadius = (self.frame.height) / 2
        if color != nil {
            self.tintColor = color!
            self.layer.borderColor = color!.CGColor
        } else {
            self.tintColor = AppConfiguration.navText
            self.layer.borderColor = AppConfiguration.navText.CGColor
        }
        self.layer.borderWidth = 4.0
        self.contentMode = .ScaleAspectFill
        self.backgroundColor = UIColor.clearColor()
        self.layer.masksToBounds = true
    }
}

extension PFUser {
    func getProfPic() -> PFFile {
        if  self["profPic"] != nil {
            return (self["profPic"] as? PFFile)!
        } else {
            return PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(UIImage(named: "ProfileIcon")!, 0.6)!)!
        }
    }
    
    func getBirthday() -> NSDate {
        if self["Birthday"] != nil {
            return (self["Birthday"] as? NSDate)!
        }
        return NSDate()
    }
    
    func getAge() -> Int {
        if self["Birthday"] != nil {
            let birthday: NSDate = (self["Birthday"] as? NSDate)!
            let ageComponents: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: birthday, toDate: NSDate(), options: NSCalendarOptions(rawValue: UInt(0)))
            return ageComponents.year
        }
        return 0
    }
    
    func settingUpCellCollection(cell: SmilesCollectionViewCell, objectPassed: PFObject) {
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(self.objectId!, block: { (object, error) in
            if error == nil {
                let user = object as! PFUser
                if  user["thumbnail"] != nil {
                    cell.CellImage.file = user["thumbnail"] as? PFFile
                    cell.CellImage.loadInBackground()
                } else {
                    cell.CellImage.image = UIImage(named: "ProfileIcon")
                }
                if user["fullname"] != nil {
                    cell.userLabel.attributedText = NSMutableAttributedString(string: user["fullname"] as! String, attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
                } else {
                    cell.userLabel.attributedText = NSMutableAttributedString(string: "No Name", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
                }
                cell.AgeLabel.attributedText = NSMutableAttributedString(string: "AGE: \(user.getAge())", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 27.0)!])
            } else {
                if objectPassed["Name"] != nil {
                    cell.userLabel.attributedText = NSMutableAttributedString(string: objectPassed["Name"] as! String, attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
                }
                if objectPassed["Age"] != nil {
                    cell.AgeLabel.hidden = false
                    cell.AgeLabel.attributedText = NSMutableAttributedString(string: objectPassed["Age"] as! String, attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 27.0)!])
                } else {
                    cell.AgeLabel.hidden = true
                }
            }
        })
        cell.CellImage.layer.cornerRadius = (cell.CellImage.frame.height) / 2
        cell.CellImage.tintColor = AppConfiguration.navText
        cell.CellImage.layer.borderColor = AppConfiguration.navText.CGColor
        cell.CellImage.layer.borderWidth = 4.0
        cell.CellImage.contentMode = .ScaleAspectFill
        cell.CellImage.backgroundColor = UIColor.clearColor()
        cell.CellImage.layer.masksToBounds = true
        
        
    }
    
    func settingUpCell(cell: FollowCell) {
        cell.FollowerPic.frame = CGRect(x: -5, y: 5, width: 70, height: 70)
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(self.objectId!, block: { (object, error) in
            if error == nil {
                let user = object as! PFUser
                if  user["thumbnail"] != nil {
                    cell.FollowerPic.file = user["thumbnail"] as? PFFile
                    cell.contentView.bringSubviewToFront(cell.FollowerPic)
                    cell.FollowerPic.alpha = 1.0
                    cell.FollowerPic.hidden = false
                    cell.FollowerPic.loadInBackground()
                } else {
                    cell.FollowerPic.image = UIImage(named: "ProfileIcon")
                }
                if user["fullname"] != nil {
                    cell.FollowerName.text = user["fullname"] as? String
                }
            }
            
            let followquery = PFQuery(className: "Follower")
            followquery.whereKey("Follower", equalTo: PFUser.currentUser()!)
            followquery.whereKey("Following", equalTo: self)
            followquery.getFirstObjectInBackgroundWithBlock({ (object: PFObject?, error: NSError?) in
                if error == nil {
                    if (object!["Active"] as! Bool) != false {
                        cell.FollowButton.tintColor = UIColor(hex: "d9272d")
                        cell.FollowButton.selected = true
                    } else {
                        cell.FollowButton.tintColor = UIColor.whiteColor()
                        cell.FollowButton.selected = false
                    }
                } else {
                    cell.FollowButton.tintColor = UIColor.whiteColor()
                    cell.FollowButton.selected = false
                }
            })
        })
        
        
        //cell.FollowerPic.layer.cornerRadius = (cell.FollowerPic.frame.height) / 2
        cell.FollowerPic.tintColor = AppConfiguration.navText
        cell.FollowerPic.layer.borderColor = AppConfiguration.navText.CGColor
        cell.FollowerPic.layer.borderWidth = 2.0
        cell.FollowerPic.contentMode = .ScaleAspectFill
        cell.FollowerPic.backgroundColor = UIColor.clearColor()
        cell.FollowerPic.layer.masksToBounds = true
        if cell.FollowButton.selected == true {
            cell.FollowButton.tintColor = UIColor(hex: "d9272d")
        } else {
            cell.FollowButton.tintColor = UIColor.whiteColor()
        }
    }
    
    func Fullname() -> String  {
        if self["fullname"] != nil {
            return self["fullname"] as! String
        } else {
            return ""
        }
    }
    
    
    func addBrushTime(secs: CGFloat) {
        var times: Int!
        if self["TimesBrushed"] != nil {
            times = self["TimesBrushed"] as? Int!
            if times == 0 {
                self["AverageBrushTime"] = secs
                self["TimesBrushed"] = 1
            } else {
                if self["AverageBrushTime"] != nil {
                    let avgTime: Int! = self["AverageBrushTime"] as! Int!
                    let avg: Int! = avgTime * times
                    let newCount = (times + 1)
                    self["AverageBrushTime"] = ((avg + Int(secs)) / newCount)
                    self["TimesBrushed"] = newCount
                } else {
                    self["AverageBrushTime"] = secs
                    self["TimesBrushed"] = 1
                }
            }
        } else {
            self["AverageBrushTime"] = secs
            self["TimesBrushed"] = 1
        }
        self.saveInBackgroundWithBlock { (success, error) in
            defaults.setBool(true, forKey: "SugarBugStatus")
            dispatch_async(dispatch_get_main_queue(), {
                sideMenuNavigationController2!.tr_popToRootViewController()
            })
            tabController!.setSelectIndex(1, to: 0)
        }
    }

    
}

class Brush: UIViewController, UINavigationControllerDelegate, NavgationTransitionable {
    
    
    @IBOutlet var BrushTabAnimation: RAMFumeAnimation!
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    
    let path: String = NSBundle.mainBundle().pathForResource("BrushYourTeeth", ofType:"mp4")!//("TimerFinal", ofType:"mov")!
    let path2: String = NSBundle.mainBundle().pathForResource("BrushYourTeeth", ofType:"mp4")!
    
    var playerController: AVPlayerViewController = AVPlayerViewController()
    
    var playerController2: AVPlayerViewController = AVPlayerViewController()
    
    var player:AVPlayer?
    var player2:AVPlayer?
    var playerObserver:Bool = false
    var playerObserver2:Bool = false
    
    
    var playerItem:AVPlayerItem?
    var playerItem2:AVPlayerItem?
    
    var playing: AVPlayer?
    
    var ShareButton: UIButton = UIButton(type: UIButtonType.Custom)
    
    var timer: Float64?
    
    var Floss: Bool!
    var shared = false
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.shared == true {
            startShare()
        }
        if playing != nil {
            playing!.pause()
        }
        if playerItem != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
        }
        if playerItem2 != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem2)
        }
        if playerObserver {
            player?.removeObserver(self, forKeyPath: "rate")
        }
        if playerObserver2 {
            player2?.removeObserver(self, forKeyPath: "rate")
        }
        playerObserver = false
        playerObserver2 = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "rate" {
            if let rate = change?[NSKeyValueChangeNewKey] as? Float {
                if rate == 1.0 {
                    self.shared = true
                    if (object as! AVPlayer) == self.player {
                        if player2!.rate != 0.0 {
                            player2!.pause()
                            player2!.seekToTime(kCMTimeZero)
                        }
                        playing = self.player
                    } else if (object as! AVPlayer) == self.player2 {
                        if player!.rate != 0.0 {
                            player!.pause()
                            player!.seekToTime(kCMTimeZero)
                        }
                        playing = self.player2
                    }
                }
            }
        }
    }
    
    func createVideo(playerController: AVPlayerViewController, url: NSURL) {
        
        if playerController == self.playerController {
            self.playerItem = AVPlayerItem.init(URL: url)
            self.player = AVPlayer(playerItem: self.playerItem)
            self.player!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
            self.playerObserver = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.itemDidFinishPlaying), name:AVPlayerItemDidPlayToEndTimeNotification, object:self.playerItem)
            playerController.player = self.player
        } else {
            self.playerItem2 = AVPlayerItem.init(URL: url)
            self.player2 = AVPlayer(playerItem: self.playerItem2)
            self.player2!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
            self.playerObserver2 = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.itemDidFinishPlaying), name:AVPlayerItemDidPlayToEndTimeNotification, object:self.playerItem2)
            playerController.player = player2
        }
        
        self.addChildViewController(playerController)
        playerController.view.backgroundColor = AppConfiguration.backgroundColor
        playerController.view.layer.backgroundColor = AppConfiguration.backgroundColor.CGColor
        if playerController == self.playerController {
            playerController.view.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.width * (9/16))
        } else {
            playerController.view.frame = CGRect(x: 0, y: self.playerController.view.frame.maxY + 15, width: self.view.frame.width, height: self.view.frame.width * (9/16))
        }
        playerController.showsPlaybackControls = true
        self.view.addSubview(playerController.view)
    }

    override func viewWillAppear(animated: Bool) {
        addHamMenu()
        playerObserver = false
        playerObserver2 = false
        let url = NSURL.fileURLWithPath(path)
        self.createVideo(self.playerController, url: url)
        let url2 = NSURL.fileURLWithPath(path2)
        self.createVideo(self.playerController2, url: url2)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if playerController.player != nil {
            if playerController.player!.currentTime() != kCMTimeZero {
                playerController.player!.seekToTime(kCMTimeZero)
            }
        }
        if playerController2.player != nil {
            if playerController2.player!.currentTime() != kCMTimeZero {
                //CMTimeGetSeconds(playerController2.player!.currentTime()) != 0 {
                playerController2.player!.seekToTime(kCMTimeZero)
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateOrientationAnimated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        constrain(ShareButton, tabController!.tabBar) { (view1, view2) in
            view1.width == view1.superview!.width * 0.95
            view1.height == 80
            view1.bottom == view2.top - 10
            view1.centerX == view2.centerX
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppConfiguration.backgroundColor
        
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            self.view.frame = CGRect(x: 0, y: 44, width: 414, height: 643)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            self.view.frame = CGRect(x: 0, y: 44, width: 375, height: 574)
        } else {
            self.view.frame = CGRect(x: 0, y: 44, width: 320, height: 475)
        }
        self.navigationItem.title = "Brush Along"
        //view.addBlur(AppConfiguration.backgroundColor)
        
        ShareButton.setAttributedTitle(NSAttributedString(string: "Share", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 35)!] as [String : AnyObject]), forState: .Normal)
        ShareButton.frame = CGRect(x: 5, y: self.playerController2.view.frame.maxY + 5, width: self.view.frame.width - 10, height: 40)
        ShareButton.backgroundColor = UIColor.clearColor()//(white: 1.0, alpha: 0.7)
        ShareButton.layer.cornerRadius = 10
        ShareButton.layer.borderWidth = 3
        ShareButton.addblur(AppConfiguration.navText)
        ShareButton.layer.borderColor = AppConfiguration.navText.CGColor
        ShareButton.addTarget(self, action: #selector(self.sharePressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(ShareButton)
        let menuButton: UIBarButtonItem = UIBarButtonItem(image: AppConfiguration.addTooth, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedManual))
        menuButton.tintColor = AppConfiguration.navText
        self.navigationItem.setLeftBarButtonItem(menuButton, animated: false)
    }
    
    func tappedManual() {
        switch tabController!.selectedIndex {
        case 0:
            if sideMenuNavigationController!.viewControllers.contains(EnterManual) {
                sideMenuNavigationController!.tr_popToViewController(EnterManual)
            } else {
                sideMenuNavigationController!.tr_pushViewController(EnterManual, method: TRPushTransitionMethod.Fade)
            }
        case 1:
            if sideMenuNavigationController2!.viewControllers.contains(EnterManual) {
                sideMenuNavigationController2!.tr_popToViewController(EnterManual)
            } else {
                sideMenuNavigationController2!.tr_pushViewController(EnterManual, method: TRPushTransitionMethod.Fade)
            }
        case 2:
            if sideMenuNavigationController3!.viewControllers.contains(EnterManual) {
                sideMenuNavigationController3!.tr_popToViewController(EnterManual)
            } else {
                sideMenuNavigationController3!.tr_pushViewController(EnterManual, method: TRPushTransitionMethod.Fade)
            }
        default:
            break
        }
    }
    
    
    func saveSmile(time: CGFloat, floss: Bool) {
        let current = NSDate()
        let smile: PFObject = PFObject(className: "SmilesClub")
        smile["User"] = PFUser.currentUser()
        smile["userPic"] = PFUser.currentUser()!.getProfPic()
        smile["Name"] = PFUser.currentUser()!.Fullname()
        smile["Age"] = "AGE: \(PFUser.currentUser()!.getAge())"
        smile["brushTime"] = time
        smile["Flosser"] = floss
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "a"
        smile["brushDate"] = current
        smile["AMPM"] = formatter.stringFromDate(current)
        smile.saveInBackgroundWithBlock({ success, error in
            tabController!.setSelectIndex(1, to: 0)
        })
    }
    
    func startShare() {
        self.shared = false
        if playing != nil {
            playing!.pause()
            timer = CMTimeGetSeconds(playing!.currentTime())
            var shareImage : UIImage!
            switch CGFloat(timer!) {
            case 0:
                shareImage = UIImage(named: "Tooth")!
            case 1...45:
                shareImage = AppConfiguration.ToothBadge1
            case 46...75:
                shareImage = AppConfiguration.ToothBadge2
            case 76...105:
                shareImage = AppConfiguration.ToothBadge3
            default:
                shareImage = AppConfiguration.ToothBadge4
            }
            if timer != 0 {
                let secs: CGFloat = CGFloat(timer!)
                let popup: PopupDialog = PopupDialog(title: "BRUSHED FOR: \(secs.toMinSec())", message: "WOULD YOU LIKE TO SHARE?", image: shareImage)
                let buttonCancel = CancelButton(title: "CANCEL") {
                }
                let buttonTwo = DefaultButton(title: "SHARE") {
                    let popup: PopupDialog = PopupDialog(title: "DID YOU FLOSS?", message: nil, image: UIImage(named: "flossicon")!)
                    let buttonCancel = CancelButton(title: "NO") {
                        let query = PFUser.query()
                        query?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error == nil || object != nil {
                                (object! as! PFUser).addBrushTime(secs)
                                self.saveSmile(secs, floss: false)
                            }
                        })
                    }
                    let buttonTwo = DefaultButton(title: "YES") {
                        let query = PFUser.query()
                        query?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error == nil || object != nil {
                                (object! as! PFUser).addBrushTime(secs)
                                self.saveSmile(secs, floss: true)
                            }
                        })
                    }
                    popup.transitionStyle = .BounceUp
                    popup.addButtons([buttonTwo,buttonCancel])
                    self.presentViewController(popup, animated: true, completion: nil)
                }
                popup.transitionStyle = .BounceUp
                popup.addButtons([buttonTwo,buttonCancel])
                self.presentViewController(popup, animated: true, completion: nil)
            }
        }
    }
    
    func updateOrientationAnimated(animated: Bool) {
        if (UIDevice.currentDevice().orientation == previousOrientation) {
            return
        }
        //let heightCheck = self.view.frame.height - (sideMenuNavigationController!.navigationBar.frame.height + tabController!.tabBar.frame.height + 50)
        if playerController.player!.currentTime() != kCMTimeZero {
            
            switch (UIDevice.currentDevice().orientation) {
            case UIDeviceOrientation.LandscapeRight:
                sideMenuNavigationController!.setNavigationBarHidden(true, animated: true)
                self.navigationController!.setNavigationBarHidden(true, animated: true)
                tabController!.setTabBarVisible(false, animated: true)
                UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.playerController.view.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                    self.playerController.view.frame = screenBounds
                    self.playerController2.view.hidden = true
                    self.ShareButton.hidden = true
                    }, completion: nil)
            case UIDeviceOrientation.LandscapeLeft:
                sideMenuNavigationController!.setNavigationBarHidden(true, animated: true)
                self.navigationController!.setNavigationBarHidden(true, animated: true)
                self.setNeedsStatusBarAppearanceUpdate()
                tabController!.setTabBarVisible(false, animated: true)
                UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.playerController.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                    self.playerController.view.frame = screenBounds
                    self.playerController2.view.hidden = true
                    self.ShareButton.hidden = true
                    }, completion: nil)
            case UIDeviceOrientation.FaceDown: return
            case UIDeviceOrientation.FaceUp: return
            case UIDeviceOrientation.Unknown: return
            default:
                sideMenuNavigationController!.setNavigationBarHidden(false, animated: true)
                self.navigationController!.setNavigationBarHidden(false, animated: true)
                tabController!.setTabBarVisible(true, animated: true)
                UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.playerController.view.transform = CGAffineTransformIdentity
                    self.playerController.view.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.width * (9/16))
                    self.playerController2.view.hidden = false
                    self.ShareButton.hidden = false
                    }, completion: nil)
            }
        } else if playerController2.player!.currentTime() != kCMTimeZero {
            
            switch (UIDevice.currentDevice().orientation) {
            case UIDeviceOrientation.LandscapeRight:
                sideMenuNavigationController!.setNavigationBarHidden(true, animated: true)
                self.navigationController!.setNavigationBarHidden(true, animated: true)
                tabController!.setTabBarVisible(false, animated: true)
                UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.playerController2.view.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                    self.playerController2.view.frame = screenBounds
                    self.playerController.view.hidden = true
                    self.ShareButton.hidden = true
                    }, completion: nil)
            case UIDeviceOrientation.LandscapeLeft:
                sideMenuNavigationController!.setNavigationBarHidden(true, animated: true)
                self.navigationController!.setNavigationBarHidden(true, animated: true)
                self.setNeedsStatusBarAppearanceUpdate()
                tabController!.setTabBarVisible(false, animated: true)
                UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.playerController2.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                    self.playerController2.view.frame = screenBounds
                    self.playerController.view.hidden = true
                    self.ShareButton.hidden = true
                    }, completion: nil)
            case UIDeviceOrientation.FaceDown: return
            case UIDeviceOrientation.FaceUp: return
            case UIDeviceOrientation.Unknown: return
            default:
                sideMenuNavigationController!.setNavigationBarHidden(false, animated: true)
                self.navigationController!.setNavigationBarHidden(false, animated: true)
                tabController!.setTabBarVisible(true, animated: true)
                UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.playerController2.view.transform = CGAffineTransformIdentity
                    self.playerController.view.hidden = false
                    self.playerController2.view.frame = CGRect(x: 0, y: self.playerController.view.frame.maxY + 15, width: self.view.frame.width, height: self.view.frame.width * (9/16))
                    self.ShareButton.hidden = false
                    }, completion: nil)
            }
        }
        previousOrientation = UIDevice.currentDevice().orientation
      
    }

    func itemDidFinishPlaying(notification: NSNotification) {
        startShare()
    }
    
    
    func sharePressed(sender: UIButton) {
        startShare()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

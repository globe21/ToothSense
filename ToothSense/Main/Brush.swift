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
import Parse
import ParseUI

extension UIImage {
    func imageMaskedWithColor(maskColor: UIColor) -> UIImage {
        let imageRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height)
        var newImage: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, self.scale)
        do {
            let context = UIGraphicsGetCurrentContext()
            CGContextScaleCTM(context!, 1.0, -1.0)
            CGContextTranslateCTM(context!, 0.0, -(imageRect.size.height))
            CGContextClipToMask(context!, imageRect, self.CGImage!)
            CGContextSetFillColorWithColor(context!, maskColor.CGColor)
            CGContextFillRect(context!, imageRect)
            newImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension PFImageView {
    
    func setProfPic(color: UIColor?) {
        self.image = UIImage(named: "ProfileIcon")
        if  PFUser.currentUser() != nil {
            self.file = PFUser.currentUser()!.profPic
            self.loadInBackground()
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
        self.file = user.profPic
        self.loadInBackground()
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
    
    func settingUpCell(cell: FollowCell) {
        cell.FollowerPic.frame = CGRect(x: -5, y: 5, width: 70, height: 70)
        do {
            try self.fetchIfNeeded()
            let user = self
            if  user["thumbnail"] != nil {
                cell.FollowerPic.file = user["thumbnail"] as? PFFile
                cell.contentView.bringSubviewToFront(cell.FollowerPic)
                cell.FollowerPic.alpha = 1.0
                cell.FollowerPic.hidden = false
                cell.FollowerPic.loadInBackground()
            } else {
                cell.FollowerPic.image = UIImage(named: "ProfileIcon")!.imageMaskedWithColor(UIColor.whiteColor())
            }
            if user["fullname"] != nil {
                cell.FollowerName.text = user["fullname"] as? String
            }
            /*if PFUser.currentUser()!["Friends"] != nil {
                var friends: [PFUser] = PFUser.currentUser()!["Friends"] as! [PFUser]
                var friendIDs: [String] = [String]()
                friends.forEach({ (user) in
                    friendIDs.append(user.objectId!)
                })
                if !friendIDs.contains(user.objectId!) {
                    friends.append(user)
                    PFUser.currentUser()!["Friends"] = friends
                    PFUser.currentUser()!.saveInBackground()
                }
            }*/
        } catch {
            
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
    
    var profPic : PFFile {
        get {
            do {
                try self.fetchIfNeeded()
                if  self["profPic"] != nil {
                    return (self["profPic"] as? PFFile)!
                } else {
                    return PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(UIImage(named: "ProfileIcon")!.imageMaskedWithColor(UIColor.whiteColor()), 0.6)!)!
                }
            } catch {
                return PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(UIImage(named: "ProfileIcon")!.imageMaskedWithColor(UIColor.whiteColor()), 0.6)!)!
            }
        }
    }
    
    var birthday : NSDate {
        get {
            do {
                try self.fetchIfNeeded()
                if self["Birthday"] != nil {
                    return (self["Birthday"] as? NSDate)!
                }
                return NSDate()
            } catch {
                return NSDate()
            }
        }
    }
    
    var age : Int {
        get {
            do {
                try self.fetchIfNeeded()
                if self["Birthday"] != nil {
                    let birthday: NSDate = (self["Birthday"] as? NSDate)!
                    let ageComponents: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: birthday, toDate: NSDate(), options: NSCalendarOptions(rawValue: UInt(0)))
                    return ageComponents.year
                }
                return 0
            } catch {
                return 0
            }
        }
    }

    
    var fullname: String {
        get {
            do {
                try self.fetchIfNeeded()
                if self["fullname"] != nil {
                    return self["fullname"] as! String
                } else {
                    return "No Name"
                }
            } catch {
                return "No Name"
            }
        }
    }
    
    var BlockedUsers : [PFUser]  {
        get {
            do {
                try self.fetchIfNeeded()
                if self["BlockedPeople"] != nil {
                    return self["BlockedPeople"] as! [PFUser]
                } else {
                    return []
                }
            } catch {
                return []
            }
        }
    }
    
    var Friends : [PFUser]  {
        get {
            do {
                try self.fetchIfNeeded()
                if self["Friends"] != nil {
                    return self["Friends"] as! [PFUser]
                } else {
                    return []
                }
            } catch {
                return []
            }
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
                sideMenuNavigationController!.tr_popToRootViewController()
            })
            tabController!.setSelectIndex(1, to: 0)
        }
    }

    
}

class Brush: UIViewController, UINavigationControllerDelegate, NavgationTransitionable {
    
    
    @IBOutlet var BrushTabAnimation: RAMFumeAnimation!
    
    var tr_pushTransition: TRNavgationTransitionDelegate?    
    
    let path: String = NSBundle.mainBundle().pathForResource("BrushYourTeeth", ofType:"mp4")!
    
    var playerController: AVPlayerViewController = AVPlayerViewController()
    
    var player:AVPlayer?
    
    var playerItem:AVPlayerItem?
    
    var ShareButton: UIButton = UIButton(type: UIButtonType.Custom)
    
    var timer: Float64?
    
    var Floss: Bool!
    
    var shared: Bool = false
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        if shared == false {
            if CMTimeGetSeconds(player!.currentTime()) != 0 {
                startShare()
            }
        }
        if player != nil {
            player!.pause()
        }
        if playerItem != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
        }
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        addHamMenu()
        let url = NSURL.fileURLWithPath(path)
        self.playerItem = AVPlayerItem.init(URL: url)
        self.player = AVPlayer(playerItem: self.playerItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.itemDidFinishPlaying), name:AVPlayerItemDidPlayToEndTimeNotification, object:self.playerItem)
        self.playerController.player = self.player
        self.addChildViewController(playerController)
        self.playerController.view.backgroundColor = AppConfiguration.backgroundColor
        self.playerController.view.layer.backgroundColor = AppConfiguration.backgroundColor.CGColor
        let playerHeight: CGFloat = (self.view.frame.width - 10) * (9/16)
        self.playerController.view.frame = CGRect(x: 5, y: self.view.frame.midY - (playerHeight/2) - 70, width: self.view.frame.width - 10, height: playerHeight)
        self.playerController.showsPlaybackControls = true
        self.view.addSubview(playerController.view)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sideMenuNavigationController = self.navigationController!
        if playerController.player != nil {
            if playerController.player!.currentTime() != kCMTimeZero {
                playerController.player!.seekToTime(kCMTimeZero)
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateOrientationAnimated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppConfiguration.backgroundColor
        self.navigationItem.title = "Brush Along"
        ShareButton.setAttributedTitle(NSAttributedString(string: "Share", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 35)!] as [String : AnyObject]), forState: .Normal)
        ShareButton.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        ShareButton.layer.cornerRadius = 10
        ShareButton.layer.borderWidth = 3
        ShareButton.addblur(AppConfiguration.navText)
        ShareButton.layer.borderColor = AppConfiguration.navText.CGColor
        ShareButton.frame = CGRect(x: 5, y: self.view.frame.maxY - 163, width: self.view.frame.width - 10, height: 60)
        ShareButton.addTarget(self, action: #selector(self.sharePressed(_:)), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(ShareButton)
        let menuButton: UIBarButtonItem = UIBarButtonItem(image: AppConfiguration.addTooth, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedManual))
        menuButton.tintColor = AppConfiguration.navText
        self.navigationItem.setLeftBarButtonItem(menuButton, animated: false)
    }
    
    func tappedManual() {
        if player != nil {
            if player!.currentTime() != kCMTimeZero {
                player!.seekToTime(kCMTimeZero)
            }
        }
        sideMenuNavigationController!.tr_pushViewController(EnterManual, method: TRPushTransitionMethod.Fade)
    }
    
    func saveSmile(floss: Bool) {
        let current = NSDate()
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "a"
        let AMPMQuery = PFQuery(className: "SmilesClub")
        AMPMQuery.whereKey("User", equalTo: PFUser.currentUser()!)
        AMPMQuery.whereKey("AMPM", equalTo: formatter.stringFromDate(current))
        AMPMQuery.whereKey("brushDate", greaterThanOrEqualTo: current.beginningOfDay)
        AMPMQuery.whereKey("brushDate", lessThanOrEqualTo: current.endOfDay)
        AMPMQuery.cachePolicy = .NetworkElseCache
        AMPMQuery.maxCacheAge = 60*60
        AMPMQuery.getFirstObjectInBackgroundWithBlock({ (object, error) in
            if error == nil {
                object!["brushTime"] = CMTimeGetSeconds(self.player!.currentTime())
                object!.saveInBackgroundWithBlock({ success, error in
                    tabController!.setSelectIndex(1, to: 0)
                })
            } else {
                let smile: PFObject = PFObject(className: "SmilesClub")
                smile["User"] = PFUser.currentUser()
                smile["userPic"] = PFUser.currentUser()!.profPic
                smile["Name"] = PFUser.currentUser()!.fullname
                smile["Age"] = "AGE: \(PFUser.currentUser()!.age)"
                smile["brushTime"] = CMTimeGetSeconds(self.player!.currentTime())
                smile["Flosser"] = floss
                smile["brushDate"] = current
                smile["AMPM"] = formatter.stringFromDate(current)
                smile.saveInBackgroundWithBlock({ success, error in
                    tabController!.setSelectIndex(1, to: 0)
                })
            }
        })
        
    }
    
    func startShare() {
        shared = true
        player!.pause()
        timer = CMTimeGetSeconds(player!.currentTime())
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
            let buttonCancel = CancelButton(title: "CANCEL") { self.shared = false }
            let buttonTwo = DefaultButton(title: "SHARE") {
                let popup: PopupDialog = PopupDialog(title: "DID YOU FLOSS?", message: nil, image: UIImage(named: "flossicon")!)
                let buttonCancel = CancelButton(title: "NO") {
                    let query = PFUser.query()
                    query?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error == nil || object != nil {
                            (object! as! PFUser).addBrushTime(secs)
                            self.saveSmile(false)
                        }
                    })
                }
                let buttonTwo = DefaultButton(title: "YES") {
                    let query = PFUser.query()
                    query?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error == nil || object != nil {
                            (object! as! PFUser).addBrushTime(secs)
                            self.saveSmile(true)
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
    
    func updateOrientationAnimated(animated: Bool) {
        if (UIDevice.currentDevice().orientation == previousOrientation) {
            return
        }
        switch (UIDevice.currentDevice().orientation) {
        case UIDeviceOrientation.LandscapeRight:
            sideMenuNavigationController!.setNavigationBarHidden(true, animated: true)
            self.navigationController!.setNavigationBarHidden(true, animated: true)
            tabController!.setTabBarVisible(false, animated: true)
            UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.playerController.view.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.playerController.view.frame = screenBounds
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
                let playerHeight: CGFloat = (self.view.frame.width - 10) * (9/16)
                self.playerController.view.frame = CGRect(x: 5, y: self.view.frame.midY - (playerHeight/2) - 70, width: self.view.frame.width - 10, height: playerHeight)
                self.ShareButton.hidden = false
                if self.ShareButton.frame != CGRect(x: 5, y: self.view.frame.maxY - 119, width: self.view.frame.width - 10, height: 60) {
                    self.ShareButton.frame = CGRect(x: 5, y: self.view.frame.maxY - 119, width: self.view.frame.width - 10, height: 60)
                }
            }, completion: nil)
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



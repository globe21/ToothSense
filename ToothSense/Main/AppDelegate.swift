///
//  AppDelegate.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/24/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import UIKit
//import Fabric
//import Crashlytics
import UserNotifications
import UserNotificationsUI

let kConstantObj = kConstant()
var sideMenuNavigationController : UINavigationController?
var sideMenuNavigationController2 : UINavigationController?
var sideMenuNavigationController3 : UINavigationController?

var tabController: RAMAnimatedTabBarController?
let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
let screenBounds = UIScreen.mainScreen().bounds
var previousOrientation: UIDeviceOrientation = UIDeviceOrientation.Unknown


let AMNotification = UILocalNotification()
let PMNotification = UILocalNotification()

let defaults = NSUserDefaults.standardUserDefaults()
@available(iOS 10.0, *)
var Notifycenter = UNUserNotificationCenter.currentNotificationCenter()


@available(iOS 10.0, *)
var movieAttachment: UNNotificationAttachment!
@available(iOS 10.0, *)
let content = UNMutableNotificationContent()
@available(iOS 10.0, *)
let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
@available(iOS 10.0, *)
var request: UNNotificationRequest!



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        defaults.setBool(true, forKey: "SugarBugStatus")
        Parse.setApplicationId("RhYIPJ9diSnYaEcFGVoIGlUNU3V9u1Y6R7jn0Ec1", clientKey: "gafsXZByOHv6F5uZ0TfIzwKBPEgygdYz5p6LCti8")
        configureStyling()
        
        if #available(iOS 10.0, *) {
            Notifycenter.requestAuthorizationWithOptions([.Alert, .Sound, .Badge]) { (granted, error) in
                if let error = error {
                    print("error:\(error)")
                } else if !granted {
                    print("not granted")
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        //self.notifyBtn.isEnabled = true
                    })
                }
            }
            Notifycenter.delegate = self
        } else {
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert , .Badge , .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            if let options = launchOptions {
                if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                    if let userInfo = notification.userInfo {
                        let customField1 = userInfo["AMPM"] as! String
                        let customField2 = userInfo["Date"] as! NSDate
                        print("didReceiveLocalNotificationMain: \(customField1)")
                        NSNotificationCenter.defaultCenter().postNotificationName("AMPMAlert", object: nil, userInfo: ["AMPM":customField1, "Date":customField2])
                    }
                }
            }
        }
        //Fabric.with([Crashlytics.self])
        if PFUser.currentUser() != nil {
            let mainVcIntial = kConstantObj.SetIntialMainViewController()
            appDelegate.window?.rootViewController = mainVcIntial
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }

    


}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    private func userNotificationCenter(center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("Tapped in notification")
        let actionIdentifier = response.actionIdentifier
        if actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" || actionIdentifier == "com.apple.UNNotificationDismissActionIdentifier" {
            return;
        }
        let accept = (actionIdentifier == "com.elonchan.yes")
        let decline = (actionIdentifier == "com.elonchan.no")
        let snooze = (actionIdentifier == "com.elonchan.snooze")
        
        repeat {
            if (accept) {
                let title = "Tom is comming now"
                self.addLabel(title, color: UIColor.yellowColor())
                break;
            }
            if (decline) {
                let title = "Tom won't come";
                self.addLabel(title, color: UIColor.redColor())
                break;
            }
            if (snooze) {
                let title = "Tom will snooze for minute"
                self.addLabel(title, color: UIColor.redColor());
                break;
            }
        } while (false);
        // Must be called when finished
        completionHandler()//UNNotificationPresentationOptions.Alert);
    }
    
    private func addLabel(title: String, color: UIColor) {
        let label = UILabel.init()
        label.backgroundColor = UIColor.redColor()
        label.text = title
        label.sizeToFit()
        label.backgroundColor = color
        let centerX = UIScreen.mainScreen().bounds.width * 0.5
        let centerY = CGFloat(arc4random_uniform(UInt32(UIScreen.mainScreen().bounds.height)))
        label.center = CGPoint(x: centerX, y: centerY)
        self.window!.rootViewController!.view.addSubview(label)
    }
    
    @available(iOS 10.0, *)
    private func userNotificationCenter(center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        
        // Must be called when finished, when you do not want foreground show, pass [] to the completionHandler()
        completionHandler(UNNotificationPresentationOptions.Alert)
        // completionHandler( UNNotificationPresentationOptions.sound)
        // completionHandler( UNNotificationPresentationOptions.badge)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        content.title = "iOS-10-Sampler"
        content.body = "This is the body."
        content.sound = UNNotificationSound.defaultSound()
        
        let baseId = "com.shu223.ios10sampler"
        let path: String = NSBundle.mainBundle().pathForResource("timer_6", ofType:"mp4")!
        let url = NSURL.fileURLWithPath(path)
        do {
            movieAttachment = try UNNotificationAttachment(identifier: "\(baseId).attachment", URL: url, options: nil)
            content.attachments = [movieAttachment]
        } catch {
            
        }
        request = UNNotificationRequest(identifier: "\(baseId).notification", content: content, trigger: trigger)
        Notifycenter.addNotificationRequest(request) { (error) in
            if let error = error {
                print("error:\(error)")
            } else {
                let alert = UIAlertController(title: "Close this app", message: "A local notification has been scheduled. Close this app and wait 10 sec.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(okAction)
                switch tabController!.selectedIndex {
                case 0:sideMenuNavigationController!.topViewController!.presentViewController(alert, animated: true, completion: nil)
                case 1:sideMenuNavigationController2!.topViewController!.presentViewController(alert, animated: true, completion: nil)
                case 2:sideMenuNavigationController3!.topViewController!.presentViewController(alert, animated: true, completion: nil)
                default:break
                }
            }
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.Alert, .Sound, .Badge])
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if notification == AMNotification {
            NSNotificationCenter.defaultCenter().postNotificationName("AMAlert", object: nil, userInfo: nil)
        } else if notification == PMNotification {
            NSNotificationCenter.defaultCenter().postNotificationName("PMAlert", object: nil, userInfo: nil)
        }
    }
}

private extension AppDelegate {
    
    func configureStyling() {
        window?.tintColor = AppConfiguration.navColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 25)!]
        UINavigationBar.appearance().barTintColor = AppConfiguration.navColor
        UINavigationBar.appearance().tintColor = AppConfiguration.navText
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 20)!], forState: .Normal)
    }
}



public struct AppConfiguration {
    
    public static var ToothBadge1 = Images.resizeImage(UIImage(named: "CavityMaker")!, width: UIImage(named: "CavityMaker")!.size.width/12, height: UIImage(named: "CavityMaker")!.size.height/12)
    public static var ToothBadge2 = Images.resizeImage(UIImage(named: "sugarbugs")!, width: UIImage(named: "sugarbugs")!.size.width/12, height: UIImage(named: "sugarbugs")!.size.height/12)
    public static var ToothBadge3 = Images.resizeImage(UIImage(named: "ToothProtector")!, width: UIImage(named: "ToothProtector")!.size.width/12, height: UIImage(named: "ToothProtector")!.size.height/12)
    public static var ToothBadge4 = Images.resizeImage(UIImage(named: "ToothHero")!, width: UIImage(named: "ToothHero")!.size.width/12, height: UIImage(named: "ToothHero")!.size.height/12)
    
    public static var addTooth : UIImage = Images.resizeImage(UIImage(named: "AddTooth")!, width: UIImage(named: "AddTooth")!.size.width/3.5, height: UIImage(named: "AddTooth")!.size.height/3.5)!
    //public static var addTooth : UIImage = Images.resizeImage(UIImage(named: "InsertTooth")!, width: UIImage(named: "AddTooth")!.size.width/3, height: UIImage(named: "AddTooth")!.size.height/3)!
    //public static var addTooth : UIImage = Images.resizeImage(UIImage(named: "ManualTooth")!, width: UIImage(named: "AddTooth")!.size.width/3, height: UIImage(named: "AddTooth")!.size.height/3)!
    
    public static var navColor: UIColor = UIColor(red: 0.697961986064911, green: 0.698083817958832, blue: 0.69795435667038, alpha: 1.0)
    public static var tealColor: UIColor = UIColor(red: 0.347532421350479, green: 0.671598851680756, blue: 0.669063985347748, alpha: 1.0)
    public static var lightGreenColor: UIColor = UIColor(red: 0.709570467472076, green: 0.901739716529846, blue: 0.116919346153736, alpha: 1.0)
    public static var darkGreenColor: UIColor = UIColor(red: 0.577647268772125, green: 0.5523521900177, blue: 0.276400357484818, alpha: 1.0)
    public static var darkGrayColor: UIColor = UIColor(red: 0.497982442378998, green: 0.498071908950806, blue: 0.497976779937744, alpha: 1.0)
    public static var purpleColor: UIColor = UIColor(red: 0.674035608768463, green: 0.485131859779358, blue: 0.67489892244339, alpha: 1.0)
    //(red: 0.952941179275513, green: 0.686274528503418, blue: 0.133333340287209, alpha: 1.0)
    public static var navSelectedColor: UIColor = UIColor(red: 0.497982442378998, green: 0.498071908950806, blue: 0.497976779937744, alpha: 1.0)//UIColor.carrotColor()//.mandarinColor()//.cantaloupeColor()//burntOrangeColor()
    public static var navText: UIColor =  UIColor.whiteColor()
    public static var backgroundColor = UIColor.peachColor()
    public static var appFont = UIFont(name: "AmericanTypewriter", size: 18)!
    public static var appFontSmall = UIFont(name: "AmericanTypewriter", size: 12)!
    public static var appFontSmallBold = UIFont(name: "AmericanTypewriter-Bold", size: 12)!
    public static var sideMenuColor = UIColor.yellowColor().complementaryColor()
    public static var sideMenuText: UIColor =  UIColor.antiqueWhiteColor()
    public static var textAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter", size: 18)!] as [String : AnyObject]
    
}



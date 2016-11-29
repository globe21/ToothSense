///
//  AppDelegate.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/24/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import UIKit
import Parse
import ParseUI
//import Fabric
//import Crashlytics
import UserNotifications
import UserNotificationsUI

let kConstantObj = kConstant()
var sideMenuNavigationController : UINavigationController?
var tabController: RAMAnimatedTabBarController?
let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
let screenBounds = UIScreen.mainScreen().bounds
var previousOrientation: UIDeviceOrientation = UIDeviceOrientation.Unknown


let AMNotification = UILocalNotification()
let PMNotification = UILocalNotification()

let defaults = NSUserDefaults.standardUserDefaults()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        defaults.setBool(true, forKey: "SugarBugStatus")
        Parse.setApplicationId("RhYIPJ9diSnYaEcFGVoIGlUNU3V9u1Y6R7jn0Ec1", clientKey: "gafsXZByOHv6F5uZ0TfIzwKBPEgygdYz5p6LCti8")
        configureStyling()
        
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
        //Fabric.with([Crashlytics.self])
        if PFUser.currentUser() != nil {
            appDelegate.window?.rootViewController = kConstantObj.SetIntialMainViewController()
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


extension AppDelegate {

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
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([UINavigationController.self]).titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 25)!]
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



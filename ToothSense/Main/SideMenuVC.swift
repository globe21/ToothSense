//
//  SideMenuVC.swift
//  SideMenuSwiftDemo
//
//  Created by Kiran Patel on 1/2/16.
//  Copyright © 2016  SOTSYS175. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import GLKit
import AVFoundation
import CoreMedia
import CoreImage
import OpenGLES
import QuartzCore
import CoreVideo
import Parse
import ParseUI


let BuildController:BuildViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("BuildViewController") as! BuildViewController
let Smiles: SmilesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SmilesViewController") as! SmilesViewController
let brushTimer: Brush = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Brush") as! Brush
let chartController:BrushChart = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("BrushChart") as! BrushChart
let LoginControl: LoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
//let vidTable: VidTable = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VidTable") as! VidTable
let videoTable: VideoTable = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VideoTable") as! VideoTable
let sideVC:SideMenuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sideMenuID") as! SideMenuVC
let FriendsControl: FriendListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FollowVC") as! FriendListViewController
var contactPickerScene: EPContactsPicker = EPContactsPicker(delegate: sideVC, multiSelection:true, subtitleCellType: SubtitleCellValue.PhoneNumber)
let EnterManual:ManualEntry = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ManualEntry") as! ManualEntry


protocol KSideMenuVCDelegate: class {
    func sidemenuDidOpen(sidemenu: KSideMenuVC)
}


class KSideMenuVC: UIViewController,UIGestureRecognizerDelegate {
    var sideMenuDelegate: KSideMenuVCDelegate?
    
    var mainContainer : UIViewController?
    var menuContainer : UIViewController?
    var menuViewController : UIViewController?
    var mainViewController : UIViewController?
    var bgImageContainer : UIImageView?
    var distanceOpenMenu : CGFloat = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setUp(){
        self.distanceOpenMenu = self.view.frame.size.width-(self.view.frame.size.width/2)//3);
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.GradLayer(AppConfiguration.navColor)
        self.menuContainer = UIViewController()
        self.menuContainer!.view.layer.anchorPoint = CGPoint(x:1.0, y:0.5)
        self.menuContainer!.view.frame = self.view.bounds;
        self.menuContainer!.view.backgroundColor = UIColor.clearColor()
        self.addChildViewController(self.menuContainer!)
        self.view.addSubview((self.menuContainer?.view)!)
        self.menuContainer?.didMoveToParentViewController(self)
        
        self.mainContainer = UIViewController()
        self.mainContainer!.view.frame = self.view.bounds;
        self.mainContainer!.view.backgroundColor = UIColor.clearColor()
        self.addChildViewController(self.mainContainer!)
        self.view.addSubview((self.mainContainer?.view)!)
        self.mainContainer?.didMoveToParentViewController(self)
        
    }
    func setupMenuViewController(menuVC : UIViewController)->Void{
        if (self.menuViewController != nil) {
            self.menuViewController?.willMoveToParentViewController(nil)
            self.menuViewController?.removeFromParentViewController()
            self.menuViewController?.view.removeFromSuperview()
        }
        
        self.menuViewController = menuVC;
        self.menuViewController!.view.frame = self.view.bounds;
        self.menuContainer?.addChildViewController(self.menuViewController!)
        self.menuContainer?.view.addSubview(menuVC.view)
        self.menuContainer?.didMoveToParentViewController(self.menuViewController)
    }
    func setupMainViewController(mainVC : UIViewController)->Void{
        closeMenu()
        
        if (self.mainViewController != nil) {
            self.mainViewController?.willMoveToParentViewController(nil)
            self.mainViewController?.removeFromParentViewController()
            self.mainViewController?.view.removeFromSuperview()
        }
        self.mainViewController = mainVC;
        self.mainViewController!.view.frame = self.view.bounds;
        self.mainContainer?.addChildViewController(self.mainViewController!)
        self.mainContainer?.view.addSubview(self.mainViewController!.view)
        self.mainViewController?.didMoveToParentViewController(self.mainContainer)
        
        if (self.mainContainer!.view.frame.minX == self.distanceOpenMenu) {
            closeMenu()
        }
    }
    func openMenu(){
        addTapGestures()
        var fMain : CGRect = self.mainContainer!.view.frame
        fMain.origin.x = -self.distanceOpenMenu;
        
        UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            let layerTemp : CALayer = (self.mainContainer?.view.layer)!
            layerTemp.zPosition = 1000
            var tRotate : CATransform3D = CATransform3DIdentity
            tRotate.m34 = 1.0/(-500)
            let aXpos: CGFloat = CGFloat(20.0*(M_PI/180))//CGFloat(-20.0*(M_PI/180))
            tRotate = CATransform3DRotate(tRotate,aXpos, 0, 1, 0)
            var tScale : CATransform3D = CATransform3DIdentity
            tScale.m34 = 1.0/(-500)
            tScale = CATransform3DScale(tScale, 0.8, 0.8, 1.0);
            layerTemp.transform = CATransform3DConcat(tScale, tRotate)
            
            self.mainContainer?.view.frame = fMain
        }) { (finished: Bool) -> Void in
        }
    }
    func closeMenu(){
        var fMain : CGRect = self.mainContainer!.view.frame
        fMain.origin.x = 0
        
        UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            self.mainContainer?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            let layerTemp : CALayer = (self.mainContainer?.view.layer)!
            layerTemp.zPosition = 1000
            var tRotate : CATransform3D = CATransform3DIdentity
            tRotate.m34 = 1.0/(-500)
            let aXpos: CGFloat = CGFloat(0.0*(M_PI/180))
            tRotate = CATransform3DRotate(tRotate,aXpos, 0, 1, 0)
            layerTemp.transform = tRotate
            var tScale : CATransform3D = CATransform3DIdentity
            tScale.m34 = 1.0/(-500)
            tScale = CATransform3DScale(tScale,1.0, 1.0, 1.0);
            layerTemp.transform = tScale;
            layerTemp.transform = CATransform3DConcat(tRotate, tScale)
            layerTemp.transform = CATransform3DConcat(tScale, tRotate)
            self.mainContainer!.view.frame = CGRect(x:0, y:0, width:appDelegate.window!.frame.size.width, height:appDelegate.window!.frame.size.height)
        }) { (finished: Bool) -> Void in
            self.mainViewController!.view.userInteractionEnabled = true
            self.removeGesture()
            
        }
    }
    func addTapGestures(){
        self.mainViewController!.view.userInteractionEnabled = false
        
        let tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KSideMenuVC.tapMainAction))
        self.mainContainer!.view.addGestureRecognizer(tapGestureRecognizer)
    }
    func removeGesture(){
        for recognizer in  self.mainContainer!.view.gestureRecognizers ?? [] {
            if (recognizer is UITapGestureRecognizer){
                self.mainContainer!.view.removeGestureRecognizer(recognizer)
            }
        }
    }
    func tapMainAction(){
        closeMenu()
    }
    func toggleMenu(){
        let fMain : CGRect = self.mainContainer!.view.frame
        if (fMain.minX == self.distanceOpenMenu) {
            closeMenu()
        }else{
            openMenu()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



class SideMenuCell: UITableViewCell {
    
    @IBOutlet weak var Field: UILabel!
}

extension SideMenuVC : EPPickerDelegate {
    //MARK: EPContactsPicker delegates
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError) {
        print("Failed with error \(error.description)")
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact) {
        print("Contact \(contact.displayName()) has been selected")
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError) {
        
        switch tabController!.selectedIndex {
        case 0:
            sideMenuNavigationController!.tr_popViewController()
        case 1:
            sideMenuNavigationController2!.tr_popViewController()
        case 2:
            sideMenuNavigationController3!.tr_popViewController()
        default:
            sideMenuNavigationController!.tr_popViewController()
        }
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
        var epPhoneNumbers: [String] = [String]()
        for contact in contacts {
            for phoneNumber in contact.phoneNumbers {
                epPhoneNumbers.append(phoneNumber.phoneNumber)
            }
        }
        print("Phones: \(epPhoneNumbers)")
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hey check out this new app I found called ToothSense. You can download it here: https://itunes.apple.com/us/app/tooth-sense/id1031245716?ls=1&mt=8"
            controller.recipients = epPhoneNumbers
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: false, completion: nil)
        }
    }
}



class SideMenuVC: UIViewController,KSideMenuVCDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, NavgationTransitionable {
    
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var ProfileImage: PFImageView!
    @IBOutlet weak var NameField: UILabel!
    @IBOutlet weak var SidebarBackground: UIView!
    
    
    let aData : [String] = ["Edit Profile", "Sugar Bug Status", "Brush Chart", "Friends List", "Invite Friends", "Log Out"]
    
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        tableView.delegate = self
        tableView.dataSource = self
        ProfileImage.setProfPic(UIColor.whiteColor())
        NameField.text = PFUser.currentUser()!.Fullname()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func sidemenuDidOpen(sidemenu: KSideMenuVC) {
        let swiperight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwipe))
        swiperight.direction = .Right
        self.view.addGestureRecognizer(swiperight)
    }
    
    
    func rightSwipe(sender: UISwipeGestureRecognizer) {
        sideMenuVC.closeMenu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuVC.sideMenuDelegate = self
        view.backgroundColor = AppConfiguration.navColor
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let aCell:SideMenuCell = tableView.dequeueReusableCellWithIdentifier("kCell")! as! SideMenuCell
        aCell.contentView.addSubview(aCell.Field)
        aCell.Field.frame = CGRect(x: aCell.contentView.frame.minX + 2.5, y: aCell.contentView.frame.minY + 2.5, width: aCell.contentView.frame.width - 5, height: aCell.contentView.frame.height - 5)
        aCell.Field.text = aData[indexPath.row]
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            aCell.Field.font = UIFont(name: "AmericanTypewriter-Bold", size: 21)!
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            aCell.Field.font = UIFont(name: "AmericanTypewriter-Bold", size: 18)!
        } else {
            aCell.Field.font = UIFont(name: "AmericanTypewriter-Bold", size: 16)!
        }
        aCell.backgroundColor = .clearColor()
        return aCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            sideMenuVC.closeMenu()
            BuildController.age = PFUser.currentUser()!.getBirthday()
            BuildController.fullname = PFUser.currentUser()!.Fullname()
            ProfileImage.file = PFUser.currentUser()!.getProfPic()
            ProfileImage.loadInBackground({ (image, error) in
                if error == nil {
                    BuildController.profileImage = image!
                }
            })
            switch tabController!.selectedIndex {
            case 0:
                if sideMenuNavigationController!.viewControllers.contains(BuildController) {
                    sideMenuNavigationController!.tr_popToViewController(BuildController)
                } else {
                    sideMenuNavigationController!.tr_pushViewController(BuildController, method: TRPushTransitionMethod.Fade)
                }
            case 1:
                if sideMenuNavigationController2!.viewControllers.contains(BuildController) {
                    sideMenuNavigationController2!.tr_popToViewController(BuildController)
                } else {
                    sideMenuNavigationController2!.tr_pushViewController(BuildController, method: TRPushTransitionMethod.Fade)
                }
            case 2:
                if sideMenuNavigationController3!.viewControllers.contains(BuildController) {
                    sideMenuNavigationController3!.tr_popToViewController(BuildController)
                } else {
                    sideMenuNavigationController3!.tr_pushViewController(BuildController, method: TRPushTransitionMethod.Fade)
                }
            default:
                break
            }
        } else if indexPath.row == 1 {
            sideMenuVC.closeMenu()
            switch tabController!.selectedIndex {
            case 0:
                if sideMenuNavigationController!.viewControllers.contains(Smiles) {
                    Smiles.getMyProgress(PFUser.currentUser()!)
                    sideMenuNavigationController!.tr_popToViewController(Smiles)
                } else {
                    defaults.setBool(true, forKey: "SugarBugStatus")
                    sideMenuNavigationController!.tr_pushViewController(Smiles, method: TRPushTransitionMethod.Fade)
                }
            case 1:
                if sideMenuNavigationController2!.viewControllers.contains(Smiles) {
                    Smiles.getMyProgress(PFUser.currentUser()!)
                    sideMenuNavigationController2!.tr_popToViewController(Smiles)
                } else {
                    defaults.setBool(true, forKey: "SugarBugStatus")
                    sideMenuNavigationController2!.tr_pushViewController(Smiles, method: TRPushTransitionMethod.Fade)
                }
            case 2:
                if sideMenuNavigationController3!.viewControllers.contains(Smiles) {
                    Smiles.getMyProgress(PFUser.currentUser()!)
                    sideMenuNavigationController3!.tr_popToViewController(Smiles)
                } else {
                    defaults.setBool(true, forKey: "SugarBugStatus")
                    sideMenuNavigationController3!.tr_pushViewController(Smiles, method: TRPushTransitionMethod.Fade)
                }
            default:
                break
            }
        } else if indexPath.row == 2 {
            sideMenuVC.closeMenu()
            switch tabController!.selectedIndex {
            case 0:
                if sideMenuNavigationController!.viewControllers.contains(chartController) {
                    sideMenuNavigationController!.tr_popToViewController(chartController)
                } else {
                    sideMenuNavigationController!.tr_pushViewController(chartController, method: TRPushTransitionMethod.Fade)
                }
            case 1:
                if sideMenuNavigationController2!.viewControllers.contains(chartController) {
                    sideMenuNavigationController2!.tr_popToViewController(chartController)
                } else {
                    sideMenuNavigationController2!.tr_pushViewController(chartController, method: TRPushTransitionMethod.Fade)
                }
            case 2:
                if sideMenuNavigationController3!.viewControllers.contains(chartController) {
                    sideMenuNavigationController3!.tr_popToViewController(chartController)
                } else {
                    sideMenuNavigationController3!.tr_pushViewController(chartController, method: TRPushTransitionMethod.Fade)
                }
            default:
                break
            }
        } else if indexPath.row == 3 {
            sideMenuVC.closeMenu()
            switch tabController!.selectedIndex {
            case 0:
                if sideMenuNavigationController!.viewControllers.contains(FriendsControl) {
                    sideMenuNavigationController!.tr_popToViewController(FriendsControl)
                } else {
                    sideMenuNavigationController!.tr_pushViewController(FriendsControl, method: TRPushTransitionMethod.Fade)
                }
            case 1:
                if sideMenuNavigationController2!.viewControllers.contains(FriendsControl) {
                    sideMenuNavigationController2!.tr_popToViewController(FriendsControl)
                } else {
                    sideMenuNavigationController2!.tr_pushViewController(FriendsControl, method: TRPushTransitionMethod.Fade)
                }
            case 2:
                if sideMenuNavigationController3!.viewControllers.contains(FriendsControl) {
                    sideMenuNavigationController3!.tr_popToViewController(FriendsControl)
                } else {
                    sideMenuNavigationController3!.tr_pushViewController(FriendsControl, method: TRPushTransitionMethod.Fade)
                }
            default:
                break
            }
        } else if indexPath.row == 4 {
            sideMenuVC.closeMenu()
            contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.PhoneNumber)
            switch tabController!.selectedIndex {
            case 0:
                if sideMenuNavigationController!.viewControllers.contains(contactPickerScene) {
                    sideMenuNavigationController!.tr_popToViewController(contactPickerScene)
                } else {
                    sideMenuNavigationController!.tr_pushViewController(contactPickerScene, method: TRPushTransitionMethod.Fade)
                }
            case 1:
                if sideMenuNavigationController2!.viewControllers.contains(contactPickerScene) {
                    sideMenuNavigationController2!.tr_popToViewController(contactPickerScene)
                } else {
                    sideMenuNavigationController2!.tr_pushViewController(contactPickerScene, method: TRPushTransitionMethod.Fade)
                }
            case 2:
                if sideMenuNavigationController3!.viewControllers.contains(contactPickerScene) {
                    sideMenuNavigationController3!.tr_popToViewController(contactPickerScene)
                } else {
                    sideMenuNavigationController3!.tr_pushViewController(contactPickerScene, method: TRPushTransitionMethod.Fade)
                }
            default:
                break
            }
        } else if indexPath.row == 5 {
            PFUser.logOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let ViewController:LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            appDelegate.window?.rootViewController = ViewController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        if !contactPickerScene.orderedContacts.isEmpty {
            let counter = (contactPickerScene.orderedContacts.count - 1)
            for i in 0..<counter {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
                if cell != nil {
                    cell!.accessoryType = UITableViewCellAccessoryType.None
                }
            }
            contactPickerScene.selectedContacts.removeAll()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}

let sideMenuVC = KSideMenuVC()
let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)


class kConstant {
    
    func SetIntialMainViewController()->(KSideMenuVC){
        var viewControllers: [UIViewController] = [UIViewController]()
        let sideMenuObj = mainStoryboard.instantiateViewControllerWithIdentifier("sideMenuID")
        let mainVcObj = mainStoryboard.instantiateViewControllerWithIdentifier("SmilesViewController")
        sideMenuNavigationController = UINavigationController(rootViewController: mainVcObj)
        sideMenuNavigationController!.navigationBar.barTintColor = AppConfiguration.navColor
        UINavigationBar.appearance().titleTextAttributes = AppConfiguration.textAttributes
        sideMenuNavigationController!.extendedLayoutIncludesOpaqueBars = true
        sideMenuVC.view.frame = UIScreen.mainScreen().bounds
        viewControllers.append(sideMenuNavigationController!)
        let centerButton = mainStoryboard.instantiateViewControllerWithIdentifier("Brush")
        sideMenuNavigationController2 = UINavigationController(rootViewController: centerButton)
        sideMenuNavigationController2!.navigationBar.barTintColor = AppConfiguration.navColor
        sideMenuNavigationController2!.extendedLayoutIncludesOpaqueBars = true
        viewControllers.append(sideMenuNavigationController2!)
        let sideMenuObj2 = mainStoryboard.instantiateViewControllerWithIdentifier("VideoTable")
        sideMenuNavigationController3 = UINavigationController(rootViewController: sideMenuObj2)
        sideMenuNavigationController3!.navigationBar.barTintColor = AppConfiguration.navColor
        sideMenuNavigationController3!.extendedLayoutIncludesOpaqueBars = true
        viewControllers.append(sideMenuNavigationController3!)
        tabController = RAMAnimatedTabBarController(viewControllers: viewControllers)
        tabController!.tabBar.barTintColor = AppConfiguration.navColor
        sideMenuVC.setupMainViewController(tabController!)
        sideMenuVC.setupMenuViewController(sideMenuObj)
        brushTimer.BrushTabAnimation.iconSelectedColor = AppConfiguration.navSelectedColor
        Smiles.SmilesTabAnimation.iconSelectedColor = AppConfiguration.navSelectedColor
        videoTable.VideoTableTabAnimation.iconSelectedColor = AppConfiguration.navSelectedColor
        return sideMenuVC
    }
    
    func SetMainViewController(aStoryBoardID: String, storyboard: String)->(KSideMenuVC){
        let newMainStoryboard = UIStoryboard(name: storyboard, bundle: nil)
        let mainVcObj = newMainStoryboard.instantiateViewControllerWithIdentifier(aStoryBoardID)
        sideMenuNavigationController = UINavigationController(rootViewController: mainVcObj)
        sideMenuNavigationController!.navigationBar.barTintColor = AppConfiguration.navColor
        UINavigationBar.appearance().titleTextAttributes = AppConfiguration.textAttributes
        sideMenuNavigationController!.navigationBarHidden = false
        sideMenuNavigationController!.navigationItem.setHidesBackButton(true, animated: false)
        sideMenuVC.view.frame = UIScreen.mainScreen().bounds
        sideMenuVC.setupMainViewController(sideMenuNavigationController!)
        return sideMenuVC
    }
    
}

extension UIViewController {
    
    
    func PresentVC(string:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ViewController = storyboard.instantiateViewControllerWithIdentifier(string)
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: sideMenuNavigationController!, action: nil)
        sideMenuNavigationController!.navigationItem.leftBarButtonItem = backButton
        sideMenuNavigationController!.setViewControllers([ViewController], animated: true)
    }
    
    
    func NavPush(string:String, keyView: UIView?, rect: CGRect?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ViewController = storyboard.instantiateViewControllerWithIdentifier(string)
        if keyView != nil {
            if ViewController is LoginViewController {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! LoginViewController, method: TRPushTransitionMethod.Blixt(keyView: keyView!, to: rect!))
            } else if ViewController is Brush {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! Brush, method: TRPushTransitionMethod.Blixt(keyView: keyView!, to: rect!))
            } else if ViewController is VideoTable {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! VideoTable, method: TRPushTransitionMethod.Blixt(keyView: keyView!, to: rect!))
            } else if ViewController is SmilesViewController {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! SmilesViewController, method: TRPushTransitionMethod.Blixt(keyView: keyView!, to: rect!))
            } else if ViewController is FriendListViewController {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! FriendListViewController, method: TRPushTransitionMethod.Blixt(keyView: keyView!, to: rect!))
            } else if ViewController is BuildViewController {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! BuildViewController, method: TRPushTransitionMethod.Blixt(keyView: keyView!, to: rect!))
            } else if ViewController is SideMenuVC {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! SideMenuVC, method: TRPushTransitionMethod.Blixt(keyView: keyView!, to: rect!))
            } else if ViewController is BrushChart {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! BrushChart, method: TRPushTransitionMethod.Blixt(keyView: keyView!, to: rect!))
            }
        } else {
            if ViewController is LoginViewController {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! LoginViewController, method: TRPushTransitionMethod.Fade)
            } else if ViewController is Brush {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! Brush, method: TRPushTransitionMethod.Fade)
            } else if ViewController is VideoTable {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! VideoTable, method: TRPushTransitionMethod.Fade)
            } else if ViewController is SmilesViewController {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! SmilesViewController, method: TRPushTransitionMethod.Fade)
            } else if ViewController is FriendListViewController {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! FriendListViewController, method: TRPushTransitionMethod.Fade)
            } else if ViewController is BuildViewController {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! BuildViewController, method: TRPushTransitionMethod.Fade)
            } else if ViewController is SideMenuVC {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! SideMenuVC, method: TRPushTransitionMethod.Fade)
            } else if ViewController is BrushChart {
                sideMenuNavigationController!.tr_pushViewController(ViewController as! BrushChart, method: TRPushTransitionMethod.Fade)
            }
        }
        ViewController.removeBack()
    }
    
    
    func addLogOut() {
        let LogOutButton: UIBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedLogout))
        LogOutButton.tintColor = AppConfiguration.navText
        LogOutButton.setTitleTextAttributes(AppConfiguration.textAttributes, forState: .Normal)
        self.navigationItem.setRightBarButtonItem(LogOutButton, animated: false)
    }
    
    func tappedLogout() {
        PFUser.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        appDelegate.window?.rootViewController = ViewController
    }
    
    func addBackButton() {
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedBack))
        backButton.tintColor = AppConfiguration.navText
        backButton.setTitleTextAttributes(AppConfiguration.textAttributes, forState: .Normal)
        self.navigationItem.setLeftBarButtonItem(backButton, animated: false)
    }
    
    func addQuitButton() {
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Quit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedBack))
        backButton.tintColor = AppConfiguration.navText
        backButton.setTitleTextAttributes(AppConfiguration.textAttributes, forState: .Normal)
        self.navigationItem.setLeftBarButtonItem(backButton, animated: false)
    }
    
    func tappedBack() {
        sideMenuNavigationController!.popViewControllerAnimated(true)
    }
    
    func addHamMenu() {
        let menuButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "MenuIcon")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedMenu))
        menuButton.tintColor = AppConfiguration.navText
        self.navigationItem.setRightBarButtonItem(menuButton, animated: false)
    }
    
    func tappedMenu() {
        sideMenuVC.toggleMenu()
    }
    
    func addGradLayer() {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        gradientLayer.frame = frame
        let color1 = UIColor.blackColor().CGColor as CGColor
        let startingColor = UIColor(red: 184.0/255.0, green: 50.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        let scheme = startingColor.colorScheme(UIColor.ColorScheme.monochromatic)
        gradientLayer.colors = [color1, scheme[2], scheme[2], scheme[2], color1]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
}


extension UIView {
    func GradLayer(startingColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = startingColor.lightenedColor(0.4).CGColor
        let color2 = startingColor.darkenedColor(0.2).CGColor
        let color3 = startingColor.darkenedColor(0.4).CGColor
        gradientLayer.colors = [color1, color2, color3, color2, color1]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func AddGrad(startingColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let color2 = startingColor.darkenedColor(0.15).CGColor
        let color3 = startingColor.darkenedColor(0.3).CGColor
        gradientLayer.colors = [startingColor.CGColor, color2, color3, color2, startingColor.CGColor]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func addblur(color: UIColor) {
        let visualEffectView = VisualEffectView(frame: self.frame)
        visualEffectView.colorTint = color
        visualEffectView.colorTintAlpha = 0.9
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        self.addSubview(visualEffectView)
    }
    
    func removeBlur() {
        for sub in subviews {
            if sub is VisualEffectView {
                sub.removeFromSuperview()
            }
        }
    }
    
    func addBlur(color: UIColor, below: UIView) {
        let visualEffectView = VisualEffectView(frame: self.frame)
        visualEffectView.colorTint = color
        visualEffectView.colorTintAlpha = 0.9
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        self.insertSubview(visualEffectView, belowSubview: below)
    }
}


//
//  SmilesViewController.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/25/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import CoreGraphics
import Parse
import ParseUI

extension UIViewController {
    
    typealias GCDClosure = () -> Void
    
    @objc func GlobalUserInteractive(closure: GCDClosure) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            closure()
        }
    }
    
    @objc func GlobalUtility(closure: GCDClosure) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            closure()
        }
    }
    
    @objc func GlobalUserInitiated(closure: GCDClosure) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            closure()
        }
    }
    
    @objc func GlobalMain(closure: GCDClosure) {
        dispatch_async(dispatch_get_main_queue()) {
            closure()
        }
    }
    
    @objc func GlobalBackground(closure: GCDClosure) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            closure()
        }
    }
    
    func getMyProgress(user: PFUser) {
        var progress: CGFloat = 0.05
        PFUser.query()!.getObjectInBackgroundWithId(user.objectId!, block: { (object, error) in
            if error == nil {
                let user = object as! PFUser
                if user["AverageBrushTime"] != nil {
                    let averageTime: CGFloat! = user["AverageBrushTime"] as! CGFloat!
                    loader = WavesLoader.showProgressBasedLoaderWithPath(FillableLoader().ToothPath(), onView: self.view)
                    loader.loaderColor = UIColor.whiteColor()
                    loader.loaderBackgroundColor = AppConfiguration.darkGreenColor
                    loader.average = averageTime
                    if averageTime >= 130.0 {
                        progress = 1.0
                    } else {
                        progress = averageTime / 130.0
                    }
                    loader.progress = progress
                }
            } else {
                loader = WavesLoader.showProgressBasedLoaderWithPath(FillableLoader().ToothPath(), onView: self.view)
                loader.loaderColor = UIColor.whiteColor()
                loader.loaderBackgroundColor = AppConfiguration.darkGreenColor
                loader.average = 0.0
                loader.progress = progress
            }
            if self is SmilesViewController {
                (self as! SmilesViewController).forceFetchData()
            }
        })
    }
}

public enum BadgeType: Int, CustomStringConvertible {
    case CavityMaker = 0
    case SugarBug
    case ToothProtector
    case ToothHero
    
    public var image: UIImage {
        get {
            switch self {
            case .CavityMaker:
                return UIImage(named: "CavityMaker")!
            case .SugarBug:
                return UIImage(named: "sugarbugs")!
            case .ToothProtector:
                return UIImage(named: "ToothProtector")!
            case .ToothHero:
                return UIImage(named: "ToothHero")!
            }
        }
    }
    
    public var description: String {
        get {
            switch self {
            case .CavityMaker:
                return "CavityMaker"
            case .SugarBug:
                return "sugarbugs"
            case .ToothProtector:
                return "ToothProtector"
            case .ToothHero:
                return "ToothHero"
            }
        }
    }
}


class SmilesCollectionViewCell: UICollectionViewCell {
    
    var userLabel: UILabel!
    var TimeLabel: UILabel!
    var AgeLabel: UILabel!
    var CellImage: PFImageView!
    var BrushBadge: UIImageView!
    var FlossBadge: UIImageView!
    
    var type: BadgeType = .CavityMaker {
        didSet {
            BrushBadge.image = self.type.image
        }
    }
    
    var Floss: Bool = false {
        didSet {
            if self.Floss == true {
                self.FlossBadge.image = UIImage(named: "flossicon")!
            } else {
                self.FlossBadge.image = nil
            }
        }
    }
    
    var object: PFObject!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        if screenBounds.size.height >= 736 {
            CellImage = PFImageView(frame: CGRect(x: 2.5, y: 5, width: 110, height: 110))
            FlossBadge = UIImageView(frame: CGRect(x: screenBounds.width - 115, y: 3.33333, width: 55, height: 55))
            BrushBadge = UIImageView(frame: CGRect(x: screenBounds.width - 57.5, y: 3.33333, width: 55, height: 55))
            TimeLabel = UILabel(frame: CGRect(x: screenBounds.width - 105, y: 61.66666, width: 72.5, height: 55))
            userLabel = UILabel(frame: CGRect(x: CellImage.frame.maxX + 5, y: 3.33333, width: (FlossBadge.frame.minX - 2.5) - (CellImage.frame.maxX + 5), height: 55))
            AgeLabel = UILabel(frame: CGRect(x: CellImage.frame.maxX + 5, y: 61.66666, width: (FlossBadge.frame.minX - 2.5) - (CellImage.frame.maxX + 5), height: 55))
        } else if screenBounds.size.height < 736 && screenBounds.size.height >= 667 {
            CellImage = PFImageView(frame: CGRect(x: 2.5, y: 5, width: 90, height: 90))
            FlossBadge = UIImageView(frame: CGRect(x: screenBounds.width - 95, y: 3.33333, width: 45, height: 45))
            BrushBadge = UIImageView(frame: CGRect(x: screenBounds.width - 47.5, y: 3.33333, width: 45, height: 45))
            TimeLabel = UILabel(frame: CGRect(x: screenBounds.width - 95, y: 51.66666, width: 92.5, height: 45))
            userLabel = UILabel(frame: CGRect(x: CellImage.frame.maxX + 5, y: 3.33333, width: (FlossBadge.frame.minX - 2.5) - (CellImage.frame.maxX + 5), height: 45))
            AgeLabel = UILabel(frame: CGRect(x: CellImage.frame.maxX + 5, y: 51.66666, width: (FlossBadge.frame.minX - 2.5) - (CellImage.frame.maxX + 5), height: 45))
        } else {
            CellImage = PFImageView(frame: CGRect(x: 2.5, y: 5, width: 70, height: 70))
            FlossBadge = UIImageView(frame: CGRect(x: screenBounds.width - 85, y: 3.33333, width: 35, height: 35))
            BrushBadge = UIImageView(frame: CGRect(x: screenBounds.width - 37.5, y: 3.33333, width: 35, height: 35))
            TimeLabel = UILabel(frame: CGRect(x: screenBounds.width - 85, y: 41.66666, width: 72.5, height: 35))
            userLabel = UILabel(frame: CGRect(x: CellImage.frame.maxX + 5, y: 3.33333, width: (FlossBadge.frame.minX - 2.5) - (CellImage.frame.maxX + 5), height: 35))
            AgeLabel = UILabel(frame: CGRect(x: CellImage.frame.maxX + 5, y: 41.66666, width: (FlossBadge.frame.minX - 2.5) - (CellImage.frame.maxX + 5), height: 35))
        }
        CellImage.contentMode = .ScaleAspectFill
        CellImage.image = UIImage(named: "ProfileIcon")
        //CellImage.layer.cornerRadius = (CellImage.frame.height) / 2
        CellImage.layer.cornerRadius = 12
        CellImage.tintColor = AppConfiguration.navText
        CellImage.layer.borderColor = UIColor.clearColor().CGColor
        CellImage.layer.borderWidth = 4.0
        CellImage.backgroundColor = UIColor.clearColor()
        CellImage.layer.masksToBounds = true
        contentView.addSubview(CellImage)
        FlossBadge.contentMode = .ScaleAspectFit
        FlossBadge.backgroundColor = UIColor.clearColor()
        contentView.addSubview(FlossBadge)
        BrushBadge.contentMode = .ScaleAspectFit
        BrushBadge.backgroundColor = UIColor.clearColor()
        contentView.addSubview(BrushBadge)
        TimeLabel.textAlignment = NSTextAlignment.Center
        TimeLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(TimeLabel)
        userLabel.textAlignment = NSTextAlignment.Left
        userLabel.adjustsFontSizeToFitWidth = true
        userLabel.attributedText = NSMutableAttributedString(string: "Loading..", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
        contentView.addSubview(userLabel)
        AgeLabel.textAlignment = NSTextAlignment.Left
        AgeLabel.adjustsFontSizeToFitWidth = true
        AgeLabel.attributedText = NSMutableAttributedString(string: "Age: 0", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 27.0)!])
        contentView.addSubview(AgeLabel)
    }
    
    
    func setupCell() {
        if object["User"] != nil {
            let user: PFUser = object["User"] as! PFUser
            let userQuery = PFUser.query()
            userQuery?.getObjectInBackgroundWithId(user.objectId!, block: { (user, error) in
                if error == nil {
                    let user = user as! PFUser
                    if user["profPic"] != nil {
                        self.CellImage.file = user.profPic
                        self.CellImage.loadInBackground() { image, error in
                            if error == nil {
                                self.CellImage.layer.borderColor = AppConfiguration.navText.CGColor
                            }
                        }
                    } else if self.object["userPic"] != nil {
                        self.CellImage.file = self.object["userPic"] as? PFFile
                        self.CellImage.loadInBackground() { image, error in
                            if error == nil {
                                self.CellImage.layer.borderColor = AppConfiguration.navText.CGColor
                            }
                        }
                    } else {
                        self.CellImage.image = UIImage(named: "ProfileIcon")
                        self.CellImage.layer.borderColor = UIColor.clearColor().CGColor
                    }
                    self.userLabel.attributedText = NSMutableAttributedString(string: user.fullname, attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
                    self.AgeLabel.attributedText = NSMutableAttributedString(string: "AGE: \(user.age)", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 27.0)!])
                } else {
                    if self.object["fullname"] != nil {
                        self.userLabel.attributedText = NSMutableAttributedString(string: self.object["Name"] as! String, attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
                    }
                    if self.object["Age"] != nil {
                        self.AgeLabel.hidden = false
                        self.AgeLabel.attributedText = NSMutableAttributedString(string: self.object["Age"] as! String, attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 27.0)!])
                    } else {
                        self.AgeLabel.hidden = true
                    }
                    if self.object["userPic"] != nil {
                        self.CellImage.file = self.object["userPic"] as? PFFile
                        self.CellImage.loadInBackground() { image, error in
                            if error == nil {
                                self.CellImage.layer.borderColor = AppConfiguration.navText.CGColor
                            }
                        }
                    }
                }
            })
        }
        if object["brushTime"] != nil {
            let mSec = (object["brushTime"] as! CGFloat)
            switch mSec {
            case 0...45:
                type = .CavityMaker
            case 46...75:
                type = .SugarBug
            case 76...105:
                type = .ToothProtector
            default:
                type = .ToothHero
            }
            TimeLabel.attributedText = NSMutableAttributedString(string: mSec.toMinSec(), attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
        } else {
            type = .CavityMaker
            TimeLabel.attributedText = NSMutableAttributedString(string: "00:00", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
        }
        if object["Flosser"] != nil {
            Floss = object["Flosser"] as! Bool
        } else {
            Floss = false
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class SmilesViewController: UICollectionViewController, NavgationTransitionable {
    
    
    @IBOutlet var SmilesTabAnimation: RAMFumeAnimation!
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    var requestInProgress = false
    var forceRefresh = false
    var stopFetching = false
    var pageNumber = 0
    let refreshControl = UIRefreshControl()
    
    var objectArray: [PFObject] = [PFObject]()
    let colorsArray = ["EE5464", "DC4352", "FD6D50", "EA583F", "F6BC43", "8DC253", "4FC2E9", "3CAFDB", "5D9CEE", "4B89DD", "AD93EE", "977BDD", "EE87C0", "D971AE", "903FB1", "9D56B9", "227FBD", "2E97DE"]
    
    override func viewDidLoad() {
        view.backgroundColor = AppConfiguration.backgroundColor
        collectionView!.backgroundColor = AppConfiguration.backgroundColor
        self.title = "Smiles Club"
        self.collectionView!.registerClass(SmilesCollectionViewCell.self, forCellWithReuseIdentifier: "smileCellReuse")
        refreshControl.tintColor = UIColor.wheatColor()
        collectionView!.addSubview(refreshControl)
        refreshControl.addTarget(self, action:#selector(self.forceFetchData), forControlEvents:.ValueChanged)
        self.forceFetchData()
    }
    
    func getWeekDates() -> [NSDate] {
        var dates: [NSDate] = []
        var todaysDate = NSDate().dateByAddingTimeInterval(-518400)//604800)
        dates.append(todaysDate)
        for _ in 0...5 {
            todaysDate = todaysDate.nextDay()!
            dates.append(todaysDate)
        }
        return dates
    }
    
    func forceFetchData() {
        forceRefresh = true
        stopFetching = false
        pageNumber = 0
        self.fetchData()
    }
    
    func fetchData() {
        if (!requestInProgress && !stopFetching) {
            requestInProgress = true
            let smilesQuery = PFQuery(className: "SmilesClub")
            smilesQuery.orderByDescending("brushDate")
            smilesQuery.limit = 20
            smilesQuery.cachePolicy = .NetworkElseCache
            smilesQuery.maxCacheAge = 60*60
            smilesQuery.skip = pageNumber*20
            if PFUser.currentUser()!["BlockedPeople"] != nil {
                smilesQuery.whereKey("User", notContainedIn: PFUser.currentUser()!.BlockedUsers)
            }
            if PFUser.currentUser()!["Friends"] != nil {
                smilesQuery.whereKey("User", containedIn: PFUser.currentUser()!.Friends)
                smilesQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
                    if error == nil {
                        if self.pageNumber == 0 {
                            self.objectArray.removeAll()
                        }
                        var array : [PFObject] = [PFObject]()
                        if (self.forceRefresh) {
                            array.appendContentsOf(self.objectArray)
                        }
                        for object in objects! {
                            array.append(object)
                        }
                        self.objectArray.appendContentsOf(array)
                        self.collectionView!.reloadData()
                        self.refreshControl.endRefreshing()
                        self.requestInProgress = false
                        self.forceRefresh = false
                        if (objects!.count<20) {
                            self.stopFetching = false
                        }
                        self.pageNumber += 1
                        ProgressHUD.dismiss()
                    } else {
                        self.requestInProgress = false
                        self.forceRefresh = false
                        self.refreshControl.endRefreshing()
                        ProgressHUD.dismiss()
                    }
                })
            } else {
                smilesQuery.whereKey("User", equalTo: PFUser.currentUser()!)
                smilesQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
                    if error == nil {
                        if self.pageNumber == 0 {
                            self.objectArray.removeAll()
                        }
                        var array : [PFObject] = [PFObject]()
                        if (self.forceRefresh) {
                            array.appendContentsOf(self.objectArray)
                        }
                        for object in objects! {
                            array.append(object)
                        }
                        self.objectArray.appendContentsOf(array)
                        self.collectionView!.reloadData()
                        self.refreshControl.endRefreshing()
                        self.requestInProgress = false
                        self.forceRefresh = false
                        if (objects!.count<20) {
                            self.stopFetching = false
                        }
                        self.pageNumber += 1
                        ProgressHUD.dismiss()
                    } else {
                        self.requestInProgress = false
                        self.forceRefresh = false
                        self.refreshControl.endRefreshing()
                        ProgressHUD.dismiss()
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeBack()
        addHamMenu()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sideMenuNavigationController = self.navigationController!
        if defaults.boolForKey("SugarBugStatus") == true {
            if PFUser.currentUser() != nil {
                self.getMyProgress(PFUser.currentUser()!)
            }
            defaults.setBool(false, forKey: "SugarBugStatus")
        }
        GlobalBackground { 
            if PFUser.currentUser() != nil {
                weekDates = self.getWeekDates()
                for day in weekDates {
                    let AMQuery = PFQuery(className: "SmilesClub")
                    AMQuery.whereKey("User", equalTo: PFUser.currentUser()!)
                    AMQuery.whereKey("brushDate", greaterThan: day.beginningOfDay)
                    AMQuery.whereKey("brushDate", lessThanOrEqualTo: day.middleOfDay)
                    AMQuery.cachePolicy = .NetworkElseCache
                    AMQuery.maxCacheAge = 60*60
                    AMQuery.getFirstObjectInBackgroundWithBlock({ (object, error) in
                        if error == nil {
                            let object = object!
                            if day == weekDates[0] {
                                AMTimes.removeAtIndex(0)
                                AMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 0)
                            } else if day == weekDates[1] {
                                AMTimes.removeAtIndex(1)
                                AMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 1)
                            } else if day == weekDates[2] {
                                AMTimes.removeAtIndex(2)
                                AMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 2)
                            } else if day == weekDates[3] {
                                AMTimes.removeAtIndex(3)
                                AMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 3)
                            } else if day == weekDates[4] {
                                AMTimes.removeAtIndex(4)
                                AMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 4)
                            } else if day == weekDates[5] {
                                AMTimes.removeAtIndex(5)
                                AMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 5)
                            } else if day == weekDates[6] {
                                AMTimes.removeAtIndex(6)
                                AMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 6)
                            }
                        }
                    })
                    let PMQuery = PFQuery(className: "SmilesClub")
                    PMQuery.whereKey("User", equalTo: PFUser.currentUser()!)
                    PMQuery.whereKey("brushDate", greaterThan: day.middleOfDay)
                    PMQuery.whereKey("brushDate", lessThanOrEqualTo: day.endOfDay)
                    PMQuery.cachePolicy = .NetworkElseCache
                    PMQuery.maxCacheAge = 60*60
                    PMQuery.getFirstObjectInBackgroundWithBlock({ (object, error) in
                        if error == nil {
                            let object = object!
                            if day == weekDates[0] {
                                PMTimes.removeAtIndex(0)
                                PMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 0)
                            } else if day == weekDates[1] {
                                PMTimes.removeAtIndex(1)
                                PMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 1)
                            } else if day == weekDates[2] {
                                PMTimes.removeAtIndex(2)
                                PMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 2)
                            } else if day == weekDates[3] {
                                PMTimes.removeAtIndex(3)
                                PMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 3)
                            } else if day == weekDates[4] {
                                PMTimes.removeAtIndex(4)
                                PMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 4)
                            } else if day == weekDates[5] {
                                PMTimes.removeAtIndex(5)
                                PMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 5)
                            } else if day == weekDates[6] {
                                PMTimes.removeAtIndex(6)
                                PMTimes.insert(object["brushTime"] as! CGFloat, atIndex: 6)
                            }
                        }
                    })
                    
                }
            }
        }
    }
}

extension SmilesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let resizer: UIImage = Images.resizeImage(UIImage(named: "Tooth")!, width: 150, height: 150)!
        return resizer
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont(name: "AmericanTypewriter-Bold", size: 25)!, NSForegroundColorAttributeName: AppConfiguration.navText, NSBackgroundColorAttributeName: AppConfiguration.backgroundColor]
        return NSAttributedString(string: "NO SMILES", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont(name: "AmericanTypewriter", size: 20)!, NSForegroundColorAttributeName: AppConfiguration.navText.darkenedColor(0.1)]
        return NSAttributedString(string: "THE SMILES CLUB SHOWS ALL OF YOUR BRUSHING ACHIEVEMENTS AS WELL AS YOUR FRIENDS. FOLLOW A FRIEND OR START BRUSHING TO GET STARTED", attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont(name: "AmericanTypewriter", size: 20)!, NSForegroundColorAttributeName: AppConfiguration.navColor.darkenedColor(0.1)]
        return NSAttributedString(string: "ADD FRIENDS", attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        if sideMenuNavigationController!.viewControllers.contains(FriendsControl) {
            sideMenuNavigationController!.tr_popToViewController(FriendsControl)
        } else {
            sideMenuNavigationController!.tr_pushViewController(FriendsControl, method: TRPushTransitionMethod.Fade)
        }
    }
    
    func spaceHeightForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return scrollView.bounds.height * 0.05
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.clearColor()
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}

extension SmilesViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objectArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SmilesCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("smileCellReuse", forIndexPath: indexPath) as! SmilesCollectionViewCell
        cell.object = objectArray[indexPath.row]
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell:SmilesCollectionViewCell = cell as? SmilesCollectionViewCell else {
            return
        }
        cell.setupCell()
        if indexPath.row < colorsArray.count - 1 {
            cell.contentView.backgroundColor = UIColor.colorFromHexString(colorsArray[indexPath.row])
        } else {
            let color = indexPath.row % (colorsArray.count - 1)
            cell.contentView.backgroundColor = UIColor.colorFromHexString(colorsArray[color])
        }
        if (indexPath.row + 1) == (pageNumber * 20) {// == objectArray.count-1) {
            if (!refreshControl.refreshing) &&  requestInProgress == false {
                ProgressHUD.show("Loading Smiles...", spincolor1:AppConfiguration.navColor.darkenedColor(0.3), backcolor1:UIColor(white: 1.0, alpha: 0.2) , textcolor1:AppConfiguration.navColor.darkenedColor(0.4))
            }
            self.fetchData()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let user: PFUser = objectArray[indexPath.row]["User"] as? PFUser else {
            return
        }
        do {
            try user.fetchIfNeeded()
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let Profile = UIAlertAction(title: "View Sugar Bug Status", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
                sideMenuNavigationController!.topViewController!.getMyProgress(user)
            }
            let Cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in}
            let Report = UIAlertAction(title: "Report \(user.fullname)", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
                self.showReportUser(user)
            }
            alertVC.addAction(Report)
            alertVC.addAction(Profile)
            alertVC.addAction(Cancel)
            self.presentViewController(alertVC, animated: true, completion: nil)
        } catch {
            
        }
    }
    
}

extension SmilesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if screenBounds.size.height >= 736 {
            return CGSizeMake(CGRectGetWidth(view.bounds), 120.0)
        } else if screenBounds.size.height < 736 && screenBounds.size.height >= 667 {
            return CGSizeMake(CGRectGetWidth(view.bounds), 100.0)
        }
        return CGSizeMake(CGRectGetWidth(view.bounds), 80.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: NSInteger) -> CGFloat {
        return 0.0
    }
}


extension UIColor {
    public class func colorFromHexString(hexString: String) -> UIColor {
        let colorString = hexString.stringByReplacingOccurrencesOfString("#", withString: "").uppercaseString
        let alpha, red, blue, green: Float
        alpha = 1.0
        red = self.colorComponentsFrom(colorString, start: 0, length: 2)
        green = self.colorComponentsFrom(colorString, start: 2, length: 2)
        blue = self.colorComponentsFrom(colorString, start: 4, length: 2)
        return UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: alpha)
    }
    
    private class func colorComponentsFrom(string: NSString, start: Int, length: Int) -> Float {
        NSMakeRange(start, length)
        let subString = string.substringWithRange(NSMakeRange(start, length))
        var hexValue: UInt32 = 0
        NSScanner(string: subString).scanHexInt(&hexValue)
        return Float(hexValue) / 255.0
    }
}

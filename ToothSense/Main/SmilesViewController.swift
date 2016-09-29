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

extension SmilesViewController {
    func getMyProgress(user: PFUser) {
        var progress: CGFloat = 0.05
        let userQuery = PFUser.query()
        userQuery!.getObjectInBackgroundWithId(user.objectId!, block: { (object, error) in
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
            self.forceFetchData()
        })
    }
}

class SmilesCollectionViewCell: UICollectionViewCell {
    
    var userLabel: UILabel!
    var TimeLabel: UILabel!
    var AgeLabel: UILabel!
    var CellImage: PFImageView!
    var BrushBadge: UIImageView!
    var FlossBadge: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            CellImage = PFImageView(frame: CGRect(x: contentView.frame.minX + 5, y: contentView.frame.minY + 5, width: contentView.frame.height - 10, height: contentView.frame.height - 10))
            CellImage.contentMode = .ScaleAspectFill
            contentView.addSubview(CellImage)
            FlossBadge = UIImageView(frame: CGRect(x: screenBounds.width - 110, y: 5, width: 50, height: 50))
            FlossBadge.contentMode = .ScaleAspectFit
            FlossBadge.backgroundColor = UIColor.clearColor()
            contentView.addSubview(FlossBadge)
            BrushBadge = UIImageView(frame: CGRect(x: screenBounds.width - 60, y: 5, width: 50, height: 50))
            BrushBadge.contentMode = .ScaleAspectFit
            BrushBadge.backgroundColor = UIColor.clearColor()
            contentView.addSubview(BrushBadge)
            TimeLabel = UILabel(frame: CGRect(x: screenBounds.width - 110, y: 60, width: 110, height: 50))
            TimeLabel.textAlignment = NSTextAlignment.Center
            TimeLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(TimeLabel)
            let widther = (screenBounds.width - 110) - (contentView.frame.height + 20)
            userLabel = UILabel(frame: CGRect(x: contentView.frame.height + 5, y: 5, width: widther, height: 55))
            userLabel.textAlignment = NSTextAlignment.Left
            userLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(userLabel)
            AgeLabel = UILabel(frame: CGRect(x: contentView.frame.height + 5, y: 55, width: widther, height: 55))
            AgeLabel.textAlignment = NSTextAlignment.Left
            AgeLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(AgeLabel)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            CellImage = PFImageView(frame: CGRect(x: contentView.frame.minX + 5, y: contentView.frame.minY + 5, width: contentView.frame.height - 10, height: contentView.frame.height - 10))
            CellImage.contentMode = .ScaleAspectFill
            contentView.addSubview(CellImage)
            FlossBadge = UIImageView(frame: CGRect(x: screenBounds.width - 110, y: 5, width: 50, height: 50))
            FlossBadge.contentMode = .ScaleAspectFit
            FlossBadge.backgroundColor = UIColor.clearColor()
            contentView.addSubview(FlossBadge)
            BrushBadge = UIImageView(frame: CGRect(x: screenBounds.width - 60, y: 5, width: 50, height: 50))
            BrushBadge.contentMode = .ScaleAspectFit
            BrushBadge.backgroundColor = UIColor.clearColor()
            contentView.addSubview(BrushBadge)
            TimeLabel = UILabel(frame: CGRect(x: screenBounds.width - 110, y: 60, width: 110, height: 50))
            TimeLabel.textAlignment = NSTextAlignment.Center
            TimeLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(TimeLabel)
            let widther = (screenBounds.width - 110) - (contentView.frame.height + 15)
            userLabel = UILabel(frame: CGRect(x: contentView.frame.height, y: 5, width: widther, height: 55))
            userLabel.textAlignment = NSTextAlignment.Left
            userLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(userLabel)
            AgeLabel = UILabel(frame: CGRect(x: contentView.frame.height, y: 55, width: widther, height: 55))
            AgeLabel.textAlignment = NSTextAlignment.Left
            AgeLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(AgeLabel)
        } else {
            CellImage = PFImageView(frame: CGRect(x: contentView.frame.minX + 2.5, y: contentView.frame.midY - ((contentView.frame.height/2 + 10)/2), width: contentView.frame.height/2 + 10, height: contentView.frame.height/2 + 10))
            CellImage.contentMode = .ScaleAspectFill
            contentView.addSubview(CellImage)
            FlossBadge = UIImageView(frame: CGRect(x: screenBounds.width - 115, y: 5, width: 55, height: 55))
            FlossBadge.contentMode = .ScaleAspectFit
            FlossBadge.backgroundColor = UIColor.clearColor()
            contentView.addSubview(FlossBadge)
            BrushBadge = UIImageView(frame: CGRect(x: screenBounds.width - 55, y: 5, width: 55, height: 55))
            BrushBadge.contentMode = .ScaleAspectFit
            BrushBadge.backgroundColor = UIColor.clearColor()
            contentView.addSubview(BrushBadge)
            TimeLabel = UILabel(frame: CGRect(x: screenBounds.width - 115, y: 70, width: 115, height: 35))
            TimeLabel.textAlignment = NSTextAlignment.Center
            TimeLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(TimeLabel)
            let widther = (screenBounds.width - 100) - ((contentView.frame.height/2) + 17.5)
            userLabel = UILabel(frame: CGRect(x: (contentView.frame.height/2) + 17.5, y: 5, width: widther, height: 55))
            userLabel.textAlignment = NSTextAlignment.Left
            userLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(userLabel)
            AgeLabel = UILabel(frame: CGRect(x: (contentView.frame.height/2) + 17.5, y: 70, width: widther, height: 35))
            AgeLabel.textAlignment = NSTextAlignment.Left
            AgeLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(AgeLabel)
        }
    }
    
    func setObject(object: PFObject) {
        CellImage.image = UIImage(named: "ProfileIcon")
        userLabel.attributedText = NSMutableAttributedString(string: "Loading..", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
        AgeLabel.attributedText = NSMutableAttributedString(string: "Age: 0", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 27.0)!])
        if object["User"] != nil {
            (object["User"] as! PFUser).settingUpCellCollection(self, objectPassed: object)
        }
        if object["brushTime"] != nil {
            let mSec = (object["brushTime"] as! CGFloat)
            switch mSec {
            case 0...45:
                BrushBadge.image = UIImage(named: "CavityMaker")!
            case 46...75:
                BrushBadge.image = UIImage(named: "sugarbugs")!
            case 76...105:
                BrushBadge.image = UIImage(named: "ToothProtector")!
            default:
                BrushBadge.image = UIImage(named: "ToothHero")!
            }
            TimeLabel.attributedText = NSMutableAttributedString(string: mSec.toMinSec(), attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
        } else {
            BrushBadge.image = nil
            TimeLabel.attributedText = NSMutableAttributedString(string: "00:00", attributes: [NSForegroundColorAttributeName : AppConfiguration.navText, NSFontAttributeName:UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!])
        }
        if object["Flosser"] != nil {
            let Floss = (object["Flosser"] as! Bool)
            if Floss == true {
                FlossBadge.image = UIImage(named: "flossicon")!
            } else {
                FlossBadge.image = nil
            }
        } else {
            FlossBadge.image = nil
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
        self.navigationItem.title = "Smiles Club"
        self.collectionView!.registerClass(SmilesCollectionViewCell.self, forCellWithReuseIdentifier: "smileCellReuse")
        refreshControl.tintColor = UIColor.wheatColor()
        collectionView!.addSubview(refreshControl)
        refreshControl.addTarget(self, action:#selector(self.forceFetchData), forControlEvents:.ValueChanged)
        
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            self.view.frame = CGRect(x: 0, y: 44, width: 414, height: 643)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            self.view.frame = CGRect(x: 0, y: 44, width: 375, height: 574)
        } else {
            self.view.frame = CGRect(x: 0, y: 44, width: 320, height: 475)
        }
        
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
                self.collectionView!.emptyDataSetSource = self
                self.collectionView!.emptyDataSetDelegate = self
                
            })
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        removeBack()
        addHamMenu()
        if defaults.boolForKey("SugarBugStatus") == true {
            if PFUser.currentUser() != nil {
                getMyProgress(PFUser.currentUser()!)
            }
            defaults.setBool(false, forKey: "SugarBugStatus")
        }
        if PFUser.currentUser() != nil {
            weekDates = getWeekDates()
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
        let object: PFObject = objectArray[indexPath.row]
        cell.setObject(object)
        if indexPath.row < colorsArray.count - 1 {
            cell.contentView.backgroundColor = UIColor.colorFromHexString(colorsArray[indexPath.row])
        } else {
            let color = indexPath.row % (colorsArray.count - 1)
            cell.contentView.backgroundColor = UIColor.colorFromHexString(colorsArray[color])
        }
        if (indexPath.row + 1) == (pageNumber * 20) {// == objectArray.count-1) {
            if (!refreshControl.refreshing) {
                ProgressHUD.show("Loading Smiles...", spincolor1:AppConfiguration.navColor.darkenedColor(0.3), backcolor1:UIColor(white: 1.0, alpha: 0.2) , textcolor1:AppConfiguration.navColor.darkenedColor(0.4))
            }
            self.fetchData()
        }
        return cell
    }
}

extension SmilesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(view.bounds), 120.0)
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

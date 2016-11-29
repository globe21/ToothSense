//
//  FriendsListViewController.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/28/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//


import Foundation
import UIKit
import UserNotifications
import UserNotificationsUI
import Parse
import ParseUI

var Followers: [PFUser] = [PFUser]()
var Following: [PFUser] = [PFUser]()
var SearchFollowers: [PFUser] = [PFUser]()


public protocol FriendCellDelegate: class {
    func friendCellDidLoad(cell: FollowCell)
}

class FriendListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ScrollPagerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UISearchBarDelegate, NavgationTransitionable {
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    var requestInProgress = false
    var forceRefresh = false
    var stopFetching = false
    var followpageNumber = 0
    var followingpageNumber = 0
    var appeared: Bool = false
    let refreshController = UIRefreshControl()
    
    @IBOutlet weak var FriendStack: UIStackView!
    @IBOutlet weak var friendSelect : ScrollPager!
    @IBOutlet weak var searchingBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var isLoading = false
    var followersCheck = false
    var searchActive = false
    
    var cellHeight: CGFloat = 80.0
    
    
    // MARK: - ScrollPagerDelegate -

    func scrollPager(scrollPager: ScrollPager, changedIndex: Int) {
        appeared = true
        switch changedIndex {
        case 0:
            followersCheck = false
            searchActive = false
            self.fetchData()
        case 1:
            followersCheck = true
            searchActive = false
            if Following.isEmpty {
                self.forceFetchData()
            } else {
                self.fetchData()
            }
        default: break
        }
    }
    
    
    func forceFetchData() {
        forceRefresh = true
        stopFetching = false
        if self.followersCheck == false {
            followpageNumber = 0
        } else {
            followingpageNumber = 0
        }
        self.fetchData()
    }
    
    func fetchData() {
        if (!requestInProgress && !stopFetching) {
            requestInProgress = true
            let followquery = PFQuery(className: "Follower")
            if followersCheck == false {
                followquery.whereKey("Follower", equalTo: PFUser.currentUser()!)
                followquery.orderByAscending("Following")
                followquery.skip = followpageNumber*20
            } else {
                followquery.whereKey("Following", equalTo: PFUser.currentUser()!)
                followquery.orderByAscending("Follower")
                followquery.skip = followingpageNumber*20
            }
            followquery.whereKey("Active", equalTo: true)
            followquery.limit = 20
            followquery.cachePolicy = .NetworkElseCache
            followquery.maxCacheAge = 60*60
            followquery.findObjectsInBackgroundWithBlock{
                followers, error in
                if error == nil {
                    if self.followersCheck == false {
                        if self.followpageNumber == 0 {
                            Followers.removeAll()
                        }
                    } else {
                        if self.followingpageNumber == 0 {
                            Following.removeAll()
                        }
                    }
                    
                    var array : [PFUser] = [PFUser]()//[follower] = [follower]()
                    if (self.forceRefresh) {
                        for follow in followers! {
                            if self.followersCheck == false {
                                array.append(follow["Following"] as! PFUser)
                            } else {
                                array.append(follow["Follower"] as! PFUser)
                            }
                        }
                    }
                    if self.followersCheck == false {
                        Followers.appendContentsOf(array)
                    } else {
                        Following.appendContentsOf(array)
                    }
                    self.tableView.reloadData()
                    self.refreshController.endRefreshing()
                    self.requestInProgress = false
                    self.forceRefresh = false
                    if (followers!.count<20) {
                        self.stopFetching = false
                    }
                    if self.followersCheck == false {
                        self.followpageNumber += 1
                    } else {
                        self.followingpageNumber += 1
                    }
                } else {
                    self.requestInProgress = false
                    self.forceRefresh = false
                    self.refreshController.endRefreshing()
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: false)
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let followquery = PFUser.query()
        followquery!.whereKey("fullname", hasPrefix: searchBar.text)
        followquery!.whereKey("fullname", notEqualTo: (PFUser.currentUser()?["fullname"])!)
        followquery!.limit = 999
        followquery!.findObjectsInBackgroundWithBlock({
            objects, error in
            if error == nil {
                SearchFollowers = objects! as! [PFUser]
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            } else if error != nil {
                ProgressHUD.showError("Cannot find users")
            }
        })
        searchBar.setShowsCancelButton(false, animated: false)
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: false)
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
        self.forceFetchData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let followquery = PFUser.query()
        followquery!.whereKey("fullname", hasPrefix: searchText)
        followquery!.whereKey("fullname", notEqualTo: PFUser.currentUser()!.fullname)
        followquery!.limit = 999
        followquery!.findObjectsInBackgroundWithBlock({
            objects, error in
            if error == nil {
                SearchFollowers = objects! as! [PFUser]
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            } else if error != nil {
                ProgressHUD.showError("Cannot find users")
            }
        })
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
    }
    
    override func viewWillAppear(animated: Bool) {
        addHamMenu()
        addBackButton()
        //removeBack()
    }
    
    override func viewDidAppear(animated: Bool) {
        appeared = false
        self.forceFetchData()
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Friends"
        self.friendSelect.delegate = self
        refreshController.tintColor = AppConfiguration.navText
        tableView.addSubview(refreshController)
        refreshController.addTarget(self, action:#selector(self.forceFetchData), forControlEvents:.ValueChanged)
        self.forceFetchData()
        
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            self.view.frame = CGRect(x: 0, y: 44, width: 414, height: 643)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            self.view.frame = CGRect(x: 0, y: 44, width: 375, height: 574)
        } else {
            self.view.frame = CGRect(x: 0, y: 44, width: 320, height: 475)
        }
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let resizer: UIImage = Images.resizeImage(UIImage(named: "Tooth")!, width: 150, height: 150)!
        return resizer
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont(name: "AmericanTypewriter", size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        if searchActive == true {
            return NSAttributedString(string: "No Search Results", attributes: attributes)
        } else if followersCheck == false {
            return NSAttributedString(string: "You are not following anyone yet. Send a friend request to get started.", attributes: attributes)
        }
        return NSAttributedString(string: "No Followers", attributes: attributes)
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive == true {
            return SearchFollowers.count
        } else if self.followersCheck == false {
            return Followers.count
        } else {
            return Following.count
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //cell.setupBadge("1")
        if cell is FollowCell {
            let cell = cell as! FollowCell
            cell.FollowerPic.center.y = cell.contentView.center.y
        }
        if searchActive != true { //&& appeared == true {
            if followersCheck == false {
                let moveRight = CASpringAnimation(keyPath: "transform.translation.x")
                moveRight.fromValue = -cell.contentView.frame.width
                moveRight.toValue = 0
                moveRight.duration = moveRight.settlingDuration
                moveRight.fillMode = kCAFillModeBackwards
                cell.contentView.layer.addAnimation(moveRight, forKey: nil)
            } else {
                let moveLeft = CASpringAnimation(keyPath: "transform.translation.x")
                moveLeft.fromValue = cell.contentView.frame.width
                moveLeft.toValue = 0
                moveLeft.duration = moveLeft.settlingDuration
                moveLeft.fillMode = kCAFillModeBackwards
                cell.contentView.layer.addAnimation(moveLeft, forKey: nil)
            }
        }
    }
    
    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let swipeCell: FollowCell = (tableView.cellForRowAtIndexPath(indexPath) as? FollowCell)!
        swipeCell.showSwipe(MGSwipeDirection.RightToLeft, animated: true) { (success: Bool) in
            //
        }
    }
    */
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let swipeCell: FollowCell = (tableView.dequeueReusableCellWithIdentifier("FollowCell") as? FollowCell)!
       /* let block: UIImage = UIImage(named:"minusicon")!
        let delete: MGSwipeButton = MGSwipeButton(title: "", icon: block, backgroundColor: UIColor.crimsonColor(), insets: UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5), callback: { (sender: MGSwipeTableCell!) -> Bool in
            
            return true
        })
        delete.buttonWidth = block.size.width * (cellHeight/block.size.height)
        delete.iconTintColor(AppConfiguration.navText)
        swipeCell.rightButtons = [delete]
        swipeCell.rightSwipeSettings.transition = MGSwipeTransition.Drag*/
        if self.searchActive == true {
            swipeCell.Follower = SearchFollowers[indexPath.row]
        } else {
            if followersCheck == false {
                swipeCell.Follower = Followers[indexPath.row]
            } else {
                swipeCell.Follower = Following[indexPath.row]
            }
        }
        return swipeCell
    }
    
    
    
}


extension UIView {
    func setupBadge(string: String) {
        var badgeAppearnce: BadgeAppearnce = BadgeAppearnce()
        badgeAppearnce.backgroundColor = UIColor.crimsonColor()
        badgeAppearnce.textColor = AppConfiguration.navText
        badgeAppearnce.textAlignment = .Center //default is center
        badgeAppearnce.textSize = 15 //default is 12
        self.badge(text: string,badgeEdgeInsets: UIEdgeInsetsMake(5, 0, 0, 5),appearnce: badgeAppearnce)
    }
}

public class FollowCell : UITableViewCell {
    @IBOutlet weak var FollowerPic: PFImageView!
    @IBOutlet weak var FollowerName: UILabel!
    @IBOutlet weak var FollowSubtitle: UILabel!
    
    @IBOutlet weak var FollowButton: UIButton!
    
    var stop = false
    
    
    var Follower: PFUser? {
        didSet {
            Follower!.settingUpCell(self)
        }
    }
    
    
    func showReportUser(user: PFUser) {
        let popVC = PopupReportTextViewController(nibName: "PopupReportTextViewController", bundle: nil)
        let popup = PopupDialog(viewController: popVC, transitionStyle: .BounceUp, buttonAlignment: .Horizontal, gestureDismissal: true)
        let buttonCancel = CancelButton(title: "CANCEL") { }
        let buttonTwo = DestructiveButton(title: "REPORT") {
            if popVC.reportTextView.text == nil {
                popVC.reportTextView.shake()
            } else {
                let text: String = popVC.reportTextView.text!
                let object: PFObject = PFObject(className: "BlockReport")
                object["User"] = user
                object["Description"] = text
                object.saveInBackgroundWithBlock({ (success, error) in
                    if error == nil {
                        let popup2 = PopupDialog(title: "Report Received", message: text, image: nil)
                        let buttonCancel = CancelButton(title: "OK") { }
                        popup2.addButtons([buttonCancel])
                        self.getParentViewController()!.presentViewController(popup2, animated: true, completion: nil)
                    } else {
                        let popup2 = PopupDialog(title: "Report Failed To Send!", message: error!.localizedDescription, image: nil)
                        let buttonCancel = CancelButton(title: "OK") { }
                        popup2.addButtons([buttonCancel])
                        self.getParentViewController()!.presentViewController(popup2, animated: true, completion: nil)
                    }
                })
            }
        }
        popup.addButtons([buttonCancel, buttonTwo])
        self.getParentViewController()!.presentViewController(popup, animated: true, completion: nil)
    }
    
    func addToFriends(otherUser: PFUser) {
        if PFUser.currentUser()!["Friends"] != nil {
            var friends: [PFUser] = PFUser.currentUser()!["Friends"] as! [PFUser]
            var friendIDs: [String] = [String]()
            friends.forEach({ (user) in
                friendIDs.append(user.objectId!)
            })
            if !friendIDs.contains(otherUser.objectId!) {
                friends.append(otherUser)
                PFUser.currentUser()!["Friends"] = friends
                PFUser.currentUser()!.saveInBackground()
            }
        } else {
            PFUser.currentUser()!["Friends"] = [otherUser]
            PFUser.currentUser()!.saveInBackground()
        }
    }
    
    func removeFromFriends(otherUser: PFUser) {
        if PFUser.currentUser()!["Friends"] != nil {
            var friends: [PFUser] = PFUser.currentUser()!["Friends"] as! [PFUser]
            var friendIDs: [String] = [String]()
            friends.forEach({ (user) in
                friendIDs.append(user.objectId!)
            })
            if !friendIDs.contains(otherUser.objectId!) {
                let index = friends.indexOf(otherUser)
                friends.removeAtIndex(index!)
                PFUser.currentUser()!["Friends"] = friends
                PFUser.currentUser()!.saveInBackground()
            }
        }
    }
    
    func removeFollow(otherUser: PFUser) {
        let query = PFQuery(className: "Follower")
        query.whereKey("Follower", equalTo: PFUser.currentUser()!)
        query.whereKey("Following", equalTo: otherUser)
        query.findObjectsInBackgroundWithBlock{
            objects, error in
            if error == nil {
                /*let myfollowers = (PFUser.currentUser()?["Followers"] as? Int)!
                let otherfollowers = (otherUser["Followers"] as? Int)!
                if myfollowers >= 1 {
                    PFUser.currentUser()?.incrementKey("Following", byAmount: -1)
                    PFUser.currentUser()?.saveInBackground()
                }
                if otherfollowers >= 1 {
                    otherUser.incrementKey("Followers", byAmount: -1)
                    otherUser.saveInBackground()
                }*/
                for object in objects! {
                    object["Active"] = false
                    object["Accepted"] = false
                    object.saveInBackground()
                    self.removeFromFriends(otherUser)
                }
            }
        }
    }
    
    func createFollow(otherUser: PFUser) {
        let query = PFQuery(className: "Follower")
        query.whereKey("Follower", equalTo: PFUser.currentUser()!)
        query.whereKey("Following", equalTo: otherUser)
        query.findObjectsInBackgroundWithBlock{
            objects, error in
            if error == nil {
                if objects?.count == 0 {
                    let friend = PFObject(className: "Follower")
                    friend.setObject(PFUser.currentUser()!, forKey: "Follower")
                    friend.setObject(otherUser, forKey: "Following")
                    friend.setObject(true, forKey: "Active")
                    friend.setObject(false, forKey: "Accepted")
                    friend.saveInBackground()
                    self.addToFriends(otherUser)
                    //if PFUser.currentUser()
                    Followers.append(otherUser)//friend)
                    let push = PFPush()
                    let data = [
                        "alert" : "\((PFUser.currentUser()?["fullname"])! as! String) wants to follow you.",
                        "badge" : "Increment",
                        "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                        "type" : "sendFollow"]
                    let installQuery = PFInstallation.query()
                    installQuery?.whereKey("User", equalTo: otherUser)
                    push.setQuery(installQuery)
                    push.setData(data)
                    push.sendPushInBackground()
                } else if objects!.count == 1 {
                    let object = objects?.first
                    object!["Active"] = true
                    object!["Accepted"] = true
                    object!.saveInBackground()
                    self.addToFriends(otherUser)
                    let push = PFPush()
                    let data = [
                        "alert" : "\((PFUser.currentUser()?["fullname"])! as! String) wants to follow you.",
                        "badge" : "Increment",
                        "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                        "type" : "sendFollow"]
                    let installQuery = PFInstallation.query()
                    installQuery?.whereKey("User", equalTo: otherUser)
                    push.setQuery(installQuery)
                    push.setData(data)
                    push.sendPushInBackground()
                }
            } else {
                let friend = PFObject(className: "Follower")
                friend.setObject(PFUser.currentUser()!, forKey: "Follower")
                friend.setObject(otherUser, forKey: "Following")
                friend.setObject(true, forKey: "Active")
                friend.setObject(false, forKey: "Accepted")
                friend.saveInBackground()
                self.addToFriends(otherUser)
                Followers.append(otherUser)//friend)//follow)
                let push = PFPush()
                let data = [
                    "alert" : "\((PFUser.currentUser()?["fullname"])! as! String) wants to follow you.",
                    "badge" : "Increment",
                    "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                    "type" : "sendFollow"]
                let installQuery = PFInstallation.query()
                installQuery?.whereKey("User", equalTo: otherUser)
                push.setQuery(installQuery)
                push.setData(data)
                push.sendPushInBackground()
            }
        }
    }
 
    @IBAction func TappedFollow(sender: UIButton) {
        if sender.selected == false {
            sender.selected = true
            FollowButton.tintColor = UIColor(hex: "d9272d")
            createFollow(Follower!)
        } else {
            sender.selected = false
            FollowButton.tintColor = UIColor.whiteColor()
            removeFollow(Follower!)
        }
    }
}

//
//  NSBadge.swift
//
//  Created by Antonio Zaitoun on 8/10/16.
//  Copyright © 2016 Crofis. All rights reserved.
//


import UIKit

extension UIView {
    
    /*
     * Assign badge with only text.
     */
    
    
    /// - parameter text: The badge value, use nil to remove exsiting badge.
    public func badge(text badgeText: String!) {
        badge(text: badgeText,appearnce: BadgeAppearnce())
    }
    
    /// - parameter text: The badge value, use nil to remove exsiting badge.
    /// - parameter appearnce: The appearance of the badge.
    public func badge(text badgeText: String!, appearnce:BadgeAppearnce){
        badge(text: badgeText, badgeEdgeInsets: nil,appearnce: appearnce)
    }
    
    /*
     * Assign badge with text and edge insets.
     */
    
    //@available(*, deprecated, message: "Use badge(text: String!, appearnce:BadgeAppearnce)")
    public func badge(text badgeText:String!,badgeEdgeInsets:UIEdgeInsets){
        badge(text: badgeText, badgeEdgeInsets: badgeEdgeInsets, appearnce: BadgeAppearnce())
    }
    
    /*
     * Assign badge with text,insets, and appearnce.
     */
    public func badge(text badgeText:String!,badgeEdgeInsets:UIEdgeInsets?,appearnce:BadgeAppearnce) {
        
        //Create badge label
        var badgeLabel:BadgeLabel!
        
        var doesBadgeExist = false
        
        //Find badge in subviews if exists
        for view in self.subviews {
            if view.tag == 1 && view is BadgeLabel{
                badgeLabel = view as! BadgeLabel
            }
        }
        
        //If assigned text is nil (request to remove badge) and badge label is not nil:
        if badgeText == nil && !(badgeLabel == nil){
            
            if appearnce.animate{
                UIView.animateWithDuration(appearnce.duration, animations: {
                    badgeLabel.alpha = 0.0
                    badgeLabel.transform = CGAffineTransformMakeScale(0.1,0.1)
                    
                    }, completion: { (Bool) in
                        
                        badgeLabel.removeFromSuperview()
                })
            }else{
                badgeLabel.removeFromSuperview()
            }
            return
        }else if badgeText == nil && badgeLabel == nil {
            return
        }
        
        //Badge label is nil (There was no previous badge)
        if (badgeLabel == nil){
            
            //init badge label variable
            badgeLabel = BadgeLabel()
            
            //assign tag to badge label
            badgeLabel.tag = 1
        }else{
            doesBadgeExist = true
        }
        
        //Clip to bounds
        badgeLabel.clipsToBounds = true
        
        //Set the text on the badge label
        badgeLabel.text = badgeText
        
        //Set font size
        badgeLabel.font = UIFont(name: "AmericanTypewriter", size: appearnce.textSize)!
        
        badgeLabel.sizeToFit()
        
        //set the allignment
        badgeLabel.textAlignment = appearnce.textAlignment
        
        //set background color
        badgeLabel.backgroundColor = appearnce.backgroundColor
        
        //set text color
        badgeLabel.textColor = appearnce.textColor
        
        //get current badge size
        let badgeSize = badgeLabel.frame.size
        
        //calculate width and height with minimum height and width of 20
        let height = max(18, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        
        badgeLabel.frame.size = CGSize(width: width, height: height)
        
        
        //add to subview
        
        if doesBadgeExist {
            //remove view to delete constraints
            badgeLabel.removeFromSuperview()
        }
        addSubview(badgeLabel)
        
        //The distance from the center of the view (vertically)
        let centerY = appearnce.distenceFromCenterY == 0 ? -(bounds.size.height / 2) : appearnce.distenceFromCenterY
        
        //The distance from the center of the view (horizontally)
        let centerX = appearnce.distenceFromCenterX == 0 ? (bounds.size.width / 2) : appearnce.distenceFromCenterX
        
        //disable auto resizing mask
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //add height constraint
        self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: CGFloat(height)))
        
        //add width constraint
        self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: CGFloat(width)))
        
        //add vertical constraint
        self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: centerX))
        
        //add horizontal constraint
        self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: centerY))
        
        
        //corner radius
        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height / 2
        
        //badge does not exist, meaning we are adding a new one
        if !doesBadgeExist {
            
            //should it animate?
            if appearnce.animate {
                UIView.animateWithDuration(appearnce.duration/2, animations: { () -> Void in
                    badgeLabel.transform = CGAffineTransformMakeScale(0,0)
                }) { (finished: Bool) -> Void in
                    UIView.animateWithDuration(appearnce.duration/2, animations: { () -> Void in
                        badgeLabel.transform = CGAffineTransformIdentity
                    })}
            }
        }
    }
    
}


extension UIBarButtonItem {
    
    /*
     * Assign badge with only text.
     */
    public func badge(text badgeText: String!) {
        getView().badge(text: badgeText ,appearnce: BadgeAppearnce())
    }
    
    
    public func badge(text badgeText: String!, appearnce:BadgeAppearnce){
        getView().badge(text: badgeText, appearnce: appearnce)
    }
    
    /*
     * Assign badge with text and edge insets.
     */
    //@available(*,deprecated, message: "Use badge(text: String!, appearnce:BadgeAppearnce)")
    public func badge(text badgeText:String!,badgeEdgeInsets:UIEdgeInsets){
        getView().badge(text: badgeText, badgeEdgeInsets: badgeEdgeInsets, appearnce: BadgeAppearnce())
    }
    
    /*
     * Assign badge with text,insets, and appearnce.
     */
    //@available(*,deprecated, message: "Use badge(text: String!, appearnce:BadgeAppearnce)")
    public func badge(text badgeText:String!,badgeEdgeInsets:UIEdgeInsets!,appearnce:BadgeAppearnce){
        getView().badge(text: badgeText, badgeEdgeInsets: badgeEdgeInsets, appearnce: appearnce)
    }
    
    private func getView()->UIView{
        return valueForKey("view") as! UIView
    }
    
}


/*
 * BadgeLabel - This class is made to avoid confusion with other subviews that might be of type UILabel.
 */
class BadgeLabel:UILabel{}

/*
 * BadgeAppearnce - This struct is used to design the badge.
 */
public struct BadgeAppearnce {
    var textSize:CGFloat = 12
    var textAlignment:NSTextAlignment = .Center
    var backgroundColor = UIColor.crimsonColor()
    var textColor = AppConfiguration.navText
    var animate = true
    var duration = 0.2
    var distenceFromCenterY:CGFloat = 0
    var distenceFromCenterX:CGFloat = 0
    
}


//  RAMFumeAnimation.swift
//
// Copyright (c) 12/2/14 Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public extension UIView {
    
    public func rippleBorder(location:CGPoint, color:UIColor) {
        rippleBorder(location, color: color){}
    }
    
    public func rippleBorder(location:CGPoint, color:UIColor, then: ()->() ) {
        Ripple.border(self, locationInView: location, color: color, then: then)
    }
    
    public func rippleFill(location:CGPoint, color:UIColor) {
        rippleFill(location, color: color){}
    }
    
    public func rippleFill(location:CGPoint, color:UIColor, then: ()->() ) {
        Ripple.fill(self, locationInView: location, color: color, then: then)
    }
    
    public func rippleStop() {
        Ripple.stop(self)
    }
    
}

public class Ripple {
    
    private static var targetLayer: CALayer?
    
    public struct Option {
        public var borderWidth = CGFloat(5.0)
        public var radius = CGFloat(30.0)
        public var duration = CFTimeInterval(0.4)
        public var borderColor = UIColor.whiteColor()
        public var fillColor = UIColor.clearColor()
        public var scale = CGFloat(3.0)
        public var isRunSuperView = true
    }
    
    public class func option () -> Option {
        return Option()
    }
    
    public class func run(view:UIView, locationInView:CGPoint, option:Ripple.Option) {
        run(view, locationInView: locationInView, option: option){}
    }
    
    public class func run(view:UIView, locationInView:CGPoint, option:Ripple.Option, then: ()->() ) {
        prePreform(view, point: locationInView, option: option, isLocationInView: true, then: then)
    }
    
    public class func run(view:UIView, absolutePosition:CGPoint, option:Ripple.Option) {
        run(view, absolutePosition: absolutePosition, option: option){}
    }
    
    public class func run(view:UIView, absolutePosition:CGPoint, option:Ripple.Option, then: ()->() ) {
        prePreform(view, point: absolutePosition, option: option, isLocationInView: false, then: then)
    }
    
    public class func border(view:UIView, locationInView:CGPoint, color:UIColor) {
        border(view, locationInView: locationInView, color: color){}
    }
    
    public class func border(view:UIView, locationInView:CGPoint, color:UIColor, then: ()->() ) {
        var opt = Ripple.Option()
        opt.borderColor = color
        prePreform(view, point: locationInView, option: opt, isLocationInView: true, then: then)
    }
    
    public class func border(view:UIView, absolutePosition:CGPoint, color:UIColor) {
        border(view, absolutePosition: absolutePosition, color: color){}
    }
    
    public class func border(view:UIView, absolutePosition:CGPoint, color:UIColor, then: ()->() ) {
        var opt = Ripple.Option()
        opt.borderColor = color
        prePreform(view, point: absolutePosition, option: opt, isLocationInView: false, then: then)
    }
    
    public class func fill(view:UIView, locationInView:CGPoint, color:UIColor) {
        fill(view, locationInView: locationInView, color: color){}
    }
    
    public class func fill(view:UIView, locationInView:CGPoint, color:UIColor, then: ()->() ) {
        var opt = Ripple.Option()
        opt.borderColor = color
        opt.fillColor = color
        prePreform(view, point: locationInView, option: opt, isLocationInView: true, then: then)
    }
    
    public class func fill(view:UIView, absolutePosition:CGPoint, color:UIColor) {
        fill(view, absolutePosition: absolutePosition, color: color){}
    }
    
    public class func fill(view:UIView, absolutePosition:CGPoint, color:UIColor, then: ()->() ) {
        var opt = Ripple.Option()
        opt.borderColor = color
        opt.fillColor = color
        prePreform(view, point: absolutePosition, option: opt, isLocationInView: false, then: then)
    }
    
    private class func prePreform(view:UIView, point:CGPoint, option: Ripple.Option, isLocationInView:Bool, then: ()->() ) {
        
        let p = isLocationInView ? CGPointMake(point.x + view.frame.origin.x, point.y + view.frame.origin.y) : point
        if option.isRunSuperView, let superview = view.superview {
            prePreform(
                superview,
                point: p,
                option: option,
                isLocationInView: isLocationInView,
                then: then
            )
        } else {
            perform(
                view,
                point:p,
                option:option,
                then: then
            )
        }
    }
    
    private class func perform(view:UIView, point:CGPoint, option: Ripple.Option, then: ()->() ) {
        UIGraphicsBeginImageContextWithOptions (
            CGSizeMake((option.radius + option.borderWidth) * 2, (option.radius + option.borderWidth) * 2), false, 3.0)
        let path = UIBezierPath(
            roundedRect: CGRectMake(option.borderWidth, option.borderWidth, option.radius * 2, option.radius * 2),
            cornerRadius: option.radius)
        option.fillColor.setFill()
        path.fill()
        option.borderColor.setStroke()
        path.lineWidth = option.borderWidth
        path.stroke()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.autoreverses = false
        opacity.fillMode = kCAFillModeForwards
        opacity.removedOnCompletion = false
        opacity.duration = option.duration
        opacity.fromValue = 1.0
        opacity.toValue = 0.0
        
        let transform = CABasicAnimation(keyPath: "transform")
        transform.autoreverses = false
        transform.fillMode = kCAFillModeForwards
        transform.removedOnCompletion = false
        transform.duration = option.duration
        transform.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(1.0 / option.scale, 1.0 / option.scale, 1.0))
        transform.toValue = NSValue(CATransform3D: CATransform3DMakeScale(option.scale, option.scale, 1.0))
        
        var rippleLayer:CALayer? = targetLayer
        
        if rippleLayer == nil {
            rippleLayer = CALayer()
            view.layer.addSublayer(rippleLayer!)
            targetLayer = rippleLayer
            targetLayer?.addSublayer(CALayer())//Temporary, CALayer.sublayers is Implicitly Unwrapped Optional
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            [weak rippleLayer] in
            if let target = rippleLayer {
                let layer = CALayer()
                layer.contents = img!.CGImage
                layer.frame = CGRectMake(point.x - option.radius, point.y - option.radius, option.radius * 2, option.radius * 2)
                target.addSublayer(layer)
                CATransaction.begin()
                CATransaction.setAnimationDuration(option.duration)
                CATransaction.setCompletionBlock {
                    layer.contents = nil
                    layer.removeAllAnimations()
                    layer.removeFromSuperlayer()
                    then()
                }
                layer.addAnimation(opacity, forKey:nil)
                layer.addAnimation(transform, forKey:nil)
                CATransaction.commit()
            }
        }
    }
    
    public class func stop(view:UIView) {
        
        guard let sublayers = targetLayer?.sublayers else {
            return
        }
        
        for layer in sublayers {
            layer.removeAllAnimations()
        }
    }
    
}

/// The RAMFumeAnimation class provides bounce animation.
public class RAMFumeAnimation : RAMItemAnimation {
  
    
    
  /**
   Start animation, method call when UITabBarItem is selected
   
   - parameter icon:      animating UITabBarItem icon
   - parameter textLabel: animating UITabBarItem textLabel
   */
  override public func playAnimation(icon : UIImageView, textLabel : UILabel) {
    
    
    let bounceAnimation = CAKeyframeAnimation(keyPath: Constants.AnimationKeys.Scale)
    bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
    bounceAnimation.duration = NSTimeInterval(self.duration)
    bounceAnimation.calculationMode = kCAAnimationCubic
    icon.layer.addAnimation(bounceAnimation, forKey: nil)
    var option = Ripple.option()
    option.borderWidth = CGFloat(2.0)
    //print("\(icon.frame.width*0.6)")
    option.radius = CGFloat(15.0)
    option.duration = CFTimeInterval(self.duration)
    option.borderColor = AppConfiguration.navColor.lightenedColor(0.5)
    option.fillColor = UIColor.clearColor()
    option.scale = CGFloat(3.0)
    
    textLabel.textColor = self.textSelectedColor
    if let iconImage = icon.image {
        let renderImage = iconImage.imageWithRenderingMode(.AlwaysTemplate)
        icon.image = renderImage
        icon.tintColor = self.iconSelectedColor
    }

    Ripple.run(icon, locationInView: CGPoint(x: icon.frame.width/2 , y: icon.frame.height/2), option: option){
        self.playMoveIconAnimation(icon, values:[icon.center.y, icon.center.y + 4.0])
        self.playLabelAnimation(textLabel)
    }
    
    
  }
  /**
   Start animation, method call when UITabBarItem is unselected
   
   - parameter icon:      animating UITabBarItem icon
   - parameter textLabel: animating UITabBarItem textLabel
   - parameter defaultTextColor: default UITabBarItem text color
   - parameter defaultIconColor: default UITabBarItem icon color
   */
  override public func deselectAnimation(icon : UIImageView, textLabel : UILabel, defaultTextColor : UIColor, defaultIconColor : UIColor) {
    playMoveIconAnimation(icon, values:[icon.center.y + 4.0, icon.center.y])
    playDeselectLabelAnimation(textLabel)
    textLabel.textColor = defaultTextColor
    
    if let iconImage = icon.image {
        let renderMode = CGColorGetAlpha(defaultIconColor.CGColor) == 0 ? UIImageRenderingMode.AlwaysOriginal :
            UIImageRenderingMode.AlwaysTemplate
        let renderImage = iconImage.imageWithRenderingMode(renderMode)
        icon.image = renderImage
        icon.tintColor = defaultIconColor
    }
    /*
    let bounceAnimation = CAKeyframeAnimation(keyPath: Constants.AnimationKeys.Scale)
    bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
    bounceAnimation.duration = NSTimeInterval(self.duration)
    bounceAnimation.calculationMode = kCAAnimationCubic
    icon.layer.addAnimation(bounceAnimation, forKey: nil)
    var option = Ripple.option()
    option.borderWidth = CGFloat(5.0)
    option.radius = CGFloat(30.0)
    option.duration = CFTimeInterval(self.duration)
    option.borderColor = UIColor.orangeColor()
    option.fillColor = UIColor.clearColor()
    option.scale = CGFloat(3.0)
    
    Ripple.run(icon, locationInView: CGPointZero, option: option){
        
    }*/
  }
  
  /**
   Method call when TabBarController did load
   
   - parameter icon:      animating UITabBarItem icon
   - parameter textLabel: animating UITabBarItem textLabel
   */
  override public func selectedState(icon : UIImageView, textLabel : UILabel) {
    
    playMoveIconAnimation(icon, values:[icon.center.y + 12.0])
    textLabel.alpha = 0
    textLabel.textColor = textSelectedColor
    
    if let iconImage = icon.image {
      let renderImage = iconImage.imageWithRenderingMode(.AlwaysTemplate)
      icon.image = renderImage
      icon.tintColor = textSelectedColor
    }
  }
    
  
  
  func playMoveIconAnimation(icon : UIImageView, values: [AnyObject]) {
    
    let yPositionAnimation = createAnimation(Constants.AnimationKeys.PositionY, values:values, duration:duration / 2)
    icon.layer.addAnimation(yPositionAnimation, forKey: nil)
   /*
    var option = Ripple.option()
    option.borderWidth = CGFloat(5.0)
    option.radius = CGFloat(30.0)
    option.duration = CFTimeInterval(0.4)
    option.borderColor = UIColor.whiteColor()
    option.fillColor = UIColor.clearColor()
    option.scale = CGFloat(3.0)
    
    Ripple.run(icon, locationInView: CGPointZero, option: option){
        /*
         */
    }

    */
   // icon.rippleFill(icon.center, color: UIColor.redColor())
    
    
  }
  
  // MARK: select animation
  
  func playLabelAnimation(textLabel: UILabel) {
    
    let yPositionAnimation = createAnimation(Constants.AnimationKeys.PositionY, values:[textLabel.center.y, textLabel.center.y - 60.0], duration:duration)
    yPositionAnimation.fillMode = kCAFillModeRemoved
    yPositionAnimation.removedOnCompletion = true
    textLabel.layer.addAnimation(yPositionAnimation, forKey: nil)
    
    let scaleAnimation = createAnimation(Constants.AnimationKeys.Scale, values:[1.0 ,2.0], duration:duration)
    scaleAnimation.fillMode = kCAFillModeRemoved
    scaleAnimation.removedOnCompletion = true
    textLabel.layer.addAnimation(scaleAnimation, forKey: nil)
    
    let opacityAnimation = createAnimation(Constants.AnimationKeys.Opacity, values:[1.0 ,0.0], duration:duration)
    textLabel.layer.addAnimation(opacityAnimation, forKey: nil)
  }
  
  func createAnimation(keyPath: String, values: [AnyObject], duration: CGFloat)->CAKeyframeAnimation {
    
    let animation = CAKeyframeAnimation(keyPath: keyPath)
    animation.values = values
    animation.duration = NSTimeInterval(duration)
    animation.calculationMode = kCAAnimationCubic
    animation.fillMode = kCAFillModeForwards
    animation.removedOnCompletion = false
    return animation
  }
  
  // MARK: deselect animation
  
  func playDeselectLabelAnimation(textLabel: UILabel) {
    
    let yPositionAnimation = createAnimation(Constants.AnimationKeys.PositionY, values:[textLabel.center.y + 15, textLabel.center.y], duration:duration)
    textLabel.layer.addAnimation(yPositionAnimation, forKey: nil)
    
    let opacityAnimation = createAnimation(Constants.AnimationKeys.Opacity, values:[0, 1], duration:duration)
    textLabel.layer.addAnimation(opacityAnimation, forKey: nil)
  }
}

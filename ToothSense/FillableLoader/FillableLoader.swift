//
//  FillableLoader.swift
//  PQFFillableLoaders
//
//  Created by Pol Quintana on 25/7/15.
//  Copyright (c) 2015 Pol Quintana. All rights reserved.
//

import UIKit


extension CGFloat {
    func toMinSec() -> String {
        let min: Int = Int(self / 60)
        let sec: Int = Int(self) - Int(min * 60)
        if sec < 10 {
            return "\(min):0\(sec)"
        }
        return "\(min):\(sec)"
    }
    
    func toMinSecLong() -> String {
        let min: Int = Int(self / 60)
        let sec: Int = Int(self) - Int(min * 60)
        if sec < 10 {
            return "Minutes: \(min), Seconds: 0\(sec)"
        }
        return "Minutes: \(min), Seconds: \(sec)"
    }
}

var loader: FillableLoader = FillableLoader()


public class FillableLoader: UIView, CAAnimationDelegate {
    internal var shapeLayer = CAShapeLayer()
    internal var strokeLayer = CAShapeLayer()
    internal var path: CGPath!
    internal var loaderView = UIView()
    internal var animate: Bool = false
    internal var extraHeight: CGFloat = 0
    internal var oldYPoint: CGFloat = 0
    //internal let mainBgColor = UIColor(white: 0.8, alpha: 0.6)
    internal weak var loaderSuperview: UIView?
    
    // MARK: Public Variables
    
    /// Duration of the animation (Default:  10.0)
    public var duration: NSTimeInterval = 10.0
    
    /// Loader background height (Default:  ScreenHeight/6 + 30)
    public var rectSize: CGFloat = UIScreen.mainScreen().bounds.height/2// + 30
    
    /// A Boolean value that determines whether the loader should have a swing effect while going up (Default: true)
    public var swing: Bool = true
    
    /// A Boolean value that determines whether the loader movement is progress based or not (Default: false)
    public var progressBased: Bool = false
    
    public var average: CGFloat = 0
    
    // MARK: Custom Getters and Setters
    
    internal var _backgroundColor: UIColor?
    internal var _loaderColor: UIColor?
    internal var _loaderBackgroundColor: UIColor?
    internal var _loaderStrokeColor: UIColor?
    internal var _loaderStrokeWidth: CGFloat = 0.5
    internal var _loaderAlpha: CGFloat = 1.0
    internal var _cornerRadius: CGFloat = 0.0
    internal var _progress: CGFloat = 0.0
    
    public func ToothPath() -> CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 468.3, y: 109.64))
        bezierPath.addCurveToPoint(CGPoint(x: 383.3, y: 17.48), controlPoint1: CGPoint(x: 458.23, y: 66.19), controlPoint2: CGPoint(x: 428.86, y: 34.35))
        bezierPath.addCurveToPoint(CGPoint(x: 246.47, y: 34.26), controlPoint1: CGPoint(x: 352.94, y: 6.27), controlPoint2: CGPoint(x: 279.02, y: -3.99))
        bezierPath.addCurveToPoint(CGPoint(x: 49.03, y: 45.92), controlPoint1: CGPoint(x: 141.55, y: -27.91), controlPoint2: CGPoint(x: 86.23, y: 5.96))
        bezierPath.addCurveToPoint(CGPoint(x: 39.59, y: 261.56), controlPoint1: CGPoint(x: -33.09, y: 134.13), controlPoint2: CGPoint(x: 4.48, y: 222.98))
        bezierPath.addCurveToPoint(CGPoint(x: 76.43, y: 324.11), controlPoint1: CGPoint(x: 64.97, y: 289.5), controlPoint2: CGPoint(x: 72.31, y: 305.66))
        bezierPath.addCurveToPoint(CGPoint(x: 79.55, y: 342.73), controlPoint1: CGPoint(x: 77.35, y: 328.17), controlPoint2: CGPoint(x: 79.44, y: 340.16))
        bezierPath.addCurveToPoint(CGPoint(x: 150.95, y: 510.47), controlPoint1: CGPoint(x: 86.04, y: 496.38), controlPoint2: CGPoint(x: 138.43, y: 509.54))
        bezierPath.addCurveToPoint(CGPoint(x: 161.68, y: 512), controlPoint1: CGPoint(x: 154.61, y: 511.52), controlPoint2: CGPoint(x: 158.2, y: 512))
        bezierPath.addCurveToPoint(CGPoint(x: 179.6, y: 506.94), controlPoint1: CGPoint(x: 168.07, y: 512), controlPoint2: CGPoint(x: 174.12, y: 510.3))
        bezierPath.addCurveToPoint(CGPoint(x: 220.69, y: 397.63), controlPoint1: CGPoint(x: 205.63, y: 490.99), controlPoint2: CGPoint(x: 213.64, y: 441.34))
        bezierPath.addCurveToPoint(CGPoint(x: 228.44, y: 358.19), controlPoint1: CGPoint(x: 223.26, y: 381.81), controlPoint2: CGPoint(x: 225.65, y: 366.87))
        bezierPath.addCurveToPoint(CGPoint(x: 237.26, y: 339.19), controlPoint1: CGPoint(x: 233.29, y: 343.14), controlPoint2: CGPoint(x: 237.3, y: 339.71))
        bezierPath.addCurveToPoint(CGPoint(x: 247.29, y: 356.44), controlPoint1: CGPoint(x: 240.75, y: 340.75), controlPoint2: CGPoint(x: 246.64, y: 352))
        bezierPath.addCurveToPoint(CGPoint(x: 249.73, y: 381.26), controlPoint1: CGPoint(x: 248.26, y: 363.06), controlPoint2: CGPoint(x: 248.95, y: 371.65))
        bezierPath.addCurveToPoint(CGPoint(x: 312.23, y: 510.43), controlPoint1: CGPoint(x: 253.75, y: 430.61), controlPoint2: CGPoint(x: 259.74, y: 505.04))
        bezierPath.addCurveToPoint(CGPoint(x: 335.69, y: 505.48), controlPoint1: CGPoint(x: 315.95, y: 511.23), controlPoint2: CGPoint(x: 324.81, y: 512.05))
        bezierPath.addCurveToPoint(CGPoint(x: 390.09, y: 377.6), controlPoint1: CGPoint(x: 360.43, y: 490.46), controlPoint2: CGPoint(x: 378.75, y: 447.44))
        bezierPath.addLineToPoint(CGPoint(x: 391.79, y: 366.43))
        bezierPath.addCurveToPoint(CGPoint(x: 424.65, y: 275.75), controlPoint1: CGPoint(x: 395.87, y: 338.43), controlPoint2: CGPoint(x: 401.53, y: 300.06))
        bezierPath.addCurveToPoint(CGPoint(x: 468.3, y: 109.64), controlPoint1: CGPoint(x: 451.37, y: 247.85), controlPoint2: CGPoint(x: 483.62, y: 175.7))
        bezierPath.closePath()
        bezierPath.miterLimit = 4
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            bezierPath.applyTransform(CGAffineTransformMakeScale(0.7, 0.7))
            fillfont = UIFont(name: "AmericanTypewriter-Bold", size: 45)!
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            bezierPath.applyTransform(CGAffineTransformMakeScale(0.6, 0.6))
            fillfont = UIFont(name: "AmericanTypewriter-Bold", size: 35)!
        } else {
            bezierPath.applyTransform(CGAffineTransformMakeScale(0.45, 0.45))
            fillfont = UIFont(name: "AmericanTypewriter-Bold", size: 25)!
        }
        return bezierPath.CGPath
    }
    
    /// Loader view background color (Default: Clear)
    override public var backgroundColor: UIColor? {
        get { return _backgroundColor }
        set {
            //super.backgroundColor = mainBgColor
            _backgroundColor = newValue
            loaderView.backgroundColor = newValue
            loaderView.layer.backgroundColor = newValue?.CGColor
        }
    }
    
    /// Filled loader color (Default: Blue)
    public var loaderColor: UIColor? {
        get { return _loaderColor }
        set {
            _loaderColor = newValue
            shapeLayer.fillColor = newValue?.CGColor
        }
    }
    
    /// Unfilled loader color (Default: White)
    public var loaderBackgroundColor: UIColor? {
        get { return _loaderBackgroundColor }
        set {
            _loaderBackgroundColor = newValue
            strokeLayer.fillColor = newValue?.CGColor
        }
    }
    
    /// Loader outline line color (Default: Black)
    public var loaderStrokeColor: UIColor? {
        get { return _loaderStrokeColor }
        set {
            _loaderStrokeColor = newValue
            strokeLayer.strokeColor = newValue?.CGColor
        }
    }
    
    /// Loader outline line width (Default: 0.5)
    public var loaderStrokeWidth: CGFloat {
        get { return _loaderStrokeWidth }
        set {
            _loaderStrokeWidth = newValue
            strokeLayer.lineWidth = newValue
        }
    }
    
    /// Loader view alpha (Default: 1.0)
    public var loaderAlpha: CGFloat {
        get { return _loaderAlpha }
        set {
            _loaderAlpha = newValue
            loaderView.alpha = newValue
        }
    }
    
    /// Loader view corner radius (Default: 0.0)
    override public var cornerRadius: CGFloat {
        get { return _cornerRadius }
        set {
            _cornerRadius = newValue
            loaderView.layer.cornerRadius = newValue
        }
    }

    /// Loader fill progress from 0.0 to 1.0 . It will automatically fire an animation to update the loader fill progress (Default: 0.0)
    public var progress: CGFloat {
        get { return _progress }
        set {
            if (!progressBased || newValue > 1.0 || newValue < 0.0) { return }
            _progress = newValue
            applyProgress()
            loaderLabel4.attributedText = NSAttributedString(string: "Average: \(average.toMinSec())", attributes: [NSForegroundColorAttributeName : fillfontColor, NSFontAttributeName : fillfont] as [String : AnyObject])
            //self.addSubview(loaderLabel4)
        }
    }
    
    
    // MARK: Initializers Methods

    /**
    Creates and SHOWS a loader with the given path
    
    :param: path Loader CGPath
    
    :returns: The loader that's already being showed
    */
    public static func showLoaderWithPath(path: CGPath, onView: UIView? = nil) -> Self {
        let loader = createLoaderWithPath(path: path, onView: onView)
        loader.showLoader()
        return loader
    }
    /**
    Creates and SHOWS a progress based loader with the given path
    
    :param: path Loader CGPath
    
    :returns: The loader that's already being showed
    */
    public static func showProgressBasedLoaderWithPath(path: CGPath, onView: UIView? = nil) -> Self {
    let loader = createProgressBasedLoaderWithPath(path: path, onView: onView)
        loader.showLoader()
        return loader
    }
    
    /**
    Creates a loader with the given path
    
    :param: path Loader CGPath
    
    :returns: The created loader
    */
    public static func createLoaderWithPath(path thePath: CGPath, onView: UIView? = nil) -> Self {
        let loader = self.init()
        loader.initialSetup(onView)
        loader.addPath(thePath)
        return loader
    }
    
    /**
    Creates a progress based loader with the given path
    
    :param: path Loader CGPath
    
    :returns: The created loader
    */
    public static func createProgressBasedLoaderWithPath(path thePath: CGPath, onView: UIView? = nil) -> Self {
        let loader = self.init()
        loader.progressBased = true
        loader.initialSetup(onView)
        loader.addPath(thePath)
        return loader
    }
    
    internal func initialSetup(view: UIView? = nil) {
        //Setting up frame
        var window = view
        if view == nil, let mainWindow = UIApplication.sharedApplication().delegate?.window {
            window = mainWindow
        }
        guard let w = window else { return }
        self.frame = w.frame
        self.center = CGPointMake(CGRectGetMidX(w.bounds), CGRectGetMidY(w.bounds))
        w.addSubview(self)
        loaderSuperview = w
        
        /*
         self.frame = screenBounds.offsetBy(dx: 0, dy: screenBounds.height)
         //w.frame.offsetBy(dx: 0, dy: 2 * w.frame.height)
         //self.center = CGPointMake(CGRectGetMidX(w.bounds), CGRectGetMidY(w.bounds))
         w.addSubview(self)
         loaderSuperview = w
         
         UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
         self.frame = w.frame.offsetBy(dx: 0, dy: -w.frame.height/2)
         }, completion: nil)
         
        */
        
        
        //Initial Values
        defaultValues()
        
        //Setting up loaderView
        loaderView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, rectSize)//frame.height)//
        loaderView.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2)
        loaderView.layer.cornerRadius = cornerRadius
        
        //Add loader to its superview
        
        self.addSubview(loaderView)
        
        //Initially hidden
        hidden = true
    }
    
    internal func addPath(thePath: CGPath) {
        let bounds = CGPathGetBoundingBox(thePath)
        let center = bounds.origin
        let height = bounds.height
        let width = bounds.width
        //assert(height <= loaderView.frame.height, "The height(\(height)) of the path has to fit the dimensions (Height: \(loaderView.frame.height) Width: \(frame.width))")
        //assert(width <= loaderView.frame.width, "The width(\(width)) of the path has to fit the dimensions (Height: \(loaderView.frame.width) Width: \(frame.width))")
        var transformation = CGAffineTransformMakeTranslation(-center.x - width/2 + loaderView.frame.width/2, -center.y - height/2 + loaderView.frame.height/2)
        path = CGPathCreateCopyByTransformingPath(thePath, &transformation)
    }
    
    
    // MARK: Prepare Loader
    
    
    public var fillfont: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 45)!
    public var fillfontColor: UIColor = AppConfiguration.navText
    public var fillfontHeight: CGFloat = 50
    
    var loaderLabel4:UILabel!
    /**
    Shows the loader.
    
    Atention: do not use this method after creating a loader with `showLoaderWithPath(path:)`
    */
    public func showLoader() {
        alpha = 1.0
        hidden = false
        animate = true
        let topBack = UIView(frame: self.frame)
        topBack.addblur(AppConfiguration.lightGreenColor)
        self.insertSubview(topBack, atIndex: 0)
        
        let loaderLabel:UILabel = UILabel(frame: CGRectMake(0, 18, screenBounds.width, fillfontHeight))//(self.loaderView.frame.minY/2) - 10))
        loaderLabel.textAlignment = NSTextAlignment.Center
        loaderLabel.attributedText = NSAttributedString(string: "Sugar Bug", attributes: [NSForegroundColorAttributeName : fillfontColor, NSFontAttributeName : fillfont] as [String : AnyObject])
        let loaderLabel2:UILabel = UILabel(frame: CGRectMake(0, loaderLabel.frame.maxY, screenBounds.width, fillfontHeight))//(self.loaderView.frame.minY/2) - 10))
        loaderLabel2.textAlignment = NSTextAlignment.Center
        loaderLabel2.attributedText = NSAttributedString(string: "Status", attributes: [NSForegroundColorAttributeName : fillfontColor, NSFontAttributeName : fillfont] as [String : AnyObject])
        self.addSubview(loaderLabel)
        self.addSubview(loaderLabel2)
        
        loaderLabel4 = UILabel(frame: CGRectMake(0, loaderView.frame.maxY + 10, screenBounds.width, fillfontHeight))//(self.loaderView.frame.minY/2) - 10))
        loaderLabel4.textAlignment = NSTextAlignment.Center
        loaderLabel4.attributedText = NSAttributedString(string: "Average: 0:00", attributes: [NSForegroundColorAttributeName : fillfontColor, NSFontAttributeName : fillfont] as [String : AnyObject])
        
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            let loaderLabel3:UIButton = UIButton(type: .Custom)
            loaderLabel3.setTitle("X", forState: .Normal)
            loaderLabel3.layer.borderColor = UIColor.whiteColor().CGColor
            loaderLabel3.layer.borderWidth = 3.0
            loaderLabel3.frame = CGRectMake(screenBounds.width - 50, 28, 40, 40)
            loaderLabel3.backgroundColor = UIColor.crimsonColor()
            loaderLabel3.layer.cornerRadius = 20
            loaderLabel3.addTarget(self, action: #selector(self.tappedRemove), forControlEvents: .TouchUpInside)
            self.addSubview(loaderLabel3)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            let loaderLabel3:UIButton = UIButton(type: .Custom)
            loaderLabel3.setTitle("X", forState: .Normal)
            loaderLabel3.layer.borderColor = UIColor.whiteColor().CGColor
            loaderLabel3.layer.borderWidth = 3.0
            loaderLabel3.frame = CGRectMake(screenBounds.width - 50, 28, 40, 40)
            loaderLabel3.backgroundColor = UIColor.crimsonColor()
            loaderLabel3.layer.cornerRadius = 20
            loaderLabel3.addTarget(self, action: #selector(self.tappedRemove), forControlEvents: .TouchUpInside)
            self.addSubview(loaderLabel3)
        } else {
            let loaderLabel3:UIButton = UIButton(type: .Custom)
            loaderLabel3.setTitle("X", forState: .Normal)
            loaderLabel3.layer.borderColor = UIColor.whiteColor().CGColor
            loaderLabel3.layer.borderWidth = 3.0
            loaderLabel3.frame = CGRectMake(screenBounds.width - 40, 10, 35, 35)
            loaderLabel3.backgroundColor = UIColor.crimsonColor()
            loaderLabel3.layer.cornerRadius = 17.5
            loaderLabel3.addTarget(self, action: #selector(self.tappedRemove), forControlEvents: .TouchUpInside)
            self.addSubview(loaderLabel3)
        }
        self.addSubview(loaderLabel4)
        generateLoader()
        startAnimating()
        if superview == nil {
            self.frame = self.frame.offsetBy(dx: 0, dy: screenBounds.height)
            loaderSuperview?.addSubview(self)
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.frame = self.frame.offsetBy(dx: 0, dy: -screenBounds.height)
            }, completion: nil)
        }
    }
    
    func tappedRemove() {
        defaults.setBool(false, forKey: "SugarBugStatus")
        Smiles.forceFetchData()
        removeLoader()
    }
    
    /**
    Stops loader animations and removes it from its superview
    */
    public func removeLoader(animated: Bool = true) {
        
        
        let completion: () -> () = {
            self.hidden = false
            self.animate = false
            self.removeFromSuperview()
            self.layer.removeAllAnimations()
            self.shapeLayer.removeAllAnimations()
        }
        
        guard animated else {
            completion()
            return
        }
        
        UIView.animateKeyframesWithDuration(0.2,
            delay: 0,
            options: .BeginFromCurrentState,
            animations: {
                self.alpha = 0.0
            }) { _ in
                completion()
        }
    }
    
    internal func layoutPath() {
        let maskingLayer = CAShapeLayer()
        maskingLayer.frame = loaderView.bounds
        maskingLayer.path = path
        
        strokeLayer = CAShapeLayer()
        strokeLayer.frame = loaderView.bounds
        strokeLayer.path = path
        strokeLayer.strokeColor = loaderStrokeColor?.CGColor
        strokeLayer.lineWidth = loaderStrokeWidth
        strokeLayer.fillColor = loaderBackgroundColor?.CGColor
        loaderView.layer.addSublayer(strokeLayer)
        
        let baseLayer = CAShapeLayer()
        baseLayer.frame = loaderView.bounds
        baseLayer.mask = maskingLayer
        
        shapeLayer.fillColor = loaderColor?.CGColor
        shapeLayer.lineWidth = 0.2
        shapeLayer.strokeColor = UIColor.blackColor().CGColor
        shapeLayer.frame = loaderView.bounds
        oldYPoint = rectSize + extraHeight
        shapeLayer.position = CGPoint(x: shapeLayer.position.x, y: oldYPoint)
        
        loaderView.layer.addSublayer(baseLayer)
        baseLayer.addSublayer(shapeLayer)
    }

    internal func defaultValues() {
        duration = 10.0
        backgroundColor = UIColor.clearColor()
        loaderColor = UIColor(red: 0.41, green: 0.728, blue: 0.892, alpha: 1.0)
        loaderBackgroundColor = UIColor.whiteColor()
        loaderStrokeColor = UIColor.blackColor()
        loaderStrokeWidth = 0.5
        loaderAlpha = 1.0
        cornerRadius = 0.0
    }
    
    
    //MARK: Animations
    
    internal func startMoving(up: Bool) {
        if (progressBased) { return }
        let key = up ? "up" : "down"
        let moveAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position.y")
        moveAnimation.values = up ? [loaderView.frame.height/2 + rectSize/2, loaderView.frame.height/2 - rectSize/2 - extraHeight] : [loaderView.frame.height/2 - rectSize/2 - extraHeight, loaderView.frame.height/2 + rectSize/2]
        moveAnimation.duration = duration
        moveAnimation.removedOnCompletion = false
        moveAnimation.fillMode = kCAFillModeForwards
        moveAnimation.delegate = self
        moveAnimation.setValue(key, forKey: "animation")
        shapeLayer.addAnimation(moveAnimation, forKey: key)
    }
    
    internal func applyProgress() {
        let yPoint = (rectSize + extraHeight)*(1-progress)
        let progressAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position.y")
        progressAnimation.values = [oldYPoint, yPoint]
        progressAnimation.duration = 0.2
        progressAnimation.removedOnCompletion = false
        progressAnimation.fillMode = kCAFillModeForwards
        shapeLayer.addAnimation(progressAnimation, forKey: "progress")
        oldYPoint = yPoint
    }

    internal func startswinging() {
        let swingAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        swingAnimation.values = [0, randomAngle(), -randomAngle(), randomAngle(), -randomAngle(), randomAngle(), 0]
        swingAnimation.duration = 12.0
        swingAnimation.removedOnCompletion = false
        swingAnimation.fillMode = kCAFillModeForwards
        swingAnimation.delegate = self
        swingAnimation.setValue("rotation", forKey: "animation")
        shapeLayer.addAnimation(swingAnimation, forKey: "rotation")
    }
    
    internal func randomAngle() -> Double {
        return M_PI_4/(Double(arc4random_uniform(16)) + 8)
    }
    
    
    public func animationDidStart(anim: CAAnimation) {
        
    }
    
    public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
    }
    
    //MARK: Abstract methods
    
    internal func generateLoader() {
        preconditionFailure("Call this method from the desired FillableLoader type class")
    }
    
    internal func startAnimating() {
        preconditionFailure("Call this method from the desired FillableLoader type class")
    }
}


var loader2: FillableLoader2 = FillableLoader2()


public class FillableLoader2: UIView, CAAnimationDelegate {
    internal var shapeLayer = CAShapeLayer()
    internal var strokeLayer = CAShapeLayer()
    internal var path: CGPath!
    internal var loaderView = UIView()
    internal var animate: Bool = false
    internal var extraHeight: CGFloat = 0
    internal var oldYPoint: CGFloat = 0
    //internal let mainBgColor = UIColor(white: 0.8, alpha: 0.6)
    internal weak var loaderSuperview: UIView?
    
    // MARK: Public Variables
    
    /// Duration of the animation (Default:  10.0)
    public var duration: NSTimeInterval = 10.0
    
    /// Loader background height (Default:  ScreenHeight/6 + 30)
    public var rectSize: CGFloat = UIScreen.mainScreen().bounds.height/2// + 30
    
    /// A Boolean value that determines whether the loader should have a swing effect while going up (Default: true)
    public var swing: Bool = true
    
    /// A Boolean value that determines whether the loader movement is progress based or not (Default: false)
    public var progressBased: Bool = true
    
    // MARK: Custom Getters and Setters
    
    internal var _backgroundColor: UIColor?
    internal var _loaderColor: UIColor?
    internal var _loaderBackgroundColor: UIColor?
    internal var _loaderStrokeColor: UIColor?
    internal var _loaderStrokeWidth: CGFloat = 0.5
    internal var _loaderAlpha: CGFloat = 1.0
    internal var _cornerRadius: CGFloat = 0.0
    internal var _progress: CGFloat = 0.0
    
    public func ToothPath() -> CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 468.3, y: 109.64))
        bezierPath.addCurveToPoint(CGPoint(x: 383.3, y: 17.48), controlPoint1: CGPoint(x: 458.23, y: 66.19), controlPoint2: CGPoint(x: 428.86, y: 34.35))
        bezierPath.addCurveToPoint(CGPoint(x: 246.47, y: 34.26), controlPoint1: CGPoint(x: 352.94, y: 6.27), controlPoint2: CGPoint(x: 279.02, y: -3.99))
        bezierPath.addCurveToPoint(CGPoint(x: 49.03, y: 45.92), controlPoint1: CGPoint(x: 141.55, y: -27.91), controlPoint2: CGPoint(x: 86.23, y: 5.96))
        bezierPath.addCurveToPoint(CGPoint(x: 39.59, y: 261.56), controlPoint1: CGPoint(x: -33.09, y: 134.13), controlPoint2: CGPoint(x: 4.48, y: 222.98))
        bezierPath.addCurveToPoint(CGPoint(x: 76.43, y: 324.11), controlPoint1: CGPoint(x: 64.97, y: 289.5), controlPoint2: CGPoint(x: 72.31, y: 305.66))
        bezierPath.addCurveToPoint(CGPoint(x: 79.55, y: 342.73), controlPoint1: CGPoint(x: 77.35, y: 328.17), controlPoint2: CGPoint(x: 79.44, y: 340.16))
        bezierPath.addCurveToPoint(CGPoint(x: 150.95, y: 510.47), controlPoint1: CGPoint(x: 86.04, y: 496.38), controlPoint2: CGPoint(x: 138.43, y: 509.54))
        bezierPath.addCurveToPoint(CGPoint(x: 161.68, y: 512), controlPoint1: CGPoint(x: 154.61, y: 511.52), controlPoint2: CGPoint(x: 158.2, y: 512))
        bezierPath.addCurveToPoint(CGPoint(x: 179.6, y: 506.94), controlPoint1: CGPoint(x: 168.07, y: 512), controlPoint2: CGPoint(x: 174.12, y: 510.3))
        bezierPath.addCurveToPoint(CGPoint(x: 220.69, y: 397.63), controlPoint1: CGPoint(x: 205.63, y: 490.99), controlPoint2: CGPoint(x: 213.64, y: 441.34))
        bezierPath.addCurveToPoint(CGPoint(x: 228.44, y: 358.19), controlPoint1: CGPoint(x: 223.26, y: 381.81), controlPoint2: CGPoint(x: 225.65, y: 366.87))
        bezierPath.addCurveToPoint(CGPoint(x: 237.26, y: 339.19), controlPoint1: CGPoint(x: 233.29, y: 343.14), controlPoint2: CGPoint(x: 237.3, y: 339.71))
        bezierPath.addCurveToPoint(CGPoint(x: 247.29, y: 356.44), controlPoint1: CGPoint(x: 240.75, y: 340.75), controlPoint2: CGPoint(x: 246.64, y: 352))
        bezierPath.addCurveToPoint(CGPoint(x: 249.73, y: 381.26), controlPoint1: CGPoint(x: 248.26, y: 363.06), controlPoint2: CGPoint(x: 248.95, y: 371.65))
        bezierPath.addCurveToPoint(CGPoint(x: 312.23, y: 510.43), controlPoint1: CGPoint(x: 253.75, y: 430.61), controlPoint2: CGPoint(x: 259.74, y: 505.04))
        bezierPath.addCurveToPoint(CGPoint(x: 335.69, y: 505.48), controlPoint1: CGPoint(x: 315.95, y: 511.23), controlPoint2: CGPoint(x: 324.81, y: 512.05))
        bezierPath.addCurveToPoint(CGPoint(x: 390.09, y: 377.6), controlPoint1: CGPoint(x: 360.43, y: 490.46), controlPoint2: CGPoint(x: 378.75, y: 447.44))
        bezierPath.addLineToPoint(CGPoint(x: 391.79, y: 366.43))
        bezierPath.addCurveToPoint(CGPoint(x: 424.65, y: 275.75), controlPoint1: CGPoint(x: 395.87, y: 338.43), controlPoint2: CGPoint(x: 401.53, y: 300.06))
        bezierPath.addCurveToPoint(CGPoint(x: 468.3, y: 109.64), controlPoint1: CGPoint(x: 451.37, y: 247.85), controlPoint2: CGPoint(x: 483.62, y: 175.7))
        bezierPath.closePath()
        bezierPath.miterLimit = 4
        bezierPath.applyTransform(CGAffineTransformMakeScale(0.2, 0.2))
        return bezierPath.CGPath
    }
    
    /// Loader view background color (Default: Clear)
    override public var backgroundColor: UIColor? {
        get { return _backgroundColor }
        set {
            //super.backgroundColor = mainBgColor
            _backgroundColor = newValue
            loaderView.backgroundColor = newValue
            loaderView.layer.backgroundColor = newValue?.CGColor
        }
    }
    
    /// Filled loader color (Default: Blue)
    public var loaderColor: UIColor? {
        get { return _loaderColor }
        set {
            _loaderColor = newValue
            shapeLayer.fillColor = newValue?.CGColor
        }
    }
    
    /// Unfilled loader color (Default: White)
    public var loaderBackgroundColor: UIColor? {
        get { return _loaderBackgroundColor }
        set {
            _loaderBackgroundColor = newValue
            strokeLayer.fillColor = newValue?.CGColor
        }
    }
    
    /// Loader outline line color (Default: Black)
    public var loaderStrokeColor: UIColor? {
        get { return _loaderStrokeColor }
        set {
            _loaderStrokeColor = newValue
            strokeLayer.strokeColor = newValue?.CGColor
        }
    }
    
    /// Loader outline line width (Default: 0.5)
    public var loaderStrokeWidth: CGFloat {
        get { return _loaderStrokeWidth }
        set {
            _loaderStrokeWidth = newValue
            strokeLayer.lineWidth = newValue
        }
    }
    
    /// Loader view alpha (Default: 1.0)
    public var loaderAlpha: CGFloat {
        get { return _loaderAlpha }
        set {
            _loaderAlpha = newValue
            loaderView.alpha = newValue
        }
    }
    
    /// Loader view corner radius (Default: 0.0)
    override public var cornerRadius: CGFloat {
        get { return _cornerRadius }
        set {
            _cornerRadius = newValue
            loaderView.layer.cornerRadius = newValue
        }
    }
    
    /// Loader fill progress from 0.0 to 1.0 . It will automatically fire an animation to update the loader fill progress (Default: 0.0)
    public var progress: CGFloat {
        get { return _progress }
        set {
            if (!progressBased || newValue > 1.0 || newValue < 0.0) { return }
            _progress = newValue
            applyProgress()
        }
    }
    
    
    // MARK: Initializers Methods
    
    /**
     Creates and SHOWS a loader with the given path
     
     :param: path Loader CGPath
     
     :returns: The loader that's already being showed
     */
    public static func showLoaderWithPath(path: CGPath, onView: UIView? = nil) -> Self {
        let loader = createLoaderWithPath(path: path, onView: onView)
        loader.showLoader()
        return loader
    }
    /**
     Creates and SHOWS a progress based loader with the given path
     
     :param: path Loader CGPath
     
     :returns: The loader that's already being showed
     */
    public static func showProgressBasedLoaderWithPath(path: CGPath, onView: UIView? = nil) -> Self {
        let loader = createProgressBasedLoaderWithPath(path: path, onView: onView)
        loader.showLoader()
        return loader
    }
    
    /**
     Creates a loader with the given path
     
     :param: path Loader CGPath
     
     :returns: The created loader
     */
    public static func createLoaderWithPath(path thePath: CGPath, onView: UIView? = nil) -> Self {
        let loader = self.init()
        loader.initialSetup(onView)
        loader.addPath(thePath)
        return loader
    }
    
    /**
     Creates a progress based loader with the given path
     
     :param: path Loader CGPath
     
     :returns: The created loader
     */
    public static func createProgressBasedLoaderWithPath(path thePath: CGPath, onView: UIView? = nil) -> Self {
        let loader = self.init()
        loader.progressBased = true
        loader.initialSetup(onView)
        loader.addPath(thePath)
        return loader
    }
    
    internal func initialSetup(view: UIView? = nil) {
        //Setting up frame
        var window = view
        if view == nil, let mainWindow = UIApplication.sharedApplication().delegate?.window {
            window = mainWindow
        }
        guard let w = window else { return }
        self.frame = w.frame
        self.center = CGPointMake(CGRectGetMidX(w.bounds), CGRectGetMidY(w.bounds))
        w.addSubview(self)
        loaderSuperview = w
        
        
        //Initial Values
        defaultValues()
        
        //Setting up loaderView
        loaderView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, rectSize)//frame.height)//
        loaderView.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2)
        loaderView.layer.cornerRadius = cornerRadius
        
        //Add loader to its superview
        
        self.addSubview(loaderView)
        
        //Initially hidden
        hidden = true
    }
    
    internal func addPath(thePath: CGPath) {
        let bounds = CGPathGetBoundingBox(thePath)
        let center = bounds.origin
        let height = bounds.height
        let width = bounds.width
        //assert(height <= loaderView.frame.height, "The height(\(height)) of the path has to fit the dimensions (Height: \(loaderView.frame.height) Width: \(frame.width))")
        //assert(width <= loaderView.frame.width, "The width(\(width)) of the path has to fit the dimensions (Height: \(loaderView.frame.width) Width: \(frame.width))")
        var transformation = CGAffineTransformMakeTranslation(-center.x - width/2 + loaderView.frame.width/2, -center.y - height/2 + loaderView.frame.height/2)
        path = CGPathCreateCopyByTransformingPath(thePath, &transformation)
    }
    
    /**
     Shows the loader.
     
     Atention: do not use this method after creating a loader with `showLoaderWithPath(path:)`
     */
    public func showLoader() {
        alpha = 1.0
        hidden = false
        animate = true
        generateLoader()
        startAnimating()
        if superview == nil {
            self.frame = self.frame.offsetBy(dx: 0, dy: screenBounds.height)
            loaderSuperview?.addSubview(self)
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.frame = self.frame.offsetBy(dx: 0, dy: -screenBounds.height)
                }, completion: nil)
        }
    }
    
    
    /**
     Stops loader animations and removes it from its superview
     */
    public func removeLoader(animated: Bool = true) {
        
        
        let completion: () -> () = {
            self.hidden = false
            self.animate = false
            self.removeFromSuperview()
            self.layer.removeAllAnimations()
            self.shapeLayer.removeAllAnimations()
        }
        
        guard animated else {
            completion()
            return
        }
        
        UIView.animateKeyframesWithDuration(0.2,
                                            delay: 0,
                                            options: .BeginFromCurrentState,
                                            animations: {
                                                self.alpha = 0.0
        }) { _ in
            completion()
        }
    }
    
    internal func layoutPath() {
        let maskingLayer = CAShapeLayer()
        maskingLayer.frame = loaderView.bounds
        maskingLayer.path = path
        
        strokeLayer = CAShapeLayer()
        strokeLayer.frame = loaderView.bounds
        strokeLayer.path = path
        strokeLayer.strokeColor = loaderStrokeColor?.CGColor
        strokeLayer.lineWidth = loaderStrokeWidth
        strokeLayer.fillColor = loaderBackgroundColor?.CGColor
        loaderView.layer.addSublayer(strokeLayer)
        
        let baseLayer = CAShapeLayer()
        baseLayer.frame = loaderView.bounds
        baseLayer.mask = maskingLayer
        
        shapeLayer.fillColor = loaderColor?.CGColor
        shapeLayer.lineWidth = 0.2
        shapeLayer.strokeColor = UIColor.blackColor().CGColor
        shapeLayer.frame = loaderView.bounds
        oldYPoint = rectSize + extraHeight
        shapeLayer.position = CGPoint(x: shapeLayer.position.x, y: oldYPoint)
        
        loaderView.layer.addSublayer(baseLayer)
        baseLayer.addSublayer(shapeLayer)
    }
    
    internal func defaultValues() {
        duration = 10.0
        backgroundColor = UIColor.clearColor()
        loaderColor = UIColor(red: 0.41, green: 0.728, blue: 0.892, alpha: 1.0)
        loaderBackgroundColor = UIColor.whiteColor()
        loaderStrokeColor = UIColor.blackColor()
        loaderStrokeWidth = 0.5
        loaderAlpha = 1.0
        cornerRadius = 0.0
    }
    
    
    //MARK: Animations
    
    internal func startMoving(up: Bool) {
        if (progressBased) { return }
        let key = up ? "up" : "down"
        let moveAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position.y")
        moveAnimation.values = up ? [loaderView.frame.height/2 + rectSize/2, loaderView.frame.height/2 - rectSize/2 - extraHeight] : [loaderView.frame.height/2 - rectSize/2 - extraHeight, loaderView.frame.height/2 + rectSize/2]
        moveAnimation.duration = duration
        moveAnimation.removedOnCompletion = false
        moveAnimation.fillMode = kCAFillModeForwards
        moveAnimation.delegate = self
        moveAnimation.setValue(key, forKey: "animation")
        shapeLayer.addAnimation(moveAnimation, forKey: key)
    }
    
    internal func applyProgress() {
        let yPoint = (rectSize + extraHeight)*(1-progress)
        let progressAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position.y")
        progressAnimation.values = [oldYPoint, yPoint]
        progressAnimation.duration = 0.2
        progressAnimation.removedOnCompletion = false
        progressAnimation.fillMode = kCAFillModeForwards
        shapeLayer.addAnimation(progressAnimation, forKey: "progress")
        oldYPoint = yPoint
    }
    
    internal func startswinging() {
        let swingAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        swingAnimation.values = [0, randomAngle(), -randomAngle(), randomAngle(), -randomAngle(), randomAngle(), 0]
        swingAnimation.duration = 12.0
        swingAnimation.removedOnCompletion = false
        swingAnimation.fillMode = kCAFillModeForwards
        swingAnimation.delegate = self
        swingAnimation.setValue("rotation", forKey: "animation")
        shapeLayer.addAnimation(swingAnimation, forKey: "rotation")
    }
    
    internal func randomAngle() -> Double {
        return M_PI_4/(Double(arc4random_uniform(16)) + 8)
    }
    
    
    public func animationDidStart(anim: CAAnimation) {
        
    }
    
    public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
    }
    
    //MARK: Abstract methods
    
    internal func generateLoader() {
        preconditionFailure("Call this method from the desired FillableLoader type class")
    }
    
    internal func startAnimating() {
        preconditionFailure("Call this method from the desired FillableLoader type class")
    }
}

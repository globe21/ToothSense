//
//  Extensions.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/24/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import ObjectiveC
import Parse
import ParseUI

extension UIViewController {
    func removeBack() {
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UITabBarController {
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        
        // animate the tabBar
        UIView.animateWithDuration(animated ? 0.3 : 0.0) {
            self.tabBar.frame = CGRectOffset(frame, 0, offsetY)
            self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
}

public extension PFImageView {
    
    func imageWithString(word: String, color: UIColor? = nil, circular: Bool = true, fontAttributes: [String : AnyObject] = [:]){
        var imageViewString: String = ""
        
        let wordsArray = word.characters.split{$0 == " "}.map(String.init)
        
        for word in wordsArray {
            imageViewString += "\(word.characters.first!)"
            if imageViewString.characters.count >= 2 {
                break
            }
        }
        
        imageSnapShotFromWords(imageViewString, color: color, circular: circular, fontAttributes: fontAttributes)
    }
    
    func imageSnapShotFromWords(snapShotString: String, color: UIColor?, circular: Bool, fontAttributes: [String : AnyObject]?) {
        
        let attributes: [String : AnyObject]
        
        if let attr = fontAttributes {
            attributes = attr
        }
        else {
            attributes = [NSForegroundColorAttributeName : UIColor.whiteColor(),  NSFontAttributeName : UIFont.systemFontOfSize( self.bounds.width * 0.4)]
        }
        
        let imageBackgroundColor: UIColor
        
        if let color = color {
            imageBackgroundColor = color
        } else {
            imageBackgroundColor = UIColor.grayColor()
        }
        
        let scale = UIScreen.mainScreen().scale
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        if circular {
            self.layer.cornerRadius = self.frame.width/2
            self.clipsToBounds = true
        }
        CGContextSetFillColorWithColor(context!, imageBackgroundColor.CGColor)
        CGContextAddRect(context!,CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let textSize = NSString(string: snapShotString).sizeWithAttributes(attributes)
        
        NSString(string: snapShotString).drawInRect(CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height), withAttributes: attributes)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.image = image
    }
    
    
    func generateRandomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 256) / 256
        let saturation = CGFloat(arc4random() % 128) / 256 + 0.5
        let brightness = CGFloat(arc4random() % 128) / 256 + 0.5
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}


private let supportsDateByAddingUnit = NSCalendar.currentCalendar().respondsToSelector(#selector(NSCalendar.dateByAddingUnit(_:value:toDate:options:)))

extension NSCalendar {
    func dateByAddingDuration(duration: Duration, toDate date: NSDate, options opts: NSCalendarOptions) -> NSDate? {
        if supportsDateByAddingUnit {
            return dateByAddingUnit(duration.unit, value: duration.value, toDate: date, options: .SearchBackwards)!
        } else {
            // otherwise fallback to NSDateComponents
            return dateByAddingComponents(NSDateComponents(duration), toDate: date, options: .SearchBackwards)!
        }
    }
}

extension String {
    // MARK - Parse into NSDate
    
    func dateFromFormat(format: String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.dateFromString(self)
    }
}

extension Int {
    var year: Duration {
        return Duration(value: self, unit: .Year)
    }
    var years: Duration {
        return year
    }
    
    var month: Duration {
        return Duration(value: self, unit: .Month)
    }
    var months: Duration {
        return month
    }
    
    var week: Duration {
        return Duration(value: self, unit: .WeekOfYear)
    }
    var weeks: Duration {
        return week
    }
    
    var day: Duration {
        return Duration(value: self, unit: .Day)
    }
    var days: Duration {
        return day
    }
    
    var hour: Duration {
        return Duration(value: self, unit: .Hour)
    }
    var hours: Duration {
        return hour
    }
    
    var minute: Duration {
        return Duration(value: self, unit: .Minute)
    }
    var minutes: Duration {
        return minute
    }
    
    var second: Duration {
        return Duration(value: self, unit: .Second)
    }
    var seconds: Duration {
        return second
    }
    
    var ordinal: String {
        
        let ones: Int = self % 10
        let tens: Int = (self/10) % 10
        
        if (tens == 1) {
            return "th"
        }
        else if (ones == 1) {
            return "st"
        }
        else if (ones == 2) {
            return "nd"
        }
        else if (ones == 3) {
            return "rd"
        }
        return "th"
    }
}


prefix func - (duration: Duration) -> (Duration) {
    return Duration(value: -duration.value, unit: duration.unit)
}

class Duration {
    let value: Int
    let unit: NSCalendarUnit
    private let calendar = NSCalendar.currentCalendar()
    
    /**
     Initialize a date before a duration.
     */
    var ago: NSDate {
        return ago(from: NSDate())
    }
    
    func ago(from date: NSDate) -> NSDate {
        return calendar.dateByAddingDuration(-self, toDate: date, options: .SearchBackwards)!
    }
    
    /**
     Initialize a date after a duration.
     */
    var later: NSDate {
        return later(from: NSDate())
    }
    
    func later(from date: NSDate) -> NSDate {
        return calendar.dateByAddingDuration(self, toDate: date, options: .SearchBackwards)!
    }
    
    init(value: Int, unit: NSCalendarUnit) {
        self.value = value
        self.unit = unit
    }
}


// MARK: - Calculation

func + (lhs: NSDate, rhs: Duration) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingDuration(rhs, toDate: lhs, options: .SearchBackwards)!
}

func - (lhs: NSDate, rhs: Duration) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingDuration(-rhs, toDate: lhs, options: .SearchBackwards)!
}

func - (lhs: NSDate, rhs: NSDate) -> NSTimeInterval {
    return lhs.timeIntervalSinceDate(rhs)
}


// MARK: - Equatable

//extension NSDate: Equatable {}

func == (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

// MARK: - Comparable

//internal extension NSDate: Comparable {}
//
//func < (lhs: NSDate, rhs: NSDate) -> Bool {
//    return lhs.compare(rhs) == .OrderedAscending
//}

// MARK: -


extension NSDateComponents {
    convenience init(_ duration: Duration) {
        self.init()
        switch duration.unit{
        case NSCalendarUnit.Day:
            day = duration.value
        case NSCalendarUnit.Weekday:
            weekday = duration.value
        case NSCalendarUnit.WeekOfMonth:
            weekOfMonth = duration.value
        case NSCalendarUnit.WeekOfYear:
            weekOfYear = duration.value
        case NSCalendarUnit.Hour:
            hour = duration.value
        case NSCalendarUnit.Minute:
            minute = duration.value
        case NSCalendarUnit.Month:
            month = duration.value
        case NSCalendarUnit.Second:
            second = duration.value
        case NSCalendarUnit.Year:
            year = duration.value
        default:
            () // unsupported / ignore
        }
    }
}


// MARK: -
extension NSDate {
    private struct AssociatedKeys {
        static var TimeZone = "timepiece_TimeZone"
    }
    
    // MARK: - Get components
    
    var year: Int {
        return components.year
    }
    
    var month: Int {
        return components.month
    }
    
    var weekday: Int {
        return components.weekday
    }
    
    var day: Int {
        return components.day
    }
    
    var hour: Int {
        return components.hour
    }
    
    var minute: Int {
        return components.minute
    }
    
    var second: Int {
        return components.second
    }
    
    var timeZone: NSTimeZone {
        return objc_getAssociatedObject(self, &AssociatedKeys.TimeZone) as? NSTimeZone ?? calendar.timeZone
    }
    
    private var components: NSDateComponents {
        return calendar.components([.Year, .Month, .Weekday, .Day, .Hour, .Minute, .Second], fromDate: self)
    }
    
    private var calendar: NSCalendar {
        return NSCalendar.currentCalendar()
    }
    
    public func Today() -> NSDate? {
        return NSDate.date(self.year, month: self.month, day: self.day)
    }
    
    // MARK: - Initialize
    
    class func date(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> NSDate {
        let now = NSDate()
        return now.change(year, month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    class func date(year: Int, month: Int, day: Int) -> NSDate {
        return NSDate.date(year, month: month, day: day, hour: 0, minute: 0, second: 0)
    }
    
    class func today() -> NSDate {
        let now = NSDate()
        return NSDate.date(now.year, month: now.month, day: now.day)
    }
    
    class func yesterday() -> NSDate {
        return today() - 1.day
    }
    
    class func tomorrow() -> NSDate {
        return today() + 1.day
    }
    
    // MARK: - Initialize by setting components
    
    /**
     Initialize a date by changing date components of the receiver.
     */
    func change(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> NSDate! {
        let components = self.components
        components.year = year ?? self.year
        components.month = month ?? self.month
        components.day = day ?? self.day
        components.hour = hour ?? self.hour
        components.minute = minute ?? self.minute
        components.second = second ?? self.second
        return calendar.dateFromComponents(components)
    }
    
    /**
     Initialize a date by changing the weekday of the receiver.
     */
    func change(weekday: Int) -> NSDate! {
        return self - (self.weekday - weekday).days
    }
    
    /**
     Initialize a date by changing the time zone of receiver.
     */
    func changeTimezone(timeZone: NSTimeZone) -> NSDate! {
        let originalTimeZone = calendar.timeZone
        calendar.timeZone = timeZone
        
        let newDate = calendar.dateFromComponents(components)!
        newDate.calendar.timeZone = timeZone
        objc_setAssociatedObject(newDate, &AssociatedKeys.TimeZone, timeZone, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        calendar.timeZone = originalTimeZone
        
        return newDate
    }
    
    // MARK: - Initialize a date at beginning/end of each units
    
    var beginningOfYear: NSDate {
        return change(month: 1, day: 1, hour: 0, minute: 0, second: 0)
    }
    var endOfYear: NSDate {
        return (beginningOfYear + 1.year).dateByAddingTimeInterval(-1)
    }
    
    var beginningOfMonth: NSDate {
        return change(day: 1, hour: 0, minute: 0, second: 0)
    }
    var endOfMonth: NSDate {
        return (beginningOfMonth + 1.month).dateByAddingTimeInterval(-1)
    }
    
    var beginningOfWeek: NSDate {
        return change(1).beginningOfDay
    }
    var endOfWeek: NSDate {
        return (beginningOfWeek + 1.week).dateByAddingTimeInterval(-1)
    }
    
    var beginningOfDay: NSDate {
        return change(hour: 0, minute: 0, second: 0)
    }
    var middleOfDay: NSDate {
        return beginningOfDay.dateByAddingTimeInterval(43200)
    }
    
    var endOfDay: NSDate {
        return (beginningOfDay + 1.day).dateByAddingTimeInterval(-1)
    }
    
    var beginningOfHour: NSDate {
        return change(minute: 0, second: 0)
    }
    var endOfHour: NSDate {
        return (beginningOfHour + 1.hour).dateByAddingTimeInterval(-1)
    }
    
    var beginningOfMinute: NSDate {
        return change(second: 0)
    }
    var endOfMinute: NSDate {
        return (beginningOfMinute + 1.minute).dateByAddingTimeInterval(-1)
    }
    
    // MARK: - Format dates
    
    func stringFromFormat(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    // MARK: - Differences
    
    func differenceWith(date: NSDate, inUnit unit: NSCalendarUnit) -> Int {
        
        return calendar.components(unit, fromDate: self, toDate: date, options: []).valueForComponent(unit)
    }
}

extension UIResponder {
    func getParentViewController() -> UIViewController? {
        if self.nextResponder() is UIViewController {
            return self.nextResponder() as? UIViewController
        } else {
            if self.nextResponder() != nil {
                return (self.nextResponder()!).getParentViewController()
            }
            else {return nil}
        }
    }
    
    func getVideoController() -> VideoTable? {
        if self.nextResponder() is VideoTable {
            return self.nextResponder() as? VideoTable
        } else {
            if self.nextResponder() != nil {
                return (self.nextResponder()!).getVideoController()
            }
            else {return nil}
        }
    }
}

class Images {
    
    
    class func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
        var imager = image
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        imager.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        imager = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return imager
    }
    
}

extension UIView {
    
    
    public enum ShakeDirection : Int {
        case horizontal
        case vertical
        
        internal func startPosition() -> ShakePosition {
            switch self {
            case .horizontal:
                return ShakePosition.Left
            default:
                return ShakePosition.Top
            }
        }
    }
    
    
    private struct DefaultValues {
        static let numberOfTimes = 5
        static let totalDuration : Float = 0.5
    }

    
    public func shake() {//_ direction: ShakeDirection) {
        let direction: ShakeDirection = .horizontal
        shake(3, position: direction.startPosition(), duration: 0.3)
    }
    
    private func shake(forTimes: Int, position: ShakePosition, duration: NSTimeInterval) {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.layer.setAffineTransform(CGAffineTransformMakeTranslation(2 * position.value, CGFloat(0)))
        }) { (complete) -> Void in
            if (forTimes == 0) {
                UIView.animateWithDuration(duration/Double(forTimes), animations: { () -> Void in
                    self.layer.setAffineTransform(CGAffineTransformIdentity)
                    }, completion: nil)
            } else {
                self.shake(forTimes - 1, position: position.oppositePosition(), duration: duration/Double(forTimes))
            }
        }
    }
    
    struct ShakePosition  {
        let value : CGFloat
        let direction : ShakeDirection
        init(value: CGFloat, direction : ShakeDirection) {
            self.value = value
            self.direction = direction
        }
        func oppositePosition() -> ShakePosition {
            return ShakePosition(value: (self.value * -1), direction: direction)
        }
        static var Left : ShakePosition {
            get {
                return ShakePosition(value: 1, direction: .horizontal)
            }
        }
        static var Right : ShakePosition {
            get {
                return ShakePosition(value: -1, direction: .horizontal)
            }
        }
        static var Top : ShakePosition {
            get {
                return ShakePosition(value: 1, direction: .vertical)
            }
        }
        static var Bottom : ShakePosition {
            get {
                return ShakePosition(value: -1, direction: .vertical)
            }
        }
        
    }
}


@IBDesignable class ImageTextField: UITextField {
    
    
    
    private var ImgIcon: UIImageView?
    
    @IBInspectable var errorEntry: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var leftTextPedding: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var lineColor: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var placeHolerColor: UIColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var errorColor: UIColor = UIColor.redColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var imageWidth: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var txtImage : UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    private func newBounds(bounds: CGRect) -> CGRect {
        
        var newBounds = bounds
        newBounds.origin.x += CGFloat(leftTextPedding) + CGFloat(imageWidth)
        return newBounds
    }
    
    var errorMessage: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setting left image
        if (txtImage != nil)
        {
            let imgView = UIImageView(image: txtImage)
            imgView.frame = CGRectMake(0, 0, CGFloat(imageWidth), self.frame.height)
            imgView.contentMode = .Center
            self.leftViewMode = UITextFieldViewMode.Always
            self.leftView = imgView
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        let height = self.bounds.height
        
        // get the current drawing context
        let context = UIGraphicsGetCurrentContext()
        
        // set the line color and width
        if errorEntry {
            CGContextSetStrokeColorWithColor(context!, errorColor.CGColor)
            CGContextSetLineWidth(context!, 1.5)
        } else {
            CGContextSetStrokeColorWithColor(context!, lineColor.CGColor)
            CGContextSetLineWidth(context!, 0.5)
        }
        
        // start a new Path
        CGContextBeginPath(context!)
        
        CGContextMoveToPoint(context!, self.bounds.origin.x, height - 0.5)
        CGContextAddLineToPoint(context!, self.bounds.size.width, height - 0.5)
        // close and stroke (draw) it
        CGContextClosePath(context!)
        CGContextStrokePath(context!)
        
        //Setting custom placeholder color
        if let strPlaceHolder: String = self.placeholder
        {
            self.attributedPlaceholder = NSAttributedString(string:strPlaceHolder,
                                                            attributes:[NSForegroundColorAttributeName:placeHolerColor])
        }
    }
    override func leftViewRectForBounds(bounds: CGRect) -> CGRect
    {
        return CGRectMake(0, 0, CGFloat(imageWidth), self.frame.height)
    }
}



class StickyCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var firstItemTransform: CGFloat?
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let items = NSArray (array: super.layoutAttributesForElementsInRect(rect)!, copyItems: true)
        var headerAttributes: UICollectionViewLayoutAttributes?
        
        items.enumerateObjectsUsingBlock { (object, idex, stop) -> Void in
            let attributes = object as! UICollectionViewLayoutAttributes
            
            if attributes.representedElementKind == UICollectionElementKindSectionHeader {
                headerAttributes = attributes
            }
            else {
                self.updateCellAttributes(attributes, headerAttributes: headerAttributes)
            }
        }
        return items as? [UICollectionViewLayoutAttributes]
    }
    
    func updateCellAttributes(attributes: UICollectionViewLayoutAttributes, headerAttributes: UICollectionViewLayoutAttributes?) {
        let minY = CGRectGetMinY(collectionView!.bounds) + collectionView!.contentInset.top
        var maxY = attributes.frame.origin.y
        
        if let headerAttributes = headerAttributes {
            maxY -= CGRectGetHeight(headerAttributes.bounds)
        }
        
        let finalY = max(minY, maxY)
        var origin = attributes.frame.origin
        let deltaY = (finalY - origin.y) / CGRectGetHeight(attributes.frame)
        
        if let itemTransform = firstItemTransform {
            let scale = 1 - deltaY * itemTransform
            attributes.transform = CGAffineTransformMakeScale(scale, scale)
        }
        
        origin.y = finalY
        attributes.frame = CGRect(origin: origin, size: attributes.frame.size)
        attributes.zIndex = attributes.indexPath.row
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}


//
//  VBPiledView.swift
//  VBPiledView
//
//  Created by Viktor Braun (v-braun@live.de) on 02.07.16.
//  Copyright © 2016 dev-things. All rights reserved.
//


public protocol VBPiledViewDataSource{
    func piledView(numberOfItemsForPiledView: VBPiledView) -> Int
    func piledView(viewForPiledView: VBPiledView, itemAtIndex index: Int) -> UIView
}

public class VBPiledView: UIView, UIScrollViewDelegate {
    
    private let _scrollview = UIScrollView()
    public var dataSource : VBPiledViewDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initInternal();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initInternal();
    }
    
    override public func layoutSubviews() {
        _scrollview.frame = self.bounds
        
        self.layoutContent()
        
        super.layoutSubviews()
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        layoutContent()
    }
    
    private func initInternal(){
        _scrollview.showsVerticalScrollIndicator = true
        _scrollview.showsHorizontalScrollIndicator = false
        _scrollview.scrollEnabled = true
        _scrollview.delegate = self
        
        self.addSubview(_scrollview)
    }
    
    public var expandedContentHeightInPercent : Float = 80
    public var collapsedContentHeightInPercent : Float = 5
    
    private func layoutContent(){
        guard let data = dataSource else {return}
        
        let currentScrollPoint = CGPoint(x:0, y: _scrollview.contentOffset.y)
        let contentMinHeight = (CGFloat(collapsedContentHeightInPercent) * _scrollview.bounds.height) / 100
        let contentMaxHeight = (CGFloat(expandedContentHeightInPercent) * _scrollview.bounds.height) / 100
        
        var lastElementH = CGFloat(0)
        var lastElementY = currentScrollPoint.y
        
        let subViewNumber = data.piledView(self)
        _scrollview.contentSize = CGSize(width: self.bounds.width, height: _scrollview.bounds.height * CGFloat(subViewNumber))
        for index in 0..<subViewNumber {
            let v = data.piledView(self, itemAtIndex: index)
            if !v.isDescendantOfView(_scrollview){
                _scrollview.addSubview(v)
            }
            
            let y = lastElementY + lastElementH
            let currentViewUntransformedLocation = CGPoint(x: 0, y: (CGFloat(index) * _scrollview.bounds.height) + _scrollview.bounds.height)
            let prevViewUntransformedLocation = CGPoint(x: 0, y: currentViewUntransformedLocation.y - _scrollview.bounds.height)
            let slidingWindow = CGRect(origin: currentScrollPoint, size: _scrollview.bounds.size)
            
            var h = contentMinHeight
            if index == subViewNumber-1 {
                h = _scrollview.bounds.size.height
                if(currentScrollPoint.y > CGFloat(index) * _scrollview.bounds.size.height){
                    h = h + (currentScrollPoint.y - CGFloat(index) * _scrollview.bounds.size.height)
                }
            }
            else if CGRectContainsPoint(slidingWindow, currentViewUntransformedLocation){
                let relativeScrollPos = currentScrollPoint.y - (CGFloat(index) * _scrollview.bounds.size.height)
                let scaleFactor = (relativeScrollPos * 100) / _scrollview.bounds.size.height
                let diff = (scaleFactor * contentMaxHeight) / 100
                h = contentMaxHeight - diff
            }
            else if CGRectContainsPoint(slidingWindow, prevViewUntransformedLocation){
                h = contentMaxHeight - lastElementH
                if currentScrollPoint.y < 0 {
                    h = h + abs(currentScrollPoint.y)
                }
                else if(h < contentMinHeight){
                    h = contentMinHeight
                }
            }
            else if slidingWindow.origin.y > currentViewUntransformedLocation.y {
                h = 0
            }
            
            v.frame = CGRect(origin: CGPoint(x: 0, y: y), size: CGSize(width: _scrollview.bounds.width, height: h))
            
            lastElementH = v.frame.size.height
            lastElementY = v.frame.origin.y
        }
    }
    
}

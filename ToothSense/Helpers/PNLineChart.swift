//
//  PNLineChart.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/4/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore
import Foundation


public class PNLineChartDataItem{
    var y:CGFloat = 0.0
    
    public init(){
    }
    
    public init(y : CGFloat){
        self.y = y;
    }
}


public  class PNLineChartData{
    
    public enum PNLineChartPointStyle:Int{
        case PNLineChartPointStyleNone = 0
        case PNLineChartPointStyleCycle
        case PNLineChartPointStyleTriangle
        case PNLineChartPointStyleSquare
    }
    
    public var getData = ({(index: Int) -> PNLineChartDataItem in
        return PNLineChartDataItem()
    })
    
    public var inflexionPointStyle:PNLineChartPointStyle = PNLineChartPointStyle.PNLineChartPointStyleNone
    public var color:UIColor = UIColor.grayColor()
    public var itemCount:Int = 0
    public var lineWidth:CGFloat = 2.0
    public var inflexionPointWidth:CGFloat = 6.0
    
    public init(){
        
    }
}

class PNChartLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.boldSystemFontOfSize(10.0)
        textColor = AppConfiguration.sideMenuText
        backgroundColor = UIColor.clearColor()
        textAlignment = NSTextAlignment.Center
        userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = UIFont.boldSystemFontOfSize(10.0)
        textColor = AppConfiguration.sideMenuText
        backgroundColor = UIColor.clearColor()
        textAlignment = NSTextAlignment.Center
        userInteractionEnabled = true
        //fatalError("init(coder:) has not been implemented")
    }
    
}

public protocol PNChartDelegate {
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex:Int)
    
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex:Int, keyPointIndex:Int)
    
    func userClickedOnBarChartIndex(barIndex:Int)
}

class PNValue{
    var point:CGPoint = CGPoint()
    init(point:CGPoint) {
        self.point = point
    }
}

public class PNLineChart: UIView{
    
    public var xLabels: NSArray = []{
        didSet{
            if showLabel {
                xLabelWidth = (chartCavanWidth! / CGFloat(xLabels.count))
                for index in 0 ..< xLabels.count {
                    let labelText = xLabels[index] as! NSString
                    let labelX = 2.0 * chartMargin +  ( CGFloat(index) * xLabelWidth) - (xLabelWidth / 2.0)
                    let label:PNChartLabel = PNChartLabel(frame: CGRect(x:  labelX, y: chartMargin + chartCavanHeight! + 10, width: xLabelWidth + 10, height: chartMargin))
                    label.textAlignment = NSTextAlignment.Right
                    label.attributedText = NSAttributedString(string: labelText as String, attributes: [NSForegroundColorAttributeName : UIColor.antiqueWhiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 15)!] as [String : AnyObject])
                    label.adjustsFontSizeToFitWidth = true
                    label.clipsToBounds = false
                    addSubview(label)
                    label.cheetah.rotate(M_PI / 3).run()
                }
            }else {
                xLabelWidth = frame.size.width / CGFloat(xLabels.count)
            }
        }
    }
    
    public var yLabels: NSArray = []{
        didSet{
            
            yLabelNum = CGFloat(yLabels.count)
            let yStep:CGFloat = 30.0
            let yStepHeight:CGFloat  = chartCavanHeight! / CGFloat(yLabelNum)
            var index:CGFloat = 0
            for _ in yLabels {
                let labelY = chartCavanHeight - (index * yStepHeight)
                let label: PNChartLabel = PNChartLabel(frame: CGRect(x: 0.0, y: CGFloat(labelY), width: chartMargin + 5, height: CGFloat(yLabelHeight) ) )
                label.textAlignment = NSTextAlignment.Left
                switch Double(yValueMin + (yStep * index)) {
                case 0:
                    label.attributedText = NSAttributedString(string: "0:00", attributes: [NSForegroundColorAttributeName : UIColor.antiqueWhiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 15)!] as [String : AnyObject])
                case 30:
                    label.attributedText = NSAttributedString(string: "0:30", attributes: [NSForegroundColorAttributeName : UIColor.antiqueWhiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 15)!] as [String : AnyObject])
                case 60:
                    label.attributedText = NSAttributedString(string: "1:00", attributes: [NSForegroundColorAttributeName : UIColor.antiqueWhiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 15)!] as [String : AnyObject])
                case 90:
                    label.attributedText = NSAttributedString(string: "1:30", attributes: [NSForegroundColorAttributeName : UIColor.antiqueWhiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 15)!] as [String : AnyObject])
                case 120:
                    label.attributedText = NSAttributedString(string: "2:00", attributes: [NSForegroundColorAttributeName : UIColor.antiqueWhiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 15)!] as [String : AnyObject])
                case 150:
                    label.attributedText = NSAttributedString(string: "2:30", attributes: [NSForegroundColorAttributeName : UIColor.antiqueWhiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 15)!] as [String : AnyObject])
                default:
                    break
                }
                label.adjustsFontSizeToFitWidth = true
                ++index
                addSubview(label)
            }
        }
    }
    
    public var chartData: NSArray = []{
        didSet{
            let yLabelsArray:NSMutableArray = NSMutableArray(capacity: chartData.count)
            var yMax:CGFloat = 0.0
            var yMin:CGFloat = CGFloat.max
            var yValue:CGFloat!
            for layer : AnyObject in chartLineArray{
                (layer as! CALayer).removeFromSuperlayer()
            }
            for layer : AnyObject in chartPointArray {
                (layer as! CALayer).removeFromSuperlayer()
            }
            chartLineArray = NSMutableArray(capacity: chartData.count)
            chartPointArray = NSMutableArray(capacity: chartData.count)
            let circle_stroke_width:CGFloat = 2.0
            let line_width:CGFloat = 3.0
            for chart : AnyObject in chartData{
                let chartObj = chart as! PNLineChartData
                let chartLine:CAShapeLayer = CAShapeLayer()
                chartLine.lineCap       = kCALineCapButt
                chartLine.lineJoin      = kCALineJoinMiter
                chartLine.fillColor     = UIColor.whiteColor().CGColor
                chartLine.lineWidth     = line_width
                chartLine.strokeEnd     = 0.0
                layer.addSublayer(chartLine)
                chartLineArray.addObject(chartLine)
                let pointLayer:CAShapeLayer = CAShapeLayer()
                pointLayer.strokeColor   = chartObj.color.CGColor
                pointLayer.lineCap       = kCALineCapRound
                pointLayer.lineJoin      = kCALineJoinBevel
                pointLayer.fillColor     = nil
                pointLayer.lineWidth     = circle_stroke_width
                layer.addSublayer(pointLayer)
                chartPointArray.addObject(pointLayer)
                for i in 0 ..< chartObj.itemCount{
                    yValue = CGFloat(chartObj.getData(i).y)
                    yLabelsArray.addObject(NSString(format: "%2f", yValue))
                    yMax = fmax(yMax, yValue)
                    yMin = fmin(yMin, yValue)
                }
            }
            setNeedsDisplay()
        }
    }
    
    var pathPoints: NSMutableArray = []
    
    //For X
    
    public var xLabelWidth:CGFloat = 10.0
    
    //For Y
    
    public let yValueMax:CGFloat = 150.0
    
    public let yValueMin:CGFloat = 0.0
    
    public var yLabelNum:CGFloat = 0.0
    
    public var yLabelHeight:CGFloat = 12.0
    
    //For Chart
    
    public var chartCavanHeight:CGFloat!
    
    public var chartCavanWidth:CGFloat!
    
    public var chartMargin:CGFloat = 35.0
    
    public var showLabel: Bool = true
    
    public var showCoordinateAxis: Bool = true
    
    // For Axis
    
    public var axisColor:UIColor = AppConfiguration.sideMenuText
    
    public var axisWidth:CGFloat = 1.0
    
    public var xUnit: NSString!
    
    public var yUnit: NSString!
    
    /**
     *  String formatter for float values in y labels. If not set, defaults to @"%1.f"
     */
    
    public var yLabelFormat:NSString = "%1.f"
    
    var chartLineArray: NSMutableArray = []  // Array[CAShapeLayer]
    var chartPointArray: NSMutableArray = [] // Array[CAShapeLayer] save the point layer
    
    var chartPaths: NSMutableArray = []     // Array of line path, one for each line.
    var pointPaths: NSMutableArray = []       // Array of point path, one for each line
    
    public var delegate:PNChartDelegate?
    
    
    // MARK: Functions
    
    func setDefaultValues() {
        backgroundColor = UIColor.whiteColor()
        clipsToBounds = true
        chartLineArray = NSMutableArray()
        showLabel = false
        pathPoints = NSMutableArray()
        userInteractionEnabled = true
        
        chartCavanWidth = frame.size.width - (chartMargin * 2.0)
        chartCavanHeight = frame.size.height - (chartMargin * 2.0)
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //touchPoint(touches, withEvent: event)
        //touchKeyPoint(touches, withEvent: event)
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //touchPoint(touches, withEvent: event)
        //touchKeyPoint(touches, withEvent: event)
    }
    
    func touchPoint(touches: NSSet!, withEvent event: UIEvent!){
        /*let touch:UITouch = touches.anyObject() as! UITouch
        let touchPoint = touch.locationInView(self)
        
        for linePoints:AnyObject in pathPoints {
            let linePointsArray = linePoints as! NSArray
            
            for i:NSInteger in 0 ..< (linePointsArray.count - 1){
                
                let p1:CGPoint = (linePointsArray[i] as! PNValue).point
                let p2:CGPoint = (linePointsArray[i+1] as! PNValue).point
                
                
                
                // Closest distance from point to line
                var distance:CGFloat = fabs(((p2.x - p1.x) * (touchPoint.y - p1.y)) - ((p1.x - touchPoint.x) * (p1.y - p2.y)))
                distance =  distance /  hypot( p2.x - p1.x,  p1.y - p2.y )
                
                
                if distance <= 5.0 {
                    // Conform to delegate parameters, figure out what bezier path this CGPoint belongs to.
                    
                    for path : AnyObject in chartPaths {
                        
                        let pointContainsPath:Bool = CGPathContainsPoint((path as! UIBezierPath).CGPath, nil, p1, false)
                        
                        if pointContainsPath {
                            
                            delegate?.userClickedOnLinePoint(touchPoint , lineIndex: chartPaths.indexOfObject(path))
                        }
                    }
                }
                
                
            }
            
            
        }*/
    }
    
    
    func touchKeyPoint(touches: NSSet!, withEvent event: UIEvent!){
        /*let touch:UITouch = touches.anyObject() as! UITouch
        let touchPoint = touch.locationInView(self)
        
        for linePoints: AnyObject in pathPoints {
            let linePointsArray: NSArray = pathPoints as NSArray
            
            for i:NSInteger in 0 ..< (linePointsArray.count - 1){
                let p1:CGPoint = (linePointsArray[i] as! PNValue).point
                let p2:CGPoint = (linePointsArray[i+1] as! PNValue).point
                
                let distanceToP1: CGFloat = fabs( CGFloat( hypot( touchPoint.x - p1.x , touchPoint.y - p1.y ) ))
                let distanceToP2: CGFloat = hypot( touchPoint.x - p2.x, touchPoint.y - p2.y)
                
                let distance: CGFloat = fmin(distanceToP1, distanceToP2)
                
                if distance <= 10.0 {
                    
                    delegate?.userClickedOnLineKeyPoint(touchPoint , lineIndex: pathPoints.indexOfObject(linePoints) ,keyPointIndex:(distance == distanceToP2 ? i + 1 : i) )
                }
            }
        }
        */
    }
    
    /**
     * This method will call and troke the line in animation
     */
    
    public func strokeChart(){
        chartPaths = NSMutableArray()
        pointPaths = NSMutableArray()
        for lineIndex in 0 ..< chartData.count {
            let chartData:PNLineChartData = self.chartData[lineIndex] as! PNLineChartData
            let chartLine:CAShapeLayer = chartLineArray[lineIndex] as! CAShapeLayer
            let pointLayer:CAShapeLayer = chartPointArray[lineIndex] as! CAShapeLayer
            var yValue:CGFloat?
            var innerGrade:CGFloat?
            UIGraphicsBeginImageContext(frame.size)
            let progressline:UIBezierPath = UIBezierPath()
            progressline.lineWidth = chartData.lineWidth
            progressline.lineCapStyle = CGLineCap.Round
            progressline.lineJoinStyle = CGLineJoin.Round
            let pointPath:UIBezierPath = UIBezierPath()
            pointPath.lineWidth = chartData.lineWidth
            chartPaths.addObject(progressline)
            pointPaths.addObject(pointPath)
            if !showLabel {
                chartCavanHeight = frame.size.height - 2 * yLabelHeight
                chartCavanWidth = frame.size.width
                chartMargin = 0.0
                xLabelWidth = (chartCavanWidth! / CGFloat(xLabels.count - 1))
            }
            let linePointsArray:NSMutableArray = NSMutableArray()
            var last_x:CGFloat = 0.0
            var last_y:CGFloat = 0.0
            let inflexionWidth:CGFloat = chartData.inflexionPointWidth
            for i:Int in 0 ..< chartData.itemCount {
                yValue = CGFloat(chartData.getData(i).y)
                innerGrade = (yValue! - yValueMin) / (yValueMax - yValueMin)
                let x:CGFloat = 2.0 * chartMargin +  (CGFloat(i) * xLabelWidth)
                let y:CGFloat = chartCavanHeight! - (innerGrade! * chartCavanHeight!) + (yLabelHeight / 2.0)
                switch chartData.inflexionPointStyle{
                case PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle:
                    
                    let circleRect:CGRect = CGRectMake(x-inflexionWidth/2.0, y-inflexionWidth/2.0, inflexionWidth,inflexionWidth)
                    let circleCenter:CGPoint = CGPointMake(circleRect.origin.x + (circleRect.size.width / 2.0), circleRect.origin.y + (circleRect.size.height / 2.0))
                    pointPath.moveToPoint(CGPointMake(circleCenter.x + (inflexionWidth/2), circleCenter.y))
                    pointPath.addArcWithCenter(circleCenter, radius: CGFloat(inflexionWidth/2.0), startAngle: 0.0, endAngle:CGFloat(2.0*M_PI), clockwise: true)
                    if i != 0 {
                        let distance:CGFloat = sqrt( pow( x-last_x, 2.0) + pow( y-last_y,2.0) )
                        let last_x1:CGFloat = last_x + (inflexionWidth/2) / distance * (x-last_x)
                        let last_y1:CGFloat = last_y + (inflexionWidth/2) / distance * (y-last_y)
                        let x1:CGFloat = x - (inflexionWidth/2) / distance * (x-last_x)
                        let y1:CGFloat = y - (inflexionWidth/2) / distance * (y-last_y)
                        progressline.moveToPoint(CGPointMake(last_x1, last_y1))
                        progressline.addLineToPoint(CGPointMake(x1, y1))
                    }
                    last_x = x
                    last_y = y
                case PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleSquare:
                    let squareRect:CGRect = CGRectMake(x-inflexionWidth/2, y-inflexionWidth/2, inflexionWidth,inflexionWidth)
                    let squareCenter:CGPoint = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y + (squareRect.size.height / 2))
                    pointPath.moveToPoint(CGPointMake(squareCenter.x - (inflexionWidth/2), squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x + (inflexionWidth/2), squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x + (inflexionWidth/2), squareCenter.y + (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x - (inflexionWidth/2), squareCenter.y + (inflexionWidth/2)))
                    pointPath.closePath()
                    if i != 0 {
                        let distance:CGFloat = sqrt( pow(x-last_x, 2) + pow(y-last_y,2) )
                        let last_x1:CGFloat = last_x + (inflexionWidth/2)
                        let last_y1:CGFloat = last_y + (inflexionWidth/2) / distance * (y-last_y)
                        let x1:CGFloat = x - (inflexionWidth/2)
                        let y1:CGFloat = y - (inflexionWidth/2) / distance * (y-last_y)
                        progressline.moveToPoint(CGPointMake(last_x1, last_y1))
                        progressline.addLineToPoint(CGPointMake(x1, y1))
                    }
                    last_x = x
                    last_y = y
                case PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleTriangle:
                    if i != 0 {
                        progressline.addLineToPoint(CGPointMake(x, y))
                    }
                    progressline.moveToPoint(CGPointMake(x, y))
                default:
                    if i != 0 {
                        progressline.addLineToPoint(CGPointMake(x, y))
                    }
                    progressline.moveToPoint(CGPointMake(x, y))
                }
                linePointsArray.addObject(PNValue(point: CGPointMake(x, y)))
            }
            pathPoints.addObject(linePointsArray)
            if chartData.color != UIColor.blackColor() {
                chartLine.strokeColor = chartData.color.CGColor
                pointLayer.strokeColor = chartData.color.CGColor
            } else {
                chartLine.strokeColor = AppConfiguration.sideMenuText.CGColor
                pointLayer.strokeColor = AppConfiguration.sideMenuText.CGColor
            }
            progressline.stroke()
            chartLine.path = progressline.CGPath
            pointLayer.path = pointPath.CGPath
            CATransaction.begin()
            let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 1.0
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue   = 1.0
            chartLine.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
            chartLine.strokeEnd = 1.0
            if chartData.inflexionPointStyle != PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleNone {
                pointLayer.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
            }
            CATransaction.commit()
            UIGraphicsEndImageContext()
        }
    }
    
    override public func drawRect(rect: CGRect)
    {
        if showCoordinateAxis {
            
            let yAsixOffset:CGFloat = 10.0
            
            let ctx:CGContextRef = UIGraphicsGetCurrentContext()!
            UIGraphicsPushContext(ctx)
            CGContextSetLineWidth(ctx, axisWidth)
            CGContextSetStrokeColorWithColor(ctx, axisColor.CGColor)
            
            let xAxisWidth:CGFloat = CGRectGetWidth(rect) - chartMargin/2.0
            let yAxisHeight:CGFloat = chartMargin + chartCavanHeight!
            
            // draw coordinate axis
            CGContextMoveToPoint(ctx, chartMargin + yAsixOffset, 0)
            CGContextAddLineToPoint(ctx, chartMargin + yAsixOffset, yAxisHeight)
            CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight)
            CGContextStrokePath(ctx)
            
            // draw y axis arrow
            CGContextMoveToPoint(ctx, chartMargin + yAsixOffset - 3, 6)
            CGContextAddLineToPoint(ctx, chartMargin + yAsixOffset, 0)
            CGContextAddLineToPoint(ctx, chartMargin + yAsixOffset + 3, 6)
            CGContextStrokePath(ctx);
            
            // draw x axis arrow
            CGContextMoveToPoint(ctx, xAxisWidth - 6, yAxisHeight - 3)
            CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight)
            CGContextAddLineToPoint(ctx, xAxisWidth - 6, yAxisHeight + 3);
            CGContextStrokePath(ctx)
            
            if showLabel{
                
                // draw x axis separator
                var point:CGPoint!
                for i:Int in 0 ..< xLabels.count {
                    point = CGPointMake(2 * chartMargin +  ( CGFloat(i) * xLabelWidth), chartMargin + chartCavanHeight!)
                    CGContextMoveToPoint(ctx, point.x, point.y - 2)
                    CGContextAddLineToPoint(ctx, point.x, point.y)
                    CGContextStrokePath(ctx)
                }
                
                // draw y axis separator
                let yStepHeight:CGFloat = chartCavanHeight! / CGFloat(yLabelNum)
                for i:Int in 0 ..< xLabels.count {
                    point = CGPointMake(chartMargin + yAsixOffset, (chartCavanHeight! - CGFloat(i) * yStepHeight + yLabelHeight/2.0
                    ))
                    CGContextMoveToPoint(ctx, point.x, point.y)
                    CGContextAddLineToPoint(ctx, point.x + 2, point.y)
                    CGContextStrokePath(ctx)
                }
            }
            
            let font:UIFont = UIFont.systemFontOfSize(11)
            // draw y unit
            if yUnit != nil{
                let height:CGFloat = heightOfString(yUnit, width: 30.0, font: font)
                let drawRect:CGRect = CGRectMake(chartMargin + 10 + 5, 0, 30.0, height)
                drawTextInContext(ctx, text:yUnit, rect:drawRect, font:font)
            }
            
            // draw x unit
            if xUnit != nil {
                let height:CGFloat = heightOfString(yUnit, width:30.0, font:font)
                let drawRect:CGRect = CGRectMake(CGRectGetWidth(rect) - chartMargin + 5, chartMargin + chartCavanHeight! - height/2, 25.0, height)
                drawTextInContext(ctx, text:yUnit, rect:drawRect, font:font)
            }
        }
        
        super.drawRect(rect)
    }
    
    func heightOfString(text: NSString, width: CGFloat, font: UIFont) -> CGFloat{
        let size : CGSize = CGSizeMake(width, CGFloat.max)
        let rect : CGRect = text.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesFontLeading , attributes: [NSFontAttributeName : font], context: nil)
        return rect.size.height
    }
    
    func drawTextInContext(ctx: CGContextRef, text: NSString!, rect: CGRect, font:UIFont){
        let priceParagraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle() as! NSMutableParagraphStyle
        priceParagraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        priceParagraphStyle.alignment = NSTextAlignment.Left
        
        text.drawInRect(rect, withAttributes: [ NSParagraphStyleAttributeName:priceParagraphStyle, NSFontAttributeName:font] )
    }
    
    
    // MARK: Init
    
    override public init(frame: CGRect){
        super.init(frame: frame)
        setDefaultValues()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setDefaultValues()
        //fatalError("init(coder:) has not been implemented")
    }

}


public extension UIColor {
    // MARK: - Closure
    typealias TransformBlock = (CGFloat) -> CGFloat
    
    // MARK: - Enums
    enum ColorScheme:Int {
        case analagous = 0, monochromatic, triad, complementary
    }
    
    enum ColorFormulation:Int {
        case rgba = 0, hsba, lab, cmyk
    }
    
    enum ColorDistance:Int {
        case cie76 = 0, cie94, cie2000
    }
    
    enum ColorComparison:Int {
        case darkness = 0, lightness, desaturated, saturated, red, green, blue
    }
    
    
    // MARK: - Color from Hex/RGBA/HSBA/CIE_LAB/CMYK
    convenience init(hex: String) {
        var rgbInt: UInt32 = 0
        let newHex = hex.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: newHex)
        scanner.scanHexInt(&rgbInt)
        let r: CGFloat = CGFloat((rgbInt & 0xFF0000) >> 16)/255.0
        let g: CGFloat = CGFloat((rgbInt & 0x00FF00) >> 8)/255.0
        let b: CGFloat = CGFloat(rgbInt & 0x0000FF)/255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    convenience init(rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)) {
        self.init(red: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    }
    
    convenience init(hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)) {
        self.init(hue: hsba.h, saturation: hsba.s, brightness: hsba.b, alpha: hsba.a)
    }
    
    convenience init(CIE_LAB: (l: CGFloat, a: CGFloat, b: CGFloat, alpha: CGFloat)) {
        // Set Up
        var Y = (CIE_LAB.l + 16.0)/116.0
        var X = CIE_LAB.a/500 + Y
        var Z = Y - CIE_LAB.b/200
        
        // Transform XYZ
        let deltaXYZ: TransformBlock = { k in
            let return1 = (pow(k, 3.0) > 0.008856)
            let return2 = pow(k, 3.0)
            let return3 = (k - 4/29.0)/7.787
            return return1 ? return2 : return3
        }
        X = deltaXYZ(X)*0.95047
        Y = deltaXYZ(Y)*1.000
        Z = deltaXYZ(Z)*1.08883
        
        // Convert XYZ to RGB
        let R = X*3.2406 + (Y * -1.5372) + (Z * -0.4986)
        let G = (X * -0.9689) + Y*1.8758 + Z*0.0415
        let B = X*0.0557 + (Y * -0.2040) + Z*1.0570
        let deltaRGB: TransformBlock = { k in
            return (k > 0.0031308) ? 1.055 * (pow(k, (1/2.4))) - 0.055 : k * 12.92
        }
        
        self.init(rgba: (deltaRGB(R), deltaRGB(G), deltaRGB(B), CIE_LAB.alpha))
    }
    
    convenience init(cmyk: (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat)) {
        let cmyTransform: TransformBlock = { x in
            return x * (1 - cmyk.k) + cmyk.k
        }
        let C = cmyTransform(cmyk.c)
        let M = cmyTransform(cmyk.m)
        let Y = cmyTransform(cmyk.y)
        self.init(rgba: (1 - C, 1 - M, 1 - Y, 1.0))
    }
    
    
    // MARK: - Color to Hex/RGBA/HSBA/CIE_LAB/CMYK
    func hexString() -> String {
        let rgbaT = rgba()
        let r: Int = Int(rgbaT.r * 255)
        let g: Int = Int(rgbaT.g * 255)
        let b: Int = Int(rgbaT.b * 255)
        let red = NSString(format: "%02x", r)
        let green = NSString(format: "%02x", g)
        let blue = NSString(format: "%02x", b)
        return "#\(red)\(green)\(blue)"
    }
    
    func rgba() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if self.respondsToSelector(#selector(UIColor.getRed(_:green:blue:alpha:))) {
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
        } else {
            let components = CGColorGetComponents(self.CGColor)
            r = (components[0])
            g = (components[1])
            b = (components[2])
            a = (components[3])
        }
        
        return (r, g, b, a)
    }
    
    func hsba() -> (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if self.respondsToSelector(#selector(UIColor.getHue(_:saturation:brightness:alpha:))) {
            self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        }
        
        return (h, s, b, a)
    }
    
    
    
    func xyz() -> (x: CGFloat, y: CGFloat, z: CGFloat, alpha: CGFloat) {
        // Get RGBA values
        let rgbaT = rgba()
        
        // Transfrom values to XYZ
        let deltaR: TransformBlock = { R in
            
            let return1 = (R > 0.04045)
            let return2 = pow((R + 0.055)/1.055, 2.40)
            let return3 = (R/12.92)
            return return1 ? return2 : return3
        }
        let R = deltaR(rgbaT.r)
        let G = deltaR(rgbaT.g)
        let B = deltaR(rgbaT.b)
        let X = (R*41.24 + G*35.76 + B*18.05)
        let Y = (R*21.26 + G*71.52 + B*7.22)
        let Z = (R*1.93 + G*11.92 + B*95.05)
        
        return (X, Y, Z, rgbaT.a)
    }
    
    func cmyk() -> (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) {
        // Convert RGB to CMY
        let rgbaT = rgba()
        let C = 1 - rgbaT.r
        let M = 1 - rgbaT.g
        let Y = 1 - rgbaT.b
        
        // Find K
        let K = min(1, min(C, min(Y, M)))
        if (K == 1) {
            return (0, 0, 0, 1)
        }
        
        // Convert cmyk
        let newCMYK: TransformBlock = { x in
            return (x - K)/(1 - K)
        }
        return (newCMYK(C), newCMYK(M), newCMYK(Y), K)
    }
    
    
    // MARK: - Color Components
    func red() -> CGFloat {
        return rgba().r
    }
    
    func green() -> CGFloat {
        return rgba().g
    }
    
    func blue() -> CGFloat {
        return rgba().b
    }
    
    func alpha() -> CGFloat {
        return rgba().a
    }
    
    func hue() -> CGFloat {
        return hsba().h
    }
    
    func saturation() -> CGFloat {
        return hsba().s
    }
    
    func brightness() -> CGFloat {
        return hsba().b
    }
    
    
    
    func cyan() -> CGFloat {
        return cmyk().c
    }
    
    func magenta() -> CGFloat {
        return cmyk().m
    }
    
    func yellow() -> CGFloat {
        return cmyk().y
    }
    
    func keyBlack() -> CGFloat {
        return cmyk().k
    }
    
    
    
    // MARK: Blues
    class func tealColor() -> UIColor
    {
        return self.colorWith(28, G:160, B:170, A:1.0)
    }
    
    class func steelBlueColor() -> UIColor
    {
        return self.colorWith(103, G:153, B:170, A:1.0)
    }
    
    class func robinEggColor() -> UIColor
    {
        return self.colorWith(141, G:218, B:247, A:1.0)
    }
    
    class func pastelBlueColor() -> UIColor
    {
        return self.colorWith(99, G:161, B:247, A:1.0)
    }
    
    class func turquoiseColor() -> UIColor
    {
        return self.colorWith(112, G:219, B:219, A:1.0)
    }
    
    class func skyBlueColor() -> UIColor
    {
        return self.colorWith(0, G:178, B:238, A:1.0)
    }
    
    class func indigoColor() -> UIColor
    {
        return self.colorWith(13, G:79, B:139, A:1.0)
    }
    
    class func denimColor() -> UIColor
    {
        return self.colorWith(67, G:114, B:170, A:1.0)
    }
    
    class func blueberryColor() -> UIColor
    {
        return self.colorWith(89, G:113, B:173, A:1.0)
    }
    
    class func cornflowerColor() -> UIColor
    {
        return self.colorWith(100, G:149, B:237, A:1.0)
    }
    
    class func babyBlueColor() -> UIColor
    {
        return self.colorWith(190, G:220, B:230, A:1.0)
    }
    
    class func midnightBlueColor() -> UIColor
    {
        return self.colorWith(13, G:26, B:35, A:1.0)
    }
    
    class func fadedBlueColor() -> UIColor
    {
        return self.colorWith(23, G:137, B:155, A:1.0)
    }
    
    class func icebergColor() -> UIColor
    {
        return self.colorWith(200, G:213, B:219, A:1.0)
    }
    
    class func waveColor() -> UIColor
    {
        return self.colorWith(102, G:169, B:251, A:1.0)
    }
    
    
    // MARK: Greens
    class func emeraldColor() -> UIColor
    {
        return self.colorWith(1, G:152, B:117, A:1.0)
    }
    
    class func grassColor() -> UIColor
    {
        return self.colorWith(99, G:214, B:74, A:1.0)
    }
    
    class func pastelGreenColor() -> UIColor
    {
        return self.colorWith(126, G:242, B:124, A:1.0)
    }
    
    class func seafoamColor() -> UIColor
    {
        return self.colorWith(77, G:226, B:140, A:1.0)
    }
    
    class func paleGreenColor() -> UIColor
    {
        return self.colorWith(176, G:226, B:172, A:1.0)
    }
    
    class func cactusGreenColor() -> UIColor
    {
        return self.colorWith(99, G:111, B:87, A:1.0)
    }
    
    class func chartreuseColor() -> UIColor
    {
        return self.colorWith(69, G:139, B:0, A:1.0)
    }
    
    class func hollyGreenColor() -> UIColor
    {
        return self.colorWith(32, G:87, B:14, A:1.0)
    }
    
    class func oliveColor() -> UIColor
    {
        return self.colorWith(91, G:114, B:34, A:1.0)
    }
    
    class func oliveDrabColor() -> UIColor
    {
        return self.colorWith(107, G:142, B:35, A:1.0)
    }
    
    class func moneyGreenColor() -> UIColor
    {
        return self.colorWith(134, G:198, B:124, A:1.0)
    }
    
    class func honeydewColor() -> UIColor
    {
        return self.colorWith(216, G:255, B:231, A:1.0)
    }
    
    class func limeColor() -> UIColor
    {
        return self.colorWith(56, G:237, B:56, A:1.0)
    }
    
    class func cardTableColor() -> UIColor
    {
        return self.colorWith(87, G:121, B:107, A:1.0)
    }
    
    
    // MARK: Reds
    class func salmonColor() -> UIColor
    {
        return self.colorWith(233, G:87, B:95, A:1.0)
    }
    
    class func brickRedColor() -> UIColor
    {
        return self.colorWith(151, G:27, B:16, A:1.0)
    }
    
    class func easterPinkColor() -> UIColor
    {
        return self.colorWith(241, G:167, B:162, A:1.0)
    }
    
    class func grapefruitColor() -> UIColor
    {
        return self.colorWith(228, G:31, B:54, A:1.0)
    }
    
    class func pinkColor() -> UIColor
    {
        return self.colorWith(255, G:95, B:154, A:1.0)
    }
    
    class func indianRedColor() -> UIColor
    {
        return self.colorWith(205, G:92, B:92, A:1.0)
    }
    
    class func strawberryColor() -> UIColor
    {
        return self.colorWith(190, G:38, B:37, A:1.0)
    }
    
    class func coralColor() -> UIColor
    {
        return self.colorWith(240, G:128, B:128, A:1.0)
    }
    
    class func maroonColor() -> UIColor
    {
        return self.colorWith(80, G:4, B:28, A:1.0)
    }
    
    class func watermelonColor() -> UIColor
    {
        return self.colorWith(242, G:71, B:63, A:1.0)
    }
    
    class func tomatoColor() -> UIColor
    {
        return self.colorWith(255, G:99, B:71, A:1.0)
    }
    
    class func pinkLipstickColor() -> UIColor
    {
        return self.colorWith(255, G:105, B:180, A:1.0)
    }
    
    class func paleRoseColor() -> UIColor
    {
        return self.colorWith(255, G:228, B:225, A:1.0)
    }
    
    class func crimsonColor() -> UIColor
    {
        return self.colorWith(187, G:18, B:36, A:1.0)
    }
    
    
    // MARK: Purples
    class func eggplantColor() -> UIColor
    {
        return self.colorWith(105, G:5, B:98, A:1.0)
    }
    
    class func pastelPurpleColor() -> UIColor
    {
        return self.colorWith(207, G:100, B:235, A:1.0)
    }
    
    class func palePurpleColor() -> UIColor
    {
        return self.colorWith(229, G:180, B:235, A:1.0)
    }
    
    class func coolPurpleColor() -> UIColor
    {
        return self.colorWith(140, G:93, B:228, A:1.0)
    }
    
    class func violetColor() -> UIColor
    {
        return self.colorWith(191, G:95, B:255, A:1.0)
    }
    
    class func plumColor() -> UIColor
    {
        return self.colorWith(139, G:102, B:139, A:1.0)
    }
    
    class func lavenderColor() -> UIColor
    {
        return self.colorWith(204, G:153, B:204, A:1.0)
    }
    
    class func raspberryColor() -> UIColor
    {
        return self.colorWith(135, G:38, B:87, A:1.0)
    }
    
    class func fuschiaColor() -> UIColor
    {
        return self.colorWith(255, G:20, B:147, A:1.0)
    }
    
    class func grapeColor() -> UIColor
    {
        return self.colorWith(54, G:11, B:88, A:1.0)
    }
    
    class func periwinkleColor() -> UIColor
    {
        return self.colorWith(135, G:159, B:237, A:1.0)
    }
    
    class func orchidColor() -> UIColor
    {
        return self.colorWith(218, G:112, B:214, A:1.0)
    }
    
    
    // MARK: Yellows
    class func goldenrodColor() -> UIColor
    {
        return self.colorWith(215, G:170, B:51, A:1.0)
    }
    
    class func yellowGreenColor() -> UIColor
    {
        return self.colorWith(192, G:242, B:39, A:1.0)
    }
    
    class func bananaColor() -> UIColor
    {
        return self.colorWith(229, G:227, B:58, A:1.0)
    }
    
    class func mustardColor() -> UIColor
    {
        return self.colorWith(205, G:171, B:45, A:1.0)
    }
    
    class func buttermilkColor() -> UIColor
    {
        return self.colorWith(254, G:241, B:181, A:1.0)
    }
    
    class func goldColor() -> UIColor
    {
        return self.colorWith(139, G:117, B:18, A:1.0)
    }
    
    class func creamColor() -> UIColor
    {
        return self.colorWith(240, G:226, B:187, A:1.0)
    }
    
    class func lightCreamColor() -> UIColor
    {
        return self.colorWith(240, G:238, B:215, A:1.0)
    }
    
    class func wheatColor() -> UIColor
    {
        return self.colorWith(240, G:238, B:215, A:1.0)
    }
    
    class func beigeColor() -> UIColor
    {
        return self.colorWith(245, G:245, B:220, A:1.0)
    }
    
    
    // MARK: Oranges
    class func peachColor() -> UIColor
    {
        return self.colorWith(242, G:187, B:97, A:1.0)
    }
    
    class func burntOrangeColor() -> UIColor
    {
        return self.colorWith(184, G:102, B:37, A:1.0)
    }
    
    class func pastelOrangeColor() -> UIColor
    {
        return self.colorWith(248, G:197, B:143, A:1.0)
    }
    
    class func cantaloupeColor() -> UIColor
    {
        return self.colorWith(250, G:154, B:79, A:1.0)
    }
    
    class func carrotColor() -> UIColor
    {
        return self.colorWith(237, G:145, B:33, A:1.0)
    }
    
    class func mandarinColor() -> UIColor
    {
        return self.colorWith(247, G:145, B:55, A:1.0)
    }
    
    
    // MARK: Browns
    class func chiliPowderColor() -> UIColor
    {
        return self.colorWith(199, G:63, B:23, A:1.0)
    }
    
    class func burntSiennaColor() -> UIColor
    {
        return self.colorWith(138, G:54, B:15, A:1.0)
    }
    
    class func chocolateColor() -> UIColor
    {
        return self.colorWith(94, G:38, B:5, A:1.0)
    }
    
    class func coffeeColor() -> UIColor
    {
        return self.colorWith(141, G:60, B:15, A:1.0)
    }
    
    class func cinnamonColor() -> UIColor
    {
        return self.colorWith(123, G:63, B:9, A:1.0)
    }
    
    class func almondColor() -> UIColor
    {
        return self.colorWith(196, G:142, B:72, A:1.0)
    }
    
    class func eggshellColor() -> UIColor
    {
        return self.colorWith(252, G:230, B:201, A:1.0)
    }
    
    class func sandColor() -> UIColor
    {
        return self.colorWith(222, G:182, B:151, A:1.0)
    }
    
    class func mudColor() -> UIColor
    {
        return self.colorWith(70, G:45, B:29, A:1.0)
    }
    
    class func siennaColor() -> UIColor
    {
        return self.colorWith(160, G:82, B:45, A:1.0)
    }
    
    class func dustColor() -> UIColor
    {
        return self.colorWith(236, G:214, B:197, A:1.0)
    }
    

    
    // MARK: - Lighten/Darken Color
    func lightenedColor(percentage: CGFloat) -> UIColor {
        return modifiedColor(percentage + 1.0)
    }
    
    func darkenedColor(percentage: CGFloat) -> UIColor {
        return modifiedColor(1.0 - percentage)
    }
    
    private func modifiedColor(percentage: CGFloat) -> UIColor {
        let hsbaT = hsba()
        return UIColor(hsba: (hsbaT.h, hsbaT.s, hsbaT.b * percentage, hsbaT.a))
    }
    
    
    // MARK: - Contrasting Color
    func blackOrWhiteContrastingColor() -> UIColor {
        let rgbaT = rgba()
        let value = 1 - ((0.299 * rgbaT.r) + (0.587 * rgbaT.g) + (0.114 * rgbaT.b));
        return value > 0.5 ? UIColor.blackColor() : UIColor.whiteColor()
    }
    
    
    // MARK: - Complementary Color
    func complementaryColor() -> UIColor {
        let hsbaT = hsba()
        let newH = UIColor.addDegree(180.0, staticDegree: hsbaT.h*360.0)
        return UIColor(hsba: (newH, hsbaT.s, hsbaT.b, hsbaT.a))
    }
    
    
    func colorScheme(type: ColorScheme) -> [UIColor] {
        switch (type) {
        case .analagous:
            return UIColor.analgousColors(self.hsba())
        case .monochromatic:
            return UIColor.monochromaticColors(self.hsba())
        case .triad:
            return UIColor.triadColors(self.hsba())
        default:
            return UIColor.complementaryColors(self.hsba())
        }
    }
    
    private class func analgousColors(hsbaT: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)) -> [UIColor] {
        return [UIColor(hsba: (self.addDegree(30, staticDegree: hsbaT.h*360)/360.0, hsbaT.s-0.05, hsbaT.b-0.1, hsbaT.a)),
                UIColor(hsba: (self.addDegree(15, staticDegree: hsbaT.h*360)/360.0, hsbaT.s-0.05, hsbaT.b-0.05, hsbaT.a)),
                UIColor(hsba: (self.addDegree(-15, staticDegree: hsbaT.h*360)/360.0, hsbaT.s-0.05, hsbaT.b-0.05, hsbaT.a)),
                UIColor(hsba: (self.addDegree(-30, staticDegree: hsbaT.h*360)/360.0, hsbaT.s-0.05, hsbaT.b-0.1, hsbaT.a))]
    }
    
    private class func monochromaticColors(hsbaT: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)) -> [UIColor] {
        return [UIColor(hsba: (hsbaT.h, hsbaT.s/2, hsbaT.b/3, hsbaT.a)),
                UIColor(hsba: (hsbaT.h, hsbaT.s, hsbaT.b/2, hsbaT.a)),
                UIColor(hsba: (hsbaT.h, hsbaT.s/3, 2*hsbaT.b/3, hsbaT.a)),
                UIColor(hsba: (hsbaT.h, hsbaT.s, 4*hsbaT.b/5, hsbaT.a))]
    }
    
    private class func triadColors(hsbaT: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)) -> [UIColor] {
        return [UIColor(hsba: (self.addDegree(120, staticDegree: hsbaT.h*360)/360.0, 2*hsbaT.s/3, hsbaT.b-0.05, hsbaT.a)),
                UIColor(hsba: (self.addDegree(120, staticDegree: hsbaT.h*360)/360.0, hsbaT.s, hsbaT.b, hsbaT.a)),
                UIColor(hsba: (self.addDegree(240, staticDegree: hsbaT.h*360)/360.0, hsbaT.s, hsbaT.b, hsbaT.a)),
                UIColor(hsba: (self.addDegree(240, staticDegree: hsbaT.h*360)/360.0, 2*hsbaT.s/3, hsbaT.b-0.05, hsbaT.a))]
    }
    
    private class func complementaryColors(hsbaT: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)) -> [UIColor] {
        return [UIColor(hsba: (hsbaT.h, hsbaT.s, 4*hsbaT.b/5, hsbaT.a)),
                UIColor(hsba: (hsbaT.h, 5*hsbaT.s/7, hsbaT.b, hsbaT.a)),
                UIColor(hsba: (self.addDegree(180, staticDegree: hsbaT.h*360)/360.0, hsbaT.s, hsbaT.b, hsbaT.a)),
                UIColor(hsba: (self.addDegree(180, staticDegree: hsbaT.h*360)/360.0, 5*hsbaT.s/7, hsbaT.b, hsbaT.a))]
    }
    
    
    // MARK: - Predefined Colors
    // MARK: -
    // MARK: System Colors
    class func infoBlueColor() -> UIColor
    {
        return self.colorWith(47, G:112, B:225, A:1.0)
    }
    
    class func successColor() -> UIColor
    {
        return self.colorWith(83, G:215, B:106, A:1.0)
    }
    
    class func warningColor() -> UIColor
    {
        return self.colorWith(221, G:170, B:59, A:1.0)
    }
    
    class func dangerColor() -> UIColor
    {
        return self.colorWith(229, G:0, B:15, A:1.0)
    }
    
    
    // MARK: Whites
    class func antiqueWhiteColor() -> UIColor
    {
        return self.colorWith(250, G:235, B:215, A:1.0)
    }
    
    class func oldLaceColor() -> UIColor
    {
        return self.colorWith(253, G:245, B:230, A:1.0)
    }
    
    class func ivoryColor() -> UIColor
    {
        return self.colorWith(255, G:255, B:240, A:1.0)
    }
    
    class func seashellColor() -> UIColor
    {
        return self.colorWith(255, G:245, B:238, A:1.0)
    }
    
    class func ghostWhiteColor() -> UIColor
    {
        return self.colorWith(248, G:248, B:255, A:1.0)
    }
    
    class func snowColor() -> UIColor
    {
        return self.colorWith(255, G:250, B:250, A:1.0)
    }
    
    class func linenColor() -> UIColor
    {
        return self.colorWith(250, G:240, B:230, A:1.0)
    }
    
    
    // MARK: Grays
    class func black25PercentColor() -> UIColor
    {
        return UIColor(white:0.25, alpha:1.0)
    }
    
    class func black50PercentColor() -> UIColor
    {
        return UIColor(white:0.5,  alpha:1.0)
    }
    
    class func black75PercentColor() -> UIColor
    {
        return UIColor(white:0.75, alpha:1.0)
    }
    
    class func warmGrayColor() -> UIColor
    {
        return self.colorWith(133, G:117, B:112, A:1.0)
    }
    
    class func coolGrayColor() -> UIColor
    {
        return self.colorWith(118, G:122, B:133, A:1.0)
    }
    
    class func charcoalColor() -> UIColor
    {
        return self.colorWith(34, G:34, B:34, A:1.0)
    }
    
    
    // MARK: - Private Helpers
    private class func colorWith(R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) -> UIColor {
        return UIColor(rgba: (R/255.0, G/255.0, B/255.0, A))
    }
    
    private class func addDegree(addDegree: CGFloat, staticDegree: CGFloat) -> CGFloat {
        let s = staticDegree + addDegree;
        if (s > 360) {
            return s - 360;
        }
        else if (s < 0) {
            return -1 * s;
        }
        else {
            return s;
        }
    }
}

//
//  BrushChart.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/25/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation


var AMTimes: [CGFloat] = [0,0,0,0,0,0,0]
var PMTimes: [CGFloat] = [0,0,0,0,0,0,0]

var weekDates: [NSDate] = [NSDate]()

class BrushChart : UIViewController, NavgationTransitionable {
    
    var lineChart:PNLineChart!
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    @IBOutlet weak var ChartSpace: UIView!
    @IBOutlet weak var Morning: UILabel!
    @IBOutlet weak var Evening: UILabel!
    @IBOutlet weak var DaysLabel: UILabel!
    
    
    var chartLoaded = false
    
    override func viewDidLoad() {
        addHamMenu()
        removeBack()
        view.backgroundColor = AppConfiguration.backgroundColor
        self.title = "Brush Chart"
        
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            self.view.frame = CGRect(x: 0, y: 44, width: 414, height: 643)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            self.view.frame = CGRect(x: 0, y: 44, width: 375, height: 574)
        } else {
            self.view.frame = CGRect(x: 0, y: 44, width: 320, height: 475)
        }
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ProgressHUD.show("Getting Brush Times...", spincolor1:AppConfiguration.navColor.darkenedColor(0.3), backcolor1:UIColor(white: 1.0, alpha: 0.2) , textcolor1:AppConfiguration.navColor.darkenedColor(0.4))
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            loadChart(AMTimes, points2: PMTimes, frame: CGRect(x: 15, y: 100, width: self.view.frame.width - 30, height: self.view.frame.height * 0.6))
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            loadChart(AMTimes, points2: PMTimes, frame: CGRect(x: 30, y: 65, width: self.view.frame.width - 60, height: self.view.frame.height * 0.5))
        } else {
            loadChart(AMTimes, points2: PMTimes, frame: CGRect(x: 20, y: self.view.frame.midY - (self.view.frame.height * 0.4), width: self.view.frame.width - 40, height: self.view.frame.height * 0.6))
        }
    }
    
    
    func loadChart(points: [CGFloat],points2: [CGFloat], frame: CGRect) {
        lineChart = PNLineChart(frame: frame)
        lineChart.yLabels = [0,30,60,90,120,150]
        lineChart.showLabel = true
        lineChart.yLabelHeight = lineChart.frame.height/5
        lineChart.backgroundColor = UIColor.clearColor()
        lineChart.xLabels = getCurrentWeek()
        lineChart.showCoordinateAxis = true
        lineChart.axisColor = AppConfiguration.sideMenuText
        lineChart.layer.masksToBounds = false
        var data01Array: [CGFloat] = points
        let data01:PNLineChartData = PNLineChartData()
        data01.color = AppConfiguration.tealColor
        data01.itemCount = 7
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            let yValue:CGFloat = data01Array[index]
            let item = PNLineChartDataItem(y: yValue)
            return item
        })
        var data02Array: [CGFloat] = points2
        let data02:PNLineChartData = PNLineChartData()
        data02.color = AppConfiguration.purpleColor
        data02.itemCount = 7
        data02.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
        data02.getData = ({(index: Int) -> PNLineChartDataItem in
            let yValue:CGFloat = data02Array[index]
            let item = PNLineChartDataItem(y: yValue)
            return item
        })
        lineChart.chartData = [data01,data02]
        lineChart.strokeChart()
        view.addSubview(lineChart)
        self.chartLoaded = true
        ProgressHUD.dismiss()
    }
    
    func getCurrentWeek() -> [String] {
        var dates: [String] = []
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM-d"
        var DateInFormat = dateFormatter.stringFromDate(weekDates[0])
        dates.append(DateInFormat)
        for i in 1...6 {
            DateInFormat = dateFormatter.stringFromDate(weekDates[i])
            dates.append(DateInFormat)
        }
        return dates
    }
    
    
}

extension NSDate {
    func nextDay() -> NSDate? {
        let cal: NSCalendar = NSCalendar.currentCalendar()
        let comp: NSDateComponents = NSDateComponents()
        comp.month = 0
        comp.day = 1
        return cal.dateByAddingComponents(comp, toDate: self, options: [])!
    }
}

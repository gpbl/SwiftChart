//
//  StockChartViewController.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

class StockChartViewController: UIViewController, ChartDelegate {
    
    var selectedChart = 0
    
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var chart: Chart!
    
    private var labelLeadingMarginInitialConstant: CGFloat!
    
    override func viewDidLoad() {
        
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        initializeChart()
    }
    
    func initializeChart() {
        chart.delegate = self
        
        // Initialize data series and labels
        let stockValues = getStockValues()
        
        var serieData: Array<Float> = []
        var labels: Array<Float> = []
        var labelsAsString: Array<String> = []
        
        // Date formatter to retrieve the month names
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM"
        
        for (i, value) in enumerate(stockValues) {
            
            serieData.append(value["close"] as! Float)
            
            // Use only one label for each month
            let month = dateFormatter.stringFromDate(value["date"] as! NSDate).toInt()!
            let monthAsString:String = dateFormatter.monthSymbols[month - 1] as! String
            if (labels.count == 0 || labelsAsString.last != monthAsString) {
                labels.append(Float(i))
                labelsAsString.append(monthAsString)
            }
        }
        
        let series = ChartSeries(serieData)
        series.area = true
        
        
        // Configure chart layout
        chart.lineWidth = 0.5
        chart.labelFont = UIFont(name: "HelveticaNeue-Light", size: 12)!
        chart.xLabels = labels
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return labelsAsString[labelIndex]
        }
        chart.xLabelsTextAlignment = .Center
        chart.yLabelsOnRightSide = true
        // Add some padding above the x-axis
        chart.minY = minElement(serieData) - 5
        
        chart.addSeries(series)
    }
    
    // MARK: - Chart delegate
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            let numberFormatter = NSNumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            label.text = numberFormatter.stringFromNumber(value)!
            
            // Align the label to the touch left position, centered
            var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
            
            // Avoid placing the label on the left of the chart
            if constant < labelLeadingMarginInitialConstant {
                constant = labelLeadingMarginInitialConstant
            }
            
            // Avoid placing the label on the right of the chart
            let rightMargin = chart.frame.width - label.frame.width
            if constant > rightMargin {
                constant = rightMargin
            }
            
            labelLeadingMarginConstraint.constant = constant
        }
    }
    
    func didFinishTouchingChart(chart: Chart) {
        label.text = ""
        labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
    }
    
    func animationDurationForSerieAtIndex(index: Int) -> CFTimeInterval {
        let values: Array<CFTimeInterval> = [1.0, 1.6, 2.2]
        return values[index]
    }
    
    // MARK: - Parsing
    func getStockValues() -> Array<Dictionary<String, Any>> {
        
        // Read the JSON file
        let filePath = NSBundle.mainBundle().pathForResource("AAPL", ofType: "json")!
        let jsonData = NSData(contentsOfFile: filePath)
        let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: nil) as! NSDictionary
        let jsonValues = json["quotes"] as! Array<NSDictionary>
        
        // Parse data
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var values = jsonValues.map() { (value: NSDictionary) -> Dictionary<String, Any> in
            let date = dateFormatter.dateFromString(value["date"]! as! String)
            let close = (value["close"]! as! NSNumber).floatValue
            return ["date": date!, "close": close]
        }
        
        return values
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
    }
    
}
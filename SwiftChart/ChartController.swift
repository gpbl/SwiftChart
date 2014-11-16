//
//  ChartViewController.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
    @IBOutlet weak var chart: Chart!
    var selectedChart = 0
    
    override func viewDidLoad() {
        
        // Draw the chart selected from the TableViewController
        
        switch selectedChart {
        case 0:
            
            // Initialization with variadic data
            let serie = ChartSerie(data: 0, 6, 2, 8, 4, 7, 3, 10, 8)
            chart.addSerie(serie)
            
        case 1:
            
            // Example with multiple series, the first two with area enabled
            
            let serie1 = ChartSerie(data: 0, 6, 2, 8, 4, 7, 3, 10, 8)
            serie1.color = ChartColors.yellowColor()
            serie1.area = true
            
            let serie2 = ChartSerie(data: 1, 0, 0.5, 0.2, 0, 1, 0.8, 0.3, 1)
            serie2.color = ChartColors.redColor()
            serie2.area = true
            
            // A partially filled serie
            let serie3 = ChartSerie(data: 9, 8, 10, 8.5, 9.5, 10)
            serie3.color = ChartColors.purpleColor()
            
            chart.addSeries([serie1, serie2, serie3])
            
            // Format labels as integers
            chart.xLabelFormatter = { "\(Int($0))" }
            chart.yLabelFormatter = { "\(Int($0))" }
            
            
        case 2:
            
            // Initialization with (x, y) data
            let data: Array<ChartPoint> = [
                (x: 1, y: 3),
                (x: 2, y: 6),
                (x: 3, y: -2),
                (x: 4, y: 6),
                (x: 5, y: 2),
                (x: 6, y: 4),
                (x: 7, y: -4),
                (x: 8, y: 3),
                (x: 9, y: -6),
                (x: 10, y: -1),
                (x: 11, y: -5)
            ]
            
            let serie = ChartSerie(data: data, aboveColor: ChartColors.redColor(), belowColor: ChartColors.blueColor(), line: true, area: true)
            
            chart.addSerie(serie)
            
            // Set minimum and maximum values for y-axis
            chart.minY = -7
            chart.maxY = 7
            
            // Format y-axis, e.g. with units
            chart.yLabelFormatter = { "\(Int($0)) ºC" }
        
        
        case 3:
            
            view.backgroundColor = UIColor.blackColor()
            chart.backgroundColor = UIColor.blackColor()
            chart.areaAlphaComponent = 0.3
            chart.lineWidth = 0.5
            chart.labelColor = UIColor.whiteColor()
            chart.axisColor = UIColor.whiteColor()
            chart.yLabelsOnRightSide = true
            
            // Initialization with (x, y) data
            let data: Array<ChartPoint> = [
                (x: 1, y: 3),
                (x: 2, y: 6),
                (x: 3, y: -2),
                (x: 4, y: 6),
                (x: 5, y: 2),
                (x: 6, y: 4),
                (x: 7, y: -4),
                (x: 8, y: 3),
                (x: 9, y: -6),
                (x: 10, y: -1),
                (x: 11, y: -5)
            ]
            
            let serie = ChartSerie(data: data)
            serie.area = true
            
            chart.addSerie(serie)
            
            // Set minimum and maximum values for y-axis
            chart.minY = -10
            chart.maxY = 10
            
            // Format y-axis, e.g. with units
            chart.yLabelFormatter = { "\(Int($0)) ºC" }
            
        default: break;
            
        }
        
        
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
        //            resetChartLabel()
    }
    
    
}

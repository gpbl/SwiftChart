//
//  BasicChartViewController.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

class BasicChartViewController: UIViewController, ChartDelegate {
    @IBOutlet weak var chart: Chart!
    var selectedChart = 0
    
    override func viewDidLoad() {
        
        // Draw the chart selected from the TableViewController
        
        chart.delegate = self
        
        switch selectedChart {
        case 0:
            
            let chart2 = Chart(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
            
            // Simple chart
            let serie = ChartSerie([0, 6, 2, 8, 4, 7, 3, 10, 8])
            serie.color = ChartColors.greenColor()
            chart.addSerie(serie)
            
            
        case 1:
            
            // Example with multiple series, the first two with area enabled
            
            let serie1 = ChartSerie([0, 6, 2, 8, 4, 7, 3, 10, 8])
            serie1.color = ChartColors.yellowColor()
            serie1.area = true
            
            let serie2 = ChartSerie([1, 0, 0.5, 0.2, 0, 1, 0.8, 0.3, 1])
            serie2.color = ChartColors.redColor()
            serie2.area = true
            
            // A partially filled serie
            let serie3 = ChartSerie([9, 8, 10, 8.5, 9.5, 10])
            serie3.color = ChartColors.purpleColor()
            
            chart.addSeries([serie1, serie2, serie3])
            
        case 2:
            
            // Chart with y-min, y-max and y-labels formatter
            
            let data: Array<Float> = [3, 6, -2, 6, 2, 4, -4, 3, -6, -1, -5]
            
            let serie = ChartSerie(data)
            serie.area = true
            
            chart.addSerie(serie)
            
            // Set minimum and maximum values for y-axis
            chart.minY = -7
            chart.maxY = 7
            
            // Format y-axis, e.g. with units
            chart.yLabelsFormatter = { String(Int($1)) +  "ºC" }
            
            
        default: break;
            
        }
        
        
    }
    
    // Chart delegate
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        for (serieIndex, dataIndex) in enumerate(indexes) {
            if let value = chart.valueForSerie(serieIndex, atIndex: dataIndex) {
                println("Touched serie: \(serieIndex): data index: \(dataIndex!); serie value: \(value); x-axis value: \(x) (from left: \(left))")
            }
        }
    }
    
    func didFinishTouchingChart(chart: Chart) {
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
    }
    
}

//
//  BasicChartViewController.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit
import SwiftChart

class BasicChartViewController: UIViewController, ChartDelegate {


    @IBOutlet weak var chart: Chart!
    var selectedChart = 0
    
    override func viewDidLoad() {
        
        // Draw the chart selected from the TableViewController
        
        chart.delegate = self

        switch selectedChart {
        case 0:
            
            // Simple chart
          let data = [
            (x: 0, y: 0),
            (x: 3, y: 2.5),
            (x: 4, y: 2),
            (x: 5, y: 2.3),
            (x: 7, y: 3),
            (x: 8, y: 2.2),
            (x: 9, y: 2.5)
          ]
          let series = ChartSeries(data: data)
          series.area = true
          chart.xLabels = [0, 3, 6, 9, 12, 15, 18, 21, 24]
          chart.xLabelsFormatter = { String(Int(round($1))) + "h" }
          chart.add(series)
//          let series = ChartSeries(data: data)
//          chart.add(series)

            
        case 1:
            
            // Example with multiple series, the first two with area enabled
            
            let series1 = ChartSeries([0, 6, 2, 8, 4, 7, 3, 10, 8])
            series1.color = ChartColors.yellowColor()
            series1.area = true
            
            let series2 = ChartSeries([1, 0, 0.5, 0.2, 0, 1, 0.8, 0.3, 1])
            series2.color = ChartColors.redColor()
            series2.area = true
            
            // A partially filled series
            let series3 = ChartSeries([9, 8, 10, 8.5, 9.5, 10])
            series3.color = ChartColors.purpleColor()
            
            chart.add([series1, series2, series3])
            
        case 2:
            
            // Chart with y-min, y-max and y-labels formatter
            let data: [Double] = [0, -2, -2, 3, -3, 4, 1, 0, -1]
            
            let series = ChartSeries(data)
            series.colors = (
              above: ChartColors.greenColor(),
              below: ChartColors.yellowColor(),
              zeroLevel: -1
            )
            series.area = true
            
            chart.add(series)
            
            // Set minimum and maximum values for y-axis
            chart.minY = -7
            chart.maxY = 7
            
            // Format y-axis, e.g. with units
            chart.yLabelsFormatter = { String(Int($1)) +  "ºC" }
        
        case 3:
            // Create a new series specifying x and y values
            let data = [(x: 0, y: 0), (x: 0.5, y: 3.1), (x: 1.2, y: 2), (x: 2.1, y: -4.2), (x: 2.6, y: 1.1)]
            let series = ChartSeries(data: data)
            chart.add(series)
            
        default: break;
            
        }
    }
    
    // Chart delegate
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        for (seriesIndex, dataIndex) in indexes.enumerated() {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
        
    }
    
}

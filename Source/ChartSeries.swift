//
//  ChartSeries.swift
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

/**
The `ChartSeries` class create a chart series and configure its appearance and behavior.
*/
open class ChartSeries {
    /**
    The data used for the chart series.
    */
    open var data: [(x: Double, y: Double)]

    /// The name of the series. Required to remove a series by name.
    open var name = ""
    
    /**
    When set to `false`, will hide the series line. Useful for drawing only the area with `area=true`.
    */
    open var line: Bool = true

    /**
    Draws an area below the series line.
    */
    open var area: Bool = false
    
    /// Draws circles at each of the data points
    open var circles: Bool = false
    
    /// Draws the series as a bar graph
    open var bar: Bool = false

    /**
    The series color.
    */
    open var color: UIColor = ChartColors.blueColor() {
        didSet {
            colors = (above: color, below: color, 0)
        }
    }
    
    /// The color for the inside of any circles
    open var fillColor = UIColor.clear
    
    /// The width of the line for this series.
    open var lineWidth: CGFloat?
    
    /// The radius of the circle for a series that is configured to display circles. Defaults to 1.5.
    open var circleRadius = CGFloat(1.5)
    
    /// A tuple to specify the colors of the line and fill area above and below the zero level.
    /// Line and area fill colors can also be set independently through separate variables.
    open var colors: (
        above: UIColor,
        below: UIColor,
        zeroLevel: Double
    ) = (above: ChartColors.blueColor(), below: ChartColors.redColor(), 0) {
        didSet {
            lineColors.above = colors.above
            lineColors.below = colors.below
            lineColors.zeroLevel = colors.zeroLevel
            areaColors.above = colors.above
            areaColors.below = colors.below
            areaColors.zeroLevel = colors.zeroLevel
        }
    }
    
    /// A tuple to specify the color of the line above and below the zero level.
    open var lineColors: (
        above: UIColor,
        below: UIColor,
        zeroLevel: Double
    ) = (above: ChartColors.blueColor(), below: ChartColors.redColor(), 0)
    
    /// A tuple to specify the color of the area fill above and below zero.
    open var areaColors: (
        above: UIColor,
        below: UIColor,
        zeroLevel: Double
    ) = (above: ChartColors.blueColor(), below: ChartColors.redColor(), 0)

    public init(_ data: [Double]) {
        self.data = []
        data.enumerated().forEach { (x, y) in
            let point: (x: Double, y: Double) = (x: Double(x), y: y)
            self.data.append(point)
        }
    }

    public init(data: [(x: Double, y: Double)]) {
        self.data = data
    }

    public init(data: [(x: Int, y: Double)]) {
      self.data = data.map { (Double($0.x), Double($0.y)) }
    }
    
    public init(data: [(x: Float, y: Float)]) {
        self.data = data.map { (Double($0.x), Double($0.y)) }
    }
}

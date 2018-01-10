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

    /**
    When set to `false`, will hide the series line. Useful for drawing only the area with `area=true`.
    */
    open var line: Bool = true

    /**
    Draws an area below the series line.
    */
    open var area: Bool = false

    /**
    The series color.
    */
    open var color: UIColor = ChartColors.blueColor() {
        didSet {
            colors = (above: color, below: color, 0)
        }
    }

    /**
    A tuple to specify the color above or below the zero
    */
    open var colors: (
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

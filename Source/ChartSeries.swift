//
//  ChartSeries.swift
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

/**
Represent a series to draw in the line chart. Each series is defined with a dataset and appareance settings.
*/
public class ChartSeries {
    public var data: Array<(x: Float, y: Float)>
    public var area: Bool = false
    public var line: Bool = true
    public var color: UIColor = ChartColors.blueColor() {
        didSet {
            colors = (above: color, below: color)
        }
    }
    var colors: (above: UIColor, below: UIColor) = (above: ChartColors.blueColor(), below: ChartColors.redColor())

    public init(_ data: Array<Float>) {
        self.data = []

        data.enumerate().forEach { (x, y) in
            let point: (x: Float, y: Float) = (x: Float(x), y: y)
            self.data.append(point)
        }
    }

    public init(data: Array<(x: Float, y: Float)>) {
        self.data = data
    }

    public init(data: Array<(x: Double, y: Double)>) {
        self.data = data.map ({ (Float($0.x), Float($0.y))})
    }
}

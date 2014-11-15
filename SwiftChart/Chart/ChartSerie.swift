//
//  ChartSerie.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

/**
Represent a serie to draw in the line chart. Each serie is defined by its data and options.
*/
class ChartSerie {
    let data: Array<ChartPoint>
    var area: Bool = false
    var line: Bool = true
    var color: UIColor = ChartColors.blueColor() {
        didSet {
            colors = (above: color, below: color)
        }
    }
    var colors: (above: UIColor, below: UIColor) = (above: ChartColors.blueColor(), below: ChartColors.redColor())
    
    init(data: Float...) {
        self.data = []
        for (x, y) in enumerate(data) {
            self.data.append((x: Float(x), y: y))
        }
    }
    
    init(data: Array<ChartPoint>) {
        self.data = data
    }
    
    init(data: Array<ChartPoint>, color: UIColor, line: Bool = true, area: Bool = false) {
        self.data = data
        self.colors = (above: color, below: color)
        self.area = area
        self.line = line
    }
    
    init(data: Array<ChartPoint>, aboveColor: UIColor, belowColor: UIColor, line: Bool = true, area: Bool = false) {
        self.data = data
        self.colors = (above: aboveColor, below: belowColor)
        self.area = area
        self.line = line
    }
}


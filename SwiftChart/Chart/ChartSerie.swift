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
struct ChartSerie {
    let data: Array<ChartPoint>
    var area: Bool = true
    var line: Bool = true
    var colors: (above: UIColor, below: UIColor) = (above: ChartColors.blueColor(), below: ChartColors.redColor())
    
    init(data: Array<ChartPoint>) {
        self.data = data
    }
    
    init(data: Array<ChartPoint>, color: UIColor, area: Bool, line: Bool) {
        self.data = data
        self.colors = (above: color, below: color)
        self.area = area
        self.line = line
    }
    
    init(data: Array<ChartPoint>, aboveColor: UIColor, belowColor: UIColor, area: Bool, line: Bool) {
        self.data = data
        self.colors = (above: aboveColor, below: belowColor)
        self.area = area
        self.line = line
    }
}


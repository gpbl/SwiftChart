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
    let data: Array<(x: Float, y: Float)>
    var area: Bool = true
    var line: Bool = true
    var color: (above: UIColor, below: UIColor) = (above: ChartColors.greenColor(), below: ChartColors.redColor())
    
    init(data: Array<(x: Float, y: Float)>, options: Dictionary<String, Any>? = nil) {
        self.data = data
        if let options = options {
            if let area = options["area"] as? Bool {
                self.area = area
            }
            if let line = options["line"] as? Bool {
                self.line = line
            }
            if let color = options["color"] as? (above: UIColor, below: UIColor) {
                self.color = color
            }
            if let color = options["color"] as? UIColor {
                self.color = (above: color, below: color)
            }
            
        }
    }
}


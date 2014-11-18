//
//  ChartColors.swift
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

/**
Shorthands for various colors to use freely in the charts.
*/
struct ChartColors {
    static func colorFromHex(hex: Int) -> UIColor {
        var red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        var green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        var blue = CGFloat((hex & 0xFF)) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    static func blueColor() -> UIColor {
        return colorFromHex(0x4A90E2)
    }
    static func orangeColor() -> UIColor {
        return colorFromHex(0xF5A623)
    }
    static func greenColor() -> UIColor {
        return colorFromHex(0x7ED321)
    }
    static func darkGreenColor() -> UIColor {
        return colorFromHex(0x417505)
    }
    static func redColor() -> UIColor {
        return colorFromHex(0xFF3200)
    }
    static func darkRedColor() -> UIColor {
        return colorFromHex(0xD0021B)
    }
    static func purpleColor() -> UIColor {
        return colorFromHex(0x9013FE)
    }
    static func maroonColor() -> UIColor {
        return colorFromHex(0x8B572A)
    }
    static func pinkColor() -> UIColor {
        return colorFromHex(0xBD10E0)
    }
    static func greyColor() -> UIColor {
        return colorFromHex(0x7f7f7f)
    }
    static func cyanColor() -> UIColor {
        return colorFromHex(0x50E3C2)
    }
    static func goldColor() -> UIColor {
        return colorFromHex(0xbcbd22)
    }
    static func yellowColor() -> UIColor {
        return colorFromHex(0xF8E71C)
    }
}
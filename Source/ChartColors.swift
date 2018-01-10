//
//  ChartColors.swift
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

/**
Shorthands for various colors to use in the charts.
*/
public struct ChartColors {

    static fileprivate func colorFromHex(_ hex: Int) -> UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    static public func blueColor() -> UIColor {
        return colorFromHex(0x4A90E2)
    }
    static public func orangeColor() -> UIColor {
        return colorFromHex(0xF5A623)
    }
    static public func greenColor() -> UIColor {
        return colorFromHex(0x7ED321)
    }
    static public func darkGreenColor() -> UIColor {
        return colorFromHex(0x417505)
    }
    static public func redColor() -> UIColor {
        return colorFromHex(0xFF3200)
    }
    static public func darkRedColor() -> UIColor {
        return colorFromHex(0xD0021B)
    }
    static public func purpleColor() -> UIColor {
        return colorFromHex(0x9013FE)
    }
    static public func maroonColor() -> UIColor {
        return colorFromHex(0x8B572A)
    }
    static public func pinkColor() -> UIColor {
        return colorFromHex(0xBD10E0)
    }
    static public func greyColor() -> UIColor {
        return colorFromHex(0x7f7f7f)
    }
    static public func cyanColor() -> UIColor {
        return colorFromHex(0x50E3C2)
    }
    static public func goldColor() -> UIColor {
        return colorFromHex(0xbcbd22)
    }
    static public func yellowColor() -> UIColor {
        return colorFromHex(0xF8E71C)
    }
}

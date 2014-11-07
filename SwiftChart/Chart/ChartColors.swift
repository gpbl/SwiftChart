//
//  ChartColors.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

struct ChartColors {
    static func UIColorFromHex(hex: Int) -> UIColor {
        var red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        var green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        var blue = CGFloat((hex & 0xFF)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    static func blueColor() -> UIColor {
        return UIColorFromHex(0x1f77b4)
    }
    static func orangeColor() -> UIColor {
        return UIColorFromHex(0xff7f0e)
    }
    static func greenColor() -> UIColor {
        return UIColorFromHex(0x2ca02c)
    }
    static func redColor() -> UIColor {
        return UIColorFromHex(0xd62728)
    }
    static func purpleColor() -> UIColor {
        return UIColorFromHex(0x9467bd)
    }
    static func maroonColor() -> UIColor {
        return UIColorFromHex(0x8c564b)
    }
    static func pinkColor() -> UIColor {
        return UIColorFromHex(0xe377c2)
    }
    static func greyColor() -> UIColor {
        return UIColorFromHex(0x7f7f7f)
    }
    static func cyanColor() -> UIColor {
        return UIColorFromHex(0x17becf)
    }
    static func goldColor() -> UIColor {
        return UIColorFromHex(0xbcbd22)
    }
    static func yellowColor() -> UIColor {
        return UIColorFromHex(0xe7ba52)
    }
}
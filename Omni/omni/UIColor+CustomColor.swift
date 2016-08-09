//
//  UIColor+CustomColor.swift
//  omni
//
//  Created by Sarah Zhou on 7/7/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import Swift
import UIKit

extension UIColor {
    
    class func fromRgbHex(fromHex: Int) -> UIColor {
        
        let red = CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue = CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func alizarin() -> UIColor {
        let alizarin = 0xff4d4d
        return UIColor.fromRgbHex(alizarin)
    }
    
    class func emerald() -> UIColor {
        let emerald = 0x2ecc71
        return UIColor.fromRgbHex(emerald)
    }
    
    class func asphalt() -> UIColor {
        let asphalt = 0x34495e
        return UIColor.fromRgbHex(asphalt)
    }
    
    class func silver() -> UIColor {
        let silver = 0xbdc3c7
        return UIColor.fromRgbHex(silver)
    }
    
    class func clouds() -> UIColor {
        let clouds = 0xecf0f1
        return UIColor.fromRgbHex(clouds)
    }
    
    class func charcoal() -> UIColor {
        let charcoal = 0x616161
        return UIColor.fromRgbHex(charcoal)
    }
}

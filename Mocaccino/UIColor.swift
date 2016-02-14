//
//  UIColor.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-13.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

extension UIColor {
    // Katou Megumi Pink
    class func KMPinkColor() -> UIColor {
        return UIColor(red: 230.0/255.0, green: 91.0/255.0, blue: 121.0/255.0, alpha: 1.0)
    }
    
    // Katou Megumi Yellow
    class func KMYellowColor() -> UIColor {
        return UIColor(red: 253.0/255.0, green: 167.0/255.0, blue: 49.0/255.0, alpha: 1.0)
    }
    
    // Katou Megumi Purple
    class func KMPurpleColor() -> UIColor {
        return UIColor(red: 164.0/255.0, green: 141.0/255.0, blue: 196.0/255.0, alpha: 1.0)
    }
    
    // Katou Megumi Red
    class func KMRedColor() -> UIColor {
        return UIColor(red: 222.0/255.0, green: 22.0/255.0, blue: 53.0/255.0, alpha: 1.0)
    }
    
    class func RandomKMColor() -> UIColor {
        switch random() % 4 {
        case 0:
            return KMPinkColor()
        case 1:
            return KMYellowColor()
        case 2:
            return KMPurpleColor()
        default:
            return KMRedColor()
        }
    }
}
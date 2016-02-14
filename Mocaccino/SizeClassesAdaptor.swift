//
//  SizeClassesAdaptor.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-13.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

protocol SizeClassesAdaptor {
    /// iPad - Portrait & Landscape
    func setWidthRegularHeightRegularLayoutWith(viewSize size: CGSize)
    
    /// iPhone 6 Plus, iPhone 6 and Before - Portrait
    func setWidthCompactHeightRegularLayoutWith(viewSize size: CGSize)
    
    /// iPhone 6 Plus - Landscape
    func setWidthRegularHeightCompactLayoutWith(viewSize size: CGSize)
    
    /// iPhone 6 and Before - Landscape
    func setWidthCompactHeightCompactLayoutWith(viewSize size: CGSize)
}
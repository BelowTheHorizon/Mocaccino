//
//  CardAddView.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-11.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CardAddView: UIView {
    
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var summaryLabel: UILabel!
//    
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var pageControl: UIPageControl!
    
    var card: Card?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    override func alignmentRectForFrame(frame: CGRect) -> CGRect {
        return bounds
    }
}

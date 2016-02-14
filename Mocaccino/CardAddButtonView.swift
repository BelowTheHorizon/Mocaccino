//
//  CardAddButtonView.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-13.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CardAddButtonView: UIView {
    
    var cardAddingControllerDelegate: CardAddingManager? 
    
    @IBAction func cardAddButtonPressed(sender: UIButton) {
        cardAddingControllerDelegate?.presentCardAddController(nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func alignmentRectForFrame(frame: CGRect) -> CGRect {
        return bounds
    }
}

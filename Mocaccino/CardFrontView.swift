//
//  CardFrontView.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CardFrontView: UIView {
    
    let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    @IBOutlet weak var frontTextLabel: UILabel!
    var card: Card? {
        didSet {
            updateView()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurredView.frame = self.bounds
        addSubview(blurredView)
        sendSubviewToBack(blurredView)
        
        updateView()
    }
    
    private func updateView() {
        frontTextLabel.text = card?.title ?? "There is no card to review today.\nAdd a card and wait for tomorrow."
    }

}

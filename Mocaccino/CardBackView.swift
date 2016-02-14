//
//  CardBackView.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CardBackView: UIView {
    
    @IBOutlet weak var frontTextLabel: UILabel!
    @IBOutlet weak var backTextLabel: UILabel!

    let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    var cardEventmanager: CardEventManager?
    var card: Card? {
        didSet {
            updateView()
        }
    }
    
    @IBAction func rememberButtonPressed(sender: UIButton) {
        cardEventmanager?.rememberButtonPressed(card!)
    }

    @IBAction func forgetButtonPressed(sender: UIButton) {
        cardEventmanager?.forgetButtonPressed(card!)
    }
    
    @IBAction func forgetButtonLongPressed(sender: UILongPressGestureRecognizer) {
        cardEventmanager?.forgetButtonLongPressed(card!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurredView.frame = self.bounds
        addSubview(blurredView)
        sendSubviewToBack(blurredView)
        
        updateView()
    }
    
    private func updateView() {
        guard let card = card else {
            // FIXME: Serious error
            return
        }
        
        frontTextLabel.text = card.title
        backTextLabel.text = card.definition
        
        print(card)
    }
}

protocol CardEventManager {
    func rememberButtonPressed(card: Card)
    func forgetButtonPressed(card: Card)
    func forgetButtonLongPressed(card: Card)
}

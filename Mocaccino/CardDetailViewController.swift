//
//  CardDetailViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-7.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    
    var cardAddingControllerDelegate: CardAddingManager?
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var pageView: UIView!
    
    var visualEffectView: UIVisualEffectView!
    var cardDetailPageViewController: CardDetailPageViewController!
    
    @IBAction func addCardButtonPressed(sender: UIButton) {
        NSLog("Add card button pressed")
        cardAddingControllerDelegate?.presentCardAddController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: .Dark)
        self.visualEffectView = UIVisualEffectView(effect: blurEffect)
        self.visualEffectView.frame = self.view.bounds
        
        self.view.addSubview(self.visualEffectView)
        self.view.sendSubviewToBack(self.visualEffectView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.visualEffectView.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func initSubView() {
        self.cardDetailPageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CardDetailPageViewController") as! CardDetailPageViewController
    }
    
    private func setLayoutOfSubView() {
        self.cardDetailPageViewController.view.frame = self.pageView.frame
    }
    
    private func addSubView() {
        self.view.addSubview(self.cardDetailPageViewController.view)
    }
}

protocol CardAddingManager {
    func presentCardAddController()
}
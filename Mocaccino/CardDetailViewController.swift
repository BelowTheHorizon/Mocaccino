//
//  CardDetailViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-7.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var visualEffectView: UIVisualEffectView!
    
    @IBAction func addCardButtonPressed(sender: UIButton) {
        NSLog("Add card button pressed")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

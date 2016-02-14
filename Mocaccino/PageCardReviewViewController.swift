//
//  PageCardReviewViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-10.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class PageCardReviewViewController: UIViewController {

    let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))

    @IBOutlet weak var titleLabel: UILabel!
    
    var isActive = false
    var index: Int!
    var card: Card?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurredView.frame = view.bounds
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
        view.backgroundColor = UIColor.clearColor()
        
        titleLabel.text = card?.title
        isActive = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.blurredView.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PageCardReviewViewController: UIPageContentViewController {
    func pageIndex() -> Int {
        return self.index
    }
}
//
//  PageCardReviewViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-10.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class PageCardReviewViewController: UIViewController {

    var index: Int!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clearColor()
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

extension PageCardReviewViewController: UIPageContentViewController {
    func pageIndex() -> Int {
        return self.index
    }
}
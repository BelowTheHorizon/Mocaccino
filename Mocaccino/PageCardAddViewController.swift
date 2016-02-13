//
//  PageCardAddViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-10.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class PageCardAddViewController: UIViewController {
    
    var index: Int!

    @IBOutlet weak var cardFrontTextField: UITextField!
    @IBOutlet weak var cardBackTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cardFrontTextField.delegate = (self.parentViewController?.parentViewController as? UITextFieldDelegate)
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

extension PageCardAddViewController: UIPageContentViewController {
    func pageIndex() -> Int {
        return self.index
    }
}
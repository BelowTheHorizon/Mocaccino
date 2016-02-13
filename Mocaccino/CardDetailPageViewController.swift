//
//  CardDetailPageViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-9.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CardDetailPageViewController: UIPageViewController {
    
    var pageContentViewControllerIdentifier = ["PageCardReviewViewController", "PageCardAddViewController", "PageCardNewDeckViewController"]
    var currentPageContentViewControllerIndex: Int = 0
    var pageViewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        // Create the first walkthrough screen
        pageViewControllers.append(self.initViewControllerAIndex(0)!)
        pageViewControllers.append(self.initViewControllerAIndex(1)!)
        pageViewControllers.append(self.initViewControllerAIndex(2)!)

        setViewControllers([pageViewControllers.first!], direction: .Forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func initViewControllerAIndex(index: Int) -> UIViewController? {
//        guard index != NSNotFound && index >= 0 && index < pageContentViewControllerIdentifier.count else {
//            return nil
//        }
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(pageContentViewControllerIdentifier[index])
        
        (controller as? PageCardReviewViewController)?.index = index
        (controller as? PageCardAddViewController)?.index = index
        (controller as? PageCardNewDeckViewController)?.index = index
        
        return controller
    }
}

extension CardDetailPageViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as? UIPageContentViewController)?.pageIndex() ?? 0
        index -= 1
        
        if index == -1 {
            index = self.pageContentViewControllerIdentifier.count - 1
        } else if index == self.pageContentViewControllerIdentifier.count {
            index = 0
        }

        return self.pageViewControllers[index]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as? UIPageContentViewController)?.pageIndex() ?? 0
        index += 1
        
        if index == -1 {
            index = self.pageContentViewControllerIdentifier.count - 1
        } else if index == self.pageContentViewControllerIdentifier.count {
            index = 0
        }

        return self.pageViewControllers[index]
    }
}

protocol UIPageContentViewController {
    func pageIndex() -> Int
}
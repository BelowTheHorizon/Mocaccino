//
//  CardDetailPageViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-9.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CardDetailPageViewController: UIPageViewController {
    
    var cards = [Card]()
    
    var pageContentViewControllerIdentifier = "PageCardReviewViewController"
    var pageViewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        // Create the first walkthrough screen
        if !cards.isEmpty {
            pageViewControllers.append(self.initViewControllerAIndex(0)!)
            setViewControllers([pageViewControllers.first!], direction: .Forward, animated: true, completion: nil)
        } else {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(pageContentViewControllerIdentifier) as! PageCardReviewViewController
            controller.index = 0
            setViewControllers([controller], direction: .Forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadCards(cards: [Card]) {
        self.cards = cards
        // save context
        pageViewControllers.removeAll()
        pageViewControllers.append(self.initViewControllerAIndex(0)!)
        setViewControllers([pageViewControllers.first!], direction: .Forward, animated: true, completion: nil)
    }
    

    private func initViewControllerAIndex(index: Int) -> UIViewController? {
        guard index != NSNotFound && index >= 0 && index < cards.count else {
            return nil
        }
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(pageContentViewControllerIdentifier) as! PageCardReviewViewController
        controller.index = index
        controller.card = cards[index]
        
        
        return controller
    }
}

extension CardDetailPageViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard pageViewControllers.isEmpty == false else {
            return nil
        }
        
        let index = (viewController as? PageCardReviewViewController)!.pageIndex() - 1
        if index <= -1 || index >= cards.count {
            return nil
        }
        
        guard index >= 0 && index < pageViewControllers.count else {
            return initViewControllerAIndex(index)
        }
        
        if let controller = pageViewControllers[index] as? PageCardReviewViewController {
            return controller
        } else {
            return initViewControllerAIndex(index)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard pageViewControllers.isEmpty == false else {
            return nil
        }
        
        let index = (viewController as? PageCardReviewViewController)!.pageIndex() + 1
        if index <= -1 || index >= cards.count {
            return nil
        }
        
        guard index >= 0 && index < pageViewControllers.count else {
            return initViewControllerAIndex(index)
        }

        if let controller = pageViewControllers[index] as? PageCardReviewViewController {
            return controller
        } else {
            return nil
        }
    }
}

protocol UIPageContentViewController {
    func pageIndex() -> Int
}
//
//  RootViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-8.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    var coreDataStack: CoreDataStack!
    var navigationController_CardListViewController: UINavigationController!
    var cardListViewController: CardListViewController!
    var cardDetailViewController: CardDetailViewController!
    
    var currentSizeClasses: (w: UIUserInterfaceSizeClass, h: UIUserInterfaceSizeClass)!
    var currentFaceIdiom: UIUserInterfaceIdiom!
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentSizeClasses = (self.view.traitCollection.horizontalSizeClass, self.view.traitCollection.verticalSizeClass)
        self.currentFaceIdiom = UIDevice.currentDevice().userInterfaceIdiom

        self.initSubView()
        self.setLayoutOfSubView()
        self.addSubView()

        // Configure RootViewController appearance
        self.view.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        coordinator.animateAlongsideTransitionInView(self.view, animation: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.setLayoutOfSubView(size)
        }, completion: nil)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        self.currentSizeClasses = (newCollection.horizontalSizeClass, newCollection.verticalSizeClass)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        self.cardListViewController.motionEnded(motion, withEvent: event)
    }
    
    // MARK: Private function
    
    private func initSubView() {
        // Init CardListViewController
        self.navigationController_CardListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NavigationController-CardListViewController") as! UINavigationController
        self.cardListViewController = self.navigationController_CardListViewController.childViewControllers.first! as! CardListViewController
        self.cardListViewController.coreDataStack = self.coreDataStack
        
        // Init CardDetailViewController
        self.cardDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
    }
    
    private func setLayoutOfSubView(size: CGSize? = nil) {
        
        let viewSize = size ?? self.view.frame.size
        let w = self.currentSizeClasses.w
        let h = self.currentSizeClasses.h

        switch (w, h) {
        case (.Regular, .Regular):
            self.setWidthRegularHeightRegularLayoutWith(viewSize: viewSize)
        case (.Compact, .Regular):
            self.setWidthCompactHeightRegularLayoutWith(viewSize: viewSize)
        case (.Regular, .Compact):
            self.setWidthRegularHeightCompactLayoutWith(viewSize: viewSize)
        case (.Compact, .Compact):
            self.setWidthCompactHeightCompactLayoutWith(viewSize: viewSize)
        default:
            NSLog("Unspecified size classes")
            break
        }
    }
    
    // iPad - Portrait & Landscape
    private func setWidthRegularHeightRegularLayoutWith(viewSize size: CGSize) {
        
        let frameRect = CGRectMake(0.0, 0.0, size.width, size.height)
        let divideDistance = CGFloat(320.0)
        let sliceRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinXEdge).slice
        let remainderRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinXEdge).remainder
        
        self.navigationController_CardListViewController.view.frame = sliceRect
        self.cardListViewController.view.frame = sliceRect
        self.cardDetailViewController.view.frame = remainderRect
        
        self.cardListViewController.view.hidden = false
    }
    
    // iPhone 6 Plus - Portrait
    // iPhone 6 and Before - Portrait
    private func setWidthCompactHeightRegularLayoutWith(viewSize size: CGSize) {
        let frameRect = CGRectMake(0.0, 0.0, size.width, size.height)
        let divideDistance = frameRect.height * 0.618
        let cardDetailFrameRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinYEdge).remainder

        self.navigationController_CardListViewController.view.frame = frameRect
        self.cardListViewController.view.frame = frameRect
        self.cardDetailViewController.view.frame = cardDetailFrameRect
        
        self.cardListViewController.tableView.scrollIndicatorInsets.bottom += cardDetailFrameRect.height
        self.cardListViewController.tableView.contentInset.bottom = cardDetailFrameRect.height
        self.cardListViewController.view.hidden = false
    }
    
    // iPhone 6 Plus - Landscape
    private func setWidthRegularHeightCompactLayoutWith(viewSize size: CGSize) {
        let frameRect = CGRectMake(0.0, 0.0, size.width, size.height)
        let divideDistance = CGFloat(320.0)
        let sliceRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinXEdge).slice
        let remainderRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinXEdge).remainder
        
        self.navigationController_CardListViewController.view.frame = sliceRect
        self.cardListViewController.view.frame = sliceRect
        self.cardDetailViewController.view.frame = remainderRect

        self.cardListViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        self.cardListViewController.tableView.contentInset = UIEdgeInsetsZero
        self.cardListViewController.view.hidden = false
    }
    
    // iPhone 6 and Before - Landscape
    private func setWidthCompactHeightCompactLayoutWith(viewSize size: CGSize) {
        let frameRect = CGRect(origin: CGPoint.zero, size: size)
        
        self.navigationController_CardListViewController.view.frame = frameRect
        self.cardListViewController.view.frame = frameRect
        self.cardDetailViewController.view.frame = frameRect
        
        self.cardListViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        self.cardListViewController.tableView.contentInset = UIEdgeInsetsZero
        self.cardListViewController.view.hidden = true
    }
    
    private func addSubView() {
        
        // Add subview CardListViewController
        self.view.addSubview(self.navigationController_CardListViewController.view)
        
        // Add subview CardDetailViewController
        self.view.addSubview(self.cardDetailViewController.view)
    }
}
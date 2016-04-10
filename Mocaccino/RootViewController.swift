//
//  RootViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-8.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    var sizeClassesAdaptor: SizeClassesAdaptor!
    let statusBarBlurredView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    var coreDataStack: CoreDataStack!
    var navigationController_CardListViewController: UINavigationController!
    var cardListViewController: CardListViewController!
    var cardDetailViewController: CardDetailViewController!
    
    var currentSizeClasses: (w: UIUserInterfaceSizeClass, h: UIUserInterfaceSizeClass)!
    var currentFaceIdiom: UIUserInterfaceIdiom!
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sizeClassesAdaptor = self
        
        self.view.addSubview(statusBarBlurredView)
        
        self.currentSizeClasses = (self.view.traitCollection.horizontalSizeClass, self.view.traitCollection.verticalSizeClass)
        self.currentFaceIdiom = UIDevice.currentDevice().userInterfaceIdiom
        
        // Autolayout statusBarBlurredView
        let leading = NSLayoutConstraint(item: statusBarBlurredView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: statusBarBlurredView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: statusBarBlurredView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: statusBarBlurredView, attribute: .Bottom, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0)
        statusBarBlurredView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([leading, trailing, top, bottom])
        
        self.initSubView()
        self.setLayoutOfSubView()
        self.addSubView()
        
        // Configure RootViewController appearance
        self.view.backgroundColor = UIColor.clearColor()
        self.view.bringSubviewToFront(statusBarBlurredView)
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
        navigationController_CardListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NavigationController-CardListViewController") as! UINavigationController
        cardListViewController = self.navigationController_CardListViewController.childViewControllers.first! as! CardListViewController
        cardListViewController.coreDataStack = self.coreDataStack
        cardListViewController.currentSizeClasses = self.currentSizeClasses
        
        // Init CardDetailViewController
        cardDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        cardDetailViewController.coreDataStack = self.coreDataStack
        cardDetailViewController.currentSizeClasses = self.currentSizeClasses
        
        // Add delegate
        cardListViewController.cardReviewManager = cardDetailViewController
        cardDetailViewController.cardAddingControllerDelegate = cardListViewController
    }
    
    private func setLayoutOfSubView(size: CGSize? = nil) {
        
        let viewSize = size ?? self.view.frame.size
        let w = self.currentSizeClasses.w
        let h = self.currentSizeClasses.h

        switch (w, h) {
        case (.Regular, .Regular):
            sizeClassesAdaptor.setWidthRegularHeightRegularLayoutWith(viewSize: viewSize)
        case (.Compact, .Regular):
            sizeClassesAdaptor.setWidthCompactHeightRegularLayoutWith(viewSize: viewSize)
        case (.Regular, .Compact):
            sizeClassesAdaptor.setWidthRegularHeightCompactLayoutWith(viewSize: viewSize)
        case (.Compact, .Compact):
            sizeClassesAdaptor.setWidthCompactHeightCompactLayoutWith(viewSize: viewSize)
        default:
            NSLog("Unspecified size classes")
            break
        }
    }
    
    private func addSubView() {
        
        // Add subview CardListViewController
        self.view.addSubview(self.navigationController_CardListViewController.view)
        
        // Add subview CardDetailViewController
        self.view.addSubview(self.cardDetailViewController.view)
    }
}

// MARK: - SizeClassesAdaptor
extension RootViewController: SizeClassesAdaptor {
    // iPad - Portrait & Landscape
    func setWidthRegularHeightRegularLayoutWith(viewSize size: CGSize) {
        
        let frameRect = CGRectMake(0.0, 0.0, size.width, size.height)
        let divideDistance = CGFloat(320.0)
        let sliceRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinXEdge).slice
        let remainderRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinXEdge).remainder
        
        navigationController_CardListViewController.view.frame = sliceRect
        cardListViewController.view.frame = sliceRect
        cardDetailViewController.view.frame = remainderRect
        
        cardListViewController.view.hidden = false
        cardListViewController.currentSizeClasses = self.currentSizeClasses
        cardDetailViewController.currentSizeClasses = self.currentSizeClasses
        
    }
    
    // iPhone 6 Plus - Portrait
    // iPhone 6 and Before - Portrait
    func setWidthCompactHeightRegularLayoutWith(viewSize size: CGSize) {
        let frameRect = CGRectMake(0.0, 0.0, size.width, size.height)
        let divideDistance = CGFloat(Int(frameRect.height * 0.618))
        let cardDetailFrameRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinYEdge).remainder

        navigationController_CardListViewController.view.frame = frameRect
        cardListViewController.view.frame = frameRect
        cardDetailViewController.view.frame = cardDetailFrameRect
        
        cardListViewController.tableView.scrollIndicatorInsets.bottom += cardDetailFrameRect.height
        cardListViewController.tableView.contentInset.bottom = cardDetailFrameRect.height
        cardListViewController.view.hidden = false
        cardListViewController.currentSizeClasses = self.currentSizeClasses
        cardDetailViewController.currentSizeClasses = self.currentSizeClasses
    }
    
    // iPhone 6 Plus - Landscape
    func setWidthRegularHeightCompactLayoutWith(viewSize size: CGSize) {
        let frameRect = CGRectMake(0.0, 0.0, size.width, size.height)
        let divideDistance = CGFloat(320.0)
        let sliceRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinXEdge).slice
        let remainderRect = frameRect.divide(divideDistance, fromEdge: CGRectEdge.MinXEdge).remainder
        
        navigationController_CardListViewController.view.frame = sliceRect
        cardListViewController.view.frame = sliceRect
        cardDetailViewController.view.frame = remainderRect

        cardListViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        cardListViewController.tableView.contentInset = UIEdgeInsetsZero
        cardListViewController.view.hidden = false
        cardListViewController.currentSizeClasses = self.currentSizeClasses
        cardDetailViewController.currentSizeClasses = self.currentSizeClasses
    }
    
    // iPhone 6 and Before - Landscape
    func setWidthCompactHeightCompactLayoutWith(viewSize size: CGSize) {
        let frameRect = CGRect(origin: CGPoint.zero, size: size)
        
        navigationController_CardListViewController.view.frame = frameRect
        cardListViewController.view.frame = frameRect
        cardDetailViewController.view.frame = frameRect
        
        cardListViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        cardListViewController.tableView.contentInset = UIEdgeInsetsZero
        cardListViewController.view.hidden = true
        cardListViewController.currentSizeClasses = self.currentSizeClasses
        cardDetailViewController.currentSizeClasses = self.currentSizeClasses
    }
}
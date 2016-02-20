//
//  CardDetailViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-7.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import CoreData

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBAction func addCardButtonPressed(sender: UIButton) {
        NSLog("Add card button pressed")
        cardAddingControllerDelegate?.presentCardAddController(self)
    }
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    var coreDataStack: CoreDataStack!
    var sizeClassesAdaptor: SizeClassesAdaptor!
    var visualEffectView: UIVisualEffectView!
    var cardReviewViewController: CardReviewViewController!
    var cardAddingControllerDelegate: CardAddingManager?
    var currentSizeClasses: (w: UIUserInterfaceSizeClass, h: UIUserInterfaceSizeClass)! {
        didSet {
            setLayoutOfSubView()
        }
    }
    
    var cards = [Card]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sizeClassesAdaptor = self
        cardReviewViewController = self.childViewControllers.first as! CardReviewViewController
        cardReviewViewController.coreDataStack = self.coreDataStack
        cardReviewViewController.cardReviewCoordinator = self

        let blurEffect = UIBlurEffect(style: .Dark)
        self.visualEffectView = UIVisualEffectView(effect: blurEffect)
        self.visualEffectView.frame = self.view.bounds
        
        spinner.center = self.view.center
        spinner.color = UIColor.KMPinkColor()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        self.view.addSubview(spinner)
        self.view.bringSubviewToFront(spinner)
        self.view.addSubview(self.visualEffectView)
        self.view.sendSubviewToBack(self.visualEffectView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "isActiveChanged:", name: "CardListActiveStatusChange", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refetchNeedToReviewCards", name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        visualEffectView.frame = view.bounds
        spinner.center = view.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private functions
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
    
    func refetchNeedToReviewCards() {
        let fetchRequest = NSFetchRequest(entityName: "Card")
        let currentDate = NSDate()
        let predicate = NSPredicate(format: "nextReviewTime <= %@", currentDate)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        do {
            let cards = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Card]
            self.cards = cards
            if !cards.isEmpty {
                cardReviewViewController.card = cards.first
            } else {
                cardReviewViewController.card = nil
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
}

// MARK: - SizeClassesAdaptor
extension CardDetailViewController: SizeClassesAdaptor {
    // iPad - Portrait & Landscape
    func setWidthRegularHeightRegularLayoutWith(viewSize size: CGSize) {
    }

    // iPhone 6 Plus - Portrait
    // iPhone 6 and Before - Portrait
    func setWidthCompactHeightRegularLayoutWith(viewSize size: CGSize) {
    }
    
    // iPhone 6 Plus - Landscape
    func setWidthRegularHeightCompactLayoutWith(viewSize size: CGSize) {
    }
    
    // iPhone 6 and Before - Landscape
    func setWidthCompactHeightCompactLayoutWith(viewSize size: CGSize) {
    }
}

// MARK: - CardReviewManager
extension CardDetailViewController: CardReviewManager {
    func presentCardReviewController(deck: Deck) {
        guard let cards = deck.cards where cards.count != 0 else {
            return
        }
    }
}

// MARK: - CardReviewCoordinator
extension CardDetailViewController: CardReviewCoordinator {
    func willShowCardBack() {
        buttonView.hidden = true
    }
    
    func willHideCardBack() {
        buttonView.hidden = false
    }
    
    func didReviewCard() {
        refetchNeedToReviewCards()
    }
}

// MARK: - Notification selector
extension CardDetailViewController {
    // FIXME: 
    func isActiveChanged(notification: NSNotification) {
        guard let isActive = notification.object as? Bool else {
            return
        }
        
        if isActive {
            spinner.startAnimating()
            refetchNeedToReviewCards()
            spinner.stopAnimating()
        } else {
            spinner.startAnimating()
        }
    }
}

// MARK: CardAddingManager protocol
protocol CardAddingManager {
    func presentCardAddController(fromController: UIViewController?)
}
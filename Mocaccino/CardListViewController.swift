//
//  CardListViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-5.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import CoreData

private let kWordCellReuseIdentifier = "wordCellReuseIdentifier"
private let kCardAddButtonViewHeight: CGFloat = 44.0

class CardListViewController: UIViewController {
    
    let cardAddButtonView = UINib(nibName: "CardAddButtonView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! CardAddButtonView!
    
    @IBOutlet weak var tableView: UITableView!
    var addDeckButton: UIButton!
    var sizeClassesAdaptor: SizeClassesAdaptor!
    var cardReviewManager: CardReviewManager!
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController!
    var isActive: Bool = false {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("CardListActiveStatusChange", object: isActive)
        }
    }
    var currentColor: UIColor! {
        didSet {
            cardAddButtonView.backgroundColor = currentColor
        }
    }
    var currentIndexPath: NSIndexPath?
    var currentDeck: Deck? {
        didSet {
            animateCardAddButtonView()
        }
    }
    var currentSizeClasses: (w: UIUserInterfaceSizeClass, h: UIUserInterfaceSizeClass)! {
        didSet {
            setLayoutOfSubView()
        }
    }
    
    func addDeckButtonPressed(sender: UIButton? = nil) {
        let alert = UIAlertController(title: "New Deck", message: "Add a new deck", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            
            textField.placeholder = "Deck name…"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            print("Cancel")
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            print("Saved")
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let deck = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! Deck

            let deckNameTextField = alert.textFields!.first
            
            deck.name = deckNameTextField!.text
            deck.timeStamp = NSDate()
            
            self.coreDataStack.saveContext()
            self.tableView.reloadData()
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentColor = UIColor.RandomKMColor()
        cardAddButtonView.cardAddingControllerDelegate = self
        sizeClassesAdaptor = self
        navigationController?.navigationBarHidden = true
        
        setupFetchedResultsController()
        refetchData()
        
        cardAddButtonView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: kCardAddButtonViewHeight)
        self.view.addSubview(cardAddButtonView)
        
        view.backgroundColor = UIColor.blackColor()
        tableView.backgroundColor = UIColor.blackColor()
        
        addDeckButton = UIButton(type: UIButtonType.ContactAdd)
        addDeckButton.tintColor = UIColor.lightTextColor()
        addDeckButton.addTarget(self, action: "addDeckButtonPressed:", forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "persistentStoreDidChange:",
            name: NSPersistentStoreCoordinatorStoresDidChangeNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "persistentStoreWillChange:",
            name: NSPersistentStoreCoordinatorStoresWillChangeNotification,
            object: self.coreDataStack.context.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "recieveICloudChanges:",
            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
            object: self.coreDataStack.context.persistentStoreCoordinator)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if fetchedResultsController.sections![0].numberOfObjects != 0 {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            currentIndexPath = indexPath
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Bottom)
            let deck = fetchedResultsController.objectAtIndexPath(indexPath) as! Deck
            currentDeck = deck
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        currentIndexPath = nil
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: coreDataStack.context.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: coreDataStack.context.persistentStoreCoordinator)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if currentDeck != nil {
            cardAddButtonView.frame = CGRect(x: 0, y: self.view.frame.size.height - kCardAddButtonViewHeight, width: self.view.frame.size.width, height: kCardAddButtonViewHeight)
        } else {
            cardAddButtonView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: kCardAddButtonViewHeight)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private functions
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let deck = fetchedResultsController.objectAtIndexPath(indexPath) as! Deck
        cell.textLabel!.text = deck.name
        cell.textLabel!.highlightedTextColor = currentColor
        let cardsCount = deck.cards?.count ?? 0
        cell.detailTextLabel!.text = (cardsCount < 2) ? "\(cardsCount) card" : "\(cardsCount) cards"
        cell.detailTextLabel!.highlightedTextColor = currentColor
        
        cell.backgroundColor = UIColor.clearColor()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "Deck")
        let titleSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [titleSort]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.coreDataStack.context,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: "MocaccinoDeck")
        self.fetchedResultsController.delegate = self
    }
    
    private func refetchData() {
        do {
            NSLog("Try to refetch data")
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func animateCardAddButtonView() {
        UIView.animateWithDuration(0.5) { () -> Void in
            if self.currentDeck != nil {
                self.cardAddButtonView.frame = CGRect(x: 0, y: self.view.frame.size.height - kCardAddButtonViewHeight, width: self.view.frame.size.width, height: kCardAddButtonViewHeight)
            } else {
                self.cardAddButtonView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: kCardAddButtonViewHeight)
            }
        }
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

    
    // MARK: - UIResponder
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if #available(iOS 9.0, *) {
            if motion != .MotionShake { return }
            
            let alert = UIAlertController(title: "Delete All?", message: nil, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
                
                print("Cancel")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction) -> Void in
                
                let fetchRequest = NSFetchRequest(entityName: "Card")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                deleteRequest.resultType = .ResultTypeCount
                do {
                    let deleteResult = try self.fetchedResultsController.managedObjectContext.executeRequest(deleteRequest) as! NSBatchDeleteResult
                    print("Delete \(deleteResult.result!) record(s)")
                    try self.fetchedResultsController.performFetch()
                } catch let error as NSError {
                    print("Could not delete, \(error.userInfo)")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }))
            alert.addAction(UIAlertAction(title: "Print", style: .Default, handler: { (action: UIAlertAction) -> Void in
                print("Card print\n----\n")
                
                let fetchRequest = NSFetchRequest(entityName: "Card")
                
                do {
                    let cards = try self.coreDataStack.context.executeFetchRequest(fetchRequest) as! [Card]
                    for card in cards {
                        print(card)
                    }
                    print("\n----\nEnd")
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
            }))
            
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - iCloud observer

extension CardListViewController {
    func persistentStoreDidChange (notification: NSNotification) {
        NSLog("PersistenStore did change")
        
        if let userInfo = notification.userInfo,
        let transitionType = userInfo[NSPersistentStoreUbiquitousTransitionTypeKey] as? NSNumber {
            switch transitionType {
            case NSPersistentStoreUbiquitousTransitionType.AccountAdded.rawValue: break
            case NSPersistentStoreUbiquitousTransitionType.AccountRemoved.rawValue: break
            case NSPersistentStoreUbiquitousTransitionType.ContentRemoved.rawValue: break
            case NSPersistentStoreUbiquitousTransitionType.InitialImportCompleted.rawValue: break
                
            default:
                break
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.refetchData()
            self.tableView.reloadData()
            self.isActive = true
        }
    }
    
    func persistentStoreWillChange (notification:NSNotification) {
        NSLog("PersistenStore will change")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let moc = self.fetchedResultsController.managedObjectContext
            
            // Disable user interface with setEnabled: or an overlay
            self.isActive = false
            
            moc.performBlock { () -> Void in
                if moc.hasChanges {
                    do {
                        try moc.save()
                    } catch {
                        print("Could not save changes")
                    }
                } else {
                    // Drop any managed object references
                    moc.reset()
                }
            }
        }   // dispatch_async(…) { }
    }
    
    func recieveICloudChanges (notification:NSNotification){
        NSLog("Recieve iCloud change")
        let moc = self.fetchedResultsController.managedObjectContext
        moc.performBlock { () -> Void in
            moc.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
}

// MARK: - UITableViewDataSource

extension CardListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kWordCellReuseIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CardListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.isActive
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let deckToRemove = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Deck
            let alert = UIAlertController(title: "Delete \(deckToRemove.name!)?", message: nil, preferredStyle: .Alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction) -> Void in
                
                if let cards = deckToRemove.cards {
                    for card in cards {
                        self.fetchedResultsController.managedObjectContext.deleteObject(card as! NSManagedObject)
                    }
                }
                self.fetchedResultsController.managedObjectContext.deleteObject(deckToRemove)
                
                do {
                    try self.fetchedResultsController.managedObjectContext.save()
                    self.currentDeck = nil
                    print("Delete")
                    
                } catch let error as NSError {
                    print("Could not save: \(error)")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
                print("Cancel")
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            })
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        let deck = fetchedResultsController.objectAtIndexPath(indexPath) as! Deck
        currentDeck = deck
        currentIndexPath = indexPath
//        cardReviewManager.presentCardReviewController(deck)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.highlightedTextColor = currentColor
        cell?.detailTextLabel?.highlightedTextColor = currentColor
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.whiteColor()
        cell?.selectedBackgroundView = backgroundView
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        currentDeck = nil
        currentColor = UIColor.RandomKMColor()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == currentIndexPath {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Bottom)
            currentDeck = fetchedResultsController.objectAtIndexPath(indexPath) as? Deck
            configureCell(cell, atIndexPath: indexPath)
        }
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = footerView.bounds
        gradientLayer.colors = [UIColor.clearColor(), UIColor.blackColor().CGColor]
        footerView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        footerView.addSubview(addDeckButton)
        let centerX = NSLayoutConstraint(item: addDeckButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: footerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: addDeckButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: footerView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        addDeckButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([centerX, centerY])
        
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CardListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
        self.isActive = false
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
        case .Insert:
            self.tableView.insertSections(indexSet , withRowAnimation: .Automatic)
        case .Delete:
            self.tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        self.isActive = true
    }
}

// MARK: - SizeClassesAdaptor
extension CardListViewController: SizeClassesAdaptor {
    // iPad - Portrait & Landscape
    func setWidthRegularHeightRegularLayoutWith(viewSize size: CGSize) {
        cardAddButtonView.hidden = false
    }

    // iPhone 6 Plus - Portrait
    // iPhone 6 and Before - Portrait
    func setWidthCompactHeightRegularLayoutWith(viewSize size: CGSize) {
        cardAddButtonView.hidden = true
    }
    
    // iPhone 6 Plus - Landscape
    func setWidthRegularHeightCompactLayoutWith(viewSize size: CGSize) {
        cardAddButtonView.hidden = false
    }
    
    // iPhone 6 and Before - Landscape
    func setWidthCompactHeightCompactLayoutWith(viewSize size: CGSize) {
        cardAddButtonView.hidden = true
    }
}


// MARK: - CardAddingManager
extension CardListViewController: CardAddingManager {
    func presentCardAddController(fromController: UIViewController?) {
        guard let currentDeck = currentDeck where isActive == true else {
            return
        }
        
        let alert = UIAlertController(title: "\(currentDeck.name!)", message: "Add a new card", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            
            textField.placeholder = "Card front…"
        }
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            
            textField.placeholder = "Card back…"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            print("Cancel")
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            print("Card saved")
            
            let model = MoccacinoMemoryModel.shared
            let context = self.coreDataStack.context
            let cardEntity = NSEntityDescription.entityForName("Card", inManagedObjectContext: context)
            let card = Card(entity: cardEntity!, insertIntoManagedObjectContext: context)
            
            let cardFrontTextField = alert.textFields!.first
            let cardBackTextField = alert.textFields!.last
            
            card.timeStamp = NSDate()
            card.title = cardFrontTextField!.text
            card.definition = cardBackTextField!.text
            card.currentPeriod = 0
            card.memoryScore = 100
            card.nextReviewTime = model.calculateNextReviewTimeWith(card)
            
            card.deck = currentDeck
            
            self.coreDataStack.saveContext()
        }))
        
        if fromController != nil {
            fromController!.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

protocol CardReviewManager {
    func presentCardReviewController(deck: Deck)
}

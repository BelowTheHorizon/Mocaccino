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

class CardListViewController: UIViewController {
    
    var addDeckButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController!
    var isActive: Bool = false {
        willSet {
//            self.navigationItem.rightBarButtonItem?.enabled = (newValue == true) ? true : false
        }
    }
    var currentDeck: Deck?
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Deck", message: "Add a new deck", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            
            textField.placeholder = "Deck name…"
        }
        
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            print("Cancel")
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        setupFetchedResultsController()
        refetchData()
        
        view.backgroundColor = UIColor.blackColor()
        tableView.backgroundColor = UIColor.blackColor()
        
        addDeckButton = UIButton(type: UIButtonType.ContactAdd)
        addDeckButton.tintColor = UIColor.whiteColor()
        
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: coreDataStack.context.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: coreDataStack.context.persistentStoreCoordinator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private functions
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let deck = fetchedResultsController.objectAtIndexPath(indexPath) as! Deck
        cell.textLabel!.text = deck.name
        cell.textLabel!.highlightedTextColor = UIColor.blackColor()
        let cardsCount = deck.cards?.count ?? 0
        cell.detailTextLabel!.text = (cardsCount == 0) ? "\(cardsCount) card" : "\(cardsCount) cards"
        cell.detailTextLabel!.highlightedTextColor = UIColor.blackColor()
        
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
    
    // MARK: - UIResponder
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        addButtonPressed(UIBarButtonItem())
        return
        
        if #available(iOS 9.0, *) {
            if motion != .MotionShake { return }
            
            let alert = UIAlertController(title: "Delete All?", message: nil, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
                
                print("Cancel")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
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
                
                self.fetchedResultsController.managedObjectContext.deleteObject(deckToRemove)
                
                do {
                    try self.fetchedResultsController.managedObjectContext.save()
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
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.whiteColor()
        cell?.selectedBackgroundView = backgroundView
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
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
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
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


// MARK: - CardAddingManager
extension CardListViewController: CardAddingManager {
    func presentCardAddController() {
        guard let currentDeck = currentDeck else {
            NSLog("No deck selected")
            return
        }
        
        let alert = UIAlertController(title: "\(currentDeck.name!)", message: "Add a new card", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            
            textField.placeholder = "Card front…"
        }
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            
            textField.placeholder = "Card back…"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
            
            print("Cancel")
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            print("Card saved")
            
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
            
            card.deck = currentDeck
            
            self.coreDataStack.saveContext()
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

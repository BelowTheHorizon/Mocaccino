//
//  WordListViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-5.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import CoreData

private let kWordCellReuseIdentifier = "wordCellReuseIdentifier"

class WordListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController!
    
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Secret Team", message: "Add a new team", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            
            textField.placeholder = "Type a word…"
        }
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            
            textField.placeholder = "Type definition(s)…"
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            print("Saved")
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let card = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! Card

            let wordTextField = alert.textFields!.first
            let definitionTextField = alert.textFields!.last
            
            card.title = wordTextField!.text
            card.paraphrase = definitionTextField!.text
            card.timeStamp = NSDate()
            
            self.coreDataStack.saveContext()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            print("Cancel")
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "Card")
        let titleSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [titleSort]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataStack.context, sectionNameKeyPath: nil, cacheName: "Mocaccino")
        self.fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistentStoreDidChange", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistentStoreWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: coreDataStack.context.persistentStoreCoordinator)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recieveICloudChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: coreDataStack.context.persistentStoreCoordinator)
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
    
    // MARK: - UIResponder
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - iCloud observer

extension WordListViewController {
    func persistentStoreDidChange () {
        NSLog("persistenStore did change")
        self.tableView.reloadData()
    }
    
    func persistentStoreWillChange (notification:NSNotification) {
        NSLog("persistenStore will change")
        
        // disable the UI
        self.navigationItem.rightBarButtonItem?.enabled = false
        let moc = coreDataStack.context
        moc.performBlock { () -> Void in
            if moc.hasChanges {
                self.coreDataStack.saveContext()
            }
        }
    }
    
    func recieveICloudChanges (notification:NSNotification){
        NSLog("Recieve iCloud change")
        let moc = coreDataStack.context
        moc.performBlock { () -> Void in
            moc.mergeChangesFromContextDidSaveNotification(notification)
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension WordListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: kWordCellReuseIdentifier)
        
        let card = fetchedResultsController.objectAtIndexPath(indexPath) as! Card
        cell.textLabel!.text = card.title
        cell.detailTextLabel!.text = card.paraphrase
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WordListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let cardToRemove = fetchedResultsController.objectAtIndexPath(indexPath) as! Card
            fetchedResultsController.managedObjectContext.deleteObject(cardToRemove)
            
            do {
                try fetchedResultsController.managedObjectContext.save()
                print("Delete")
            } catch let error as NSError {
                print("Could not save: \(error)")
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension WordListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
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
    }
}

//
//  CoreDataStack.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-5.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import CoreData

class CoreDataStack {
    var modelName: String
    var storeName: String
    var options: [NSObject : AnyObject]? = nil
    var finaliCloudURL: NSURL?
    
    // Flag of listening notification or not
    var updateContextWithUbiquitousContentUpdates: Bool = false {
        willSet {
            ubiquitousChangesObserver = newValue ? NSNotificationCenter.defaultCenter() : nil
        }
    }
    
    private var ubiquitousChangesObserver: NSNotificationCenter? {
        didSet {
            oldValue?.removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: psc)
            ubiquitousChangesObserver?.addObserver(self, selector: "persistentStoreDidimportUbiquitousContentChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: psc)
            
            oldValue?.removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: psc)
            ubiquitousChangesObserver?.addObserver(self, selector: "persistentStoreCoordinatorWillChangeStores:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: psc)
            
            oldValue?.removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: psc)
            ubiquitousChangesObserver?.addObserver(self, selector: "persistentStoreCoordinatorDidChangeStores:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: psc)
        }
    }
    
    init(modelName: String, storeName: String, options: ([NSObject : AnyObject])?) {
        self.modelName = modelName
        self.storeName = storeName
        self.options = options
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.psc
        return managedObjectContext
    }()
    
    lazy var psc: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.modelName + ".sqlite")
        
        do {
            let store: NSPersistentStore = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: self.options)
            self.finaliCloudURL = store.URL
        } catch {
            print("Error adding persistent stroe.")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }   // if …
    }
    
    @objc func persistentStoreDidimportUbiquitousContentChanges(notification: NSNotification) {
        NSLog("Merging ubiquitous content changes")
        context.performBlock { () -> Void in
            self.context.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    @objc func persistentStoreCoordinatorWillChangeStores(notification: NSNotification) {
        NSLog("NSPersistentStoreCoordinator will change")
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Error saving \(error)")
            }
        }
        
        context.reset()
    }
    
    @objc func persistentStoreCoordinatorDidChangeStores(notification: NSNotification) {
        NSLog("NSPersistentStoreCoordinator did change")
    }
}
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
    
    private lazy var psc: NSPersistentStoreCoordinator = {
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
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
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
}
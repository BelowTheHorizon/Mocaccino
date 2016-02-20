//
//  TestCoreDataStack.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import CoreData
@testable import Mocaccino

class TestCoreDataStack: CoreDataStack {
    init() {
        super.init(modelName: "Mocaccino", storeName: "Mocaccino", options: nil)
        self.psc = {
            let p = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            do {
                try p.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
            } catch {
                fatalError()
            }
            
            return p
        }()
    }   // init() { … }
}
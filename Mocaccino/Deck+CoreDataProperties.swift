//
//  Deck+CoreDataProperties.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-8.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Deck {

    @NSManaged var name: String?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var cards: NSSet?

}

//
//  DeckService.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import CoreData

// TODO:
class DeckService {
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    init(managedObjectContext context: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = context
        self.coreDataStack = coreDataStack
    }
    
    func addDeck(name: String) -> Deck {
        let deck = NSEntityDescription.insertNewObjectForEntityForName("Deck", inManagedObjectContext: managedObjectContext) as! Deck
        deck.name = name
        deck.timeStamp = NSDate()
        
        coreDataStack.saveContext(context: managedObjectContext)
        
        return deck
    }
}

//
//  CardService.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import CoreData

// TODO: 
class CardService {
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    init(managedObjectContext context: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = context
        self.coreDataStack = coreDataStack
    }
    
    func addCard(title: String, definition: String, inDeck deck: Deck?) -> Card? {
        let card = NSEntityDescription.insertNewObjectForEntityForName("Card", inManagedObjectContext: managedObjectContext) as! Card
        card.title = title
        card.definition = definition
        card.deck = deck
        
        coreDataStack.saveContext(context: managedObjectContext)
        
        return card
    }
}

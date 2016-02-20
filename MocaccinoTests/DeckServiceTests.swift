//
//  DeckServiceTests.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import CoreData
import XCTest
@testable import Mocaccino

class DeckServiceTests: XCTestCase {
    var deckService: DeckService!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()

        coreDataStack = TestCoreDataStack()
        deckService = DeckService(managedObjectContext: coreDataStack.context, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        
        coreDataStack = nil
        deckService = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAddDeck() {
        let deck = deckService.addDeck("Aircraft carrier deck")
        
        XCTAssertTrue(deck.name == "Aircraft carrier deck")
    }
    
    func testRootContextIsSavedAfterAddDeck() {
        expectationForNotification(NSManagedObjectContextDidSaveNotification, object: coreDataStack.rootContext) { (notification: NSNotification) -> Bool in
            
            return true
        }
        
        deckService.addDeck("Island deck")
        
        waitForExpectationsWithTimeout(2.0) { (error: NSError?) -> Void in
            
            XCTAssertNil(error, "Save did not occur")
        }
    }

}

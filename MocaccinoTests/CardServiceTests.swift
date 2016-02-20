//
//  CardServiceTests.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import CoreData
import XCTest
@testable import Mocaccino

class CardServiceTests: XCTestCase {
    var cardService: CardService!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        
        coreDataStack = TestCoreDataStack()
        cardService = CardService(managedObjectContext: coreDataStack.context, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        
        cardService = nil
        coreDataStack = nil
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAddCard() {
        let card = cardService.addCard("Mocaccino", definition: "摩卡", inDeck: nil)
        
        print(card)
        
        XCTAssertNotNil(card)
        XCTAssertTrue(card.title == "Mocaccino")
        XCTAssertTrue(card.definition == "摩卡")
        XCTAssertNil(card.deck)
    }
    
    func testRootContextIsSavedAfterAddCard() {
        expectationForNotification(NSManagedObjectContextDidSaveNotification, object: coreDataStack.rootContext) { (notification: NSNotification) -> Bool in
            
            return true
        }
        
        cardService.addCard("Mocaccino", definition: "摩卡", inDeck: nil)
        
        waitForExpectationsWithTimeout(2.0) { (error: NSError?) -> Void in
            
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
}

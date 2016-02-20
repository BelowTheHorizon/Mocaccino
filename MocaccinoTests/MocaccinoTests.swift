//
//  MocaccinoTests.swift
//  MocaccinoTests
//
//  Created by Cirno MainasuK on 2016-2-5.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import CoreData
import XCTest
@testable import Mocaccino

class MocaccinoTests: XCTestCase {
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
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

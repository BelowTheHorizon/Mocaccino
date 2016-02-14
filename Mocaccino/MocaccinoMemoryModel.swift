//
//  MocaccinoMemoryModel.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

class MoccacinoMemoryModel {
    
    private let forgetLimit = 20.0
    private let forgetScore: [Double] = {
        var temp = 100.0
        var score = [Double]()
        for i in 0..<100 {
            score.append(temp)
            temp *= 0.8
        }
        
        return score
    }()
    
    
    // MARK: - Singleton
    private static let instance = MoccacinoMemoryModel()
    
    private init() {
        
    }
    
    static var shared: MoccacinoMemoryModel {
        return self.instance
    }
    
    func caculateNextReviewTimeWith(card: Card) -> NSDate {
        let currentDate = card.nextReviewTime ?? card.timeStamp!
        var currentPeriod = card.currentPeriod!.integerValue
        var memoryScore = card.memoryScore!.doubleValue
        
        for (var dayPass = 0; dayPass < 365; dayPass++) {
            if currentPeriod >= forgetScore.count {
                currentPeriod = forgetScore.count - 1
            }
            
            if memoryScore < forgetScore[currentPeriod] {
                memoryScore = 0
            } else {
                memoryScore -= forgetScore[currentPeriod]
            }
            
            if memoryScore <= forgetLimit {
                NSLog("Day \(dayPass) review word, in \(currentPeriod) with \(memoryScore).")
                return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: ((dayPass == 0) ? 1 : dayPass), toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))!
            }
        }
        
        return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 365, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func caculateOneDayMore(card: Card) -> NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: card.nextReviewTime ?? card.timeStamp!, options: NSCalendarOptions.init(rawValue: 0))!
    }
}
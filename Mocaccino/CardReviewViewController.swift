//
//  CardReviewViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class CardReviewViewController: UIViewController {
    
    let cardFrontView = UINib(nibName: "CardFrontView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! CardFrontView!
    let cardBackView = UINib(nibName: "CardBackView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! CardBackView!
    
    var coreDataStack: CoreDataStack!
    var card: Card? {
        didSet {
            configureCardView(card)
        }
    }
    var cardReviewCoordinator: CardReviewCoordinator?
    var showBack = false
    var isActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardFrontView.frame = view.bounds
        cardFrontView.backgroundColor = UIColor.clearColor()
        cardBackView.frame = view.bounds
        cardBackView.backgroundColor = UIColor.clearColor()
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        singleTap.numberOfTapsRequired = 1
        cardFrontView.addGestureRecognizer(singleTap)
        
        cardFrontView.cardEventmanager = self
        cardBackView.cardEventmanager = self
        
        configureCardView(card)
        
        view.addSubview(cardFrontView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        cardFrontView.frame = view.bounds
        cardBackView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tapped() {
        NSLog("Card Tapped")
        guard isActive == true && card != nil else {
            return
        }
        
        if showBack {
            showBack = false
            cardReviewCoordinator?.willHideCardBack()
            UIView.transitionFromView(cardBackView, toView: cardFrontView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromBottom, completion: nil)
        } else {
            showBack = true
            cardReviewCoordinator?.willShowCardBack()
            UIView.transitionFromView(self.cardFrontView, toView: self.cardBackView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromTop, completion: nil)
        }
    }
    
    private func configureCardView(card: Card?) {
        guard let card = card else {
            if showBack {
                showBack = false
                cardReviewCoordinator?.willHideCardBack()
                UIView.transitionFromView(cardBackView, toView: cardFrontView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: nil)
            }
            
            cardFrontView.card = nil
            isActive = false
            return
        }
        
        isActive = true
        cardFrontView.card = card
        cardBackView.card = card
    }
    
    private func saveCard(card: Card) {
        print("Save card:\n\(card)")
        let context = self.coreDataStack.context
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    private func deleteCard(card: Card) {
        let alert = UIAlertController(title: "Delete \(card.title!)", message: nil, preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action: UIAlertAction) -> Void in
            print("Delete card:\n\(card)")
            let context = self.coreDataStack.context
            context.deleteObject(card)
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            self.tapped()
            self.cardReviewCoordinator?.didReviewCard()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction) -> Void in
            print("Cancel")
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension CardReviewViewController: CardEventManager {
    func rememberButtonPressed(card: Card) {
        let model = MoccacinoMemoryModel.shared
        card.memoryScore = 100.0
        card.currentPeriod = NSNumber(integer: card.currentPeriod!.integerValue + 1)
        card.nextReviewTime = model.calculateNextReviewTimeWith(card)
        saveCard(card)
        tapped()
        cardReviewCoordinator?.didReviewCard()
        
    }
    
    func forgetButtonPressed(card: Card) {
        let model = MoccacinoMemoryModel.shared
        card.nextReviewTime = model.calculateOneDayMore(card)
        saveCard(card)
        tapped()
        cardReviewCoordinator?.didReviewCard()
    }
    
    func forgetButtonLongPressed(card: Card) {
        deleteCard(card)
    }
    
    func speak(string: String?) {
        guard let string = string else {
            return
        }
        
        if #available(iOS 9.0, *) {
            let voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
            let synth = AVSpeechSynthesizer()
            
            synth.delegate = self
            
            let utter = AVSpeechUtterance(string: string)
            utter.voice = voice
            NSLog("Speak \(utter)")
            synth.speakUtterance(utter)
        } else {
            // Fallback on earlier versions
        }
    }

}

// TODO: - AVSpeechSynthesizerDelegate
extension CardReviewViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didCancelSpeechUtterance utterance: AVSpeechUtterance) {
        print("didCancelSpeechUtterance")
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didPauseSpeechUtterance utterance: AVSpeechUtterance) {
        print("didPauseSpeechUtterance")
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didContinueSpeechUtterance utterance: AVSpeechUtterance) {
        print("didContinueSpeechUtterance")
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        print("didFinishSpeechUtterance")
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
        print("didStartSpeechUtterance")
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print("willSpeakRangeOfSpeechString")
    }
    
}

protocol CardReviewCoordinator {
    func willShowCardBack()
    func willHideCardBack()
    func didReviewCard()
}

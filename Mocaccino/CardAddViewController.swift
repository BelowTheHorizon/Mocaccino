//
//  CardAddViewController.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-11.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

private let kCardAddViewHeight: CGFloat = 200
private let kCardAddViewWidth: CGFloat  = 300
private let kCardAddViewOffset: CGFloat = kCardAddViewHeight/2 + 64

class CardAddViewController: UIViewController {
    
    let fromView: UIView
    let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    var animator: UIDynamicAnimator!
    var attachmentBehavior: UIAttachmentBehavior!
    var snapBehavior: UISnapBehavior!
    var panBehavior: UIAttachmentBehavior!
    
    var cardAddView: CardAddView!
    
    // MARK: - View life cycle
    
    init(fromView: UIView) {
        self.fromView = fromView
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .OverFullScreen
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurredView.frame = view.bounds
        view.addSubview(blurredView)
        
        cardAddView = creatCardAddView()
        cardAddView.center = fromView.center
        cardAddView.center.y = kCardAddViewOffset
        view.addSubview(cardAddView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
//        setupAnimator()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupAnimator() {
        animator = UIDynamicAnimator(referenceView: view)
        
        var center = CGPoint(x: CGRectGetWidth(view.bounds)/2, y: CGRectGetHeight(view.bounds)/2)
        
        cardAddView = creatCardAddView()
        view.addSubview(cardAddView)
        snapBehavior = UISnapBehavior(item: cardAddView, snapToPoint: center)
        
        center.y += kCardAddViewOffset
        attachmentBehavior = UIAttachmentBehavior(item: cardAddView, offsetFromCenter: UIOffset(horizontal: 0, vertical: kCardAddViewOffset), attachedToAnchor: center)
        
//        setupTipView(tipView, index: 0)
//        resetTipView(tipView, position: .RotatedRight)
        
//        let pan = UIPanGestureRecognizer(target: self, action: "panTipView:")
//        view.addGestureRecognizer(pan)
    }
    
    
    private func creatCardAddView() -> CardAddView? {
        if let view = UINib(nibName: "CardAddView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! CardAddView? {
            view.frame = CGRect(x: 0, y: 0, width: kCardAddViewWidth, height: kCardAddViewHeight)
            return view
        }
        return nil
    }
}

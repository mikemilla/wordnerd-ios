//
//  Extensions.swift
//  wordnerd
//
//  Created by Michael Miller on 7/18/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}

extension UIView {
    func slideOutIn(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let slideInFromRightTransition = CATransition()
        
        if let delegate: AnyObject = completionDelegate {
            slideInFromRightTransition.delegate = delegate
        }
        
        slideInFromRightTransition.type = kCATransitionPush
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = duration
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved
        
        self.layer.addAnimation(slideInFromRightTransition, forKey: "slideInFromRightTransition")
    }
    
    func slideInFromBottom(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let slideInFromBottomTransition = CATransition()
        
        if let delegate: AnyObject = completionDelegate {
            slideInFromBottomTransition.delegate = delegate
        }
        
        slideInFromBottomTransition.type = kCATransitionPush
        slideInFromBottomTransition.subtype = kCATransitionFromTop
        slideInFromBottomTransition.duration = duration
        slideInFromBottomTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        slideInFromBottomTransition.fillMode = kCAFillModeRemoved
        
        self.layer.addAnimation(slideInFromBottomTransition, forKey: "slideInFromBottomTransition")
    }
    
    func slideOutToTop(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let slideOutToTopTransition = CATransition()
        
        if let delegate: AnyObject = completionDelegate {
            slideOutToTopTransition.delegate = delegate
        }
        
        slideOutToTopTransition.type = kCATransitionPush
        slideOutToTopTransition.subtype = kCATransitionFromBottom
        slideOutToTopTransition.duration = duration
        slideOutToTopTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        slideOutToTopTransition.fillMode = kCAFillModeRemoved
        
        self.layer.addAnimation(slideOutToTopTransition, forKey: "slideInFromBottomTransition")
    }
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.075
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - 5, self.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.center.x + 5, self.center.y))
        self.layer.addAnimation(animation, forKey: "position")
    }
}

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

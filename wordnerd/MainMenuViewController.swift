//
//  MainMenuViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 6/13/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    var fade = CATransition()
    
    @IBAction func overFlowMenuAction(sender: AnyObject) {
        println("Overflow Clicked")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change Button Font
        startButton.titleLabel!.font = UIFont(name: "8BITWONDERNominal", size: 12)
        
        // Text Looping Animations
        loopTextChangeAnimation(true)
    }
    
    func loopTextChangeAnimation(tutorialIsShowing: Bool) {
        if (tutorialIsShowing) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                Int64(2 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    self.startButton.layer.addAnimation(self.fade, forKey: "Fade")
                    self.startButton.setTitle("rhyme with the words", forState: UIControlState.Normal)
                    self.loopTextChangeAnimation(false)
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                Int64(2 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    self.startButton.layer.addAnimation(self.fade, forKey: "Fade")
                    self.startButton.setTitle("tap here to play", forState: UIControlState.Normal)
                    self.loopTextChangeAnimation(true)
            }
        }
    }
    
    /*
    * Hide status bar
    */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

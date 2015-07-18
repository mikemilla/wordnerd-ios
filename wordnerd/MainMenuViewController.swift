//
//  MainMenuViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 6/13/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import GameKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    var fade = CATransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change Button Font
        startButton.titleLabel!.font = UIFont(name: "8BITWONDERNominal", size: 12)
        
        // Text Looping Animations
        loopTextChangeAnimation(true)
        
        authenticateLocalPlayer()
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
    
    /*
    * Sign into GameCenter
    */
    func authenticateLocalPlayer() {
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                self.presentViewController(viewController, animated: true, completion: nil)
            }
            else {
                println((GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
    
}

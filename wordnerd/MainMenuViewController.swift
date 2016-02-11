//
//  MainMenuViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 6/13/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import GameKit
import SwiftyJSON

class MainMenuViewController: UIViewController {
    
    let WORD_KEY:String = "word_key"
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    var fade = CATransition()
    
    @IBAction func playButton(sender: AnyObject) {
        performSegueWithIdentifier("PlayNewGame", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change Label Fonts
        logoLabel.font = UIFont(name: "8BITWONDERNominal", size: 52)
        startButton.titleLabel!.font = UIFont(name: "8BITWONDERNominal", size: 12)
        
        // Set logo text
        logoLabel.text = "Word\nNerd"
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 16
        style.alignment = .Center
        let attributes = [NSParagraphStyleAttributeName: style]
        logoLabel.attributedText = NSAttributedString(string: logoLabel.text!, attributes:attributes)
        
        // Text Looping Animations
        //loopTextChangeAnimation(true)
        
        // Sign Player into Game Center
        authenticateLocalPlayer()
        
        setButtonObservers(startButton)
        setButtonObservers(menuButton)
        startButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
    }
    
    // Set the observers to both of the buttons
    func setButtonObservers(sender: UIButton) {
        sender.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
        sender.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchDragExit)
        sender.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // Button is touched
    func buttonDown(sender: UIButton) {
        sender.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
    }
    
    // Button is dragged away and canceled
    func buttonUp(sender: UIButton) {
        if (sender == startButton) {
            sender.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        } else {
            sender.backgroundColor = UIColor.clearColor()
        }
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
    * Sign into GameCenter
    */
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
            else {
                print((GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
    
}

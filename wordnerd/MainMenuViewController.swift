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
    
    @IBOutlet weak var nerdLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    let WORD_KEY:String = "word_key"
    let BIT_FONT:String = "8BITWONDERNominal"
    @IBOutlet weak var copyRight: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    var fade = CATransition()
    
    @IBAction func playButton(sender: AnyObject) {
        canRunOpenningAnimation = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        vc.mainViewController = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sign Player into Game Center
        authenticateLocalPlayer()
        
        setButtonObservers(startButton)
        setButtonObservers(menuButton)
        startButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        
        wordLabel.font = UIFont(name: BIT_FONT, size: 52)
        nerdLabel.font = UIFont(name: BIT_FONT, size: 52)
        
        runOpeningAnimation()
    }
    
    let SECONDS_SHORT = dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC)))
    let SECONDS_TWO = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
    var canRunOpenningAnimation:Bool = true
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func runOpeningAnimation() {
        if (canRunOpenningAnimation) {
            self.delay(4) {
                self.wordLabel.slideOutIn(0.4, completionDelegate: self)
                self.nerdLabel.text = nil
                self.delay(1) {
                    self.nerdLabel.text = "N"
                    self.delay(0.1) {
                        self.nerdLabel.text = "NE"
                        self.delay(0.1) {
                            self.nerdLabel.text = "NER"
                            self.delay(0.1) {
                                self.nerdLabel.text = "NERD"
                                self.runOpeningAnimation()
                            }
                        }
                    }
                }
            }
        } else {
            self.nerdLabel.text = "NERD"
        }
    }
    
    @IBOutlet weak var logoImage: UIImageView!
    
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
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
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var nerdLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    let WORD_KEY:String = "word_key"
    let BIT_FONT:String = "8BITWONDERNominal"
    @IBOutlet weak var copyRight: UILabel!
    @IBOutlet weak var startButton: UIButton!
    var fade = CATransition()
    
    @IBAction func playButton(sender: AnyObject) {
        canRunOpenningAnimation = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        vc.mainViewController = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func rateAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/bars/id706081574")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sign Player into Game Center
        authenticateLocalPlayer()
        
        setButtonObservers(startButton)
        setButtonObservers(rateButton)
        setButtonObservers(moreButton)
        startButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        rateButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        moreButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        
        wordLabel.font = UIFont(name: BIT_FONT, size: 52)
        nerdLabel.font = UIFont(name: BIT_FONT, size: 52)
        
        rateButton.titleLabel?.font = UIFont(name: BIT_FONT, size: 16)
        moreButton.titleLabel?.font = UIFont(name: BIT_FONT, size: 16)
        rateButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: UIControlState.Normal)
        moreButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: UIControlState.Normal)
        
        runOpeningAnimation()
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year], fromDate: date)
        let year = components.year
        copyRight.text = "© Michael Miller \(year)"
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
        sender.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
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
                print("User is signed into Game Center \(GKLocalPlayer.localPlayer().authenticated)")
            }
        }
    }
    
}
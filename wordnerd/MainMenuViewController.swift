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
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    var fade = CATransition()
    
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
        loopTextChangeAnimation(true)
        
        // Sign Player into Game Center
        authenticateLocalPlayer()
        
        let url = NSURL(string: "http://www.mikemilla.com/words.json")
        let wordData = NSData(contentsOfURL: url!)
        let json = JSON(data: wordData!)
        print(json)
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

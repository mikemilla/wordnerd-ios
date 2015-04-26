//
//  ViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 4/19/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var computerRhyme: UILabel!
    @IBOutlet weak var userRhyme: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startGame()
        
        // Progress View Styles
        var transform = CGAffineTransformMakeScale(1, 8)
        progressBar.transform = transform
        progressBar.trackTintColor = UIColor.clearColor()
        
        // Score Label Styles
        scoreLabel.font = UIFont (name: "VarelaRound", size: 28)
        scoreLabel.alpha = 0.5
        scoreLabel.text = "12"
        
        // Computer Rhyme Styles
        computerRhyme.textAlignment = .Center;
        computerRhyme.font = UIFont(name: "VarelaRound", size: 40)
        
        // User Rhyme Styles
        userRhyme.textAlignment = .Center;
        userRhyme.font = UIFont (name: "VarelaRound", size: 40)
        
        // Open Keyboard on launch
        userRhyme.delegate = self;
        userRhyme.becomeFirstResponder()
        
        // Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        // TextField textChangeListener notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidChange:"), name:UITextFieldTextDidChangeNotification, object:userRhyme);
        
        checkUserRhyme()
    }
    
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var gameTime:Double = 4
    
    func startGame() {
        progressBar.setProgress(1, animated: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func updateTime() {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = currentTime - startTime
        var seconds = gameTime - elapsedTime
        if seconds > 0 {
            elapsedTime -= NSTimeInterval(seconds)
            
            print(-Float(seconds))
            
            //println(gameTime)
            //println(currentTime)
            //println(elapsedTime)
            
            progressBar.setProgress(-Float(seconds), animated: true)
            
        } else {
            timer.invalidate()
            print("nigga")
        }
    }
    
    /*
    * Hide status bar
    */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /*
    * Check if keyboard is show
    */
    func keyboardWillShow(sender: NSNotification) {
        
        // Get Keyboard Height
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            // Set the Bottom UITextfield Constraint
            bottomConstraint.constant = keyboardSize.height
            
            // Animate Changes
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    /*
    * Check if keyboard will hide
    */
    func keyboardWillHide(sender: NSNotification) {
        
        // Set the Bottom UITextfield Constraint
        bottomConstraint.constant = 0
        
        // Animate Changes
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    /*
    * UITextField Change Listener
    */
    func textFieldDidChange(sender: NSNotification) {
        
        // Variable for handling userRhyme " " replacement
        let userRhymeWithNoSpaces = userRhyme.text.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // Set text of userRhyme to the string with no spaces
        userRhyme.text = userRhymeWithNoSpaces
        
        println(self.userRhyme.text)
        //methodThatWillTakeOverTheWorld(txtAfterUpdate)
        
        checkUserRhyme()
        
    }
    
    func timerCountDown() {
        //progressBar.progress += timer;
        println("Sweet Timer End")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        startGame()
        //println("Dope")
        return true
    }
    
    func methodThatWillTakeOverTheWorld(txtAfterUpdate: NSString) {
        println("Sup")
    }
    
    func checkUserRhyme() {
        if (userRhyme.text == "") {
            userRhyme.backgroundColor = UIColor.blueColor()
        } else {
            userRhyme.backgroundColor = UIColor.whiteColor()
        }
    }
    
}
//
//  ViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 4/19/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var computerRhyme: UILabel!
    @IBOutlet weak var userRhyme: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // Instances
    var timer = NSTimer()
    var gameTime:Double = 400
    var shuffledWords = Array<String>()
    var item: String = ""
    var increment = 0
    
    // Outer class reference?
    var words = ["word", "dope", "sweet", "gnar", "factory"]
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Progress View Styles
        var transform = CGAffineTransformMakeScale(1, 8)
        progressBar.transform = transform
        progressBar.trackTintColor = UIColor.clearColor()
        progressBar.setProgress(0, animated: false)
        
        // Score Label Styles
        scoreLabel.font = UIFont (name: "VarelaRound", size: 28)
        scoreLabel.alpha = 0.5
        scoreLabel.text = "12"
        
        // Computer Rhyme Styles
        computerRhyme.textAlignment = .Center
        computerRhyme.font = UIFont(name: "VarelaRound", size: 40)
        
        // User Rhyme Styles
        userRhyme.textAlignment = .Center
        userRhyme.font = UIFont (name: "VarelaRound", size: 40)
        
        // Open Keyboard on launch
        userRhyme.delegate = self
        userRhyme.becomeFirstResponder()
        
        // Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // TextField textChangeListener notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidChange:"), name:UITextFieldTextDidChangeNotification, object:userRhyme)
      
        // Check if text is entered
        checkUserRhyme()
        
        // Create a word to rhyme with
        generateRhyme()
    }
    
    /**
    * Set the computer rhyme word
    */
    func generateRhyme() {
        if (increment == 0) {
            // Shuffle words if it's the first run
            shuffledWords = shuffle(words)
        }
        else if (increment == words.count) {
            // Index out of bounds will never happen again
            shuffledWords = shuffle(words)
            increment = 1
        }
        item = shuffledWords[increment]
        println(shuffledWords)
        println(increment)
        computerRhyme.text = item
        increment++
    }
    
    /**
    * Shuffle an array
    */
    func shuffle < C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let c = count(list)
        for i in 0..<(c - 1) {
            let j = Int(arc4random_uniform(UInt32(c - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
    
    /*
    * Reset Timer
    */
    func startGame() {
        timer.invalidate()
        gameTime = 400
        progressBar.setProgress(1, animated: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(
            0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
    }
    
    /*
    * Update Progress bar and do countdown
    */
    func updateTime() {
        progressBar.setProgress(Float(0.0025 * gameTime), animated: true)
        if (gameTime > 0) {
            gameTime--
            //println(gameTime)
        } else {
            // Kill timer
            timer.invalidate()
        
            // Reset for playing again
            increment = 0
            
            // Vibrate on gameover
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // textField.resignFirstResponder()
        // Restart the countdown
        generateRhyme()
        startGame()
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
//
//  ViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 4/19/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import AudioToolbox

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
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideOutIn(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromRightTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromRightTransition.type = kCATransitionPush
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = duration
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.addAnimation(slideInFromRightTransition, forKey: "slideInFromRightTransition")
    }
    
    func slideInFromBottom(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromBottomTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromBottomTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromBottomTransition.type = kCATransitionPush
        slideInFromBottomTransition.subtype = kCATransitionFromTop
        slideInFromBottomTransition.duration = duration
        slideInFromBottomTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        slideInFromBottomTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.addAnimation(slideInFromBottomTransition, forKey: "slideInFromBottomTransition")
    }
    
    func slideOutToTop(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideOutToTopTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideOutToTopTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideOutToTopTransition.type = kCATransitionPush
        slideOutToTopTransition.subtype = kCATransitionFromBottom
        slideOutToTopTransition.duration = duration
        slideOutToTopTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        slideOutToTopTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.addAnimation(slideOutToTopTransition, forKey: "slideInFromBottomTransition")
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var computerRhyme: UILabel!
    @IBOutlet weak var userRhyme: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var homeView: UIView!
    
    @IBAction func startGameButton(sender: AnyObject) {
        homeView.slideInFromBottom(duration: delayDuration, completionDelegate: self)
        NSThread.sleepForTimeInterval(delayDuration)
        homeView.hidden = true
        userRhyme.becomeFirstResponder()
        score = 0
        createRhyme()
    }
    
    @IBAction func restartButton(sender: AnyObject) {
        createRhyme()
    }
    
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var scoreViewBottomConstraint: NSLayoutConstraint!
    var delayDuration = 0.15
    
    // Instances
    var timer = NSTimer()
    var gameTime:Double = 400
    var shuffledWords = Array<String>()
    var item: String = ""
    var score = 0
    var color = 0
    
    var isGameOver = false
    
    // Outer class reference?
    var words = ["word", "dope", "sweet", "gnar", "factory"]
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreView.hidden = true
        
        // Progress View Styles
        var transform = CGAffineTransformMakeScale(1, 8)
        progressBar.transform = transform
        progressBar.trackTintColor = UIColor.clearColor()
        progressBar.setProgress(0, animated: false)
        
        // Score Label Styles
        scoreLabel.font = UIFont (name: "VarelaRound", size: 28)
        scoreLabel.alpha = 0.5
        
        // Computer Rhyme Styles
        computerRhyme.textAlignment = .Center
        computerRhyme.font = UIFont(name: "VarelaRound", size: 40)
        
        // User Rhyme Styles
        userRhyme.textAlignment = .Center
        userRhyme.font = UIFont (name: "VarelaRound", size: 40)
        userRhyme.tintColor = UIColor.clearColor()
        
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
        createRhyme()
    }
    
    /**
    * Set the computer rhyme word
    */
    func createRhyme() {
        
        userRhyme.text = nil
        
        if (score == 0) {
            
            // Shuffle words if it's the first run
            shuffledWords = shuffle(words)
            
            //var colorRandom = arc4random_uniform(5) + 1
            
            if (color == 0) {
                color++
                var blue:Int = 0x2196F3
                view.backgroundColor = UIColor(hex: blue)
            } else if (color == 1) {
                color++
                var indigo:Int = 0x3F51B5
                view.backgroundColor = UIColor(hex: indigo)
            } else if (color == 2) {
                color++
                var teal:Int = 0x009688
                view.backgroundColor = UIColor(hex: teal)
            } else if (color == 3) {
                color++
                var deep_purple:Int = 0x673AB7
                view.backgroundColor = UIColor(hex: deep_purple)
            } else if (color == 4) {
                color++
                var red:Int = 0xF44336
                view.backgroundColor = UIColor(hex: red)
            } else if (color == 5) {
                color = 0
                var green:Int = 0x4CAF50
                view.backgroundColor = UIColor(hex: green)
            }
            
            scoreView.slideOutToTop(duration: delayDuration, completionDelegate: self)
            NSThread.sleepForTimeInterval(delayDuration)
            scoreView.hidden = true
            checkUserRhyme()
            
        } else {
            computerRhyme.slideOutIn(duration: 0.3, completionDelegate: self)
            isGameOver = false
        }
        
        // Index out of bounds will never happen again
        if (score == words.count) {
            shuffledWords = shuffle(words)
            score = 1
        }
        
        // If score is 0, remove the score text
        scoreLabel.text = String(score)
        if (scoreLabel.text == String(0)) {
            scoreLabel.text = nil
        }
        
        // Set new computer rhyme text
        item = shuffledWords[score]
        computerRhyme.text = item
        
        // Add one to the score
        score++
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
    * Update Progress bar and do countdown
    */
    func updateTime() {
        progressBar.setProgress(Float(0.0025 * gameTime), animated: true)
        if (gameTime > 0) {
            gameTime--
            isGameOver = false
        } else {
            // Kill timer
            timer.invalidate()
            
            // Reset for playing again
            score = 0
            
            // Vibrate on gameover
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            isGameOver = true
            
            scoreView.hidden = false
            scoreView.slideInFromBottom(duration: delayDuration, completionDelegate: self)
            userRhyme.text = ""
            
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
            scoreViewBottomConstraint.constant = keyboardSize.height
            
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
        scoreViewBottomConstraint.constant = 0
        
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
        
        //println(self.userRhyme.text)
        methodThatWillTakeOverTheWorld(userRhyme.text)
        
        if (!scoreView.hidden) {
            userRhyme.text = nil
        }
        
        checkUserRhyme()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Create new rhyme
        createRhyme()
        
        // Restart timer if game isn't over
        if (!isGameOver) {
            timer.invalidate()
            gameTime = 400
            progressBar.setProgress(1, animated: false)
            timer = NSTimer.scheduledTimerWithTimeInterval(
                0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        }
        
        return true
    }
    
    func methodThatWillTakeOverTheWorld(txtAfterUpdate: NSString) {
        println("Sup")
    }
    
    func checkUserRhyme() {
        if (userRhyme.text == "" || userRhyme.text == nil) {
            userRhyme.backgroundColor = UIColor(hex: 0xF1F1F1)
        } else {
            userRhyme.backgroundColor = UIColor(hex: 0xFFFFFF)
        }
    }
    
}
//
//  ViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 4/19/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox

/**
* UI Color with HEX
*/
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

/**
* UIView Animation Extensions
*/
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
    
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.075
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - 5, self.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.center.x + 5, self.center.y))
        self.layer.addAnimation(animation, forKey: "position")
    }
}

class GameViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var computerRhyme: UILabel!
    @IBOutlet weak var userRhyme: UITextField!
    @IBOutlet weak var userRhymeAnimation: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var scoreViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var highScore: UILabel!
    @IBOutlet weak var newScore: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var scoreAreaContainer: UIView!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var syllablesLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var dashedLine: UIView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Instances
    var timer = NSTimer()
    var gameTime:Double = 400
    var shuffledWords = Array<String>()
    var item: String = ""
    var position = 0
    var score = 0
    var color = 0
    var delayDuration = 0.15
    var isGameOver = false
    
    var theme = 0
    
    var words = rhymableWords.list
    
    // Colors
    var blue:Int = 0x2196F3
    var indigo:Int = 0x3F51B5
    var teal:Int = 0x009688
    var deep_purple:Int = 0x673AB7
    var red:Int = 0xF44336
    var green:Int = 0x4CAF50
    
    // Actions
    @IBAction func startGameButton(sender: AnyObject) {
        homeView.slideInFromBottom(duration: delayDuration, completionDelegate: self)
        NSThread.sleepForTimeInterval(delayDuration)
        homeView.hidden = true
        userRhyme.becomeFirstResponder()
        position = 0
        createRhyme()
    }
    
    @IBAction func restartButton(sender: AnyObject) {
        score = 0
        position = 0
        scoreLabel.text = nil
        Verify.playedRhymes.removeAllObjects()
        createRhyme()
    }
    
    @IBAction func homeButton(sender: AnyObject) {
        score = 0
        position = 0
        scoreLabel.text = nil
        Verify.playedRhymes.removeAllObjects()
    }
    
    @IBAction func gamesButton(sender: AnyObject) {
        println("Games Button")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Check the Font Names
        for fontFamilyNames in UIFont.familyNames() {
            for fontName in UIFont.fontNamesForFamilyName(fontFamilyNames as! String) {
                println("FONTNAME:\(fontName)")
            }
        }
        */
        
        scoreView.hidden = true
        
        // Progress View Styles
        var transform = CGAffineTransformMakeScale(1, 8)
        progressBar.transform = transform
        progressBar.trackTintColor = UIColor.clearColor()
        progressBar.setProgress(0, animated: false)
        
        // Score Styles
        scoreLabel.alpha = 0.5
        scoreLabel.text = nil
        
        // Computer Rhyme Styles
        computerRhyme.textAlignment = .Center
        
        // User Rhyme Styles
        userRhyme.textAlignment = .Center
        userRhyme.tintColor = UIColor.clearColor()
        
        // Restart Button Styles
        //restartButton.layer.cornerRadius = 4
        var borderLeftNotch = CALayer()
        borderLeftNotch.borderColor = UIColor(hex: 0xffffff).CGColor
        borderLeftNotch.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
        borderLeftNotch.borderWidth = 4
        restartButton.layer.addSublayer(borderLeftNotch)
        
        var borderRightNotch = CALayer()
        borderRightNotch.borderColor = UIColor(hex: 0xffffff).CGColor
        borderRightNotch.frame = CGRect(x: restartButton.frame.size.width - 4, y: 0, width: 4, height: 4)
        borderRightNotch.borderWidth = 4
        restartButton.layer.addSublayer(borderRightNotch)
        restartButton.layer.masksToBounds = true
        setButtonObservers(restartButton)
        
        // Open Keyboard on launch
        userRhyme.delegate = self
        userRhyme.becomeFirstResponder()
        
        // Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // TextField textChangeListener notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidChange:"), name:UITextFieldTextDidChangeNotification, object:userRhyme)
        
        // Set the font type for the View Controller
        setFonts("8BITWONDERNominal")
        
        println(words)
        
        // Check if text is entered
        checkUserRhyme()
        
        // Create a word to rhyme with
        createRhyme()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Add border to Score Game Over Label
        var border = CALayer()
        border.borderColor = UIColor(hex: 0xDDDDDD).CGColor
        border.frame = CGRect(x: 0, y: gameOverLabel.frame.size.height - 3, width:  gameOverLabel.frame.size.width, height: gameOverLabel.frame.size.height)
        border.borderWidth = 3
        gameOverLabel.layer.addSublayer(border)
        gameOverLabel.layer.masksToBounds = true
    }
    
    /**
    * Set the font of the view controller elements
    * Storyboard couldn't find the font for some reason
    */
    func setFonts(name: String) {
        userRhyme.font = UIFont (name: name, size: 30)
        computerRhyme.font = UIFont(name: name, size: 30)
        gameOverLabel.font = UIFont (name: name, size: 20)
        scoreLabel.font = UIFont (name: name, size: 22)
        newScore.font = UIFont (name: name, size: 20)
        syllablesLabel.font = UIFont (name: name, size: 16)
        highScore.font = UIFont (name: name, size: 16)
        bestLabel.font = UIFont (name: name, size: 16)
    }
    
    /**
    * Set the computer rhyme word
    */
    func createRhyme() {
        
        // Create the dot animation
        createRandomUserRhymeAnimation()
        
        // Delay clearing text
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.15 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue()) {
                self.userRhyme.text = nil
                self.checkUserRhyme()
        }
        
        if (position == 0) {
            
            // Shuffle words if it's the first run
            shuffledWords = shuffle(words)
            
            //var colorRandom = arc4random_uniform(5) + 1
            
            if (color == 0) {
                color++
                view.backgroundColor = UIColor(hex: blue)
            } else if (color == 1) {
                color++
                view.backgroundColor = UIColor(hex: indigo)
            } else if (color == 2) {
                color++
                view.backgroundColor = UIColor(hex: teal)
            } else if (color == 3) {
                color++
                view.backgroundColor = UIColor(hex: deep_purple)
            } else if (color == 4) {
                color++
                view.backgroundColor = UIColor(hex: red)
            } else if (color == 5) {
                color = 0
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
        if (position == words.count) {
            shuffledWords = shuffle(words)
            position = 0
        }
        
        // Set new computer rhyme text
        item = shuffledWords[position]
        computerRhyme.text = item
    }
    
    /**
    * Create a the animation for the user input area
    */
    func createRandomUserRhymeAnimation() {
        
        var randomNumber: Int = random() % 3;
        var frames = "AFrame%03d"
        
        switch(randomNumber) {
        case 0:
            frames = "AFrame%03d"
            break
        case 1:
            frames = "BFrame%03d"
            break
        case 2:
            frames = "CFrame%03d"
            break
        default:
            frames = "AFrame%03d"
            break
        }
        
        userRhymeAnimation.animationImages = [UIImage]()
        
        for var index = 0; index < 4; index++ {
            var frameName = String(format: frames, index)
            userRhymeAnimation.animationImages?.append(UIImage(named: frameName)!)
        }
        
        userRhymeAnimation.animationDuration = 1
        userRhymeAnimation.startAnimating()
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
            isGameOver = true
            onGameOver()
        }
    }
    
    func onGameOver(){
        // Kill timer
        timer.invalidate()
        
        // Vibrate on gameover
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        restartButton.backgroundColor = getThemeColor(true)
        
        // Reset for playing again
        position = 0
        
        // Show the Score Screen
        scoreView.hidden = false
        scoreView.slideInFromBottom(duration: delayDuration, completionDelegate: self)
        userRhyme.text = ""
        
        // Create a constant for the high score
        let bestScore = defaults.integerForKey("highScore")
        
        // Check if new score is better than old
        if (score > bestScore) {
            defaults.setObject(score, forKey: "highScore")
            highScore.text = String(score)
        } else {
            highScore.text = String(bestScore)
        }
        
        // Show the score
        newScore.text = String(score)
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
        
        
        if (userRhyme.text.lowercaseString == computerRhyme.text) {
            
            // Shake and clear if rhyme is same as generated
            userRhyme.shake()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.15 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    self.userRhyme.text = nil
            }
            
        } else if (Verify.crunchTheWord(computerRhyme.text, attemptedRhyme: userRhyme.text.lowercaseString) == 1) {
            
            // Rhyme was accepted
            score += Verify.syllables
            scoreLabel.text = String(score)
            advanceWord()
            
        } else if (Verify.crunchTheWord(computerRhyme.text, attemptedRhyme: userRhyme.text.lowercaseString) == 2) {
            
            // Rhyme was a duplicate
            userRhyme.text = nil
        }
        
        // Disable text in score view
        if (!scoreView.hidden) {
            userRhyme.text = nil
        }
        
        // Check if the rhyme is null
        checkUserRhyme()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Clear Text
        userRhyme.text = nil
        checkUserRhyme()
        return true;
    }
    
    func advanceWord() {
        
        // Advance the list position
        position++
        
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
    }
    
    // Check if the user rhyme has text
    func checkUserRhyme() {
        if (userRhyme.text == "" || userRhyme.text == nil) {
            userRhymeAnimation.hidden = false
        } else {
            userRhymeAnimation.hidden = true
        }
    }
    
    // Set the observers to both of the buttons
    func setButtonObservers(sender: UIButton) {
        sender.addTarget(self, action: "restartButtonDown:", forControlEvents: UIControlEvents.TouchDown)
        sender.addTarget(self, action: "restartButtonUp:", forControlEvents: UIControlEvents.TouchDragExit)
        sender.addTarget(self, action: "restartButtonUp:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func getThemeColor(up: Bool) -> UIColor {
        if (up) {
            // Handle Button Up State
            if (color == 1) {
                return UIColor(hex: blue)
            } else if (color == 2) {
                return UIColor(hex: indigo)
            } else if (color == 3) {
                return UIColor(hex: teal)
            } else if (color == 4) {
                return UIColor(hex: deep_purple)
            } else if (color == 5) {
                return UIColor(hex: red)
            } else {
                return UIColor(hex: green)
            }
        } else {
            // Handle Button Down State
            if (color == 1) {
                return UIColor(hex: indigo)
            } else if (color == 2) {
                return UIColor(hex: teal)
            } else if (color == 3) {
                return UIColor(hex: deep_purple)
            } else if (color == 4) {
                return UIColor(hex: red)
            } else if (color == 5) {
                return UIColor(hex: green)
            } else {
                return UIColor(hex: blue)
            }
        }
    }
    
    // Button is touched
    func restartButtonDown(sender: UIButton) {
        sender.backgroundColor = getThemeColor(false)
    }
    
    // Button is dragged away and canceled
    func restartButtonUp(sender: UIButton) {
        sender.backgroundColor = getThemeColor(true)
    }
    
}
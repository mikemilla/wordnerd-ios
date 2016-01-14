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
import GameKit
import SwiftyJSON

class GameViewController: UIViewController, UITextFieldDelegate, GKGameCenterControllerDelegate {
    
    var json:JSON?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let HIDE_BACK_BUTTON:CGFloat = -60
    let SHOW_BACK_BUTTON:CGFloat = 0
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonLeadingConstraint: NSLayoutConstraint!
    
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
    
    var playedRhymes:NSMutableArray = []
    
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
    
    var shuffledWordArray = [Int]()
    
    // Colors
    var blue:Int = 0x2196F3
    var indigo:Int = 0x3F51B5
    var teal:Int = 0x009688
    var deep_purple:Int = 0x673AB7
    var red:Int = 0xF44336
    var green:Int = 0x4CAF50
    
    // Actions
    @IBAction func startGameButton(sender: AnyObject) {
        homeView.slideInFromBottom(delayDuration, completionDelegate: self)
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
        playedRhymes.removeAllObjects()
        createRhyme()
    }
    
    @IBAction func gamesButton(sender: AnyObject) {
        showGameCenter()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreView.hidden = true
        
        // Progress View Styles
        let transform = CGAffineTransformMakeScale(1, 8)
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
        let borderLeftNotch = CALayer()
        borderLeftNotch.borderColor = UIColor(hex: 0xffffff).CGColor
        borderLeftNotch.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
        borderLeftNotch.borderWidth = 4
        restartButton.layer.addSublayer(borderLeftNotch)
        
        let borderRightNotch = CALayer()
        borderRightNotch.borderColor = UIColor(hex: 0xffffff).CGColor
        borderRightNotch.frame = CGRect(x: restartButton.frame.size.width - 4, y: 0, width: 4, height: 4)
        borderRightNotch.borderWidth = 4
        restartButton.layer.addSublayer(borderRightNotch)
        restartButton.layer.masksToBounds = true
        setButtonObservers(restartButton)
        setButtonObservers(backButton)
        
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
        
        // Pass the JSON
        json = appDelegate.json
        
        // Check if text is entered
        checkUserRhyme()
        
        // Create a word to rhyme with
        createRhyme()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add border to Score Game Over Label
        let border = CALayer()
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
        userRhyme.font = UIFont (name: name, size: 34)
        computerRhyme.font = UIFont(name: name, size: 34)
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
            shuffledWordArray = appDelegate.wordCountArray.shuffle()
            
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
            
            scoreView.slideOutToTop(delayDuration, completionDelegate: self)
            NSThread.sleepForTimeInterval(delayDuration)
            scoreView.hidden = true
            checkUserRhyme()
            
        } else {
            computerRhyme.slideOutIn(0.3, completionDelegate: self)
            isGameOver = false
        }
        
        // Index out of bounds will never happen again
        if (position == (json!["words"].count - 1)) {
            shuffledWordArray = appDelegate.wordCountArray.shuffle()
            position = 0
        }
        
        // Set new computer rhyme text
        item = json!["words"][shuffledWordArray[position]]["word"].stringValue
        computerRhyme.text = item
    }
    
    /**
    * Create a the animation for the user input area
    */
    func createRandomUserRhymeAnimation() {
        
        let randomNumber: Int = random() % 3;
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
            let frameName = String(format: frames, index)
            userRhymeAnimation.animationImages?.append(UIImage(named: frameName)!)
        }
        
        userRhymeAnimation.animationDuration = 1
        userRhymeAnimation.startAnimating()
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
        
        if (backButtonLeadingConstraint.constant != SHOW_BACK_BUTTON) {
            backButtonLeadingConstraint.constant = SHOW_BACK_BUTTON
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.backButton.layoutIfNeeded()
            })
        }
        
        // Kill timer
        timer.invalidate()
        
        // Vibrate on gameover
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        restartButton.backgroundColor = getThemeColor(true)
        
        // Reset for playing again
        position = 0
        
        // Show the Score Screen
        scoreView.hidden = false
        scoreView.slideInFromBottom(delayDuration, completionDelegate: self)
        userRhyme.text = ""
        
        // Create a constant for the high score
        let bestScore = defaults.integerForKey("highScore")
        
        // Check if new score is better than old
        if (score > bestScore) {
            defaults.setObject(score, forKey: "highScore")
            highScore.text = String(score)
            bestLabel.text = "New Best"
            bestLabel.textColor = getThemeColor(true)
            highScore.textColor = getThemeColor(true)
            saveHighscore(score)
        } else {
            highScore.text = String(bestScore)
            bestLabel.text = "Best"
            bestLabel.textColor = UIColor(hex: 0xBFBFBF)
            highScore.textColor = UIColor(hex: 0xBFBFBF)
        }
        
        // Show the score
        newScore.text = String(score)
    }
    
    /*
    * Save the highest score
    */
    func saveHighscore(score:Int) {
        
        // check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "Best_Score_Leaderboard") // leaderboard id here
            scoreReporter.value = Int64(score) // score variable here (same as above)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, withCompletionHandler: {(NSError) -> Void in
                if NSError != nil {
                    print(NSError!.localizedDescription)
                } else {
                    print("Score Complete")
                }
                
            })
        }
    }
    
    /*
    * Show GameCenter
    */
    func showGameCenter() {
        let vc = self
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc.presentViewController(gc, animated: true, completion: nil)
    }
    
    /*
    * Hide GameCenter
    */
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
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
        let userRhymeWithNoSpaces = userRhyme.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // Set text of userRhyme to the string with no spaces
        userRhyme.text = userRhymeWithNoSpaces
        
        if (userRhyme.text!.lowercaseString == computerRhyme.text) {
            
            // Shake and clear if rhyme is same as generated
            userRhyme.shake()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.15 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    self.userRhyme.text = nil
            }
        }
        
        if (playedRhymes.containsObject(userRhyme.text!.lowercaseString)) {
            
            // Shake and clear if rhyme is same as generated
            userRhyme.shake()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.15 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    self.userRhyme.text = nil
            }
        }
        
        if let singles = json!["words"][shuffledWordArray[position]]["rhymes"]["singles"].object as? [String] {
            if (singles.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 1)
            }
        }
        if let doubles = json!["words"][shuffledWordArray[position]]["rhymes"]["doubles"].object as? [String] {
            if (doubles.contains(userRhyme.text!.lowercaseString)) {
               addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 2)
            }
        }
        if let triples = json!["words"][shuffledWordArray[position]]["rhymes"]["triples"].object as? [String] {
            if (triples.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 3)
            }
        }
        if let quadruples = json!["words"][shuffledWordArray[position]]["rhymes"]["quadruples"].object as? [String] {
            if (quadruples.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 4)
            }
        }
        if let quintuples = json!["words"][shuffledWordArray[position]]["rhymes"]["quintuples"].object as? [String] {
            if (quintuples.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 5)
            }
        }
        if let sextuples = json!["words"][shuffledWordArray[position]]["rhymes"]["sextuples"].object as? [String] {
            if (sextuples.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 6)
            }
        }
        if let septuples = json!["words"][shuffledWordArray[position]]["rhymes"]["septuples"].object as? [String] {
            if (septuples.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 7)
            }
        }
        if let octuples = json!["words"][shuffledWordArray[position]]["rhymes"]["octuples"].object as? [String] {
            if (octuples.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 8)
            }
        }
        if let nonuples = json!["words"][shuffledWordArray[position]]["rhymes"]["nonuples"].object as? [String] {
            if (nonuples.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 9)
            }
        }
        if let decuples = json!["words"][shuffledWordArray[position]]["rhymes"]["decuples"].object as? [String] {
            if (decuples.contains(userRhyme.text!.lowercaseString)) {
                addScoreAndAdvance(userRhyme.text!.lowercaseString, points: 10)
            }
        }
        
        // Disable text in score view
        if (!scoreView.hidden) {
            userRhyme.text = nil
        }
        
        // Check if the rhyme is null
        checkUserRhyme()
    }
    
    func addScoreAndAdvance(rhymePlayed: String, points: Int) {
        playedRhymes.addObject(rhymePlayed)
        score += points
        scoreLabel.text = String(score)
        advanceWord()
        return
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Clear Text
        userRhyme.text = nil
        checkUserRhyme()
        return true;
    }
    
    func advanceWord() {
        
        // Slide out the back button
        if (backButtonLeadingConstraint.constant != HIDE_BACK_BUTTON) {
            backButtonLeadingConstraint.constant = HIDE_BACK_BUTTON
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.backButton.layoutIfNeeded()
            })
        }
        
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
    
    // Set the observers to both of the buttons
    func setButtonObservers(sender: UIButton) {
        sender.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
        sender.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchDragExit)
        sender.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // Button is touched
    func buttonDown(sender: UIButton) {
        if (sender == backButton) {
            sender.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        } else {
            sender.backgroundColor = getThemeColor(false)
        }
    }
    
    // Button is dragged away and canceled
    func buttonUp(sender: UIButton) {
        if (sender == backButton) {
            sender.backgroundColor = UIColor.clearColor()
        } else {
            sender.backgroundColor = getThemeColor(true)
        }
    }
    
}
//
//  NewGameViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 1/13/16.
//  Copyright © 2016 Michael Miller. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import GameKit
import SwiftyJSON

class GameViewController: UIViewController, UITextFieldDelegate, GKGameCenterControllerDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let BIT_FONT:String = "8BITWONDERNominal"
    let HIGH_SCORE:String = "highScore"
    var position = 0
    var shuffledWordArray = [Int]()
    var json:JSON?
    var gameTime:Double = 400
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var playedRhymes:NSMutableArray = []
    var score = 0
    var timer = NSTimer()
    var isGameOver = false
    let HIDE_BACK_BUTTON:CGFloat = -60
    let SHOW_BACK_BUTTON:CGFloat = 0
    let HIDE_SCORE_VIEW:CGFloat = UIScreen.mainScreen().applicationFrame.height
    let SHOW_SCORE_VIEW:CGFloat = 0
    var closeIcon:UIImage?
    var tintedCloseIcon:UIImage?
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var achievementsButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var finalBestAmountLabel: UILabel!
    @IBOutlet weak var finalScoreAmountLabel: UILabel!
    @IBOutlet weak var finalBestLabel: UILabel!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var backButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var cursorImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var gameViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var restartButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var scoreViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreViewHeight: NSLayoutConstraint!
    
    @IBAction func restartButton(sender: AnyObject) {
        restartGame()
        backButton.tintColor = UIColor.whiteColor()
        gameView.backgroundColor = setNextColor(gameView.backgroundColor!)
    }
    
    @IBAction func leaderboard(sender: AnyObject) {
        showGameLeaderboard()
    }
    
    @IBAction func achievements(sender: AnyObject) {
        showGameAchievements()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the json
        json = appDelegate.json
        
        // Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // TextField textChangeListener notification
        userInput.delegate = self
        userInput.becomeFirstResponder()
        userInput.font = UIFont(name: BIT_FONT, size: 34)
        createRandomUserRhymeAnimation()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidChange:"), name:UITextFieldTextDidChangeNotification, object:userInput)
        
        // Progress Bar
        // Progress View Styles
        let transform = CGAffineTransformMakeScale(1, 8)
        progressBar.transform = transform
        progressBar.trackTintColor = UIColor.clearColor()
        progressBar.setProgress(0, animated: false)
        
        // Back Button
        setButtonObservers(backButton)
        backButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        closeIcon = UIImage(named: "CloseIcon")!
        tintedCloseIcon = closeIcon!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        backButton.setImage(tintedCloseIcon, forState: .Normal)
        backButton.tintColor = UIColor.whiteColor()
        
        // Score Label
        scoreLabel.alpha = 0.5
        scoreLabel.text = nil
        scoreLabel.font = UIFont(name: BIT_FONT, size: 22)
        
        // Rhyme Label
        wordLabel.font = UIFont(name: BIT_FONT, size: 34)
        
        // Background Color
        gameView.backgroundColor = randomColor()
        restartButton.backgroundColor = gameView.backgroundColor!
        
        // Set the word
        createRhyme()
        
        // Game Over View
        restartButtonWidth.constant = view.frame.width / 3
        scoreViewTopConstraint.constant = HIDE_SCORE_VIEW
        gameOverLabel.font = UIFont(name: BIT_FONT, size: 20)
        finalScoreLabel.font = UIFont(name: BIT_FONT, size: 18)
        finalScoreAmountLabel.font = UIFont(name: BIT_FONT, size: 24)
        finalBestLabel.font = UIFont(name: BIT_FONT, size: 18)
        finalBestAmountLabel.font = UIFont(name: BIT_FONT, size: 24)
        setButtonObservers(leaderboardButton)
        setButtonObservers(achievementsButton)
        setButtonObservers(restartButton)
        leaderboardButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.05)
        achievementsButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.05)
    }
    
    func textFieldDidChange(sender: NSNotification) {
        
        
        if (isGameOver) {
            userInput.text = nil
        } else {
            
            let userRhymeWithNoSpaces = userInput.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
            userInput.text = userRhymeWithNoSpaces
            
            // Animation Logic
            if (userInput.text == "" || userInput.text == nil) {
                createRandomUserRhymeAnimation()
                cursorImageView.hidden = false
            } else {
                cursorImageView.stopAnimating()
                cursorImageView.hidden = true
            }
            
            if (playedRhymes.containsObject(userInput.text!.lowercaseString)
                || userInput.text!.lowercaseString == wordLabel.text) {
                    userInput.shake()
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                        Int64(0.15 * Double(NSEC_PER_SEC))),
                        dispatch_get_main_queue()) {
                            self.userInput.text = nil
                            self.createRandomUserRhymeAnimation()
                            self.cursorImageView.hidden = false
                    }
                    return
            }
            
            if let singles = json!["words"][shuffledWordArray[position]]["rhymes"]["singles"].object as? [String] {
                if (singles.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(1)
                }
            }
            if let doubles = json!["words"][shuffledWordArray[position]]["rhymes"]["doubles"].object as? [String] {
                if (doubles.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(2)
                }
            }
            if let triples = json!["words"][shuffledWordArray[position]]["rhymes"]["triples"].object as? [String] {
                if (triples.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(3)
                }
            }
            if let quadruples = json!["words"][shuffledWordArray[position]]["rhymes"]["quadruples"].object as? [String] {
                if (quadruples.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(4)
                }
            }
            if let quintuples = json!["words"][shuffledWordArray[position]]["rhymes"]["quintuples"].object as? [String] {
                if (quintuples.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(5)
                }
            }
            if let sextuples = json!["words"][shuffledWordArray[position]]["rhymes"]["sextuples"].object as? [String] {
                if (sextuples.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(6)
                }
            }
            if let septuples = json!["words"][shuffledWordArray[position]]["rhymes"]["septuples"].object as? [String] {
                if (septuples.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(7)
                }
            }
            if let octuples = json!["words"][shuffledWordArray[position]]["rhymes"]["octuples"].object as? [String] {
                if (octuples.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(8)
                }
            }
            if let nonuples = json!["words"][shuffledWordArray[position]]["rhymes"]["nonuples"].object as? [String] {
                if (nonuples.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(9)
                }
            }
            if let decuples = json!["words"][shuffledWordArray[position]]["rhymes"]["decuples"].object as? [String] {
                if (decuples.contains(userInput.text!.lowercaseString)) {
                    addScoreAndAdvance(10)
                }
            }
        }
    }
    
    func addScoreAndAdvance(points: Int) {
        
        playedRhymes.addObject(userInput.text!.lowercaseString)
        score += points
        scoreLabel.text = String(score)
        position++
        createRhyme()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.15 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue()) {
                self.userInput.text = nil
                self.createRandomUserRhymeAnimation()
                self.cursorImageView.hidden = false
        }
        
        // Restart timer if game isn't over
        if (!isGameOver) {
            timer.invalidate()
            gameTime = 400
            progressBar.setProgress(1, animated: false)
            timer = NSTimer.scheduledTimerWithTimeInterval(
                0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        }
        
        // Slide out the back button
        if (backButtonLeftConstraint.constant != HIDE_BACK_BUTTON) {
            backButtonLeftConstraint.constant = HIDE_BACK_BUTTON
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.backButton.layoutIfNeeded()
            })
        }
        
        return
    }
    
    func createRhyme() {
        
        // Delay clearing text
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.15 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue()) {
                self.userInput.text = nil
        }
        
        if (position == 0) {
            shuffledWordArray = appDelegate.wordCountArray.shuffle()
        } else {
            wordLabel.slideOutIn(0.3, completionDelegate: self)
        }
        
        // Index out of bounds will never happen again
        if (position == (json!["words"].count - 1)) {
            shuffledWordArray = appDelegate.wordCountArray.shuffle()
            position = 0
        }
        
        // Set new computer rhyme text
        wordLabel.text = json!["words"][shuffledWordArray[position]]["word"].stringValue
    }
    
    func updateTime() {
        progressBar.setProgress(Float(0.0025 * gameTime), animated: true)
        if (gameTime > 0) {
            gameTime--
        } else {
            gameOver()
        }
    }
    
    func gameOver() {
        
        backButton.tintColor = Colors.greyIconColor
        isGameOver = true
        timer.invalidate()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        userInput.text = nil
        
        // Create a constant for the high score
        let bestScore = defaults.integerForKey(HIGH_SCORE)
        if (score > bestScore) {
            defaults.setObject(score, forKey: HIGH_SCORE)
            print("New Best Score")
            finalBestAmountLabel.text = String(score)
            finalBestAmountLabel.textColor = Colors.blueColor
            finalBestLabel.textColor = Colors.blueColor
            finalBestLabel.text = "New Best"
            finalBestLabel.alpha = 1
        } else {
            finalBestAmountLabel.text = String(bestScore)
            finalBestAmountLabel.textColor = UIColor.blackColor()
            finalBestLabel.textColor = UIColor.blackColor()
            finalBestLabel.text = "Best"
            finalBestLabel.alpha = 0.26
        }
        
        unlockAchievements(bestScore)
        saveHighscore(bestScore)
        finalScoreAmountLabel.text = String(score)
        
        scoreView.hidden = false
        if (backButtonLeftConstraint.constant != SHOW_BACK_BUTTON) {
            backButtonLeftConstraint.constant = SHOW_BACK_BUTTON
            scoreViewTopConstraint.constant = 0
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.backButton.layoutIfNeeded()
                self.scoreView.layoutIfNeeded()
            })
        }
    }
    
    func restartGame() {
        userInput.text = nil
        scoreLabel.text = nil
        isGameOver = false
        position = 0
        score = 0
        createRandomUserRhymeAnimation()
        cursorImageView.hidden = false
        playedRhymes.removeAllObjects()
        createRhyme()
        if (scoreViewTopConstraint.constant != HIDE_SCORE_VIEW) {
            scoreViewTopConstraint.constant = HIDE_SCORE_VIEW
            UIView.animateWithDuration(0.25, animations: {
                self.scoreView.layoutIfNeeded()
                }, completion: { finished in
                    self.scoreView.hidden = true
            })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        userInput.text = nil
        createRandomUserRhymeAnimation()
        cursorImageView.hidden = false
        return true;
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            gameViewBottomConstraint.constant = keyboardSize.height
            scoreViewHeight.constant = UIScreen.mainScreen().applicationFrame.height - keyboardSize.height
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        gameViewBottomConstraint.constant = 0
        scoreViewHeight.constant = UIScreen.mainScreen().applicationFrame.height
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
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
        cursorImageView.animationImages = [UIImage]()
        for var index = 0; index < 4; index++ {
            let frameName = String(format: frames, index)
            cursorImageView.animationImages?.append(UIImage(named: frameName)!)
        }
        cursorImageView.animationDuration = 1
        cursorImageView.startAnimating()
    }
    
    func randomColor(range: Range<Int> = 0...3) -> UIColor {
        let min = range.startIndex
        let max = range.endIndex
        let number = Int(arc4random_uniform(UInt32(max - min))) + min
        var color:UIColor?
        
        switch number {
        case 0:
            color = Colors.greenColor
            break
        case 1:
            color = Colors.amberColor
            break
        case 2:
            color = Colors.deepPurpleColor
            break
        case 3:
            color = Colors.redColor
            break
        default:
            color = Colors.greenColor
            break
        }
        
        return color!
    }
    
    func setNextColor(currentColor: UIColor) -> UIColor {
        var nextColor:UIColor?
        switch currentColor {
        case Colors.greenColor:
            nextColor = Colors.deepPurpleColor
            break
        case Colors.amberColor:
            nextColor = Colors.greenColor
            break
        case Colors.deepPurpleColor:
            nextColor = Colors.redColor
            break
        case Colors.redColor:
            nextColor = Colors.amberColor
            break
        default:
            nextColor = Colors.deepPurpleColor
            break
        }
        return nextColor!
    }
    
    func setButtonObservers(sender: UIButton) {
        sender.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
        sender.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchDragExit)
        sender.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func buttonDown(sender: UIButton) {
        if (sender == backButton) {
            sender.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        } else if (sender == restartButton) {
            sender.backgroundColor = setNextColor(gameView.backgroundColor!)
        } else {
            sender.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        }
    }
    
    func buttonUp(sender: UIButton) {
        if (sender == backButton) {
            sender.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        } else if (sender == restartButton) {
            sender.backgroundColor = gameView.backgroundColor!
        } else {
            sender.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.05)
        }
    }
    
    // Save the highest score
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
    
    // GameCenter
    
    func unlockAchievements(score: Int) {
        
        var achievementArray:[GKAchievement] = []
        
        // First rhyme
        if (score > 0) {
            let achievement = GKAchievement(identifier: "Rhyme_Time")
            achievement.showsCompletionBanner = true
            achievement.percentComplete = 100
            achievementArray.append(achievement)
        }
        
        // 10 Syllables
        if (score >= 10) {
            let achievement = GKAchievement(identifier: "Decade_Made")
            achievement.showsCompletionBanner = true
            achievement.percentComplete = 100
            achievementArray.append(achievement)
        }
        
        // 20 Syllables
        if (score >= 20) {
            let achievement = GKAchievement(identifier: "Spaghetti_Twenty")
            achievement.showsCompletionBanner = true
            achievement.percentComplete = 100
            achievementArray.append(achievement)
        }
        
        // 30 Syllables
        if (score >= 30) {
            let achievement = GKAchievement(identifier: "Dirty_Thirty")
            achievement.showsCompletionBanner = true
            achievement.percentComplete = 100
            achievementArray.append(achievement)
        }
        
        // 40 Syllables
        if (score >= 40) {
            let achievement = GKAchievement(identifier: "Forty_Shortie")
            achievement.showsCompletionBanner = true
            achievement.percentComplete = 100
            achievementArray.append(achievement)
        }
        
        // 50 Syllables
        if (score >= 50) {
            let achievement = GKAchievement(identifier: "Nifty_Fifty")
            achievement.showsCompletionBanner = true
            achievement.percentComplete = 100
            achievementArray.append(achievement)
        }
        
        GKAchievement.reportAchievements(achievementArray, withCompletionHandler: nil)
    }
    
    func showGameLeaderboard() {
        let vc = self
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        gc.viewState = GKGameCenterViewControllerState.Leaderboards
        vc.presentViewController(gc, animated: true, completion: nil)
    }
    
    func showGameAchievements() {
        let vc = self
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        gc.viewState = GKGameCenterViewControllerState.Achievements
        vc.presentViewController(gc, animated: true, completion: nil)
    }
    
    // Hide GameCenter
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
//
//  AboutViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 7/17/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import Google

class AboutViewController: UIViewController {

    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var mikeButton: UIButton!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    let TWITTER_SCHEME:String = "twitter://post?message=@killamikemilla%20%23wordnerd%20"
    let TWITTER_WEB:String = "https://twitter.com/killamikemilla"
    let BIT_FONT:String = "8BITWONDERNominal"
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func mikeButton(sender: AnyObject) {
        
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Action",
            action: "Me Button Click",
            label: nil,
            value: nil)
            .build() as [NSObject : AnyObject])
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.mikemilla.com")!)
    }
    
    @IBAction func tweetButton(sender: AnyObject) {
        
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Action",
            action: "Tweet Button Click",
            label: nil,
            value: nil)
            .build() as [NSObject : AnyObject])
        
        if (UIApplication.sharedApplication().openURL(NSURL(string: TWITTER_SCHEME)!)) {
            UIApplication.sharedApplication().openURL(NSURL(string: TWITTER_SCHEME)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: TWITTER_WEB)!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Google Analytics
        GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: "About")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        GAI.sharedInstance().defaultTracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.greyDarkColor
        
        setButtonObservers(backButton)
        setButtonObservers(mikeButton)
        setButtonObservers(tweetButton)
        
        backButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        mikeButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        tweetButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        
        mikeButton.titleLabel!.font =  UIFont(name: BIT_FONT, size: 18)
        tweetButton.titleLabel!.font =  UIFont(name: BIT_FONT, size: 18)
        aboutLabel.font = UIFont(name: BIT_FONT, size: 20)
        
        let closeIcon = UIImage(named: "CloseIcon")!
        let tintedCloseIcon = closeIcon.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        backButton.setImage(tintedCloseIcon, forState: .Normal)
        backButton.tintColor = UIColor.whiteColor()
        
        aboutLabel.text = "If words are missing\n\nContact the creator"
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 12
        let attributes = [NSParagraphStyleAttributeName: style]
        aboutLabel.attributedText = NSAttributedString(string: aboutLabel.text!, attributes:attributes)
    }
    
    func setButtonObservers(sender: UIButton) {
        sender.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
        sender.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchDragExit)
        sender.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func buttonDown(sender: UIButton) {
        sender.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
    }
    
    func buttonUp(sender: UIButton) {
        sender.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
    }
    
}
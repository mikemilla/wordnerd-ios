//
//  AboutViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 7/17/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import GameKit
import Social

class AboutViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mikeButton: UIButton!
    @IBOutlet weak var pageDots: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tipsLabel: UILabel!
    let TWITTER_SCHEME:String = "twitter://post?message=@killamikemilla%20"
    let TWITTER_WEB:String = "https://twitter.com/killamikemilla"
    let pageViewIdentifier:String = "PageView"
    let tips:[String] = ["Tweet at the creator if a word is missing", "Rhymes dont have to be exact", "Score is amount of syllables played", "Swear words are acceptable"]
    let BIT_FONT:String = "8BITWONDERNominal"
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func mikeButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.mikemilla.com")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.greyDarkColor
        tipsLabel.font = UIFont(name: BIT_FONT, size: 22)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: pageViewIdentifier, bundle:nil), forCellWithReuseIdentifier: pageViewIdentifier)
        pageDots.numberOfPages = tips.count
        setButtonObservers(backButton)
        setButtonObservers(mikeButton)
        backButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        mikeButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        let closeIcon = UIImage(named: "CloseIcon")!
        let tintedCloseIcon = closeIcon.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        backButton.setImage(tintedCloseIcon, forState: .Normal)
        backButton.tintColor = UIColor.whiteColor()
        
        createdLabel.font = UIFont(name: BIT_FONT, size: 18)
        createdLabel.text = "Created By\nMike Miller"
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.alignment = .Center
        let attributes = [NSParagraphStyleAttributeName: style]
        createdLabel.attributedText = NSAttributedString(string: createdLabel.text!, attributes:attributes)
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
    
    func tweetButton(sender: UIButton) {
        if (UIApplication.sharedApplication().openURL(NSURL(string: TWITTER_SCHEME)!)) {
            UIApplication.sharedApplication().openURL(NSURL(string: TWITTER_SCHEME)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: TWITTER_WEB)!)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(pageViewIdentifier, forIndexPath: indexPath) as! PageView
        cell.label.text = tips[indexPath.row]
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.alignment = .Center
        let attributes = [NSParagraphStyleAttributeName: style]
        cell.label.attributedText = NSAttributedString(string: cell.label.text!, attributes:attributes)
        
        if (indexPath.row == 0) {
            cell.button.hidden = false
            cell.button.addTarget(self, action: "tweetButton:", forControlEvents: .TouchUpInside)
        } else {
            cell.button.hidden = true
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width, collectionView.frame.height)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tips.count
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageDots.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
}
//
//  AboutViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 7/17/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import GameKit
import SwiftyJSON

class AboutViewController: UIViewController {
    
    var position = 0
    var shuffledWordArray = [Int]()
    var json:JSON?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        json = appDelegate.json
        shuffledWordArray = appDelegate.wordCountArray.shuffle()
        print(json!["words"][shuffledWordArray[position]]["word"].stringValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    * Hide status bar
    */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
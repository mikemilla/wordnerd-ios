//
//  MainMenuViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 6/13/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBAction func overFlowMenuAction(sender: AnyObject) {
        println("Overflow Clicked")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Empty
    }
    
    /*
    * Hide status bar
    */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

//
//  ViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 4/19/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var computerRhyme: UILabel!
    @IBOutlet weak var userRhyme: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Computer Rhyme Styles
        computerRhyme.font = UIFont.boldSystemFontOfSize(40.0)
        computerRhyme.font = UIFont(name: "VarelaRound", size: 40)
        
        // User Rhyme Styles
        userRhyme.textAlignment = .Center;
        userRhyme.font = UIFont (name: "VarelaRound", size: 40)
        
        // Open Keyboard on launch
        userRhyme.delegate = self;
        userRhyme.becomeFirstResponder()
        
        // Keyboard will show notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        
        // Keyboard will hide notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        // TextField textChangeListener notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidChange:"), name:UITextFieldTextDidChangeNotification, object:userRhyme);
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
    }
    
    func methodThatWillTakeOverTheWorld(txtAfterUpdate: NSString) {
        println("Sup")
    }
    
}
//
//  ViewController.swift
//  wordnerd
//
//  Created by Michael Miller on 4/19/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userRhyme: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var oldKeyboardHeight: CGFloat = 0
    var difference: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userRhyme.textAlignment = .Center;
        userRhyme.delegate = self;
        userRhyme.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    /*
    * Check if keyboard is show
    */
    func keyboardWillShow(sender: NSNotification) {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            if (oldKeyboardHeight != keyboardSize.height && oldKeyboardHeight != 0) {
                
                // Find Difference is keyboard height
                difference = keyboardSize.height - oldKeyboardHeight
                bottomConstraint.constant = keyboardSize.height - difference
            } else {
                bottomConstraint.constant = keyboardSize.height
            }
            
            // Reset oldKeyboardHeight
            oldKeyboardHeight = keyboardSize.height
            
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
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            oldKeyboardHeight = keyboardSize.height
        }
        
        // Change the bottom constraint
        self.bottomConstraint.constant = 0
        
        // Animate Changes
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
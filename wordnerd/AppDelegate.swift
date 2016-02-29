//
//  AppDelegate.swift
//  wordnerd
//
//  Created by Michael Miller on 4/19/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import SwiftyJSON
import Google

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var json:JSON?
    var wordCountArray = [Int]()
    let WORD_KEY:String = "word_key"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        
        let url = NSURL(string: "http://www.mikemilla.com/words.json")
        if let responseData = NSData(contentsOfURL: url!) {
            NSUserDefaults.standardUserDefaults().setObject(responseData, forKey: WORD_KEY)
        } else {
            if (NSUserDefaults.standardUserDefaults().objectForKey(WORD_KEY) == nil) {
                let file = NSBundle(forClass: AppDelegate.self).pathForResource("words", ofType: "json")
                let data = NSData(contentsOfFile: file!)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: WORD_KEY)
            }
        }
        
        // Set JSON to global
        let data = NSUserDefaults.standardUserDefaults().objectForKey(WORD_KEY)
        json = JSON(data: data as! NSData)
        
        // Set array count position variable
        for index in 0...(json!["words"].count - 1) {
            wordCountArray.append(index)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


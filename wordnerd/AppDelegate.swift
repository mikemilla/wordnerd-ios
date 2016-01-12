//
//  AppDelegate.swift
//  wordnerd
//
//  Created by Michael Miller on 4/19/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Default word data
    let WORD_KEY:String = "word_key"
    
    var wordData: NSData {
        get {
            if let value = NSUserDefaults.standardUserDefaults().objectForKey(WORD_KEY) as? NSData {
                return value
            } else {
                let file = NSBundle(forClass: AppDelegate.self).pathForResource("words", ofType: "json")
                let data = NSData(contentsOfFile: file!)
                return data!
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: WORD_KEY)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //let json = JSON(data: defaultData as! NSData)
        //print(json["words"][0]["rhymes"]["singles"])
        
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


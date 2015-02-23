//
//  AppDelegate.swift
//  Background App
//
//  Created by Alexander v. Below on 19.02.15.
//  Copyright (c) 2015 Alexander von Below. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let types = UIUserNotificationType.Badge |
            UIUserNotificationType.Sound | UIUserNotificationType.Alert
        
        let mySettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSLog("didRegisterUserNotificationSettings %@", notificationSettings)
    }
}


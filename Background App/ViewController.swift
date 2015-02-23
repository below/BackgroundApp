//
//  ViewController.swift
//  Background App
//
//  Created by Alexander v. Below on 19.02.15.
//  Copyright (c) 2015 Alexander von Below. All rights reserved.
//
//  Artwork used as permitted by CC 2.0, Copyright by Fuzzy Gerdes
//  https://flic.kr/p/bvu78 https://creativecommons.org/licenses/by/2.0/

import UIKit

let kUseBackgroundTask = "useBackgroundTask"

extension UIStepper {
    var timeInterval : NSTimeInterval { return self.value * 10 }
}

class ViewController: UIViewController {

    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var countdownPicker: UIStepper!
    @IBOutlet weak var infoField: UITextView!
    var timer : NSTimer? = nil
    var displayTimer : NSTimer?
    var dateFormatter : NSDateFormatter
    @IBOutlet weak var backgroundSwitch: UISwitch!

    override class func initialize()
    {
        NSUserDefaults.standardUserDefaults().registerDefaults([ kUseBackgroundTask : true]
        )
    }
    
    required init(coder aDecoder: NSCoder) {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        super.init(coder: aDecoder)
        self.displayTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateDisplay:", userInfo: nil, repeats: true)
        
        for name in [UIApplicationWillResignActiveNotification,
            UIApplicationDidEnterBackgroundNotification,
            UIApplicationWillEnterForegroundNotification,
            UIApplicationDidBecomeActiveNotification,
            UIApplicationWillTerminateNotification] {
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationStateChanged:", name: name,
                    object: nil)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name:UIApplicationDidEnterBackgroundNotification , object: nil)
    }

    @IBAction func stepStepper(sender: AnyObject) {
        self.setCountdownTime(self.countdownPicker.timeInterval)
    }
    
    @IBAction func startStopTimer(sender: AnyObject) {
        if ((timer) != nil) {
            timer?.invalidate()
            timer = nil
            self.startStopButton.setTitle(NSLocalizedString("Start", comment: ""), forState: UIControlState.Normal)
            countdownPicker.enabled = true
            self.stepStepper(self.countdownPicker)
        }
        else {
            countdownPicker.enabled = false
            let interval = self.countdownPicker.timeInterval;
            timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "fireTimer:", userInfo: ["startDate" : NSDate(), "interval": interval], repeats: false)
            self.startStopButton.setTitle(NSLocalizedString("Stop", comment: ""), forState: UIControlState.Normal)
        }
    }
    
    func setCountdownTime ( seconds : NSTimeInterval ) {
        let date = NSDate(timeIntervalSinceReferenceDate: seconds)
        let string = self.dateFormatter.stringFromDate(date)
        self.countdownLabel.text = string
    }
    
    func log (string : String) {
        var text = self.infoField.text
        self.infoField.text = text.stringByAppendingFormat("%@: %@\n", NSDate(), string)
        NSLog("%@", string)
        
    }
    
    func fireTimer (timer : NSTimer) {
        var note = UILocalNotification()
        note.alertBody = NSLocalizedString("Timer Fired", comment: "")
        UIApplication.sharedApplication().presentLocalNotificationNow(note)
        var dict : NSDictionary = timer.userInfo as NSDictionary
        var interval = dict["interval"] as NSNumber
        var info = NSString(format: "Timer Fired. Interval %.0f, set at %@", interval, dict["startDate"] as NSDate);
        self.log(info)
        self.startStopTimer(timer)
    }
    
    func updateDisplay (timer : NSTimer) {
        if (self.timer != nil && self.timer?.valid == true) {
            let interval = self.timer?.fireDate.timeIntervalSinceNow
            self.setCountdownTime(interval!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func applicationStateChanged(note: NSNotification) {
        self.log(note.name)
    }
    
    @IBAction func switchBackgroundTask(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: kUseBackgroundTask)
    }
    
    func applicationDidEnterBackground(note: NSNotification) {
        if (NSUserDefaults.standardUserDefaults().boolForKey(kUseBackgroundTask) == true) {
            UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                var note = UILocalNotification()
                let info = NSLocalizedString("Background Task Expired", comment: "")
                note.alertBody = info
                UIApplication.sharedApplication().presentLocalNotificationNow(note)

                self.log(info)
            })
        }
    }
}


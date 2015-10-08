//
//  HomeViewController.swift
//  Earth Memo
//
//  Created by Yuning Jin on 7/24/15.
//  Copyright (c) 2015 Noctiz. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class HomeViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate{

    @IBOutlet weak var t1Label: UIButton!
    @IBOutlet weak var t2Label: UIButton!
    @IBOutlet weak var t3Label: UIButton!
    @IBOutlet weak var t1Bar: UIImageView!
    @IBOutlet weak var t2Bar: UIImageView!
    @IBOutlet weak var t3Bar: UIImageView!
    @IBOutlet weak var t1Frame: UIImageView!
    @IBOutlet weak var t2Frame: UIImageView!
    @IBOutlet weak var t3Frame: UIImageView!
    @IBOutlet weak var t1Time: UILabel!
    @IBOutlet weak var t2Time: UILabel!
    @IBOutlet weak var t3Time: UILabel!
    
    @IBOutlet weak var statsHeader: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var futureLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var todayStats: UILabel!
    @IBOutlet weak var futureStats: UILabel!
    @IBOutlet weak var totalStats: UILabel!
    @IBOutlet weak var importantSwitch: UISwitch!
    @IBOutlet weak var t1Im: UIImageView!
    @IBOutlet weak var t2Im: UIImageView!
    @IBOutlet weak var t3Im: UIImageView!

    @IBOutlet var scrollView: UIScrollView!

    
    var logInViewController: PFLogInViewController! = PFLogInViewController()
    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
    
    var isImportant: Bool! = false
    let unit: NSCalendarUnit = .CalendarUnitDay
    
    var memoObjects: [PFObject]!
    var headerNum: Int = 0
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        
        PFUser.logOut()
        logInViewPopup()
    }
    
    
    func logInViewPopup() {
        // The PFLogInViewController class presents and manages a standard authentication interface for logging in a PFUser.
        var logInViewController = PFLogInViewController()
        
        var loginImage = UIImage(named: "logo")
        var loginLogo = UIImageView(image: loginImage)
        
        logInViewController.logInView?.logo = loginLogo
        // Delegate that responds to the control events of PFLogInViewController
        // In this case, set the delegate to itself
        logInViewController.delegate = self
        
        // Create a sign up view controller
        var signUpViewController = PFSignUpViewController()
        
        var signupImage = UIImage(named: "logo")
        var signupLogo = UIImageView(image: loginImage)
        
        signUpViewController.signUpView?.logo = signupLogo
        // Set view controller delegate
        signUpViewController.delegate = self
        
        // This assigns our sign up controller to be displayed from the login controller
        logInViewController.signUpController = signUpViewController
        
        // iOS view controller: popup view
        self.presentViewController(logInViewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "headerToEdit") {
            
            var upcoming: MemoWriteViewController = segue.destinationViewController as! MemoWriteViewController
            
            if (headerNum == 0) {
                return
            } else if (headerNum == 1) {
                upcoming.object = memoObjects[0]
                return
            } else if (headerNum == 2){
                upcoming.object = memoObjects[1]
                return
            } else {
                upcoming.object = memoObjects[2]
                return
            }
        }
        
        if (segue.identifier == "gotoHelp") {
            
            var upcoming: HelpViewController = segue.destinationViewController as! HelpViewController
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.t1Im.hidden = true
        self.t2Im.hidden = true
        self.t3Im.hidden = true
        
        self.statsHeader.textColor = UIColor.whiteColor()
        self.todayLabel.textColor = UIColor.whiteColor()
        self.futureLabel.textColor = UIColor.whiteColor()
        self.totalLabel.textColor = UIColor.whiteColor()
        self.totalStats.textColor = UIColor.whiteColor()
        self.totalStats.textColor = UIColor.whiteColor()
        self.futureStats.textColor = UIColor.whiteColor()
        
        self.scrollView.backgroundColor = UIColor(red: 44/255, green: 54/255, blue: 62/255, alpha: 1)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.title = PFUser.currentUser()?.username
        
        if (PFUser.currentUser() == nil)
        {
            self.logInViewPopup()
            
        } else {
        
            self.fetchAllObjectsFromLocalDatastore()
            
            self.fetchAllObjects()
            
            self.putHeaderMemo()
            
            importantSwitch.setOn(isImportant, animated: false)
            
            if (isImportant == false) {
                self.getStats()
            } else {
                self.getStatsImportant()
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        
        // Pops up a little welcome message
        var username : String = user.username!
        var welcomeBackMsg = "Welcome back, " + username
        // Old alert view method: brings up a simple dialog box
        var alertView = UIAlertView(title: "Login Successful", message: welcomeBackMsg, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = UIAlertViewStyle.Default
        alertView.show()
        
        // Dismiss animation
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchAllObjectsFromLocalDatastore() {
        
        var today = NSDate() as NSDate
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.fromLocalDatastore()
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        
        query.whereKey("importantFlag", equalTo: true)
        
        query.whereKey("activeAt", greaterThanOrEqualTo: today)
        
        query.orderByAscending("activeAt")
        
        query.limit = 3
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                self.memoObjects = objects as! [PFObject]
                
            } else {
                
                print(error!.userInfo)
                
            }
            
        }
        
    }
    
    func fetchAllObjects() {
        
        PFObject.unpinAllObjectsInBackground()
        
        var today = NSDate() as NSDate
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        
        query.whereKey("importantFlag", equalTo: true)
        
        query.whereKey("activeAt", greaterThanOrEqualTo: today)
        
        query.orderByAscending("activeAt")
        
        query.limit = 3
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                PFObject.pinAll(objects)
                
                self.fetchAllObjectsFromLocalDatastore()
                
            } else {
                
                print(error!.userInfo)
                
            }
        }
    }
    
    func putHeaderMemo() {
        
        self.hideAllHeader()
        
        if (self.memoObjects == nil || self.memoObjects.isEmpty) {
            return
        }
        
        self.t1Label.hidden = false
        self.t1Time.hidden = false
        self.t1Bar.hidden = false
        self.t1Frame.hidden = false
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        
        self.t1Label.setTitle(memoObjects[0]["title"] as? String, forState: UIControlState.Normal)
        
        var activeFormatter = NSDateFormatter()
        activeFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var dateActive = memoObjects[0]["activeAt"] as! NSDate!
        var today = NSDate() as NSDate
        
        var todayTemp = dateFormatter.stringFromDate(today)
        var todayDay = dateFormatter.dateFromString(todayTemp)
        var dateTemp = dateFormatter.stringFromDate(dateActive)
        var dateDay = dateFormatter.dateFromString(dateTemp)
        
        let cal = NSCalendar.currentCalendar()
        
        var days = cal.components(unit, fromDate: todayDay!, toDate: dateDay!, options: nil)
        
        var dayString: String
        
        if (days.day == 0) {
            dayString = "Today"
        } else if(days.day < 0) {
            if (days.day == -1) {
                dayString = "Yesterday"
            } else {
                dayString = days.day.description + " day(s)"
            }
        } else {
            if (days.day == 1) {
                dayString = "Tomorrow"
            } else {
                dayString = "+" + days.day.description + " day(s)"
            }
        }
        
        self.t1Time?.text = activeFormatter.stringFromDate(dateActive) + "   " + dayString
        

        
        if (memoObjects.count == 1) {
            return
        }
        
        self.t2Label.hidden = false
        self.t2Time.hidden = false
        self.t2Bar.hidden = false
        self.t2Frame.hidden = false
        
        self.t2Label.setTitle(memoObjects[1]["title"] as? String, forState: UIControlState.Normal)
        
        dateActive = memoObjects[1]["activeAt"] as! NSDate!
        
        todayTemp = dateFormatter.stringFromDate(today)
        todayDay = dateFormatter.dateFromString(todayTemp)
        dateTemp = dateFormatter.stringFromDate(dateActive)
        dateDay = dateFormatter.dateFromString(dateTemp)
        
        days = cal.components(unit, fromDate: todayDay!, toDate: dateDay!, options: nil)
        if (days.day == 0) {
            dayString = "Today"
        } else if(days.day < 0) {
            if (days.day == -1) {
                dayString = "Yesterday"
            } else {
                dayString = days.day.description + " day(s)"
            }
        } else {
            if (days.day == 1) {
                dayString = "Tomorrow"
            } else {
                dayString = "+" + days.day.description + " day(s)"
            }
        }
        self.t2Time?.text = activeFormatter.stringFromDate(dateActive) + "   " + dayString
        

        
        if (memoObjects.count == 2) {
            return
        }
        
        self.t3Label.hidden = false
        self.t3Time.hidden = false
        self.t3Bar.hidden = false
        self.t3Frame.hidden = false
        
        self.t3Label.setTitle(memoObjects[2]["title"] as? String, forState: UIControlState.Normal)
        
        dateActive = memoObjects[2]["activeAt"] as! NSDate!
        
        todayTemp = dateFormatter.stringFromDate(today)
        todayDay = dateFormatter.dateFromString(todayTemp)
        dateTemp = dateFormatter.stringFromDate(dateActive)
        dateDay = dateFormatter.dateFromString(dateTemp)
        
        days = cal.components(unit, fromDate: todayDay!, toDate: dateDay!, options: nil)
        if (days.day == 0) {
            dayString = "Today"
        } else if(days.day < 0) {
            if (days.day == -1) {
                dayString = "Yesterday"
            } else {
                dayString = days.day.description + " day(s)"
            }
        } else {
            if (days.day == 1) {
                dayString = "Tomorrow"
            } else {
                dayString = "+" + days.day.description + " day(s)"
            }
        }
        self.t3Time?.text = activeFormatter.stringFromDate(dateActive) + "   " + dayString
        
        
        return
        
    }
    
    func hideAllHeader() {
        
        self.t1Label.hidden = true
        self.t1Time.hidden = true
        
        self.t2Label.hidden = true
        self.t2Time.hidden = true
        
        self.t3Label.hidden = true
        self.t3Time.hidden = true
        
        self.t1Bar.hidden = true
        self.t1Frame.hidden = true
        self.t2Bar.hidden = true
        self.t2Frame.hidden = true
        self.t3Bar.hidden = true
        self.t3Frame.hidden = true
        
        return
    }
    
    @IBAction func reloadHeader(sender: UIButton) {
        
        self.hideAllHeader()
        self.putHeaderMemo()
        
    }
    
    
    @IBAction func gotoMemo1(sender: UIButton) {
        
        headerNum = 1
        performSegueWithIdentifier("headerToEdit", sender: self)
        
    }
    
    @IBAction func gotoMemo2(sender: UIButton) {
        
        headerNum = 2
        performSegueWithIdentifier("headerToEdit", sender: self)
        
    }
    
    @IBAction func gotoMemo3(sender: UIButton) {
        
        headerNum = 3
        performSegueWithIdentifier("headerToEdit", sender: self)
        
    }
    
    @IBAction func gotoAdd(sender: UIBarButtonItem) {
        
        headerNum = 0
        performSegueWithIdentifier("headerToEdit", sender: self)
    }
    
    func getStats() {
        
        self.todayStats.textColor = UIColor.whiteColor()
        self.futureStats.textColor = UIColor.whiteColor()
        self.totalStats.textColor = UIColor.whiteColor()
        self.t1Im.hidden = true
        self.t2Im.hidden = true
        self.t3Im.hidden = true
        
        var today = NSDate() as NSDate
        
        var today24 = NSDate(timeInterval: 60*60*24, sinceDate: today)
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        
        self.totalStats.text = query.countObjects().description
        
        query.whereKey("activeAt", greaterThanOrEqualTo: today)
        
        self.futureStats.text = query.countObjects().description
        
        query.whereKey("activeAt", lessThanOrEqualTo: today24)

        self.todayStats.text = query.countObjects().description
        
    }
    
    func getStatsImportant() {
        
        self.todayStats.textColor = UIColor(red: 205/255, green: 220/255, blue: 57/255, alpha: 1)
        self.futureStats.textColor = UIColor(red: 205/255, green: 220/255, blue: 57/255, alpha: 1)
        self.totalStats.textColor = UIColor(red: 205/255, green: 220/255, blue: 57/255, alpha: 1)
        self.t1Im.hidden = false
        self.t2Im.hidden = false
        self.t3Im.hidden = false
        
        var today = NSDate() as NSDate
        
        var today24 = NSDate(timeInterval: 60*60*24, sinceDate: today)
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        
        query.whereKey("importantFlag", equalTo: true)
        
        self.totalStats.text = query.countObjects().description
        
        query.whereKey("activeAt", greaterThanOrEqualTo: today)
        
        self.futureStats.text = query.countObjects().description
        
        query.whereKey("activeAt", lessThanOrEqualTo: today24)
        
        self.todayStats.text = query.countObjects().description
        
    }
    
    
    @IBAction func statsChanged(sender: UISwitch) {
        
        if (importantSwitch.on == false) {
            
            self.getStats()
            
            isImportant = false
            
        } else {
            
            self.getStatsImportant()
            
            isImportant = true
            
        }
    }
    
    
    @IBAction func guideAction(sender: UIButton) {
        
        performSegueWithIdentifier("gotoHelp", sender: self)
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

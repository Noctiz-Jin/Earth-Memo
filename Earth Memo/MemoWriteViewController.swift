//
//  MemoWriteViewController.swift
//  Earth Memo
//
//  Created by Yuning Jin on 7/24/15.
//  Copyright (c) 2015 Noctiz. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MemoWriteViewController: UIViewController{

    var tempImportant: Bool = false
    
    @IBOutlet weak var memoTitle: UITextField!
    @IBOutlet weak var memo: UITextView!
    

    @IBOutlet weak var timePicker: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var latitude: UITextField!
    @IBOutlet weak var longitude: UITextField!
    
    @IBOutlet weak var isImportant: UISwitch!
    @IBOutlet var scrollView: UIScrollView!
    
    
    var object: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.backgroundColor = UIColor(red: 44/255, green: 54/255, blue: 62/255, alpha: 1)
        self.memoTitle.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
        self.memo.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
        self.timePicker.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
        self.latitude.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
        self.longitude.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
        
        if (self.object != nil) {
            
            
            var activeDate = self.object["activeAt"] as! NSDate
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            var strDate = dateFormatter.stringFromDate(activeDate)
            
            self.memoTitle?.text = self.object["title"] as? String
            self.memo?.text = self.object["memo"] as? String
            self.timePicker.text = strDate
            self.datePicker.setDate(activeDate, animated: true)
            
            if ((self.object["location"]) != nil) {
                
                var geoPoint = self.object["location"] as! PFGeoPoint
                
                self.latitude.text = geoPoint.latitude.description
                self.longitude.text = geoPoint.longitude.description
            }
            
            self.isImportant.setOn(tempImportant, animated: true)
            
        } else {
            
            
            self.object = PFObject(className: "Memo")
            
            self.isImportant.setOn(tempImportant, animated: true)
            
            var today = NSDate() as NSDate
            
            datePicker.setDate(today, animated: true)
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            var strDate = dateFormatter.stringFromDate(datePicker.date)
            timePicker.text = strDate
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func timePickerAction(sender: UIDatePicker) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        timePicker.text = strDate
    }
    
    @IBAction func setTodayAction(sender: UIButton) {
        
        var today = NSDate() as NSDate
        
        datePicker.setDate(today, animated: true)
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        timePicker.text = strDate
    }
    
    @IBAction func changeTimeAction(sender: UITextField) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        var changedDate: NSDate! = dateFormatter.dateFromString(timePicker.text)
        
        //println("changedDate = ")
        //println(changedDate)
        
        if (changedDate != nil) {
            
            datePicker.setDate(changedDate, animated: true)
            
        } else {
            
            var alertView = UIAlertView(title: "Invalid date & time", message: "Please follow the format:\n Month-Day-Year  Hour:Minute", delegate: self, cancelButtonTitle: "OK")
            alertView.alertViewStyle = UIAlertViewStyle.Default
            alertView.show()
            
        }
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        self.object["userId"] = PFUser.currentUser()!.objectId
        self.object["username"] = PFUser.currentUser()!.username
        var titleOfMemo = self.memoTitle?.text
        
        if (titleOfMemo == "") {
            
            var alertView = UIAlertView(title: "Invalid title", message: "Memo should at least have a title and a activated time", delegate: self, cancelButtonTitle: "OK")
            alertView.alertViewStyle = UIAlertViewStyle.Default
            alertView.show()
        } else {
        
        self.object["title"] = titleOfMemo
        self.object["memo"] = self.memo?.text
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var changedDate: NSDate! = dateFormatter.dateFromString(timePicker.text!)
        
        if (changedDate == nil) {
            
            var alertView = UIAlertView(title: "Invalid date & time", message: "Memo should at least have a title and a activated time", delegate: self, cancelButtonTitle: "OK")
            alertView.alertViewStyle = UIAlertViewStyle.Default
            alertView.show()
            
        } else {
        
        self.object["activeAt"] = changedDate
        
        self.object["importantFlag"] = self.isImportant.on
        
        // check geoPoint input empty
        if (latitude.text.isEmpty && longitude.text.isEmpty) {
            
            //Do nothing, proceed without geoPoint
            self.saveItAndSegue()
            
        } else if ((latitude.text.isEmpty == false) && (longitude.text.isEmpty == false)) {
            
            //Both inputs for latitude & longitude are detected
            
            var tempLatitude = (latitude.text as NSString).doubleValue
            var tempLongitude = (longitude.text as NSString).doubleValue
            
            //check latitude
            if ((tempLatitude < -90) || (tempLatitude > 90)) {
                //Invalid latitude (FAILED AT 90 ??? )
                var alertView = UIAlertView(title: "Invalid Latitude", message: "Input latitude value between -90 and 90", delegate: self, cancelButtonTitle: "OK")
                alertView.alertViewStyle = UIAlertViewStyle.Default
                alertView.show()
                
            } else if ((tempLongitude < -180) || (tempLongitude > 180)) {
                //Invalid longitude (FAILED AT 180 ??? )
                var alertView = UIAlertView(title: "Invalid Longitude", message: "Input longitude value between -180 and 180", delegate: self, cancelButtonTitle: "OK")
                alertView.alertViewStyle = UIAlertViewStyle.Default
                alertView.show()
                
            } else {
                
                if (tempLatitude == 90) {tempLatitude = 89.999999}
                if (tempLongitude == 180) {tempLongitude = 179.999999}
                
                let geoPoint = PFGeoPoint(latitude: tempLatitude, longitude: tempLongitude)
                
                self.object["location"] = geoPoint
                self.saveItAndSegue()
                
            }
            
            
        } else {
            
            var alertView = UIAlertView(title: "Invalid Location Information", message: "Please leave blank\nOR\nInput correct latitude & longitude", delegate: self, cancelButtonTitle: "OK")
            alertView.alertViewStyle = UIAlertViewStyle.Default
            alertView.show()
            
        }
            
        }
            
        }
    }
    
    func saveItAndSegue() {
        
        
        self.object.saveEventually() { (success, error) -> Void in
            
            if (error == nil) {
                
            } else {
                
                println(error!.userInfo)
                
            }
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    @IBAction func deleteAction(sender: UIButton) {
        
        if (self.isImportant.on == true) {
            var alertView = UIAlertView(title: "The important flag is on", message: "Please turn off the important flag at bottom if you want to truly delete the memo", delegate: self, cancelButtonTitle: "OK")
            alertView.alertViewStyle = UIAlertViewStyle.Default
            alertView.show()
        } else {
            object.delete()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
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

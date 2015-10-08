//
//  MemoTimeTableViewController.swift
//  Earth Memo
//
//  Created by Yuning Jin on 7/24/15.
//  Copyright (c) 2015 Noctiz. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MemoTimeTableViewController: UITableViewController {

    var memoObjects: NSMutableArray! = NSMutableArray()

    
    let unit: NSCalendarUnit = .CalendarUnitDay

    @IBOutlet weak var importantSwitch: UISwitch!
    @IBOutlet weak var importantLabel: UIBarButtonItem!
    
    var isImportant: Bool! = false
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "timeToEdit") {
            
            var upcoming: MemoWriteViewController = segue.destinationViewController as! MemoWriteViewController
            
            var indexPath = self.tableView.indexPathForSelectedRow!
            
            var object: PFObject = self.memoObjects.objectAtIndex(indexPath.row) as! PFObject
            
            upcoming.object = object
            
            upcoming.tempImportant = object["importantFlag"] as! Bool
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
        
        if (segue.identifier == "timeToAdd") {
            
            var upcoming: MemoWriteViewController = segue.destinationViewController as! MemoWriteViewController
            
            upcoming.tempImportant = isImportant
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(red: 44/255, green: 54/255, blue: 62/255, alpha: 1)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationItem.title = PFUser.currentUser()!.username! + "'s Timeline"
        
        self.importantSwitch.setOn(isImportant, animated: true)
        
        if (isImportant == true) {
            
            self.fetchCategoryObjectsFromLocalDatastore()
            
            self.fetchCategoryObjects()
            
            
        } else {
            
            self.fetchAllObjectsFromLocalDatastore()
            
            self.fetchAllObjects()
        }
    }
    
    func fetchAllObjectsFromLocalDatastore() {
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.fromLocalDatastore()
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        
        query.orderByAscending("activeAt")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                var temp: NSArray = objects as NSArray!
                
                self.memoObjects = temp.mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                
            } else {
                
                print(error!.userInfo)
                
            }
            
        }
        
    }
    
    func fetchCategoryObjectsFromLocalDatastore() {
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.fromLocalDatastore()
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        query.whereKey("importantFlag", equalTo: true)
        
        query.orderByAscending("activeAt")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                var temp: NSArray = objects as NSArray!
                
                self.memoObjects = temp.mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                
            } else {
                
                print(error!.userInfo)
                
            }
            
        }
        
    }
    
    func fetchAllObjects() {
        
        PFObject.unpinAllObjectsInBackground()
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        
        query.orderByAscending("activeAt")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                PFObject.pinAll(objects)
                
                self.fetchAllObjectsFromLocalDatastore()
            } else {
                
                print(error!.userInfo)
            }
            
        }
    }
    
    func fetchCategoryObjects() {
        
        PFObject.unpinAllObjectsInBackground()
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        query.whereKey("importantFlag", equalTo: true)
        
        query.orderByAscending("activeAt")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                PFObject.pinAll(objects)
                
                self.fetchAllObjectsFromLocalDatastore()
            } else {
                
                print(error!.userInfo)
            }
            
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.memoObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timeCell", forIndexPath: indexPath) as! MemoTimeTableViewCell
        
        cell.backgroundColor = UIColor(red: 59/255, green: 65/255, blue: 71/255, alpha: 1)
        cell.titleLabel.textColor = UIColor.whiteColor()
        cell.activeAtLabel.textColor = UIColor.whiteColor()
        cell.dayAway.textColor = UIColor(red: 97/255, green: 222/255, blue: 128/255, alpha: 1)
        
        // Configure the cell...
        var object: PFObject = self.memoObjects.objectAtIndex(indexPath.row) as! PFObject
        
        var dateFormatter = NSDateFormatter()
        var activeFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        activeFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        //var dateCreated = object.createdAt as NSDate!
        var dateActive = object["activeAt"] as! NSDate!
        var today = NSDate() as NSDate
        
        var todayTemp = dateFormatter.stringFromDate(today)
        var todayDay = dateFormatter.dateFromString(todayTemp)
        var dateTemp = dateFormatter.stringFromDate(dateActive)
        var dateDay = dateFormatter.dateFromString(dateTemp)
        
        let cal = NSCalendar.currentCalendar()
        
        var days = cal.components(unit, fromDate: todayDay!, toDate: dateDay!, options: nil)
        cell.titleLabel?.text = object["title"] as? String
        cell.activeAtLabel?.text = activeFormatter.stringFromDate(dateActive)
        
        if (days.day == 0) {
            cell.dayAway?.text = "Today"
            
            cell.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
            cell.titleLabel.textColor = UIColor.blackColor()
            cell.activeAtLabel.textColor = UIColor.blackColor()
            cell.dayAway.textColor = UIColor(red: 56/255, green: 142/255, blue: 60/255, alpha: 1)
            
        } else if(days.day < 0) {
            if (days.day == -1) {
                cell.dayAway?.text = "Yesterday"
            } else {
                cell.dayAway?.text = days.day.description + " day(s)"
            }
        } else {
            if (days.day == 1) {
                cell.dayAway?.text = "Tomorrow"
            } else {
                cell.dayAway?.text = "+" + days.day.description + " day(s)"
            }
        }
        
        if (object["importantFlag"] as! Bool == false) {
            cell.star.hidden = true
        } else {
            cell.star.hidden = false
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("timeToEdit", sender: self)
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.animate(cell)
    }
    
    func animate (cell:UITableViewCell) {
        /*
        let view = cell.contentView
        view.layer.opacity = 0.1
        UIView.animateWithDuration(1.4) {
            view.layer.opacity = 1
        }
        */
        
        let view = cell.contentView
        let rotationDegrees: CGFloat = -30.0 //-15.0
        let rotationRadians: CGFloat = rotationDegrees * (CGFloat(M_PI)/180.0)
        let offset = CGPointMake(-20, -20)
        var startTransform = CATransform3DIdentity // 2
        startTransform = CATransform3DRotate(CATransform3DIdentity,
            rotationRadians, 0.0, 0.0, 1.0) // 3
        startTransform = CATransform3DTranslate(startTransform, offset.x, offset.y, 0.0) // 4
        
        // 5
        view.layer.transform = startTransform
        view.layer.opacity = 0.8
        
        // 6
        UIView.animateWithDuration(0.4) {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }
    }
    
    @IBAction func importantSwitchAction(sender: UISwitch) {
        
        if (importantSwitch.on == false) {
            
            
            self.fetchAllObjectsFromLocalDatastore()
            
            self.fetchAllObjects()
            
            isImportant = false
            
            //self.toolButtonLabel.title = "Show All Memo"
            
        } else {
            
            self.fetchCategoryObjectsFromLocalDatastore()
            
            self.fetchCategoryObjects()
            
            isImportant = true
            
            //self.toolButtonLabel.title = "Show Important Memo"
            
        }
        
    }
    
    
    @IBAction func timeToAdd(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("timeToAdd", sender: self)

    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

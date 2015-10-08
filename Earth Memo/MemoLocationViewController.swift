//
//  MemoLocationViewController.swift
//  Earth Memo
//
//  Created by Yuning Jin on 7/24/15.
//  Copyright (c) 2015 Noctiz. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MapKit
import CoreLocation

class MemoLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    let locationManager = CLLocationManager()
    
    var nextObject: PFObject!
    var memoObjects: [PFObject]!
    var memoDict = [String : PFObject]()
    var userLocation: CLLocation!
    var dict = [Int : String]()

    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var importantSwitch: UISwitch!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var importantIcon: UIImageView!
    

    
    var isImportant: Bool! = false
    
    var regionRadius: CLLocationDistance = 500
    
    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if (segue.identifier == "geoToEdit") {
            
            print(nextObject)
            
            var upcoming: MemoWriteViewController = segue.destinationViewController as! MemoWriteViewController
            
            upcoming.object = nextObject
            
            upcoming.tempImportant = nextObject["importantFlag"] as! Bool
            
        }
        
        
        if (segue.identifier == "geoToAdd") {
            
            var upcoming: MemoWriteViewController = segue.destinationViewController as! MemoWriteViewController
            
            upcoming.tempImportant = isImportant
            
            //println("isImportant =")
            //println(isImportant)
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        self.loadDummyUser()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        var tempImage = UIImage(named: "focusSlider")
        distanceSlider.minimumTrackTintColor = UIColor(red: 65/255, green: 117/255, blue: 5/255, alpha: 1)
        distanceSlider.setThumbImage(tempImage, forState: UIControlState.Normal)
        //self.locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationItem.title = PFUser.currentUser()!.username! + "'s Map"
        
        self.importantSwitch.setOn(isImportant, animated: true)
        
        if (isImportant == true) {
            
            self.importantIcon.hidden = false
        } else {
            
            self.importantIcon.hidden = true
        }
        
        /*
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(initialLocation)
        var anotation: MKPointAnnotation = MKPointAnnotation()
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 21.282778, longitude: -157.829444)
        anotation.coordinate = location
        anotation.title = "The Location"
        anotation.subtitle = "This is the location !!!"
        self.mapView.addAnnotation(anotation)
        //self.mapView.selectAnnotation(anotation, animated: true)
        */
        
        
        if (isImportant == true) {
            
            self.fetchCategoryObjects(userLocation, radiusKm: 99999)
            
            
        } else {
            
            self.fetchAllObjects(userLocation, radiusKm: 99999)
        }
        
        //println(dict)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            
            if (error != nil)
            {
                println("Error: " + error.localizedDescription)
                return
            }
            
            if (placemarks.count > 0)
            {
                let pm = placemarks[0] as! CLPlacemark
                self.fetchAllObjects(self.userLocation, radiusKm: 99999)
            }
            
        })
    }
    
    /*
    func displayLocationInfo(placemarks: CLPlacemark) {
        
        self.locationManager.stopUpdatingLocation()
        println(placemarks.locality)
        println(placemarks.postalCode)
        println(placemarks.administrativeArea)
        println(placemarks.country)
        
    }
    */
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        print("Error: " + error.localizedDescription)
    }
    
    @IBAction func addMemo(sender: UIBarButtonItem) {
    
        self.performSegueWithIdentifier("geoToAdd", sender: self)
        
    }
    
    @IBAction func importantSwitchAction(sender: UISwitch) {
        
        
        if (importantSwitch.on == false) {
            
            self.fetchAllObjects(userLocation, radiusKm: 99999)
            
            isImportant = false
            
            self.importantIcon.hidden = true
            
            //self.toolButtonLabel.title = "Show All Memo"
            
        } else {
            
            self.fetchCategoryObjects(userLocation, radiusKm: 99999)
            
            isImportant = true
            
            self.importantIcon.hidden = false
            
            //self.toolButtonLabel.title = "Show Important Memo"
            
        }
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var pinView: MKPinAnnotationView = MKPinAnnotationView()
        pinView.annotation = annotation
        pinView.pinColor = MKPinAnnotationColor.Green
        pinView.animatesDrop = true

        var calloutButton: UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure)
        var buttonImage: UIImage = UIImage(named: "pinIcon") as UIImage!
        //calloutButton.setTitle("EDIT", forState: UIControlState.Normal)
        calloutButton.setImage(buttonImage, forState: UIControlState.Normal)
        
        pinView.rightCalloutAccessoryView = calloutButton as UIView
        pinView.canShowCallout = true

        return  pinView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        print("annotation selected")
    
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        nextObject = memoDict[self.dict[view.annotation!.hash]!]
        performSegueWithIdentifier("geoToEdit", sender: self)
        //println(self.dict[view.annotation.hash])
        
    }
    
    func fetchAllObjects(userLocation: CLLocation, radiusKm: CLLocationAccuracy) {
        
        PFObject.unpinAllObjectsInBackground()
        
        var point = PFGeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        
        query.whereKey("location", nearGeoPoint: point, withinKilometers: radiusKm)
        
        query.orderByAscending("activeAt")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                self.memoObjects = objects as! [PFObject]
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                self.putPlacesOnMap()
                
            } else {
                
                var alertView = UIAlertView(title: "No memo was found", message: "Add memos and make sure location service is allowed", delegate: self, cancelButtonTitle: "OK")
                alertView.alertViewStyle = UIAlertViewStyle.Default
                alertView.show()
                
            }
        }
    }
    
    func fetchCategoryObjects(userLocation: CLLocation, radiusKm: CLLocationAccuracy) {
        
        PFObject.unpinAllObjectsInBackground()
        
        var point = PFGeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        var query: PFQuery = PFQuery(className: "Memo")
        
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        
        query.whereKey("location", nearGeoPoint: point, withinKilometers: radiusKm)
        
        query.whereKey("importantFlag", equalTo: true)
        query.orderByAscending("activeAt")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                self.memoObjects = objects as! [PFObject]
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                self.putPlacesOnMap()
                
            } else {
                
                var alertView = UIAlertView(title: "No Memo Nearby", message: "Add memos and make sure location service is allowed", delegate: self, cancelButtonTitle: "OK")
                alertView.alertViewStyle = UIAlertViewStyle.Default
                alertView.show()
                
            }
        }
        
    }
    
    func putPlacesOnMap()
    {
        dict.removeAll(keepCapacity: false)
        memoDict.removeAll(keepCapacity: false)
        
        for memo in memoObjects
        {
            var annotation = MKPointAnnotation()
            var coord = memo.objectForKey("location") as! PFGeoPoint
            var CLLcoord = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            annotation.coordinate = CLLcoord
            annotation.title = memo.objectForKey("title") as! String
            
            var activeFormatter = NSDateFormatter()
            activeFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            var dateActive = memo.objectForKey("activeAt") as! NSDate!
            annotation.subtitle = activeFormatter.stringFromDate(dateActive)
            
            self.mapView.addAnnotation(annotation)
            
            /*
            if (memo.objectForKey("importantFlag") as! Bool == true) {
                
            }
            */
            
            dict[annotation.hash] = memo.objectId! as String
            memoDict[memo.objectId! as String] = memo
            //println(dict[annotation])
        }
    }
    
    @IBAction func distanceChanged(sender: UISlider) {
        
        var sliderDouble = Double(self.distanceSlider.value)
        
        var focusDistance = regionRadius * sliderDouble
        
        //self.distanceLabel.text = focusDistance.description
        
        centerMapOnLocation(userLocation, regionRadius: focusDistance)
        
    }
    
    
    func loadDummyUser() {
        
        var initialLocation = CLLocation(latitude: 34.041801, longitude: -118.437853)
        self.userLocation = initialLocation
        
        centerMapOnLocation(initialLocation, regionRadius: regionRadius)
        
        var annotation = MKPointAnnotation()
        var location = CLLocationCoordinate2D(latitude: 34.041801, longitude: -118.437853)
        annotation.coordinate = location
        annotation.title = "Admin"
        annotation.subtitle = "You are HERE"
        
        //mapView.addAnnotation(annotaion)
        
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

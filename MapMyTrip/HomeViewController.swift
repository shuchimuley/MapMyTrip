//
//  HomeViewController.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 11/6/15.
//  Copyright © 2015 Shuchi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var showSideViewButton: UIImageView!
    @IBOutlet weak var mmvMapView: MKMapView!
    
    // array to store coordinates
    var annotations: Array<Place> = [Place]()
    
    // countryname and triptitle variables
    var countryName:String = ""
    var tripTitle:String = ""
    var uniqueNameErrorOccured:Bool = false
    var currentObjectTitle :String = ""
    var endCountry:String = ""
    var startCountry:String = ""
    
    // Location manager variable
    var locationManager = CLLocationManager()
    
    // outlets
    @IBOutlet weak var lastTripSummaryBar: UINavigationBar!
    @IBOutlet weak var fromCountry: UILabel!
    @IBOutlet weak var toCountry: UILabel!
    @IBOutlet weak var distanceTravelled: UILabel!

    // variables
    var pointLatitude: CLLocationDegrees = CLLocationDegrees()
    var pointLongitude: CLLocationDegrees = CLLocationDegrees()
    var currentAnnotations: Array<Place> = [Place]()
    
    @IBOutlet weak var homeNavBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // signup for notification 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addRouteOnMap:", name: "addRoute", object: nil)
        
        
        // Show side view gesture
        let showSideViewTapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("showSideView"))
        showSideViewButton.userInteractionEnabled = true
        showSideViewButton.addGestureRecognizer(showSideViewTapGestureRecognizer)
        
        // Mapview Delegate self
        mmvMapView.delegate = self
        let titleTextAttribute:Dictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName:UIFont(name: "Optima-Bold", size: 23.0)!]
        UINavigationBar.appearance().titleTextAttributes = titleTextAttribute
        
        
        let lastTripSummaryBarTitleTextAttribute:Dictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName:UIFont(name: "Optima-Bold", size: 18.0)!]
        lastTripSummaryBar.titleTextAttributes = lastTripSummaryBarTitleTextAttribute
     
        // display last trip
        queryLastTrip()
        
        // username
        homeNavBar.topItem?.title = "Welcome, " + (PFUser.currentUser()?.username)!
        
    }
    
    func queryLastTrip() {
        // get last inserted object
        let lastElementQuery = PFQuery(className: "Trip")
        let currentUser = PFUser.currentUser()?.objectId
        lastElementQuery.orderByDescending("createdAt")
        lastElementQuery.whereKey("userId", equalTo: currentUser!)
        lastElementQuery.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error:NSError?) -> Void in
            if (error != nil) {
                print(error)
            }
            else if let currentObject = object {
                self.currentObjectTitle = currentObject.valueForKey("title") as! String
                self.endCountry = currentObject.valueForKey("country") as! String
                
                //get all elements with that title
                let allElementsWithTitleQuery = PFQuery(className: "Trip")
                allElementsWithTitleQuery.whereKey("title", equalTo: self.currentObjectTitle)
                allElementsWithTitleQuery.whereKey("userId", equalTo: currentUser!)
                allElementsWithTitleQuery.orderByAscending("sequence")
                allElementsWithTitleQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                    if let allObjects = objects {
                        for (var i = 0 ; i < allObjects.count; i++) {
                            // create points and join them
                            let object = allObjects[i]
                            let latitude = object.valueForKey("latitude") as! Double
                            let longitude = object.valueForKey("longitude") as! Double
                            var pinColor = UIColor()
                            if i == 0 {
                                pinColor = UIColor(red: 0, green: 102, blue: 0, alpha: 1)
                                self.startCountry = object.valueForKey("country") as! String
                            } else if i == allObjects.count - 1 {
                                pinColor = UIColor.redColor()
                            } else {
                                pinColor = UIColor.grayColor()
                            }
                            
                            let newPlace = Place(latitude: latitude, longitude: longitude, pinColor: pinColor)
                            newPlace.countryName = object.valueForKey("country") as! String
                            self.currentAnnotations.append(newPlace)
                            
                        }
                    }
                    
                    self.calculateTotalDistance()
                    
                    let firstPlace:Place = self.currentAnnotations[0]
                    // put pins on the map
                    for place in self.currentAnnotations {
                        self.mmvMapView.addAnnotation(place)
                    }
                    
                    // center map on annotation
                    self.mmvMapView.centerCoordinate = firstPlace.coordinate
                    
                    
                    if self.currentAnnotations.count > 1 {
                        self.joinPoints()
                    }
                    
                    // set from and to country
                    self.fromCountry.text = self.startCountry
                    self.toCountry.text = self.endCountry
                    
//                    self.mmvMapView.showAnnotations(self.currentAnnotations, animated: true)

                }
                

            }
        }
    }
    
    func calculateTotalDistance() {
        var totalDistance:Double = 0.0
        for (var i = 0 ; i < self.currentAnnotations.count-1; i++) {
            let location1 = CLLocation(latitude: self.currentAnnotations[i].latitude, longitude: self.currentAnnotations[i].longitude)
            let location2 = CLLocation(latitude: self.currentAnnotations[i+1].latitude, longitude: self.currentAnnotations[i+1].longitude)
            
            let distance = location1.distanceFromLocation(location2)/1000.0
            print("Distance: \(distance)")
            totalDistance += distance
        }
        print("TotalDistance: \(totalDistance)")
        distanceTravelled.text = String(format: "%.2f km", totalDistance)
    }
    
    // Add Lines to connect the countries
    func joinPoints() {
        var points: [CLLocationCoordinate2D] = []
        for annotation in currentAnnotations {
            points.append(annotation.coordinate)
        }
        
        // Draw a line
        let polyline = MKPolyline(coordinates: &points, count: points.count)
        //MKPolyline(coordinates: &points, count: points.count)
        self.mmvMapView.removeOverlays(self.mmvMapView.overlays)
        self.mmvMapView.addOverlay(polyline)
        
        
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blackColor()
            polylineRenderer.lineWidth = 2
            polylineRenderer.lineDashPattern = [2, 5]
            return polylineRenderer
        }
        return MKOverlayPathRenderer()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            return nil
        } else {
            let pinView:MKPinAnnotationView = MKPinAnnotationView()
            let colorAnnotation = annotation as! Place
            pinView.annotation = colorAnnotation
            pinView.pinTintColor = colorAnnotation.pinColor
            return pinView
        }
    }
    
    // Show side menu
    func showSideView() {
        NSNotificationCenter.defaultCenter().postNotificationName("showSideView", object: nil)
    }
    
    // Create new location data
    func createNewTrip() {
        // Create Parse data for Trip (title, country, longitude, latitude)
        let newTrip = PFObject(className: "Trip")
        newTrip["title"] = tripTitle
        newTrip["country"] = countryName
        newTrip["latitude"] = pointLatitude
        newTrip["longitude"] = pointLongitude
        newTrip["userId"] = PFUser.currentUser()!.objectId
        newTrip["sequence"] = 1
        newTrip.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("Object Successfully added")
                print("Object id : \(newTrip.objectId)")
            } else {
                print("Error: \(error)")
            }
        }
        
    }
    
    // Method to put pin on the map
    func addRouteOnMap(notification: NSNotification) {
        print("Notification: Parent method called")
        var locationNames:Dictionary = (notification.object as? Dictionary<String,String>)!
        let fromValue = locationNames["from"] as String!
        countryName = fromValue
        
        let tripValue = locationNames["title"] as String!
        tripTitle = tripValue
        
        if fromValue == "" || tripValue == ""{
          let showAlert = UIAlertController(title: "Trip not valid!", message: "Enter all fields", preferredStyle: UIAlertControllerStyle.Alert)
            showAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(showAlert, animated: true, completion: nil)
        } else {
            // Query to see if the trip title is same
            let sameTripQuery:PFQuery = PFQuery(className: "Trip")
            let currentUser = PFUser.currentUser()?.objectId
            sameTripQuery.whereKey("title", equalTo: tripValue)
            sameTripQuery.whereKey("userId", equalTo: currentUser!)
            sameTripQuery.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                if objects!.count > 0 {
                    self.showTripNameMustBeUniqueAlert()
                } else {
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(fromValue, completionHandler: {(placemarks, error) -> Void in
                        if error != nil {
                            print("Error occured: \(error)")
                        }
                        else if placemarks?.count > 0 {
                            let placemark = placemarks![0] as CLPlacemark
                            let location = placemark.location
                            self.pointLatitude = (location?.coordinate.latitude)!
                            self.pointLongitude = (location?.coordinate.longitude)!
                            let annotation = Place(latitude: self.pointLatitude, longitude: self.pointLongitude, pinColor: UIColor(red: 0, green: 102, blue: 0, alpha: 1))
                            annotation.sequenceOfVisit = self.annotations.count + 1
                            self.annotations.append(annotation)
                            self.mmvMapView.addAnnotation(annotation)
                            self.createNewTrip()
                            print("Longitude and latitude \(self.pointLatitude) : \(self.pointLongitude)")
                        }
                    })
                }
            }
        
        }
    }
    
   
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let latitude:CLLocationDegrees = userLocation.coordinate.latitude
        let longitude:CLLocationDegrees = userLocation.coordinate.longitude
        
        let latitudeDelta:CLLocationDegrees = 0.05
        let longitudeDelta:CLLocationDegrees = 0.05
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        self.mmvMapView.setRegion(region, animated: true)
        
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = location
        mapAnnotation.title = "You are here"
        self.mmvMapView.addAnnotation(mapAnnotation)
        
    }
    
    func addFromTextField(fromTextField: UITextField) {
        fromTextField.placeholder = "Starting place.."
    }
    
    func addTitleTextField(titleTextField: UITextField) {
        titleTextField.placeholder = "Trip Title.."
    }
    
    func showTripNameMustBeUniqueAlert() {
            let uniqueTripNameAlert = UIAlertController(title: "Choose another name", message: "Trip name must be unique", preferredStyle: UIAlertControllerStyle.Alert)
            uniqueTripNameAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(uniqueTripNameAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
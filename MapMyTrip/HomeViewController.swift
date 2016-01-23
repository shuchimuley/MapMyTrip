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
    
//    @IBOutlet weak var addTripButton: UIImageView!
    @IBOutlet weak var showSideViewButton: UIImageView!
    
    @IBOutlet weak var mmvMapView: MKMapView!
    var locationManager = CLLocationManager()
    
    // array to store coordinates
    var annotations: Array<Place> = [Place]()
    
    // countryname and triptitle variables
    var countryName:String = ""
    var tripTitle:String = ""
    var uniqueNameErrorOccured:Bool = false

    // variables
    var pointLatitude: CLLocationDegrees = CLLocationDegrees()
    var pointLongitude: CLLocationDegrees = CLLocationDegrees()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Add trip button gesture
//        let addTripTapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:Selector("showAddTripDetailsViewController"))
//        addTripButton.userInteractionEnabled = true
//        addTripButton.addGestureRecognizer(addTripTapGestureRecognizer)
        
        // signup for notification 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addRouteOnMap:", name: "addRoute", object: nil)
        
        
        // Show side view gesture
        let showSideViewTapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("showSideView"))
        showSideViewButton.userInteractionEnabled = true
        showSideViewButton.addGestureRecognizer(showSideViewTapGestureRecognizer)
        
        // Mapview Delegate self
        mmvMapView.delegate = self
    }
    
    // Show side menu
    func showSideView() {
        NSNotificationCenter.defaultCenter().postNotificationName("showSideView", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        print("View Displayed")

//        // if annotations have more than 1 coordinate, join them
//        if annotations.count > 1 {
//            joinPoints()
//        }

    }
    
    
//    func joinPoints() {
//        var points: [CLLocationCoordinate2D] = []
//        for annotation in annotations {
//            points.append(annotation.coordinate)
//        }
//        
//        // Draw a line
//        let polyline = MKPolyline(coordinates: &points, count: points.count)
//        mmvMapView.addOverlay(polyline)
//    }
    
//    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is MKPolyline {
//            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
//            polylineRenderer.strokeColor = UIColor.blackColor()
//            polylineRenderer.lineWidth = 2
//            polylineRenderer.lineDashPattern = [2, 5]
//            return polylineRenderer
//        }
//        return MKOverlayPathRenderer()
//    }
    
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
        
        // Query to see if the trip title is same
        let sameTripQuery:PFQuery = PFQuery(className: "Trip")
        sameTripQuery.whereKey("title", equalTo: tripValue)
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
                        let annotation = Place(latitude: self.pointLatitude, longitude: self.pointLongitude, pinColor: UIColor.greenColor())
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
        fromTextField.placeholder = "Starting country.."
    }
    
    func addTitleTextField(titleTextField: UITextField) {
        titleTextField.placeholder = "Trip Title.."
    }
    
    
    //
//    func showAddTripDetailsViewController() {
//        let fromAlertView = UIAlertController(title: "Add new Trip?", message: "Enter trip title:", preferredStyle: UIAlertControllerStyle.Alert)
//        fromAlertView.addTextFieldWithConfigurationHandler(addTitleTextField)
//        fromAlertView.addTextFieldWithConfigurationHandler(addFromTextField)
//        
//        fromAlertView.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {action -> Void in
//            let tripTitle = fromAlertView.textFields![0].text!
//            let fromCountryValue = fromAlertView.textFields![1].text!
//            let routeData:[String:String] = ["from":fromCountryValue, "title":tripTitle]
//            NSNotificationCenter.defaultCenter().postNotificationName("addRoute", object: routeData)
//            
//        }))
//        fromAlertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
//        
//        presentViewController(fromAlertView, animated: true, completion: nil)
//        
//        
//    }
    
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
//
//  TripDetailViewController.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 1/10/16.
//  Copyright © 2016 Shuchi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse


class TripDetailViewController : UIViewController, MKMapViewDelegate {
    @IBOutlet weak var tripNavigationBar: UINavigationBar!
    @IBOutlet weak var tripDetailMapView: MKMapView!
    var tripTitle: String!
    var locationManager = CLLocationManager()
    var places:[Place] = []
    var countryName:String!
    var totalDistance:CLLocationDistance = CLLocationDistance()

    // variables for coordinates
    var pointLatitude: CLLocationDegrees = CLLocationDegrees()
    var pointLongitude: CLLocationDegrees = CLLocationDegrees()
    
    // array to store coordinates
    var annotations: Array<Place> = [Place]()
    var justDisplay:Bool = false
    
    @IBOutlet weak var distanceTravelledLabel: UILabel!
    @IBOutlet weak var fromCountry: UILabel!
    @IBOutlet weak var toCountry: UILabel!

    
    @IBAction func showMyTrips(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func addMoreCountries(sender: AnyObject) {
        let fromAlertView = UIAlertController(title: "Add more destinations?", message: "Enter Place name:", preferredStyle: UIAlertControllerStyle.Alert)
        fromAlertView.addTextFieldWithConfigurationHandler(addCountryNameTextField)
        
        fromAlertView.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {action -> Void in
            let countryValue = fromAlertView.textFields![0].text!
            let routeData:[String:String] = ["countryName":countryValue]
            NSNotificationCenter.defaultCenter().postNotificationName("addCountries", object: routeData)
            
        }))
        fromAlertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(fromAlertView, animated: true, completion: nil)
    }
    
    func addCountryNameTextField(countryTextField: UITextField) {
        countryTextField.placeholder = "Enter place name.."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripNavigationBar.topItem!.title = tripTitle
        getAllCountriesForTrip()
        
        // signup for notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addCountries:", name: "addCountries", object: nil)
        
        // delegate for map
        self.tripDetailMapView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        tripDetailMapView.showsUserLocation = false
        tripDetailMapView.delegate = nil
        tripDetailMapView.removeFromSuperview()
        tripDetailMapView = nil
    }
    
    deinit {
        print("Deinit in Trip Detail is called")
    }
    
    func calculateTotalDistance() {
        totalDistance = 0.0
        for (var i = 0 ; i < self.places.count-1; i++) {
            let location1 = CLLocation(latitude: self.places[i].latitude, longitude: self.places[i].longitude)
            let location2 = CLLocation(latitude: self.places[i+1].latitude, longitude: self.places[i+1].longitude)
            
            let distance = location1.distanceFromLocation(location2)/1000.0
            totalDistance += distance
        }
        distanceTravelledLabel.text = String(format: "%.2f km", totalDistance)
    }
    
    // Method to put pin on the map
    func addCountries(notification: NSNotification) {
        print("Notification: Parent method called")
        var locationNames:Dictionary = (notification.object as? Dictionary<String,String>)!
        self.countryName = locationNames["countryName"] as String!
        
        // check for null else add
        if self.countryName == "" {
            let showAlert = UIAlertController(title: "Place not valid!", message: "Enter a valid location", preferredStyle: UIAlertControllerStyle.Alert)
            showAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(showAlert, animated: true, completion: nil)
        } else {
            // Query to see if the trip title is same
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(self.countryName, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Error occured: \(error)")
                }
                else if placemarks?.count > 0 {
                    let placemark = placemarks![0] as CLPlacemark
                    let location = placemark.location
                    self.pointLatitude = (location?.coordinate.latitude)!
                    self.pointLongitude = (location?.coordinate.longitude)!
                    
                    let newPlace = Place(latitude: self.pointLatitude, longitude: self.pointLongitude, pinColor: UIColor.redColor())
                    newPlace.countryName = self.countryName
                    newPlace.sequenceOfVisit = self.places.count + 1
                    
                    self.places.append(newPlace)
                    self.annotations.append(newPlace)
                    self.calculateTotalDistance()
                    
                    for var i = 1 ; i < self.places.count; i++ {
                        if i == self.places.count - 1 {
                            self.places[i].pinColor = UIColor.redColor()
                            self.toCountry.text = self.places[i].countryName
                        } else {
                            self.places[i].pinColor = UIColor.grayColor()
                        }
                    }
                    
                    // remove all and add all annotations
                    self.tripDetailMapView.removeAnnotations(self.annotations)
//                    self.tripDetailMapView.addAnnotations(self.annotations)
                    self.tripDetailMapView.showAnnotations(self.annotations, animated: true)
                    self.createNewTrip()
                    if self.places.count > 1 {
                        self.joinPoints()
                    }
                    print("Longitude and latitude \(self.pointLatitude) : \(self.pointLongitude)")
                }
            })
        }
    }
    
    // create new trip in Parse
    func createNewTrip() {
        let newTrip = PFObject(className: "Trip")
        newTrip["title"] = tripTitle
        newTrip["country"] = countryName
        newTrip["latitude"] = pointLatitude
        newTrip["longitude"] = pointLongitude
        newTrip["userId"] = PFUser.currentUser()!.objectId
        newTrip["sequence"] = annotations.count
        newTrip.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("Object Successfully added")
                print("Object id : \(newTrip.objectId)")
               
            } else {
                print("Error: \(error)")
            }
        }

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func getAllCountriesForTrip() {
        // table view title
        self.navigationController?.navigationBar.topItem!.title = tripTitle
        
        let currentUserId = PFUser.currentUser()!.objectId
        let query = PFQuery(className: "Trip")
        query.whereKey("title", equalTo: tripTitle)
        query.whereKey("userId", equalTo: currentUserId!)
        query.orderByAscending("sequence")
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for (var i = 0 ; i < objects.count; i++) {
                        // create points and join them
                        let object = objects[i]
                        let latitude = object.valueForKey("latitude") as! Double
                        let longitude = object.valueForKey("longitude") as! Double
                        var pinColor = UIColor()
                        if i == 0 {
                            pinColor = UIColor(red: 0, green: 102, blue: 0, alpha: 1)
                        } else if i == objects.count - 1 {
                            pinColor = UIColor.redColor()
                        } else {
                            pinColor = UIColor.grayColor()
                        }
                        
                        let seq = object.valueForKey("sequence") as! Int
                        if seq == 1 {
                            self.fromCountry.text = object.valueForKey("country") as?String
                        } else if seq == objects.count {
                            self.toCountry.text = object.valueForKey("country") as? String
                        }
                        
                        let newPlace = Place(latitude: latitude, longitude: longitude, pinColor: pinColor)
                        newPlace.countryName = object.valueForKey("country") as! String
                        self.places.append(newPlace)
                        self.annotations.append(newPlace)
                    }
                    
                    // put pins on the map
                    self.tripDetailMapView.showAnnotations(self.places, animated: true)
                    
                }
                
                if self.places.count > 1 {
                    self.joinPoints()
                }
                
                if !self.justDisplay {
                    self.calculateTotalDistance()
                }
                self.justDisplay = true
                
            } else {
                print("Error: \(error)")
            }
        }
    }
    
    // Add Lines to connect the countries
    func joinPoints() {
        var points: [CLLocationCoordinate2D] = []
        for annotation in annotations {
            points.append(annotation.coordinate)
        }
        
        // Draw a line
        let polyline = MKGeodesicPolyline(coordinates: &points, count: points.count)
        self.tripDetailMapView.removeOverlays(self.tripDetailMapView.overlays)
        self.tripDetailMapView.addOverlay(polyline)
        
        
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
        
        let pinView:MKPinAnnotationView = MKPinAnnotationView()
        let colorAnnotation = annotation as! Place
        pinView.annotation = colorAnnotation
        pinView.pinTintColor = colorAnnotation.pinColor
        return pinView
    }
    
}

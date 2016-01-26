//
//  MyTripsViewController.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 1/9/16.
//  Copyright © 2016 Shuchi. All rights reserved.
//

import UIKit
import Parse

class MyTripsViewController : UITableViewController {
    
    
    @IBOutlet weak var myTripsTableView: UITableView!
    var setOfTrips = Set<String>()
    var arrayOfTrips = [String]()
    var tripTitle: String!
    var rControl:UIRefreshControl!
    var listOfTrips:[String:[Place]] = [:]
    let tripCellIdentifier = "TripCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pull to refresh
        self.rControl = UIRefreshControl()
        self.rControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.rControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(rControl)

        // get all trips
        queryAllTrips()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func refresh(sender:AnyObject) {
        queryAllTrips()
        self.tableView.reloadData()
        self.rControl?.endRefreshing()
    }
    
    @IBAction func closeMyTrips(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func addNewTrips(sender: AnyObject) {
        let fromAlertView = UIAlertController(title: "Add new Trip?", message: "Enter trip title:", preferredStyle: UIAlertControllerStyle.Alert)
        fromAlertView.addTextFieldWithConfigurationHandler(addTitleTextField)
        fromAlertView.addTextFieldWithConfigurationHandler(addFromTextField)
        
        fromAlertView.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {action -> Void in
            let tripTitle = fromAlertView.textFields![0].text!
            self.tripTitle = tripTitle
            let fromCountryValue = fromAlertView.textFields![1].text!
            let routeData:[String:String] = ["from":fromCountryValue, "title":tripTitle]
            NSNotificationCenter.defaultCenter().postNotificationName("addRoute", object: routeData)
            
        }))
        fromAlertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(fromAlertView, animated: true, completion: nil)
    }
    
    func addFromTextField(fromTextField: UITextField) {
        fromTextField.placeholder = "Starting country.."
    }
    
    func addTitleTextField(titleTextField: UITextField) {
        titleTextField.placeholder = "Trip Title.."
    }
    
    func queryAllTrips() {
        let currentUserId:String = PFUser.currentUser()!.objectId!
        let tripsQuery = PFQuery(className: "Trip")
        
        tripsQuery.whereKey("userId", equalTo: currentUserId)
        tripsQuery.orderByAscending("sequence")
        tripsQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let title = object.valueForKey("title") as! String
                        self.tripTitle = title
                        self.setOfTrips.insert(title)
                        
                        // set place variables
                        let lat = object.valueForKey("latitude") as! Double
                        let long = object.valueForKey("longitude") as! Double
                        let pColor = UIColor.lightGrayColor()
                        let seq = object.valueForKey("sequence") as! Int
                        let newPlace:Place = Place(latitude: lat, longitude: long, pinColor: pColor)
                        newPlace.sequenceOfVisit = seq
                        newPlace.countryName = object.valueForKey("country") as! String
                        
                        if self.listOfTrips[title] != nil {
                            if var listOfPlaces:[Place] = self.listOfTrips[title] {
                                listOfPlaces.append(newPlace)
                                self.listOfTrips[title] = listOfPlaces
                            }
                        } else {
                            self.listOfTrips[title] = [newPlace]
                        }

                    }
                }
                print(self.listOfTrips)
                
                if self.setOfTrips.count > 0 {
                    for ele in self.setOfTrips {
                        if !self.arrayOfTrips.contains(ele) {
                            self.arrayOfTrips.append(ele)
                        }
                    }
                }
                self.tableView.reloadData()
                
            } else {
                print("Error: \(error)")
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setOfTrips.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tripCellIdentifier) as! TripCell
        setTripTitle(cell, indexPath: indexPath)
        setTripStart(cell, indexPath: indexPath)
        setTripEnd(cell, indexPath: indexPath)
        return cell
    }
    
    func setTripTitle(cell:TripCell, indexPath:NSIndexPath) {
        if self.arrayOfTrips.count != 0 {
            let item = self.arrayOfTrips[indexPath.row]
            cell.tripTitle.text = item ?? "No Title"
        }
    }
    
    func setTripStart(cell:TripCell, indexPath:NSIndexPath) {
        if self.arrayOfTrips.count != 0 {
            let item:String = self.arrayOfTrips[indexPath.row]
            let listOfCountries:[Place] = self.listOfTrips[item]!
            for place in listOfCountries {
                if place.sequenceOfVisit == 1 {
                    cell.tripStart.text = place.countryName
                }
            }
        }
        
    }
    
    func setTripEnd(cell:TripCell, indexPath:NSIndexPath) {
        let item:String = self.arrayOfTrips[indexPath.row]
        let listOfCountries:[Place] = self.listOfTrips[item]!
        for place in listOfCountries {
            if place.sequenceOfVisit == listOfCountries.count {
                cell.tripEnd.text = place.countryName
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let cell = sender as? UITableViewCell {
            if segue.identifier == "tripDetailSegue" {
            
                let index = tableView.indexPathForCell(cell)!.row
                tripTitle = arrayOfTrips[index]
                let tripDetailsViewController = segue.destinationViewController as! TripDetailViewController
                tripDetailsViewController.tripTitle = tripTitle
            }
        }
    }
    
    
}

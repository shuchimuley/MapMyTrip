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
    var deleteIndexPath:NSIndexPath? = nil
    var tripToDelete:String = ""
    
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
    
    override func viewDidAppear(animated: Bool) {
        //self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func refresh(sender:AnyObject) {
        self.listOfTrips.removeAll()
        self.setOfTrips.removeAll()
        self.arrayOfTrips.removeAll()
        
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
        fromTextField.placeholder = "Starting place.."
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
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // delete row
            deleteIndexPath = indexPath
            tripToDelete = self.arrayOfTrips[(deleteIndexPath?.row)!]
            confirmDelete(tripToDelete)
            
//            // delete every row in Parse where title is tripTitle for this user
//            let lastElementQuery = PFQuery(className: "Trip")
//            let currentUser = PFUser.currentUser()?.objectId
//            lastElementQuery.whereKey("title", equalTo: tripTitle)
//            lastElementQuery.whereKey("userId", equalTo: currentUser!)
//            lastElementQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
//                if error == nil {
//                    if let tripObjs:[PFObject] = objects!{
//                        PFObject.deleteAllInBackground(tripObjs)
//                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//                        self.setOfTrips.remove(tripTitle)
//                    }
//                }
//            }
        }
    }
    
    func confirmDelete(tripTitle:String) {
       let alert = UIAlertController(title: "Delete Trip", message: "Are you sure you want to delete \(tripTitle)", preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: handleDeleteTrip)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: cancelDeleteTrip)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(1.0, 1.0, self.view.bounds.size.width/2, self.view.bounds.size.height/2)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteTrip(alertAction:UIAlertAction!) -> Void {
        // delete every row in Parse where title is tripTitle for this user
        var isTripDeleted:Bool = false
        let lastElementQuery = PFQuery(className: "Trip")
        let currentUser = PFUser.currentUser()?.objectId
        lastElementQuery.whereKey("title", equalTo: tripToDelete)
        lastElementQuery.whereKey("userId", equalTo: currentUser!)
        lastElementQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if error == nil {
                if let tripObjs:[PFObject] = objects{
                    PFObject.deleteAllInBackground(tripObjs)
                    isTripDeleted = true
                    if isTripDeleted {
                        self.tableView.beginUpdates()
                        self.tableView.deleteRowsAtIndexPaths([self.deleteIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                        self.setOfTrips.remove(self.tripToDelete)
                        self.listOfTrips.removeValueForKey(self.tripToDelete)
                        self.arrayOfTrips.removeAtIndex(self.deleteIndexPath!.row)
                        self.deleteIndexPath = nil
                        self.tableView.endUpdates()
                    }

                }
            }
        }
        
    }
    
    func cancelDeleteTrip(alertAction:UIAlertAction!) -> Void {
        deleteIndexPath = nil
    }
    
    
    func setTripTitle(cell:TripCell, indexPath:NSIndexPath) {
        if self.arrayOfTrips.count != 0 {
            let item = self.arrayOfTrips[indexPath.row]
            cell.tripTitle.text = item ?? "No Title"
        }
    }
    
    func setTripStart(cell:TripCell, indexPath:NSIndexPath) {
        if self.arrayOfTrips.count != 0 && self.listOfTrips.count != 0 {
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
        if self.arrayOfTrips.count != 0 && self.listOfTrips.count != 0 {
            let item:String = self.arrayOfTrips[indexPath.row]
            let listOfCountries:[Place] = self.listOfTrips[item]!
            for place in listOfCountries {
                if place.sequenceOfVisit == listOfCountries.count {
                    cell.tripEnd.text = place.countryName
                }
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

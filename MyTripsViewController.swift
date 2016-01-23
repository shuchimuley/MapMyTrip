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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pull to refresh
        self.rControl = UIRefreshControl()
        self.rControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.rControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(rControl)
        
        queryAllTrips()
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
        tripsQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let title = object.valueForKey("title") as! String
                        self.setOfTrips.insert(title)
                    }
                }
                if self.setOfTrips.count > 0 {
                    for ele in self.setOfTrips {
                        self.arrayOfTrips.append(ele)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("tripCellIdentifier", forIndexPath: indexPath)
        let tripName = self.arrayOfTrips[indexPath.row]
        cell.textLabel!.text = tripName
        return cell
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let index = indexPath.row
//
//        //performSegueWithIdentifier("tripDetailSegue", sender: self)
//    }
    
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

//
//  MenuViewController.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 1/9/16.
//  Copyright © 2016 Shuchi. All rights reserved.
//

import UIKit

class MenuViewController : UITableViewController {
    
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 49, green: 46, blue: 104, alpha: 1.0)
    }
    
    func setContentHeight() {
        dispatch_async(dispatch_get_main_queue()){
            var frame:CGRect = self.tableView.frame
            frame.size.height = self.tableView.contentSize.height
            self.tableView.frame = frame
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    struct NotificationsForMenu {
        static let MyTripsSelected = "MyTripsSelected"
        static let LogoutSelected = "LogoutSelected"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentItem = indexPath.row
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        switch currentItem {
        case 0 : notificationCenter.postNotification(NSNotification(name: NotificationsForMenu.MyTripsSelected, object: nil))
                 notificationCenter.postNotificationName("showSideView", object: nil)
            
        case 1: notificationCenter.postNotificationName("showSideView", object: nil)
                notificationCenter.postNotification(NSNotification(name: NotificationsForMenu.LogoutSelected, object: nil))
            
        default: print("Unrecognized item")
            return
        }
    }
    
}

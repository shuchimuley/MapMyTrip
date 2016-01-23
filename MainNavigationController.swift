//
//  MainNavigationController.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 1/9/16.
//  Copyright © 2016 Shuchi. All rights reserved.
//

import UIKit
import Parse

class MainNavigationController : UINavigationController {
    private var myTyipsSelectedObserver : NSObjectProtocol?
    private var logoutSelectedObserver : NSObjectProtocol?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    private func addObservers() {
        let center = NSNotificationCenter.defaultCenter()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        myTyipsSelectedObserver = center.addObserverForName(MenuViewController.NotificationsForMenu.MyTripsSelected, object: nil, queue: nil){ (notification: NSNotification!) -> Void in
                let myTripsViewController = storyboard.instantiateViewControllerWithIdentifier("MyTripsViewController") 
//                self.setViewControllers([myTripsViewController], animated: true)
            self.showViewController(myTripsViewController, sender: self)
        }
        
        logoutSelectedObserver = center.addObserverForName(MenuViewController.NotificationsForMenu.LogoutSelected, object: nil, queue: nil){ (notification: NSNotification!) -> Void in
                PFUser.logOut()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
                self.setViewControllers([loginViewController], animated: true)
            })

        }
    }
    
    private func removeObservers() {
        let center = NSNotificationCenter.defaultCenter()
        
        if myTyipsSelectedObserver != nil {
            center.removeObserver(myTyipsSelectedObserver!)
        }
    }
}

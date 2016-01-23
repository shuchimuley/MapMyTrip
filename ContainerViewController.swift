//
//  ContainerViewController.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 1/9/16.
//  Copyright © 2016 Shuchi. All rights reserved.
//

import UIKit

class ContainerViewController : UIViewController {
    var leftViewController : UIViewController? {
        willSet{
            if self.leftViewController != nil {
                if self.leftViewController!.view != nil {
                  self.leftViewController!.view!.removeFromSuperview()
                }
                
                self.leftViewController!.removeFromParentViewController()
            }
        }
        
        didSet{
            self.view!.addSubview(self.leftViewController!.view)
            self.addChildViewController(self.leftViewController!)
        }
    }
    
    var rightViewController : UIViewController? {
        willSet{
            if self.rightViewController != nil {
                if self.rightViewController!.view != nil {
                    self.rightViewController!.view!.removeFromSuperview()
                }
                
                self.rightViewController!.removeFromParentViewController()
            }
        }
        
        didSet{
            self.view!.addSubview(self.rightViewController!.view)
            self.addChildViewController(self.rightViewController!)
        }
    }
    
    var menuShown:Bool = false
    
//    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
//        showMenu()
//    }
//    
//    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
//        hideMenu()
//    }
    
    func showMenu() {
        UIView.animateWithDuration (0.3, animations: {
            self.rightViewController!.view.frame = CGRect(x: self.view.frame.origin.x + 235, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)},
        completion: {(Bool) -> Void in
            self.menuShown = true
            
        })
    
    }
    
    
    func hideMenu() {
        UIView.animateWithDuration (0.3, animations: {
            self.rightViewController!.view.frame = CGRect(x: 0, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)},
            completion: {(Bool) -> Void in
                self.menuShown = false
                
        })
    }
    
    func toggleMenu() {
        if self.menuShown {
            hideMenu()
        } else {
            showMenu()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNavigationViewController: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("MainNavigationController") as! UINavigationController
        let menuViewController: MenuViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        
        
        self.leftViewController = menuViewController
        self.rightViewController = mainNavigationViewController
        
        // signup for notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showSideView:", name: "showSideView", object: nil)
        
    }
    
    func showSideView(notification: NSNotification) {
        toggleMenu()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


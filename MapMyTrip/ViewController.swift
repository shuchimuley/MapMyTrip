//
//  ViewController.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 11/5/15.
//  Copyright © 2015 Shuchi. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func signUp(sender: AnyObject) {
        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignUpViewController")
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    @IBAction func loginIntoMapMyTrip(sender: AnyObject) {
        loginInMapMyTrip()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordField.delegate = self
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 1 {
            usernameField.placeholder = nil
        } else if textField.tag == 2 {
            passwordField.placeholder = nil
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 2 {
            passwordField.placeholder = "Password"
        }
    }
    
    
    func loginInMapMyTrip() {
        
        if !Reachability.isConnectedToNetwork() {
            let alertView = UIAlertController(title: "No Network Connection", message: "Make sure your device is connected to internet", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
            
        } else {
            let username = usernameField.text
            let password = passwordField.text
            
            let spinner:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            PFUser.logInWithUsernameInBackground(username!, password: password!) { (user, error) -> Void in
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ContainerViewController") 
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                } else {
                    let alert = UIAlertController(title: "Username or Password is incorrect", message: "Please retry!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_textField: UITextField) -> Bool {
        _textField.resignFirstResponder()
        loginInMapMyTrip()
        return true
    }

}


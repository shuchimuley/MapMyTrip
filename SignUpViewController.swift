//
//  SignUpViewController.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 1/14/16.
//  Copyright © 2016 Shuchi. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Error Labels
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    var isError: Bool = false
    
    @IBAction func signUp(sender: AnyObject) {
        // validations
        if usernameTextField.text == "" || passwordTextField.text == "" || emailTextField.text == "" {
            let alertPopup = UIAlertController(title: "All fields are required", message: "Please fill in all fields", preferredStyle: UIAlertControllerStyle.Alert)
            alertPopup.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alertPopup, animated: true, completion: nil)
        } else {
            let username = usernameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let password = passwordTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let email = emailTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
            if username.characters.count < 5 {
                usernameErrorLabel.text = "Username must be greater than 5 characters!"
                isError = true
            }
            
            if password.characters.count < 8 {
                passwordErrorLabel.text = "Password must be greater than 8 characters!"
                isError = true
            }
            
            if !isValidEmail(email) {
                emailErrorLabel.text = "Enter a valid email!"
                isError = true
            }
            
            if !isError {
                // sign into the org
                let spinner = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 150,height: 150)) as UIActivityIndicatorView
                spinner.startAnimating()
                
                // call Parse for user
                let user = PFUser()
                user.username = username
                user.password = password
                user.email = email
                
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    if error == nil {
                        spinner.stopAnimating()
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ContainerViewController")
                            self.presentViewController(viewController, animated: true, completion: nil)
                        })
                    } else {
                        let errorCode = error!.code
                        switch errorCode {
                        case 203:
                            let errorAlert = UIAlertController(title: "The email address has already been used", message: "Sign in with your username", preferredStyle: UIAlertControllerStyle.Alert)
                            errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                            self.presentViewController(errorAlert, animated: true, completion: nil)
                            break
                            
                        default: break
                        }
                    }
                })
            }
        }
        
    }
    
    
    @IBAction func cancelAndShowLoginPage(sender: AnyObject) {
        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
}

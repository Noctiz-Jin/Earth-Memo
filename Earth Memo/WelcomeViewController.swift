//
//  WelcomeViewController.swift
//  Earth Memo
//
//  Created by Yuning Jin on 7/24/15.
//  Copyright (c) 2015 Noctiz. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class WelcomeViewController: UITabBarController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate{

    @IBAction func logout(sender: UIBarButtonItem) {
        PFUser.logOut()
        logInViewPopup()
    }
    
    func logInViewPopup() {
        // The PFLogInViewController class presents and manages a standard authentication interface for logging in a PFUser.
        var logInViewController = PFLogInViewController()
        
        var loginImage = UIImage(named: "logo")
        var loginLogo = UIImageView(image: loginImage)
        
        logInViewController.logInView?.logo = loginLogo
        // Delegate that responds to the control events of PFLogInViewController
        // In this case, set the delegate to itself
        logInViewController.delegate = self
        
        // Create a sign up view controller
        var signUpViewController = PFSignUpViewController()
        
        var signupImage = UIImage(named: "logo")
        var signupLogo = UIImageView(image: loginImage)
        
        signUpViewController.signUpView?.logo = signupLogo
        // Set view controller delegate
        signUpViewController.delegate = self
        
        // This assigns our sign up controller to be displayed from the login controller
        logInViewController.signUpController = signUpViewController
        
        // iOS view controller: popup view
        self.presentViewController(logInViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = 1
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (PFUser.currentUser() == nil)
        {
            self.logInViewPopup()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        
        // Pops up a little welcome message
        var username : String = user.username!
        var welcomeBackMsg = "Welcome back, " + username
        // Old alert view method: brings up a simple dialog box
        var alertView = UIAlertView(title: "Login Successful", message: welcomeBackMsg, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = UIAlertViewStyle.Default
        alertView.show()
        
        // Dismiss animation
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

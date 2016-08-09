//
//  SignUpViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/6/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var backgroundImage = UIImageView()
    var blur = UIVisualEffectView()
    var logo = UIImageView()
    var usernameField = UITextField()
    var emailField = UITextField()
    var passwordField = UITextField()
    var confirmPasswordField = UITextField()
    var loginButton = UIButton()
    var signUpButton = UIButton()
    var invalidLabel = UILabel()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        
        backgroundImage.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        logo.frame = CGRect(x: 148, y: 95, width: 80, height: 80)
        usernameField.frame = CGRect(x: 25, y: 220, width: 320, height: 30)
        emailField.frame = CGRect(x: 25, y: 270, width: 320, height: 30)
        passwordField.frame = CGRect(x: 25, y: 320, width: 320, height: 30)
        confirmPasswordField.frame = CGRect(x: 25, y: 370, width: 320, height: 30)
        invalidLabel.frame = CGRect(x: 0, y: 420, width: 375, height: 40)
        loginButton.frame = CGRect(x: 35, y: 567, width: 300, height: 30)
        signUpButton.frame = CGRect(x: 0, y: 607, width: 375, height: 60)
        
        backgroundImage.image = UIImage(named: "background")
        logo.image = UIImage(named: "logo")
        
        let blurEffect = UIBlurEffect(style: .Dark)
        blur = UIVisualEffectView(effect: blurEffect)
        blur.alpha = 0.6
        blur.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        
        usernameField.textColor = UIColor.whiteColor()
        emailField.textColor = UIColor.whiteColor()
        passwordField.textColor = UIColor.whiteColor()
        confirmPasswordField.textColor = UIColor.whiteColor()
        usernameField.attributedPlaceholder = NSAttributedString(string: "USERNAME", attributes: [NSForegroundColorAttributeName : UIColor.silver()])
        emailField.attributedPlaceholder = NSAttributedString(string: "EMAIL", attributes: [NSForegroundColorAttributeName : UIColor.silver()])
        passwordField.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes: [NSForegroundColorAttributeName : UIColor.silver()])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "CONFIRM PASSWORD", attributes: [NSForegroundColorAttributeName : UIColor.silver()])
        passwordField.secureTextEntry = true
        confirmPasswordField.secureTextEntry = true
        
        usernameField.font = usernameField.font?.fontWithSize(16.0)
        emailField.font = emailField.font?.fontWithSize(16.0)
        passwordField.font = passwordField.font?.fontWithSize(16.0)
        confirmPasswordField.font = confirmPasswordField.font?.fontWithSize(16.0)
        
        usernameField.alpha = 0.8
        emailField.alpha = 0.8
        passwordField.alpha = 0.8
        confirmPasswordField.alpha = 0.8
        loginButton.alpha = 0.8
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        let border0 = CALayer()
        let width = CGFloat(1.0)
        border0.borderColor = UIColor.silver().CGColor
        border0.frame = CGRect(x: 0, y: emailField.frame.size.height - width, width: emailField.frame.size.width, height: emailField.frame.size.height)
        border0.borderWidth = width
        usernameField.layer.addSublayer(border0)
        usernameField.layer.masksToBounds = true
        
        let border = CALayer()
        border.borderColor = UIColor.silver().CGColor
        border.frame = CGRect(x: 0, y: emailField.frame.size.height - width, width: emailField.frame.size.width, height: emailField.frame.size.height)
        border.borderWidth = width
        emailField.layer.addSublayer(border)
        emailField.layer.masksToBounds = true
        
        let border2 = CALayer()
        border2.borderColor = UIColor.silver().CGColor
        border2.frame = CGRect(x: 0, y: passwordField.frame.size.height - width, width: passwordField.frame.size.width, height: passwordField.frame.size.height)
        border2.borderWidth = width
        passwordField.layer.addSublayer(border2)
        passwordField.layer.masksToBounds = true
        
        let border3 = CALayer()
        border3.borderColor = UIColor.silver().CGColor
        border3.frame = CGRect(x: 0, y: confirmPasswordField.frame.size.height - width, width: confirmPasswordField.frame.size.width, height: confirmPasswordField.frame.size.height)
        border3.borderWidth = width
        confirmPasswordField.layer.addSublayer(border3)
        confirmPasswordField.layer.masksToBounds = true
        
        usernameField.autocapitalizationType = UITextAutocapitalizationType.None
        usernameField.autocorrectionType = .No
        emailField.autocapitalizationType = UITextAutocapitalizationType.None
        emailField.autocorrectionType = .No
        passwordField.autocapitalizationType = UITextAutocapitalizationType.None
        passwordField.autocorrectionType = .No
        confirmPasswordField.autocapitalizationType = UITextAutocapitalizationType.None
        confirmPasswordField.autocorrectionType = .No
        
        signUpButton.backgroundColor = UIColor.clouds()
        signUpButton.setTitle("S I G N U P", forState: UIControlState.Normal)
        signUpButton.setTitleColor(UIColor.asphalt(), forState: UIControlState.Normal)
        
        loginButton.setTitle("Already have an account? Login!", forState: UIControlState.Normal)
        loginButton.setTitleColor(UIColor.clouds(), forState: UIControlState.Normal)
        loginButton.titleLabel!.font = loginButton.titleLabel!.font.fontWithSize(14.0)
        
        invalidLabel.backgroundColor = UIColor.alizarin()
        invalidLabel.alpha = 0.8
        invalidLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightLight)
        invalidLabel.textColor = UIColor.whiteColor()
        invalidLabel.textAlignment = NSTextAlignment.Center
        invalidLabel.hidden = true
        
        signUpButton.addTarget(self, action: #selector(signUpClicked), forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.addTarget(self, action: #selector(loginClicked), forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(backgroundImage)
        view.addSubview(blur)
        view.addSubview(logo)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(confirmPasswordField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(invalidLabel)
    }
    
    func signUpClicked() {
        
        if usernameField.text == "" {
            invalidLabel.text = "Username is required"
            invalidLabel.hidden = false
        } else if emailField.text == "" {
            invalidLabel.text = "Email Address is required"
            invalidLabel.hidden = false
        } else if passwordField.text == "" {
            invalidLabel.text = "Password is required"
            invalidLabel.hidden = false
        } else if confirmPasswordField.text == "" {
            invalidLabel.text = "Please confirm password"
            invalidLabel.hidden = false
        } else if passwordField.text != confirmPasswordField.text {
            invalidLabel.text = "Passwords do not match"
            invalidLabel.hidden = false
        } else {
            // initialize a user object
            let newUser = PFUser()
        
            // set user properties
            newUser.username = usernameField.text
            newUser.email = emailField.text
            newUser.password = passwordField.text
        
            // call sign up function on the object
            newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Created a user")
                    let nav = UINavigationController(rootViewController: PostSignUpViewController())
                    nav.modalPresentationStyle = .FullScreen
                    nav.modalTransitionStyle = .CoverVertical
                    self.presentViewController(nav, animated: true, completion: nil)
                    User.currentUser()?.setObject(true, forKey: "newUser")

                } else {
                    print(error?.localizedDescription)
                    if error?.code == 202 {
                        self.invalidLabel.text = "Username is already taken"
                        self.invalidLabel.hidden = false
                    } else if error?.code == 203 {
                        self.invalidLabel.text = "Email is already taken"
                        self.invalidLabel.hidden = false
                    }
                }
            }
        }
    }
    
    func loginClicked() {
        let vc = LoginViewController()
        vc.modalPresentationStyle = .FullScreen
        vc.modalTransitionStyle = .CoverVertical
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

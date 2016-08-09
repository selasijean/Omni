//
//  LoginViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/6/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var backgroundImage = UIImageView()
    var blur = UIVisualEffectView()
    var logo = UIImageView()
    var usernameField = UITextField()
    var passwordField = UITextField()
    var loginButton = UIButton()
    var signUpButton = UIButton()
    var invalidLabel = UILabel()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        
        backgroundImage.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        
        logo.frame = CGRect(x: 148, y: 95, width: 80, height: 80)
        usernameField.frame = CGRect(x: 25, y: 220, width: 320, height: 30)
        passwordField.frame = CGRect(x: 25, y: 270, width: 320, height: 30)
        invalidLabel.frame = CGRect(x: 0, y: 320, width: 375, height: 40)
        signUpButton.frame = CGRect(x: 37, y: 567, width: 300, height: 30)
        loginButton.frame = CGRect(x: 0, y: 607, width: 375, height: 60)

        backgroundImage.image = UIImage(named: "background")
        logo.image = UIImage(named: "logo")
        
        
        
        let blurEffect = UIBlurEffect(style: .Dark)
        blur = UIVisualEffectView(effect: blurEffect)
        blur.alpha = 0.6
        blur.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        blur.userInteractionEnabled = true
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        blur.addGestureRecognizer(tapGestureRec)
        
        usernameField.textColor = UIColor.whiteColor()
        passwordField.textColor = UIColor.whiteColor()
        usernameField.attributedPlaceholder = NSAttributedString(string: "USERNAME", attributes: [NSForegroundColorAttributeName : UIColor.silver()])
        passwordField.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes: [NSForegroundColorAttributeName : UIColor.silver()])
        passwordField.secureTextEntry = true
        
        usernameField.font = usernameField.font?.fontWithSize(16.0)
        passwordField.font = passwordField.font?.fontWithSize(16.0)
        
        usernameField.alpha = 0.8
        passwordField.alpha = 0.8
        signUpButton.alpha = 0.8
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.silver().CGColor
        border.frame = CGRect(x: 0, y: usernameField.frame.size.height - width, width: usernameField.frame.size.width, height: usernameField.frame.size.height)
        border.borderWidth = width
        usernameField.layer.addSublayer(border)
        usernameField.layer.masksToBounds = true
        
        let border2 = CALayer()
        let width2 = CGFloat(1.0)
        border2.borderColor = UIColor.silver().CGColor
        border2.frame = CGRect(x: 0, y: passwordField.frame.size.height - width2, width: passwordField.frame.size.width, height: passwordField.frame.size.height)
        border2.borderWidth = width2
        passwordField.layer.addSublayer(border2)
        passwordField.layer.masksToBounds = true
        
        usernameField.autocapitalizationType = UITextAutocapitalizationType.None
        usernameField.autocorrectionType = .No
        passwordField.autocapitalizationType = UITextAutocapitalizationType.None
        passwordField.autocorrectionType = .No
        
        invalidLabel.backgroundColor = UIColor.alizarin()
        invalidLabel.alpha = 0.8
        invalidLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightLight)
        invalidLabel.textColor = UIColor.whiteColor()
        invalidLabel.font = invalidLabel.font.fontWithSize(14.0)
        invalidLabel.textAlignment = NSTextAlignment.Center
        invalidLabel.hidden = true
        
        loginButton.backgroundColor = UIColor.clouds()
        loginButton.setTitle("L O G I N", forState: UIControlState.Normal)
        loginButton.setTitleColor(UIColor.asphalt(), forState: UIControlState.Normal)
        
        signUpButton.setTitle("Don't have an account? Sign up!", forState: UIControlState.Normal)
        signUpButton.setTitleColor(UIColor.clouds(), forState: UIControlState.Normal)
        signUpButton.titleLabel!.font = signUpButton.titleLabel!.font.fontWithSize(14.0)
        
        loginButton.addTarget(self, action: #selector(loginClicked), forControlEvents: UIControlEvents.TouchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpClicked), forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(backgroundImage)
        view.addSubview(blur)
        view.addSubview(logo)
        view.addSubview(passwordField)
        view.addSubview(usernameField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(invalidLabel)
    }
    
    func loginClicked() {
        
        if usernameField.text == "" {
            invalidLabel.text = "Username is required"
            invalidLabel.hidden = false
        } else if passwordField.text == "" {
            invalidLabel.text = "Password is required"
            invalidLabel.hidden = false
        } else {
            PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!) { (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    print("Logged in successfully")
//                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                    self.presentViewController(LoadingViewController(), animated: true, completion: nil)
//                    appDelegate.window?.rootViewController = LoadingViewController() //appDelegate.tabBar!
//                    appDelegate.pullCurrentUserDataFromParse()
                    
//                    self.view.window!.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
//
//                    let nav = UINavigationController(rootViewController: PostSignUpViewController())
                    self.presentViewController(LoadingViewController(), animated: true, completion: nil)
                }
                if error?.code == 101 {
                    self.invalidLabel.text = "Username or password is invalid"
                    self.invalidLabel.hidden = false
                }
            }
        }
    }

    func signUpClicked() {
        let vc = SignUpViewController()
        
        vc.modalPresentationStyle = .FullScreen
        vc.modalTransitionStyle = .CoverVertical
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        loginButton.frame.origin.y = 607 - keyboardViewEndFrame.height

    }
    
    func keyboardWillHide(notification: NSNotification){
        UIView.animateWithDuration(3.0) { 
            self.loginButton.frame.origin.y = 607
        }
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
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

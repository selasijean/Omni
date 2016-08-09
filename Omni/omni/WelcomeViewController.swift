//
//  WelcomeViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/6/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    var logo = UIImageView()
    var backgroundImage = UIImageView()
    var blur = UIVisualEffectView()
    var titleLabel = UILabel()
    var loginButton = UIButton()
    var signUpButton = UIButton()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        
        backgroundImage.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
        logo.frame = CGRect(x: 148, y: 120, width: 80, height: 80)
        titleLabel.frame = CGRect(x: 61, y: 215, width: 253, height: 50)
        loginButton.frame = CGRect(x: 16, y: 552, width: 342, height: 40)
        signUpButton.frame = CGRect(x: 16, y: 600, width: 342, height: 40)
        
        backgroundImage.image = UIImage(named: "background")
        logo.image = UIImage(named: "logo")
        
        let blurEffect = UIBlurEffect(style: .Light)
        blur = UIVisualEffectView(effect: blurEffect)
        blur.alpha = 0.7
        blur.frame = CGRect(x: 16, y: 600, width: 342, height: 40)
        blur.layer.cornerRadius = 10.0
        blur.clipsToBounds = true
        
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "O M N I"
        titleLabel.textColor = UIColor.clouds()
        titleLabel.font = titleLabel.font.fontWithSize(40.0)
        
        loginButton.setTitle("L O G I N", forState: UIControlState.Normal)
        loginButton.titleLabel?.font = loginButton.titleLabel?.font.fontWithSize(17.0)
        loginButton.setTitleColor(UIColor.asphalt(), forState: UIControlState.Normal)
        loginButton.backgroundColor = UIColor.clouds()
        loginButton.layer.cornerRadius = 10.0
        
        signUpButton.setTitle("S I G N U P", forState: UIControlState.Normal)
        signUpButton.titleLabel?.font = signUpButton.titleLabel?.font.fontWithSize(17.0)
        signUpButton.setTitleColor(UIColor.clouds(), forState: UIControlState.Normal)
        signUpButton.layer.cornerRadius = 10.0
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.borderColor = UIColor.clouds().CGColor
        
        loginButton.addTarget(self, action: #selector(loginClicked), forControlEvents: UIControlEvents.TouchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpClicked), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backgroundImage)
        view.addSubview(logo)
        view.addSubview(titleLabel)
        view.addSubview(loginButton)
        view.addSubview(blur)
        view.addSubview(signUpButton)
    }

    func loginClicked() {
        let vc = LoginViewController()
        vc.modalPresentationStyle = .FullScreen
        vc.modalTransitionStyle = .CoverVertical
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func signUpClicked() {
        let vc = SignUpViewController()
        vc.modalPresentationStyle = .FullScreen
        vc.modalTransitionStyle = .CoverVertical
        self.presentViewController(vc, animated: true, completion: nil)
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

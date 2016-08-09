//
//  AppPolicyViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/29/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse

class AppPolicyViewController: UIViewController {
    
    var backgroundImage = UIImageView()
    var omniLabel = UILabel()
    var descriptionLabel = UILabel()
    var continueButton = UIButton()
    var image = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        
        view.backgroundColor = UIColor.asphalt()
        
        backgroundImage.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        omniLabel.frame = CGRect(x: 16, y: 104, width: 342, height: 80)
        descriptionLabel.frame = CGRect(x: 16, y: 173, width: 342, height: 90)
        continueButton.frame = CGRect(x: 72, y: 464, width: 230, height: 45)
        image.frame = CGRect(x: 112, y: 329, width: 150, height: 150)
        
        backgroundImage.image = UIImage(named: "background")
        
        omniLabel.text = "O M N I"
        omniLabel.textColor = UIColor.whiteColor()
        omniLabel.font = UIFont.systemFontOfSize(40.0, weight: UIFontWeightLight)
        omniLabel.textAlignment = NSTextAlignment.Center
        
        descriptionLabel.text = "Omni connects you with your neighbors, allowing you to reach out and ask for immediate help when needed. By continuing, you agree to not abuse this app and defeat its intended purpose."
        descriptionLabel.textColor = UIColor.silver()
        descriptionLabel.font = descriptionLabel.font.fontWithSize(14.0)
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        descriptionLabel.numberOfLines = 0
        
        continueButton.setTitle("Continue", forState: UIControlState.Normal)
        continueButton.titleLabel?.font = continueButton.titleLabel?.font.fontWithSize(16.0)
        continueButton.setTitleColor(UIColor.asphalt(), forState: UIControlState.Normal)
        continueButton.backgroundColor = UIColor.whiteColor()
        continueButton.layer.cornerRadius = 20.0
        
        image.image = UIImage(named: "bear")
        
        continueButton.addTarget(self, action: #selector(AppPolicyViewController.continueToHome), forControlEvents: .TouchUpInside)
        
        view.addSubview(backgroundImage)
        view.addSubview(omniLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(continueButton)
        view.addSubview(image)
    }

    func continueToHome() {
        User.currentUser()?.setObject(false, forKey: "newUser")
        User.currentUser()?.saveInBackground()
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


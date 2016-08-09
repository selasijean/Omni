//
//  NeighborhoodSettingsViewController.swift
//  omni
//
//  Created by Ming Horn on 7/12/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//


import UIKit
import Eureka
import Parse
import Material

class NeighborhoodSettingsViewController: FormViewController {
    
    //Get the current user
    var user: PFUser!
    var neighborhood: PFObject?
    var house: PFObject!
    var fromHomeSettings = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.currentUser()
        //self.neighborhood = user?.objectForKey("currentNeighborhood") as? PFObject
        
        //Set up navigation
        self.navigationItem.title = "Neighborhood Settings"
        self.navigationItem.titleLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
        self.navigationItem.titleLabel.textAlignment = .Left
        self.navigationItem.titleLabel.textColor = UIColor.clouds()
        
        //Set up the form
        tableView?.tintColor = UIColor.asphalt()
        
        form +++ Section("Neighborhood Details")
            <<< NameRow("neighborhoodName"){ row in
                row.title = "Title"
                row.placeholder = "Neighborhood Title"
            }
            <<< TextAreaRow("summary") { row in
                row.title = "Neighborhood Description"
                row.placeholder = "Describe your neighborhood"
            }

            +++ Section("Security Details")
            <<< PhoneRow("policeNum"){
                $0.title = "Local Police"
                $0.placeholder = "Local Police Phone Number"
            }
            <<< PhoneRow("hosNum") {
                $0.title = "Local Hospital"
                $0.placeholder = "Local Hospital Phone Number"
            }
            <<< PhoneRow("universityNum") {
                $0.title = "University Security"
                $0.placeholder = "University Security Phone Number"
            }
            <<< PhoneRow("neighborhoodSecurity") {
                $0.title = "Neighborhood Private Security"
                $0.placeholder = "Neighborhood Private Security Phone Number"
            }
            <<< ButtonRow() {
                $0.title = "Save"
                $0.onCellSelection({ (cell, row) in
                    saveEurekaInformation(self, object: self.neighborhood!, sender: nil, completion: {
                        if !self.fromHomeSettings {
                            joinNeighborhood(self.neighborhood!, house: self.house, user: self.user, completion: ({
                                let vc = UINavigationController(rootViewController: PostSignUpViewController())
                                self.presentViewController(vc, animated: true, completion: nil)
                            }))
                        } else {
                            AppDelegate.getAppDelegate().loadingVC.pullCurrentUserDataFromParse({
                                AppDelegate.getAppDelegate().loadingVC.getMenuVC().tableView.reloadData()
                            })
                        }
                    })
                })
            }
        
        getInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //Called in the completion block of the getHouses function
    func getInfo() {
        form.setValues(["neighborhoodName": neighborhood?.objectForKey("neighborhoodName"), "summary": neighborhood?.objectForKey("summary"), "policeNum": neighborhood?.objectForKey("policeNum"), "hosNum": neighborhood?.objectForKey("hosNum"), "universityNum": neighborhood?.objectForKey("universityNum"), "neighborhoodSecurity": neighborhood?.objectForKey("neighborhoodSecurity")])
        tableView?.reloadData()
        print("getting info")
    }
    
}



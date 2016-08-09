//
//  SelectListViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/11/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
import SwiftRequest

class SelectListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var listTableView = UITableView()
    var policeButton = UIButton()
    var instructionLabel = UILabel()
    
    let cellReuseIdentifier = "listNames"
    
    var user: User?
    // var neighborhoodMembersNumbers: [String]?
    // set a boolean whether the user wants to contact the neighborhood
    var lists = [[String: [String: String]]]() // total emergency contact lists
    var defaultNeighborsEmergencyContactList: [String: [String: String]]!
    var selectedLists: [String] = [] // keys of selected lists to contact
    var numbersToContact: [String] = [] // store all of the numbers from the selected lists
    
    let locationManager = CLLocationManager()
    var long: String = ""
    var lat: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        user = User.currentUser()
        
        self.navigationController?.navigationBarHidden = false
        
        if defaultNeighborsEmergencyContactList != nil {
            self.lists.append(defaultNeighborsEmergencyContactList)
        }
        
        if user?.objectForKey("lists") != nil {
            self.lists.appendContentsOf(user?.objectForKey("lists") as! [[String: [String: String]]])
        }
        
        listTableView.allowsMultipleSelection = true
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.registerClass(ListCell.self, forCellReuseIdentifier: "listNames")
        listTableView.rowHeight = 50
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        
        //Set up navigation
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(17.0, weight: UIFontWeightMedium)]
        navigationController?.navigationBar.tintColor = UIColor.asphalt()
        self.title = "Select Lists to Contact"
        let doneButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(SelectListViewController.doneSelecting))
        self.navigationItem.rightBarButtonItem = doneButton
        navigationController?.navigationBar.topItem!.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: #selector(SelectListViewController.doneSelecting))
        
        view.backgroundColor = UIColor.silver()
        listTableView.backgroundColor = UIColor.clouds()
        
        instructionLabel.frame = CGRect(x: 0, y: 64, width: 375, height: 55)
        listTableView.frame = CGRect(x: 0, y: 119, width: 375, height: UIScreen.mainScreen().bounds.size.height - 119)
        policeButton.frame = CGRect(x: 20, y: 543, width: 335, height: 53)
        
        instructionLabel.text = "Your current location will be shared when you click 'Next'"
        instructionLabel.textAlignment = NSTextAlignment.Center
        instructionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = UIColor.whiteColor()
        instructionLabel.backgroundColor = UIColor.emerald()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(EmergencyViewController.callPolice(_:)))
        policeButton.addGestureRecognizer(longPress)
        policeButton.setTitle("CALL THE POLICE", forState: UIControlState.Normal)
        policeButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        policeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        policeButton.backgroundColor = UIColor.asphalt()
        policeButton.layer.cornerRadius = 10.0
        
        policeButton.addTarget(self, action: #selector(callPolice), forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(instructionLabel)
        view.addSubview(listTableView)
        view.addSubview(policeButton)
    }
    
    func fillNumbersArray(selectedLists: [String]) {
        for list in lists {
            for (key, value) in list {
                if selectedLists.contains(key) {
                    print(key)
                    for (_, number) in value {
                        print(number)
                        numbersToContact.append("%2B1\(number)")
                    }
                }
            }
        }
    }
    
    func callPolice(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://6507963633")!)
        }
    }

    func doneSelecting() {
        print(selectedLists)
        
        if selectedLists.count == 0 {
            print("please select a list")
            instructionLabel.text = "Please select a list first"
            instructionLabel.backgroundColor = UIColor.alizarin()
            return
        }
        
        fillNumbersArray(selectedLists)
        SendTextsViewController().numbersToContact = self.numbersToContact
        
        let twilioSID = "AC9766ba47739f9da36b5246e7efca6399"
        let twilioSecret = "ffa991fd86c3fbe55c064c063a766248"
        
        let userFullName = User.currentUser()?.objectForKey("fullName")
        
        var possessive = String()
        if (User.currentUser()?.objectForKey("gender"))! as! String == "Male" {
            possessive = "His"
        } else {
            possessive = "Her"
        }
        
        let message = "\(userFullName!) hit the emergency button. \(possessive) current location: https://google.com/maps/place/\(lat),\(long)"
        
        for toNumber in numbersToContact {
            // Build the request
            let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
            request.HTTPMethod = "POST"
            request.HTTPBody = "From=%2B12132796664&To=\(toNumber)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
        
            // Build the completion block and send the request
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                print("Finished")
                if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    // Success
                    print("Response: \(responseDetails)")
                } else {
                    // Failure
                    print("Error: \(error)")
                }
            }).resume()
        }
        
        let vc = SendTextsViewController()
        vc.numbersToContact = self.numbersToContact
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ListCell
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clouds()
        cell.tintColor = UIColor.alizarin()
        
        let key = Array(lists[indexPath.row].keys)
        
        cell.descriptionLabel.text = key[0]
        
        if cell.selected {
            cell.selected = false
            if cell.accessoryType == UITableViewCellAccessoryType.None {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell!.selected {
            cell!.selected = false
            let listAtCell = Array(lists[indexPath.row].keys)[0] // key string
            if cell!.accessoryType == UITableViewCellAccessoryType.None {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
                selectedLists.append(listAtCell)
                print("appended: \(listAtCell)")
                print("size of selected array: \(selectedLists.count)")
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.None
                let index = selectedLists.indexOf(listAtCell)
                selectedLists.removeAtIndex(index!)
                print("removed: \(listAtCell)")
                print("size of selected array: \(selectedLists.count)")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue: CLLocationCoordinate2D?
        if let _ = manager.location?.coordinate {
            locValue = manager.location?.coordinate
            
            lat = String(format: "%.3f", locValue!.latitude)
            long = String(format: "%.3f", locValue!.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location:" + error.localizedDescription)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        
    }
}

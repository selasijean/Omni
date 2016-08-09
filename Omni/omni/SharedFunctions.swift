//
//  SharedFunctions.swift
//  omni
//
//  Created by Sarah Zhou on 7/19/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import SwiftRequest
import UIKit
import Parse
import ParseUI
import GoogleMaps
import Eureka
import Spring

public func checkNetwork(view: UIView) {
    let error = NetworkConnectionError(frame: CGRect(x: 0, y: 0, width: 375, height: 60))
    
    error.hidden = true
    
    if !Reachability.isConnectedToNetwork() {
        error.hidden = false
        error.animation = "slideDown"
        error.curve = "easeIn"
        error.duration = 2.0
        error.animate()
    }
    
    view.addSubview(error)
}

public func moreInfoPopup(view: UIView) {
    
    let moreInfo = EmergencyInfo(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 554))
    
    moreInfo.animation = "fadeIn"
    moreInfo.curve = "easeIn"
    moreInfo.duration = 2.0
    moreInfo.animate()
    
    view.addSubview(moreInfo)
}

public func showCheckmark(sender: UIButton) -> UIImageView {
    
    let checkmark = UIImageView(image: UIImage(named: "checkmark"))
    checkmark.frame = CGRect(x: sender.frame.origin.x + sender.frame.width - 10, y: sender.frame.origin.y - 10, width: 22, height: 22)
    
    return checkmark
}

// Saves all form fields in a Eureka form except for the multi-select field because it is a Set instead of a string
// @param formController: the form controller whose form you're accessing
// @param object: the PFObject that you're saving the data to on Parse
// @param sender: option field that is used for the save button on the PostSignUpViewController to dismiss the page

public func saveEurekaInformation(formController: FormViewController, object: PFObject, sender: UIBarButtonItem?, completion: (() -> ())?) {
    let form = formController.form
    let values = form.values()
    
    //Eureka returns multiple select rows as sets to save to parse it's converted to a NSArray
    //medBool lets us query for users who have medical training
    let medInfo = form.rowByTag("med")?.baseValue as? Set<String>
    var medArr = [String]()
    var medBool: Bool! = false
    if medInfo != nil {
        medBool = true
        
        for item in medInfo! {
            medArr.append(item)
        }
        
    }
    
    // Saves the values of each row to the object
    for (key, value) in values {
        if form.rowByTag(key)?.baseValue != nil && key != "med" && key != "profilePic"{
            object.setObject(value as! String, forKey: key)
        }
        
        if key == "med" {
            if medBool == true {
                object.setObject(medArr, forKey: "med")
            }
        }
        
        if key == "profilePic" {
            let pic = getPFFileFromImage(value as? UIImage)
            object.setObject(pic!, forKey: "profilePic")
        }
    }
    
    object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
        if success {
            if completion != nil {
                completion!()
            }
            // Dismisses the view if sent by the Save button
            if sender != nil {
                let vc = LoadingViewController()
                vc.newUser = true
                formController.presentViewController(vc, animated: true, completion: nil)

            }
        } else {
            print(error?.localizedDescription)
        }
    })
}

// Converts a UIImage to a PFFile so that Parse can save and display it
public func getPFFileFromImage(image: UIImage?) -> PFFile? {
    // check if image is not nil
    if let image = image {
        // get image data and check if that is not nil
        if let imageData = UIImagePNGRepresentation(image) {
            return PFFile(name: "image.png", data: imageData)
        }
    }
    return nil
}


// Adds the user to the array of users in neighborhood, sets the neighborhood id in house, and adds the house id to the user's houses array
public func joinNeighborhood(neighborhood: PFObject, house: PFObject, user: PFObject, completion: (() -> ())?) {
    neighborhood.addObject(user.objectId!, forKey: "users")
    house.setObject(neighborhood.objectId!, forKey: "neighborhood")
    user.addObject(house.objectId!, forKey: "houses")
    user.addObject(neighborhood.objectId!, forKey: "neighborhoods")
    user.setObject(neighborhood.objectId!, forKey: "currentNeighborhood")
    var callbackCount = 0 {
        didSet {
            if callbackCount == 3 && completion != nil {
                completion!()
            }
        }
    }
    
    neighborhood.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
        if (error == nil) {
            callbackCount += 1
        }
    }
    house.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
        if error == nil {
            callbackCount += 1
        }
    }
    user.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
        if error == nil {
            callbackCount += 1
        }
    }
    
    
}
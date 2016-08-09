//
//  House.swift
//  omni
//
//  Created by Sarah Zhou on 7/7/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse

class House: NSObject {
    
    var parseHouseObject: PFObject!{
        didSet{
            neighborhoodID = parseHouseObject["neighborhood"] as? String
            address = parseHouseObject["address"] as? String
            let pfGeoPoint = parseHouseObject["coords"] as! PFGeoPoint
            coordinates = CLLocationCoordinate2D(latitude: pfGeoPoint.latitude, longitude: pfGeoPoint.longitude)
        }
    }
    var neighborhoodID: String?
    var bio: String?
    var address: String?
    var coordinates: CLLocationCoordinate2D?
    
    init(parseObject: PFObject){
        super.init()
        ({self.parseHouseObject = parseObject})()
    }

    
    class func createHouse(coords: CLLocationCoordinate2D, address: String?, completion: (() -> Void)?) {
        let newHouse = PFObject(className: "House")
        let lat = coords.latitude
        let long = coords.longitude
        
        newHouse["address"] = address
        newHouse["coords"] = PFGeoPoint(latitude: lat, longitude: long)
        newHouse["userCreator"] = User.currentUser()?.username
        
        newHouse.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) in
            if success {
                if completion != nil {
                    completion!()
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
}

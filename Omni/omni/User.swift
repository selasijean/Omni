//
//  User.swift
//  omni
//
//  Created by Sarah Zhou on 7/7/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse

class User: PFUser {
    
    override class func initialize() {
        self.registerSubclass()
    }
    
    class func markUserAsSafe(){
        User.currentUser()?.setObject(true, forKey: "safe")
        User.currentUser()?.saveInBackground()
    }
    
    class func markUserAsUnSafe(){
        User.currentUser()?.setObject(false, forKey: "safe")
        User.currentUser()?.saveInBackground()
    }
}

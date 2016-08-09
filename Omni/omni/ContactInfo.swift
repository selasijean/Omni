//
//  ContactInfo.swift
//  omni
//
//  Created by Sarah Zhou on 7/7/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse

class Contact: NSObject {
    
    var name: String!
    var email: String?
    var phoneNumber: String?
    
    init(title: String, number: String){
        name = title
        phoneNumber = number
    }
}

//
//  Person.swift
//  omni
//
//  Created by Sarah Zhou on 7/7/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse

class Person: NSObject {
    
    var userID: String?
    var name: String?
    var profilePic: PFFile?
//    var contactInfo: ContactInfo?
    var birthday: NSDate?
    var neighborhoods: [String]?
    var houses: [String]?
    var currentNeighborhood: String? {
        didSet {
            
        }
    }
    var currentNeighborhoodName: String?
    
    init(dictionary: NSDictionary) {
        if userID != nil {
            //self.getUser(userID!)
        }
    }
    
//    func getAge(birthday: NSDate) -> Int {
//        return NSCalendar.currentCalendar().component(NSCalendarUnit.NSYearCalendarUnit, fromDate: birthday)
//    }
//    
//    func getUser(userID: String) -> User {
//        var user: User
//        return user
//    }
}

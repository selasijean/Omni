//
//  Neighbor.swift
//  omni
//
//  Created by Jean Adedze on 7/20/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse

class Neighbor: NSObject {
    
    var neighborPFObject: PFObject!{
        didSet{
            name = neighborPFObject["fullName"] as? String
            bio = neighborPFObject["bio"] as? String
            mobileNum = neighborPFObject["cellNum"] as? String
            workNum = neighborPFObject["workNum"] as? String
            medTraining = neighborPFObject["med"] as? [String]
            gender = neighborPFObject["gender"] as? String
            profilePic = neighborPFObject["profilePic"] as? PFFile
            email = neighborPFObject["email"] as? String
            if let status = neighborPFObject["safe"] as? Bool{
                safe = status
            }
        }
    }

    var name:String?
    var bio: String?
    var gender: String?
    var profilePic: PFFile?
    var mobileNum: String?
    var workNum: String?
    var email: String?
    var medTraining: [String]?
    var safe: Bool?
    
    init(neighbor: PFObject){
        super.init()
        ({neighborPFObject = neighbor})()
    }
    
    func isDoctor() -> Bool{
        return (medTraining?.contains("Doctor"))!
    }
    
    func isSurgeon() -> Bool{
        return (medTraining?.contains("Surgeon"))!
    }
    
    func isNurse() -> Bool{
        return (medTraining?.contains("Nurse"))!
    }
    
    func isEMT() -> Bool{
        return (medTraining?.contains("EMT"))!
    }
    
    func isVeterinarian() -> Bool{
        return (medTraining?.contains("Veterinarian"))!
    }
    
    func isLifeGuard() -> Bool{
        return (medTraining?.contains("Lifeguard"))!
    }
    
    func isCPR() -> Bool{
        return (medTraining?.contains("CPR"))!
    }
    
    func isAED() -> Bool{
        return (medTraining?.contains("AED"))!
    }
    
    func isFirstAid() -> Bool{
        return (medTraining?.contains("First Aid"))!
    }
    
    func isSafe(neighborhood: Neighborhood) -> Bool{
        let id = neighborPFObject.objectId
        if neighborhood.safeNeighbors.contains(id!){
            return true
        }
        return false
    }
    
    func isUnsafe(neighborhood: Neighborhood) -> Bool{
        let id = neighborPFObject.objectId
        if neighborhood.unsafeNeighbors.contains(id!){
            return true
        }
        return false
    }
    
}

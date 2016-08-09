//
//  Neighborhood.swift
//  
//
//  Created by Sarah Zhou on 7/6/16.
//
//

import UIKit
import Parse
import GoogleMaps

class Neighborhood: NSObject {
    
    
    var neighborhoodParseObject: PFObject! {
        didSet{
            title = neighborhoodParseObject["neighborhoodName"] as? String
            bio = neighborhoodParseObject["summary"] as? String
            neighborhoodID = neighborhoodParseObject.objectId
            let neighborhoodPFPath = neighborhoodParseObject["pathCoordinates"] as! [PFGeoPoint]
            let neighborhoodMutablePath = NeighborhoodRegion.convertArrayOfPfGeoPointsToGMSMutablePath(neighborhoodPFPath)
            neighborhoodPolygon = GMSPolygon(path: neighborhoodMutablePath)
            if let policeNum = neighborhoodParseObject["policeNum"] as? String{
                police = Contact(title: "Local Police", number: policeNum)
                arrayOfContacts.append(police!)
            }
            if let hosNum = neighborhoodParseObject["hosNum"] as? String{
                hospital = Contact(title: "Local Hospital", number: hosNum)
                arrayOfContacts.append(hospital!)
            }
            if let uniNum = neighborhoodParseObject["universityNum"] as? String{
                university = Contact(title: "University Security", number: uniNum)
                arrayOfContacts.append(university!)
            }
            if let naySec = neighborhoodParseObject["neighborhoodSecurity"] as? String{
                neighborHoodSecurity = Contact(title: "Neighborhood Private Security", number: naySec)
                arrayOfContacts.append(neighborHoodSecurity!)
            }
            
            if let stateOfEmergency = neighborhoodParseObject["isInStateOfEmergency"] as? Bool{
                isInAStateOfEmergency = stateOfEmergency
            }else{
                isInAStateOfEmergency = false
                neighborhoodParseObject.setObject(false, forKey: "isInStateOfEmergency")
                neighborhoodParseObject.saveInBackground()
            }
            
            if let description = neighborhoodParseObject["stateOfEmergencyDescription"] as? String{
                stateOfEmergencyDescription = description
            }else{
                neighborhoodParseObject.setObject("", forKey: "stateOfEmergencyDescription")
                neighborhoodParseObject.saveInBackground()
            }
            if let safePersons = neighborhoodParseObject["safeNeighbors"] as? [String] {
                safeNeighbors = safePersons
            }else{
                neighborhoodParseObject.setObject([], forKey: "safeNeighbors")
                neighborhoodParseObject.saveInBackground()
            }
            if let unsafePersons = neighborhoodParseObject["unsafeNeighbors"] as? [String]{
                unsafeNeighbors = unsafePersons
            }else{
                neighborhoodParseObject.setObject([], forKey: "unsafeNeighbors")
                neighborhoodParseObject.saveInBackground()
            }
        }
    }
    
    var currentUserID = (User.currentUser()?.objectId)!
    var neighborhoodPolygon: GMSPolygon!
    var neighborhoodID: String?
    var title: String?
    var bio: String?
    var police: Contact?
    var hospital: Contact?
    var neighborHoodSecurity: Contact?
    var university: Contact?
    var houses: [House]?
    var arrayOfContacts:[Contact] = []
    var isInAStateOfEmergency: Bool!
    var stateOfEmergencyDescription: String?
    var safeNeighbors: [String] = []
    var unsafeNeighbors: [String] = []
    
    init(parseObject: PFObject) {
        super.init()
        ({neighborhoodParseObject = parseObject})()
    }
    
    func declareStateOfEmergency(emergencyDescription description: String){
        isInAStateOfEmergency = true
        stateOfEmergencyDescription = description
        neighborhoodParseObject["isInStateOfEmergency"] = isInAStateOfEmergency
        neighborhoodParseObject["stateOfEmergencyDescription"] = stateOfEmergencyDescription!
        neighborhoodParseObject.saveInBackground()
    }
    
    func turnOffStateOfEmergency(){
        isInAStateOfEmergency = false
        stateOfEmergencyDescription = ""
        safeNeighbors = []
        unsafeNeighbors = []
        neighborhoodParseObject["isInStateOfEmergency"] = isInAStateOfEmergency
        neighborhoodParseObject["stateOfEmergencyDescription"] = stateOfEmergencyDescription!
        neighborhoodParseObject["safeNeighbors"] = safeNeighbors
        neighborhoodParseObject["unsafeNeighbors"] = safeNeighbors
        User.currentUser()?.setObject(NSNull(), forKey: "safe")
        neighborhoodParseObject.saveInBackground()
        User.currentUser()?.saveInBackground()
    }
    
    func updateNeighborhoodData(completion: ()->()){
        neighborhoodParseObject.fetchInBackgroundWithBlock { (update: PFObject?, error: NSError?) in
            if error == nil{
                ({self.neighborhoodParseObject = update})()
                completion()
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    func markUserAsSafe(){
        updateNeighborhoodData { 
            self.neighborhoodParseObject.removeObject(self.currentUserID, forKey:"unsafeNeighbors")
            self.neighborhoodParseObject.addObject(self.currentUserID, forKey: "safeNeighbors")
            self.neighborhoodParseObject.saveInBackground()
        }
        
    }
    
    func markUserAsUnsafe(){
        updateNeighborhoodData { 
            self.neighborhoodParseObject.removeObject(self.currentUserID, forKey: "safeNeighbors")
            self.neighborhoodParseObject.addObject(self.currentUserID, forKey: "unsafeNeighbors")
            self.neighborhoodParseObject.saveInBackground()
        }
        
    }
    
    func listOfSafeNeighbors(neighbors: [Neighbor]) -> [Neighbor]{
        let safePersons = neighbors.filter({ (person: Neighbor) -> Bool in
            person.isSafe(self)
        })
        return safePersons
    }
    
    func listOfUnsafeNeighbors(neighbors: [Neighbor]) -> [Neighbor]{
        let unsafePersons = neighbors.filter({ (person: Neighbor) -> Bool in
            person.isUnsafe(self)
        })
        return unsafePersons
    }
    
    func listOfUnaccountedNeighbors(neighbors: [Neighbor]) -> [Neighbor]{
        let unaccounted = neighbors.filter({ (person: Neighbor) -> Bool in
            if !person.isSafe(self) && !person.isUnsafe(self){
                return true
            }
            return false
        })
        return unaccounted
    }
}

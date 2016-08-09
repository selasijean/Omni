//
//  NeighborhoodRegion.swift
//  omni
//
//  Created by Jean Adedze on 7/8/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//


import UIKit
import Parse
import GoogleMaps

class NeighborhoodRegion: NSObject {
    
    class func saveNeighborHoodPathCoordinates(path: GMSMutablePath, object:(PFObject) ->(), failure: (NSError?) -> ()){
        
        let neighborhood = PFObject(className: "Neighborhoods")
        let arrayOfPFGeoPoints = convertToArrayOfGeoPoints(path)
        neighborhood["pathCoordinates"] = arrayOfPFGeoPoints
        //neighhorhood["houses"] =[User.currentUser()?]
        neighborhood.saveInBackgroundWithBlock { (success:Bool, error: NSError?) in
            if success{
                print(neighborhood.objectId)
                object(neighborhood)
            }else{
                failure(error)
//                print(error?.localizedDescription)
            }
        }
        //neighborhood.saveInBackgroundWithBlock(completion)
//        success(neighborhood)
    }
    
    
    class func convertToArrayOfGeoPoints(path: GMSPath) -> [PFGeoPoint]{
        var arrayOfPFGeoPoints = [PFGeoPoint]()
        let length = path.count()
        for i in 0 ..< length {
            let coordinate = path.coordinateAtIndex(i)
            let pfGeoPoint = convertToPFGeoPoint(coordinate)
            arrayOfPFGeoPoints.append(pfGeoPoint)
        }
        return arrayOfPFGeoPoints
    }
    
    //convert GMSPath/GMSMutablePath to an array of CLLocationCoordinate2D
    class func convertGMSPathToArrayOfCoordinates(path: GMSPath) -> [CLLocationCoordinate2D]{
        var array = [CLLocationCoordinate2D]()
        let length = path.count()
        for i in 0 ..< length {
            let coordinate = path.coordinateAtIndex(i)
            array.append(coordinate)
        }
        return array
    }
    
    //convert an array of CLLocationCoordinate2D to a GMSPath
    
    class func convertArrayOfCoordinatesToGMSPath(array:[CLLocationCoordinate2D]) ->GMSPath {
        let path = GMSMutablePath()
        for coordinate in array{
            path.addCoordinate(coordinate)
        }
        return path
    }
    
    
    //convert CLLocationCoordinate to PFGeoPoint
    class func convertToPFGeoPoint(coordinate: CLLocationCoordinate2D) -> PFGeoPoint{
        let pfGeoPoint = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return pfGeoPoint
    }
    //convert  PFGeoPoints to GMSMutablePath
    class func convertArrayOfPfGeoPointsToGMSMutablePath(arrayOfPfGeoPoints: [PFGeoPoint]) -> GMSMutablePath{
        
        let mutablePath = GMSMutablePath()
        for geoPoint in arrayOfPfGeoPoints{
            let cllocationCoordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            mutablePath.addCoordinate(cllocationCoordinate)
        }
        return mutablePath
    }
    
    class func convertMutablePathToGMSPolygon(path: GMSMutablePath) -> GMSPolygon {
        return GMSPolygon(path: path)
    }
    
    class func convertArrayOFGMSPathsToArrayOfGMSPolygons(arrayOfMutablePath paths: [GMSMutablePath]) -> [GMSPolygon]{
        var array = [GMSPolygon]()
        for path in paths{
            let polygon = GMSPolygon(path: path)
            array.append(polygon)
        }
        return array
    }
    
    class func convertArrayOfArrayOfPfGeoPointsToArrayOfGMSMutablePaths(arrayOfArrayOfPFGeoPoints arrays :[[PFGeoPoint]]) -> [GMSMutablePath]{
        var arrayOfMutablePaths = [GMSMutablePath]()
        for array in arrays{
            let convert = convertArrayOfPfGeoPointsToGMSMutablePath(array)
            arrayOfMutablePaths.append(convert)
        }
        return arrayOfMutablePaths
    }
    
    
    
}

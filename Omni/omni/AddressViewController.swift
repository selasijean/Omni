//
//  AddressViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/6/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import Spring


class AddressViewController: UIViewController, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var mapView = GMSMapView()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var existingNeighborhoods = [GMSPolygon]()
    
    var inNeighborhood: Bool!
    
    //House marker and house object pulled from queryLastHouse
    var newHouse: GMSMarker!
    var newHouse2: PFObject!
    
    //The neighborhood that is passed to JoinNeighborhood if their house is in an existing neighborhood
    var neighborhood: [String: GMSPolygon]?
    
    //Dictionary of neighborhoods
    var dict = [String: GMSPolygon]()
    
    //Creates a dictionary with the GMSPolygon and id of each neighborhood and fills existingNeighborhoods with the polygons to draw easier
    var neighborhoodObjects: [PFObject]? {
        didSet {
            if let neighborhoodObjects = neighborhoodObjects {
                for obj in neighborhoodObjects {
                    let path = NeighborhoodRegion.convertArrayOfPfGeoPointsToGMSMutablePath(obj["pathCoordinates"] as! [PFGeoPoint])
                    let gmsPolygon = NeighborhoodRegion.convertMutablePathToGMSPolygon(path)
                    existingNeighborhoods.append(gmsPolygon)
                    dict.updateValue(gmsPolygon, forKey: obj.objectId!)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queryForNeighborhoods()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView = GMSMapView(frame: CGRectZero)
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        self.view = mapView
        
        checkAuthorization()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
        //add done button to navigation bar
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(doneWithAddress))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doneWithAddress() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Queries and draws all the existing neighborhoods so the user can see them
    func queryForNeighborhoods() {
        let query = PFQuery(className: "Neighborhoods")
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (neighborhoods: [PFObject]?, error: NSError?) -> Void in
            print("begun querying")
            if let neighborhoods = neighborhoods {
                self.neighborhoodObjects = neighborhoods
                self.showExistingNeighborhoods()
                
            } else {
                // handle error
                print(error?.localizedDescription)
            }
        }
    }
    
    //Draws saved neighborhoods after getting data from Parse
    func showExistingNeighborhoods() {
        for polygon in existingNeighborhoods {
            polygon.fillColor = UIColor.randomColor()
            polygon.map = mapView
        }
    }
    
    //Checks whether or not a House is within an existing neighborhood
    func overlapWithExistingNeighborhoods() -> Void {
        for (id, neighborhood) in dict {
            let coordinate = newHouse.position
            if GMSGeometryContainsLocation(coordinate, neighborhood.path!, true){
                self.inNeighborhood = true
                self.neighborhood = [id: neighborhood]
            }
        }
        if self.inNeighborhood != true {
            self.inNeighborhood = false
        }
    }
    
    //Gets the last created house and saves it to newHouse2
    func queryLastHouse() {
        let user = User.currentUser()?.username
        let query = PFQuery(className: "House")
        query.whereKey("userCreator", equalTo: user!)
        query.orderByDescending("createdAt")
        query.limit = 1
        
        query.findObjectsInBackgroundWithBlock { (house: [PFObject]?, error: NSError?) in
            if let house = house {
                self.newHouse2 = house[0]
                self.goToNeighborhood()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
//1
extension AddressViewController: CLLocationManagerDelegate {
    
    // 2
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 3
        if status == .AuthorizedWhenInUse {
            // 4
            locationManager.startUpdatingLocation()
            //5
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    // 6
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            // 7
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            print(location.coordinate)
            // 8
            locationManager.stopUpdatingLocation()
        }
    }
    
    func checkAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .AuthorizedWhenInUse {
            // 4
            locationManager.startUpdatingLocation()
            
            //5
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
}

// Handle the user's selection.
extension AddressViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        let pos = place.coordinate
        let marker = GMSMarker(position: pos)
        marker.title = place.formattedAddress
        marker.snippet = "Tap window to set as home or enter new address into search to choose a different address."
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
        mapView.selectedMarker = marker
        mapView.camera = GMSCameraPosition(target: pos, zoom: 15, bearing: 0, viewingAngle: 0)
    }
    
    //On tap, it sets the user's address and posts it and then segues back to the PostSignUpViewController
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        House.createHouse(marker.position, address: marker.title, completion: { () in
            self.newHouse = marker
            self.overlapWithExistingNeighborhoods()
            self.queryLastHouse()
        })
        
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    //This used to query all the houses then choose the first object because it was in order by last created. Now it needs to just get the house from this page, maybe call this in the completion block of saveInBackground
    func goToNeighborhood() {
        if (inNeighborhood != false) {
            let vc = JoinNeighborhoodViewController()
            vc.house = newHouse2
            vc.neighborhoodObject = self.neighborhood!
            
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
            let vc = SetNeighborhoodViewController()
            vc.house = newHouse2
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}

//
//  JoinNeighborhoodViewController.swift
//  omni
//
//  Created by Jean Adedze on 7/13/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse

class JoinNeighborhoodViewController: UIViewController {
    
    var homeAddressCoordinate:CLLocationCoordinate2D!
    
    var pinIcon = UIImageView()
    var popupView = UIView()
    var nameLabel = UILabel()
    var descriptionLabel = UILabel()
    var joinNeighborhoodButton = UIButton()
    var mapView = GMSMapView()
    var dismissViewButton = UIButton()
    var house: PFObject!
    var id: String!

    var neighborhoodObject: [String: GMSPolygon]? {
        didSet {
            print(neighborhoodObject)
            for (id, polygon) in neighborhoodObject! {
                showNeighborhood(polygon)
                self.id = id
            }
        }
    }

    var user: PFUser!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User.currentUser()
        
        view.backgroundColor = UIColor.whiteColor()
        
        pinIcon.image = UIImage(named: "pin")
        pinIcon.layer.cornerRadius = 35
        pinIcon.layer.borderWidth = 3.0
        pinIcon.layer.borderColor = UIColor.whiteColor().CGColor
        
        popupView.backgroundColor = UIColor.whiteColor()
        popupView.layer.cornerRadius = 20.0
        popupView.clipsToBounds = true
        
        _ = PFQuery(className: "Neighborhoods").getObjectInBackgroundWithId(id) { (hood: PFObject?, error: NSError?) in
            if let hood = hood {
                self.nameLabel.text = hood.objectForKey("neighborhoodName") as? String
                self.descriptionLabel.text = hood.objectForKey("summary") as? String
            }
        }
        
        nameLabel.textColor = UIColor.asphalt()
        nameLabel.font = UIFont.systemFontOfSize(20.0, weight: UIFontWeightBold)
        nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        nameLabel.numberOfLines = 0
        nameLabel.sizeToFit()
        
        descriptionLabel.textColor = UIColor.charcoal()
        descriptionLabel.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightLight)
        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        
        joinNeighborhoodButton.backgroundColor = UIColor.emerald()
        joinNeighborhoodButton.setTitle("Join", forState: UIControlState.Normal)
        joinNeighborhoodButton.titleLabel?.textColor = UIColor.whiteColor()
        joinNeighborhoodButton.addTarget(self, action: #selector(joinNeighborhoodButtonFunc), forControlEvents: .TouchUpInside)

        popupView.frame = CGRect(x: 20, y: UIScreen.mainScreen().bounds.size.height - 182, width: UIScreen.mainScreen().bounds.size.width - 40, height: 162)
        
        pinIcon.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width/2 - 35, y: popupView.frame.origin.y - 35, width: 70, height: 70)
        
        nameLabel.frame = CGRect(x: 16, y: 40, width: 300, height: 30)
        descriptionLabel.frame = CGRect(x: 16, y: 72, width: 300, height: 30)
        joinNeighborhoodButton.frame = CGRect(x: 0, y: popupView.frame.height - 50, width: UIScreen.mainScreen().bounds.size.width - 40, height: 50)
        
        mapView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        
        //setting mapView
        let coords = house.objectForKey("coords") as! PFGeoPoint
        let clCoords = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
        mapView.camera = GMSCameraPosition(target: clCoords, zoom: 16.0, bearing: 0, viewingAngle: 0)
        let marker = GMSMarker(position: clCoords)
        marker.icon = UIImage(named: "homePin")
        marker.map = mapView
        mapView.settings.scrollGestures = false
        
        let frameForDismissButton = CGRectMake(UIScreen.mainScreen().bounds.size.width - 44, 30, 30, 30)
        dismissViewButton.frame = frameForDismissButton
        dismissViewButton.setImage(UIImage(named: "cancel"), forState: .Normal)
        dismissViewButton.addTarget(self, action: #selector(didTapDismissViewButton), forControlEvents: .TouchUpInside)
        
        //adding objects to view 
        view.addSubview(mapView)
        popupView.addSubview(nameLabel)
        popupView.addSubview(descriptionLabel)
        popupView.addSubview(joinNeighborhoodButton)
        view.addSubview(popupView)
        view.addSubview(pinIcon)
        view.addSubview(dismissViewButton)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Draws neighborhood after getting data from Parse
    func showNeighborhood(polygon: GMSPolygon){
        polygon.fillColor = UIColor.randomColor()
        polygon.map = mapView
    }
    
    
    //Joins Neighborhood
    func joinNeighborhoodButtonFunc() {
        let user = User.currentUser()
        PFQuery(className: "Neighborhoods").getObjectInBackgroundWithId(self.id) { (neighborhood: PFObject?, error: NSError?) in
            if let neighborhood = neighborhood {
                joinNeighborhood(neighborhood, house: self.house, user: user!, completion: { 
                    let vc = UINavigationController(rootViewController: PostSignUpViewController())
                    self.presentViewController(vc, animated: true, completion: nil)
                })
            } else {
                print(error?.localizedDescription)
            }
        }

    }
    
    func didTapDismissViewButton(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

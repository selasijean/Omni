//
//  SetNeighborhoodViewController.swift
//
//
//  Created by Sarah Zhou on 7/6/16.
//
//

import UIKit
import GoogleMaps
import Parse
import Material
class SetNeighborhoodViewController: UIViewController, GMSMapViewDelegate, UIGestureRecognizerDelegate {
    
    var neighborhoodsFromParse:[[PFGeoPoint]]?{
        didSet {
            if let neighborhoodsFromParse = neighborhoodsFromParse{
                let arrayOfMutablePaths = NeighborhoodRegion.convertArrayOfArrayOfPfGeoPointsToArrayOfGMSMutablePaths(arrayOfArrayOfPFGeoPoints: neighborhoodsFromParse)
                existingNeighborhoods = NeighborhoodRegion.convertArrayOFGMSPathsToArrayOfGMSPolygons(arrayOfMutablePath: arrayOfMutablePaths)
            }
            
        }
    }
    
    var drawnNeighborhood: GMSPolygon!
    var existingNeighborhoods = [GMSPolygon]()
    var hoodPathForPointMarkers = GMSMutablePath()
    var mapView: GMSMapView!
    var createPolygonEnabled = false
    var coordinatesOnTap:CLLocationCoordinate2D!
    var marker = GMSMarker()
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var lockMode = false
    var arrayOfSketchedMarkers = [GMSMarker]()
    var house: PFObject!
    
    var currentNeighborhood: String!
    
    //buttons and switches
    var createNeighborHoodButton = UIButton()
    var nextButton = UIButton()
    var deleteSketchButton = UIButton()
    var continueButton = UIButton()
    var undoButton = UIButton()
    var lockSwitch = UISwitch()
    var dismissViewButton = UIButton()
    var instructionButton = UIButton()
    
    var instructionView = UIView()
    var blur = UIVisualEffectView()
    var reminderLabel = UILabel()
    var fillInInstructionLabel = UILabel()
    var fillInScreenArrow = UIImageView()
    var undoInstructionLabel = UILabel()
    var undoArrow = UIImageView()
    var lockScreenInstructionLabel = UILabel()
    var lockScreenArrow = UIImageView()
    var tapToContinueLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        //setting mapView
        let frame = CGRectMake(0,0, 375, 667)
        mapView = GMSMapView(frame: frame)
        let houseCoords = house.objectForKey("coords") as! PFGeoPoint
        let clCoords = CLLocationCoordinate2D(latitude: houseCoords.latitude, longitude: houseCoords.longitude)
        mapView.camera = GMSCameraPosition(target: clCoords, zoom: 16.0, bearing: 0, viewingAngle: 0)
        mapView.delegate = self
        mapView.settings.compassButton = true
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.mapType = kGMSTypeHybrid
        view.addSubview(mapView)
        let gestureRec = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        gestureRec.delegate = self
        gestureRec.maximumNumberOfTouches = 1
        //mapView.userInteractionEnabled = true
        mapView.addGestureRecognizer(gestureRec)
        
        //defining frames for various buttons
        let frameForNextButton = CGRectMake(0, 613, 375, 54)
        let frameForDeleteSketchButton = CGRectMake(68, 596, 58, 58)
        let frameForContinueButton = CGRectMake(243, 596, 58, 58)
        
        let frameForLockSwitch = CGRectMake(311, 118, 0, 0)
        let frameForCreateNeighborHoodButton = CGRectMake(311, 174, 50, 50)
        let frameForUndoButton = CGRectMake(311, 232, 50, 50)
        
        let frameForInstructionButton = CGRectMake(14, 30, 30, 30)
        let frameForDismissButton = CGRectMake(UIScreen.mainScreen().bounds.size.width - 44, 30, 30, 30)
        
        //setting frames for buttons
        nextButton.frame = frameForNextButton
        deleteSketchButton.frame = frameForDeleteSketchButton
        continueButton.frame = frameForContinueButton
        createNeighborHoodButton.frame = frameForCreateNeighborHoodButton
        undoButton.frame = frameForUndoButton
        lockSwitch.frame = frameForLockSwitch
        dismissViewButton.frame = frameForDismissButton
        instructionButton.frame = frameForInstructionButton
        
        //setting images in buttons
        let imageForDeleteButton = UIImage(named: "trash1")
        let imageForCreateNeighborhoodButton = UIImage(named: "continue")
        let imageForContinueButton = UIImage(named: "continue")
        let imageForUndoButton = UIImage(named: "undo")
        deleteSketchButton.setImage(imageForDeleteButton, forState: UIControlState.Normal)
        continueButton.setImage(imageForContinueButton, forState: UIControlState.Normal)
        createNeighborHoodButton.setImage(imageForCreateNeighborhoodButton, forState: UIControlState.Normal)
        undoButton.setImage(imageForUndoButton, forState: UIControlState.Normal)
        
        dismissViewButton.setImage(UIImage(named: "cancel"), forState: .Normal)
        instructionButton.setImage(UIImage(named: "instructions"), forState: .Normal)
        
        //setting actions for buttons
        createNeighborHoodButton.addTarget(self, action: #selector(createNeighborhood), forControlEvents: UIControlEvents.TouchUpInside)
        undoButton.addTarget(self, action: #selector(resetMap), forControlEvents: UIControlEvents.TouchUpInside)
        deleteSketchButton.addTarget(self, action: #selector(resetMap), forControlEvents: UIControlEvents.TouchUpInside)
        lockSwitch.addTarget(self, action: #selector(lockScreen), forControlEvents: UIControlEvents.ValueChanged)
        continueButton.addTarget(self, action: #selector(saveNeighborhood), forControlEvents: UIControlEvents.TouchUpInside)
        dismissViewButton.addTarget(self, action: #selector(didTapDismissViewButton), forControlEvents: .TouchUpInside)
        instructionButton.addTarget(self, action: #selector(didTapInstructionButton), forControlEvents: .TouchUpInside)
        
        setUpInstructionView()
        
        //adding buttons to view
        view.addSubview(continueButton)
        view.addSubview(deleteSketchButton)
        view.addSubview(dismissViewButton)
        view.addSubview(instructionButton)
        
        view.addSubview(instructionView)
        view.addSubview(createNeighborHoodButton)
        view.addSubview(undoButton)
        view.addSubview(lockSwitch)
        
        if User.currentUser()?.objectForKey("houses") == nil {
            instructionView.hidden = false
        }
        
        continueButton.hidden = true
        deleteSketchButton.hidden = true
        
        //Add marker for house location
        let marker = GMSMarker(position: clCoords)
        marker.icon = UIImage(named: "homePin")
        marker.map = mapView
        
        
        // load neighborhoods
        loadNeighborhoodsData()
    }
    
    func setUpInstructionView() {
        instructionView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        
        let blurEffect = UIBlurEffect(style: .Dark)
        blur = UIVisualEffectView(effect: blurEffect)
        blur.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        
        reminderLabel.frame = CGRect(x: 28, y: 30, width: 319, height: 59)
        lockScreenInstructionLabel.frame = CGRect(x: 35, y: 110, width: 209, height: 50)
        lockScreenArrow.frame = CGRect(x: 259, y: 116, width: 35, height: 35)
        fillInInstructionLabel.frame = CGRect(x: 0, y: 206, width: 266, height: 50)
        fillInScreenArrow.frame = CGRect(x: 268, y: 206, width: 35, height: 35)
        undoInstructionLabel.frame = CGRect(x: 131, y: 320, width: 230, height: 50)
        undoArrow.frame = CGRect(x: 318, y: 291, width: 35, height: 35)
        tapToContinueLabel.frame = CGRect(x: 28, y: 600, width: 319, height: 35)
        
        reminderLabel.text = "Reminder: keep your neighborhood small to maximize Omni's features"
        reminderLabel.textColor = UIColor.whiteColor()
        reminderLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
        reminderLabel.textAlignment = NSTextAlignment.Center
        reminderLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        reminderLabel.numberOfLines = 0
        
        lockScreenInstructionLabel.text = "LOCK the screen before drawing on the map"
        lockScreenInstructionLabel.textColor = UIColor.whiteColor()
        lockScreenInstructionLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
        lockScreenInstructionLabel.textAlignment = NSTextAlignment.Right
        lockScreenInstructionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        lockScreenInstructionLabel.numberOfLines = 0
        lockScreenArrow.image = UIImage(named: "rightArrow")
        
        fillInInstructionLabel.text = "Click to FILL IN & PREVIEW your neighborhood after drawing on map "
        fillInInstructionLabel.textColor = UIColor.whiteColor()
        fillInInstructionLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
        fillInInstructionLabel.textAlignment = NSTextAlignment.Right
        fillInInstructionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        fillInInstructionLabel.numberOfLines = 0
        fillInScreenArrow.image = UIImage(named: "upRightArrow")
        
        undoInstructionLabel.text = "UNDO your changes on the map"
        undoInstructionLabel.textColor = UIColor.whiteColor()
        undoInstructionLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
        undoInstructionLabel.textAlignment = NSTextAlignment.Right
        undoInstructionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        undoInstructionLabel.numberOfLines = 0
        undoArrow.image = UIImage(named: "upArrow")
        
        tapToContinueLabel.text = "Tap Anywhere to Continue"
        tapToContinueLabel.textColor = UIColor.whiteColor()
        tapToContinueLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
        tapToContinueLabel.textAlignment = NSTextAlignment.Center
        tapToContinueLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        tapToContinueLabel.numberOfLines = 0
        
        instructionView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(SetNeighborhoodViewController.doneWithInstructions(_:)))
        instructionView.addGestureRecognizer(tap)
        
        instructionView.addSubview(blur)
        instructionView.addSubview(reminderLabel)
        instructionView.addSubview(fillInInstructionLabel)
        instructionView.addSubview(fillInScreenArrow)
        instructionView.addSubview(undoInstructionLabel)
        instructionView.addSubview(undoArrow)
        instructionView.addSubview(lockScreenInstructionLabel)
        instructionView.addSubview(lockScreenArrow)
        instructionView.addSubview(tapToContinueLabel)
    }
    
    func doneWithInstructions(sender: UIGestureRecognizer) {
        instructionView.hidden = true
    }
    
    func didTapInstructionButton() {
        instructionView.hidden = false
    }
    
    //show saved neighborhoods after getting data from Parse
    func showExistingNeighborhoods(){
        for polygon in existingNeighborhoods{
            polygon.fillColor = UIColor.randomColor()
            polygon.map = mapView
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //action function for sketching regions on map
    func didPan(sender: UIPanGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began && lockMode && (drawnNeighborhood == nil){
            drawMarkers(gestureRecognizer: sender, arrayForMarkers: &arrayOfSketchedMarkers)
        } else if sender.state == UIGestureRecognizerState.Changed && lockMode && (drawnNeighborhood == nil){
            drawMarkers(gestureRecognizer: sender, arrayForMarkers: &arrayOfSketchedMarkers)
        } else if sender.state == UIGestureRecognizerState.Ended && lockMode && (drawnNeighborhood == nil){
            drawMarkers(gestureRecognizer: sender,arrayForMarkers: &arrayOfSketchedMarkers)
        }
        
    }
    
    //lock screen
    func lockScreen(sender: UISwitch){
        lockMode = sender.on
        mapView.settings.scrollGestures = !sender.on
        mapView.settings.zoomGestures = !sender.on
    }
    
    //function that allows gesture recognizers to work simulaneoulsy
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if (drawnNeighborhood == nil){
            let marker = GMSMarker(position: coordinate)
            arrayOfSketchedMarkers.append(marker)
            marker.map = mapView
        }
    }
    
    //Draws polygon after markers have been setup
    func createNeighborhood(){
        
        if !arrayOfSketchedMarkers.isEmpty{
            
            drawPolygon(&hoodPathForPointMarkers)
            for marker in arrayOfSketchedMarkers{
                marker.map = nil
            }
            arrayOfSketchedMarkers = [GMSMarker]()
        }
    }
    
    //save drawn neighborhood path to Parse
    func saveNeighborhood(){
        
        NeighborhoodRegion.saveNeighborHoodPathCoordinates(hoodPathForPointMarkers, object: { (createdNeighborhood: PFObject) in
            
//                self.loadNeighborhoodsData()
                print("Uploaded Neighborhood to Parse successfully")
                let vc = NeighborhoodSettingsViewController()
                vc.house = self.house
                vc.neighborhood = createdNeighborhood
                self.presentViewController(vc, animated: true, completion: nil)

        }) { (error: NSError?) in
                print(error?.localizedDescription)
        }
    }
    
    
    //clears map of all markers and creates new empty mutable path objects
    func resetMap(sender: UIButton){
        
        if sender == undoButton{
            hoodPathForPointMarkers = GMSMutablePath()
            for marker in arrayOfSketchedMarkers{
                marker.map = nil
            }
            arrayOfSketchedMarkers = [GMSMarker]()
        } else{
            drawnNeighborhood.map = nil
            drawnNeighborhood = nil
            continueButton.hidden = true
            deleteSketchButton.hidden = true
            mapView.settings.myLocationButton = true
            createNeighborHoodButton.hidden = false
            undoButton.hidden = false
            hoodPathForPointMarkers = GMSMutablePath()
            for marker in arrayOfSketchedMarkers{
                marker.map = nil
            }
            arrayOfSketchedMarkers = [GMSMarker]()
        }
        
    }
    
    //create GMSPath from array of markers
    func arrayOfMarkersToGMSPath(arrayOfMarkers: [GMSMarker], inout path: GMSMutablePath) {
        for marker in arrayOfMarkers{
            let coordinate = marker.position
            path.addCoordinate(coordinate)
        }
    }
    
    //draws polygon
    func drawPolygon(inout path: GMSMutablePath){
        
        if !overlapWithExistingNeighborhoods(arrayOfSketchedMarkers){
            
            arrayOfMarkersToGMSPath(arrayOfSketchedMarkers, path: &path)
            let polygon = GMSPolygon(path: path)
            polygon.fillColor =  UIColor.randomColor()
            polygon.strokeColor = UIColor.blackColor()
            polygon.strokeWidth = 2
            polygon.map = mapView
            drawnNeighborhood = polygon
            
            UIView.animateWithDuration(3.0, animations: {
                self.deleteSketchButton.hidden = false
                self.continueButton.hidden = false
                self.mapView.settings.myLocationButton = false
                self.createNeighborHoodButton.hidden = true
                self.undoButton.hidden = true
                self.lockSwitch.hidden = true 
            })
            lockSwitch.setOn(false, animated: true)
            lockScreen(lockSwitch)
            
        } else{
            lockSwitch.setOn(false, animated: true)
            lockScreen(lockSwitch)
            let alert = UIAlertController(title: "Alert", message: "Overlapping Neighborhood. Please Redraw", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    //draws markers using pan gestures
    func drawMarkers(gestureRecognizer sender: UIPanGestureRecognizer, inout arrayForMarkers: [GMSMarker] ) {
        
        if sender.state == UIGestureRecognizerState.Began{
            let location = sender.locationInView(mapView)
            let coordinate = mapView.projection.coordinateForPoint(location)
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            arrayForMarkers.append(marker)
        } else if sender.state == UIGestureRecognizerState.Ended{
            let location = sender.locationInView(mapView)
            let coordinate = mapView.projection.coordinateForPoint(location)
            let marker = GMSMarker(position: coordinate)
            marker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            marker.map = mapView
            arrayForMarkers.append(marker)
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            let location = sender.locationInView(mapView)
            let coordinate = mapView.projection.coordinateForPoint(location)
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            let image = UIImage(named: "Dot")
            let iconView = UIImageView(image: image)
            marker.iconView = iconView
            arrayForMarkers.append(marker)
        }
    }
    
    func overlapWithExistingNeighborhoods(arrayOfMarkers:[GMSMarker]) -> Bool{
        
        for neighborhood in existingNeighborhoods{
            
            for marker in arrayOfMarkers{
                let coordinate = marker.position
                if GMSGeometryContainsLocation(coordinate, neighborhood.path!, true){
                    return true
                }
            }
        }
        return false
    }
    
    func overlapWithNeighborhood(polygonPath:GMSPath, neighborhood:GMSPolygon) -> Bool{
        let length = polygonPath.count()
        for i in 0 ..< UInt(length) {
            let coordinate = polygonPath.coordinateAtIndex(i)
            if GMSGeometryContainsLocation(coordinate, neighborhood.path!, true){
                return true
            }
        }
        return false
    }
    
    func detectOverlap(polygonPath: GMSPath)-> [[CLLocationCoordinate2D]]{
        
        var arrayOfOverlaps = [[CLLocationCoordinate2D]]()
        
        for neighborhood in existingNeighborhoods{
            let array = NeighborhoodRegion.convertGMSPathToArrayOfCoordinates(polygonPath)
            var sorted1 = array.filter({(coordinate: CLLocationCoordinate2D) -> Bool in
                return GMSGeometryContainsLocation(coordinate, neighborhood.path!, true)
            })
            let neighborhoodPath = neighborhood.path!
            let array2 = NeighborhoodRegion.convertGMSPathToArrayOfCoordinates(neighborhoodPath)
            let sorted2 = array2.filter({ (coordinate: CLLocationCoordinate2D) -> Bool in
                return GMSGeometryContainsLocation(coordinate, polygonPath, true)
            })
            sorted1.appendContentsOf(sorted2)
            arrayOfOverlaps.append(sorted1)
        }
        return arrayOfOverlaps
    }
    
    func loadNeighborhoodsData(){
        
        var neighborhoods: [PFObject]!
        var arrayOfPFGeoPoints = [[PFGeoPoint]]()
        let query = PFQuery(className: "Neighborhoods")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (posts:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil{
                neighborhoods = posts!
                for pfObject in neighborhoods{
                    let pathCoordinates = pfObject["pathCoordinates"] as! [PFGeoPoint]
                    arrayOfPFGeoPoints.append(pathCoordinates)
                }
                self.neighborhoodsFromParse = arrayOfPFGeoPoints
                self.showExistingNeighborhoods()
            }else{
                print(error)
            }
        }
        
    }
    
    func didTapDismissViewButton(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}


    extension UIColor{
        class func randomColor() -> UIColor{
            let red = CGFloat(drand48())
            let green = CGFloat(drand48())
            let blue = CGFloat(drand48())
            return UIColor(red: red, green: green, blue: blue, alpha: 0.5)
        }
}

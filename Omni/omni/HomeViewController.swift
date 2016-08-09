//
//  HomeViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/6/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Material
import GoogleMaps
import Parse
import IGLDropDownMenu
import MBProgressHUD

class HomeViewController: UIViewController, UITextViewDelegate {
    
    private var neighborhoodsFromParse:[[PFGeoPoint]]?{
        didSet {
            if let neighborhoodsFromParse = neighborhoodsFromParse{
                let arrayOfMutablePaths = NeighborhoodRegion.convertArrayOfArrayOfPfGeoPointsToArrayOfGMSMutablePaths(arrayOfArrayOfPFGeoPoints: neighborhoodsFromParse)
                existingNeighborhoods = NeighborhoodRegion.convertArrayOFGMSPathsToArrayOfGMSPolygons(arrayOfMutablePath: arrayOfMutablePaths)
            }
        }
    }
    
    private var safeUnsafeVC : SafeNotSafeMenuViewController!
    private var timer: NSTimer!
    private var menuButton: IconButton!
    var tableView: UITableView!
    private var isAnimating: Bool = false
    private var mapViewIsDisplayed: Bool = false
    private var mapView: GMSMapView!
    private var dropDownMenu : IGLDropDownMenu!
    private var blurEffect: UIBlurEffect!
    private var blurView : UIVisualEffectView!
    private var menuLabel: UILabel!
    
    var allNeighbors:[Neighbor] = []{
        didSet{
            medics = allNeighbors.filter({ (neighbor: Neighbor) -> Bool in
                return !(neighbor.medTraining?.isEmpty)!
            })
        }
    }
    var currentNeighborsNumbers: [String] = []
    
    var medics: [Neighbor] = []
    var currentNeighborhood: Neighborhood!{
        didSet{
            refreshDropDownMenu()
            tableView.reloadData()
        }
    }
    var existingNeighborhoods = [GMSPolygon]()
    var userHouses:[House]!{
        didSet{
            housesInCurrentNeighborhood = []
            for house in userHouses{
                let currentNeighborHoodID = User.currentUser()?.objectForKey("currentNeighborhood") as! String
                if house.neighborhoodID == currentNeighborHoodID{
                    housesInCurrentNeighborhood.append(house)
                }
                
            }
            setUserHousesOnMap()
        }
    }

    var collectionView: UICollectionView!
    var newUser: Bool?
    var currentUserFullName: String!
    
    var emergencyBlur = UIVisualEffectView()
    var emergencyView = UIView()
    var backgroundImage = UIImageView()
    var iconImage = UIImageView()
    var instructionLabel = UILabel()
    var descriptionTextView = UITextView()
    var cancelButton = UIButton()
    var submitButton = UIButton()
    
    var housesInCurrentNeighborhood:[House] = []
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        prepareMenuButton()
        prepareNavigationItem()
        prepareNavigationBar()
        setupDropDownMenu()
        setupTableView()
        setupMapView()
        loadNeighborhoodsData()
        setUpEmergencyView()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        currentUserFullName = User.currentUser()?.objectForKey("fullName") as? String
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        safeUnsafeVC = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        newUser = User.currentUser()?.objectForKey("newUser") as? Bool
        if newUser == true || newUser == nil {
            self.presentViewController(AppPolicyViewController(), animated: true, completion: nil)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(refreshHome), userInfo: nil, repeats: true)
        refreshDropDownMenu()
        tableView.reloadData()
        fillCurrentNeighborsNumbers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
        timer = nil
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fillCurrentNeighborsNumbers() {
        for neighbor in allNeighbors {
            if let mobileNum = neighbor.mobileNum {
                print(mobileNum)
                currentNeighborsNumbers.append("%2B1\(mobileNum)")
            } else if let workNum = neighbor.workNum {
                currentNeighborsNumbers.append("%2B1\(workNum)")
            }
        }
    }
    
    func setUpView() {
        view.backgroundColor = UIColor.whiteColor()
        self.navigationDrawerController?.delegate = self
    }
    
    func setUpEmergencyView() {
        
        let blurEffect = UIBlurEffect(style: .Dark)
        emergencyBlur = UIVisualEffectView(effect: blurEffect)
        emergencyBlur.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        
        emergencyView.frame = CGRect(x: 35, y: 110, width: Int(UIScreen.mainScreen().bounds.size.width) - 70, height: 420)
        emergencyView.backgroundColor = UIColor.whiteColor()
        emergencyView.layer.cornerRadius = 20.0
        emergencyView.clipsToBounds = true
        
        backgroundImage.frame = CGRect(x: 0, y: 0, width: emergencyView.frame.width, height: 140)
        iconImage.frame = CGRect(x: 112, y: 30, width: 80, height: 80)
        
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = .ScaleAspectFill
        backgroundImage.clipsToBounds = true
        iconImage.image = UIImage(named: "description")
        
        instructionLabel.frame = CGRect(x: 8, y: 144, width: emergencyView.frame.width - 16, height: 75)
        instructionLabel.text = "Be detailed and thorough in your description to help your neighbors become more aware of the situation."
        instructionLabel.textColor = UIColor.charcoal()
        instructionLabel.textAlignment = NSTextAlignment.Center
        instructionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        instructionLabel.numberOfLines = 0
        instructionLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
        
        descriptionTextView.frame = CGRect(x: 8, y: 222, width: emergencyView.frame.width - 16, height: 144)
        descriptionTextView.backgroundColor = UIColor.clouds()
        descriptionTextView.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightLight)
        descriptionTextView.textColor = UIColor.charcoal()
        descriptionTextView.delegate = self
        
        cancelButton.frame = CGRect(x: emergencyView.frame.width - 30, y: 10, width: 20, height: 20)
        cancelButton.setImage(UIImage(named: "cancel"), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(HomeViewController.hideEmergencyView), forControlEvents: .TouchUpInside)
        
        submitButton.frame = CGRect(x: 0, y: emergencyView.frame.height - 45, width: emergencyView.frame.width, height: 45)
        submitButton.setTitle("Declare State of Emergency", forState: .Normal)
        submitButton.backgroundColor = UIColor.asphalt()
        submitButton.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        submitButton.titleLabel?.textColor = UIColor.clouds()
        submitButton.addTarget(self, action: #selector(HomeViewController.declareStateOfEmergency), forControlEvents: .TouchUpInside)
        
        emergencyView.addSubview(backgroundImage)
        emergencyView.addSubview(iconImage)
        emergencyView.addSubview(instructionLabel)
        emergencyView.addSubview(descriptionTextView)
        emergencyView.addSubview(cancelButton)
        emergencyView.addSubview(submitButton)
        
        view.addSubview(emergencyBlur)
        view.addSubview(emergencyView)
        emergencyBlur.hidden = true
        emergencyView.hidden = true
    }
    
    func hideEmergencyView() {
        descriptionTextView.text = ""
        emergencyBlur.hidden = true
        emergencyView.hidden = true
    }
    
    func showEmergencyView() {
        emergencyBlur.hidden = false
        emergencyView.hidden = false
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 150
    }
    
    func declareStateOfEmergency() {
        currentNeighborhood.declareStateOfEmergency(emergencyDescription: descriptionTextView.text)
        hideEmergencyView()
        sendTextNotification("\(self.currentUserFullName) has declared your neighborhood to be in a state of emergency. Please open the app.")
        refreshDropDownMenu()
    }
    
    func safeNotSafeAlert() {
        let safeStatus = User.currentUser()?.objectForKey("safe") as? Bool
        let alertController = UIAlertController(
            title: "Please mark yourself as safe or not safe.",
            message: "If you mark yourself as 'not safe,' your phone number will be public to your neighbors until you mark yourself as 'safe.'",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let safeAction = UIAlertAction(
        title: "Safe", style: UIAlertActionStyle.Default) { (action) in
            if safeStatus == nil{
                User.markUserAsSafe()
                self.currentNeighborhood.markUserAsSafe()
            }else if safeStatus! == false{
                User.markUserAsSafe()
                self.currentNeighborhood.markUserAsSafe()
            }
            self.refreshDropDownMenu()
        }
        
        let notSafeAction = UIAlertAction(
        title: "Not Safe", style: UIAlertActionStyle.Default) { (action) in
            if safeStatus == nil{
                User.markUserAsUnSafe()
                self.currentNeighborhood.markUserAsUnsafe()
            }else if safeStatus! == true{
                User.markUserAsUnSafe()
                self.currentNeighborhood.markUserAsUnsafe()
            }
            self.refreshDropDownMenu()
        }
        
        alertController.addAction(safeAction)
        alertController.addAction(notSafeAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func turnOffEmergencyAlert() {
        let alertController = UIAlertController(
            title: "Please Confirm",
            message: "Turning off the neighborhood's state of emergency will prevent you and all neighbors from seeing who is safe, not safe, or still unaccounted for. Your neighbors will receive an SMS message saying that you have turned it off.",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let submitAction = UIAlertAction(
        title: "Emergency Has Ended", style: UIAlertActionStyle.Default) { (action) in
            let message = "\(self.currentUserFullName) has turned off the neighborhood's state of emergency."
            self.currentNeighborhood.turnOffStateOfEmergency()
            self.refreshDropDownMenu()
            self.sendTextNotification(message)
        }
        
        alertController.addAction(submitAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //sets up MapView
    func setupMapView(){
        
        mapView = GMSMapView()
        mapView.mapType = kGMSTypeNormal
        mapView.settings.compassButton = true
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        let height = CGFloat(500)
        let width = CGFloat(375)
        self.mapView.frame = CGRectMake(0,-height, width, height)
        self.mapViewIsDisplayed = false
        setupLocationButton()
        view.addSubview(mapView)


    }
    
    //sets up button on mapView which when tap returns the camera to the location of the current neighborhood
    func setupLocationButton(){
        let frameForCurrentHouseButton = CGRectMake(300, 320, 60, 60)
        let currentHouseButton = FabButton(frame: frameForCurrentHouseButton)
        let img = UIImage(named: "mylocation")
        currentHouseButton.setImage(img, forState: .Normal)
         currentHouseButton.addTarget(self, action: #selector(zoomBackToHouse), forControlEvents: UIControlEvents.TouchUpInside)
        currentHouseButton.backgroundColor = UIColor.whiteColor()
        mapView.addSubview(currentHouseButton)
    }
    
    //action button for location button on mapView
    func zoomBackToHouse(){
        let house = housesInCurrentNeighborhood[0]
        let update = GMSCameraUpdate.setTarget(house.coordinates!, zoom: 16.3)
        mapView.moveCamera(update)
    }
    
    //places house pins on map indicating the location of the user's house
    func setUserHousesOnMap(){
        for house in housesInCurrentNeighborhood{
            let marker = GMSMarker(position: house.coordinates!)
            marker.icon = UIImage(named: "homePin")
            marker.map = mapView
            let cameraPosition = GMSCameraPosition(target: house.coordinates!, zoom: 16, bearing: 0, viewingAngle: 0)
            mapView.camera = cameraPosition
  
        }
    }
    
    //setups tableView
    func setupTableView(){
        tableView = UITableView()
        let frame = CGRectMake(0, dropDownMenu.bounds.height + 10, 375, view.bounds.height-143)
        tableView.frame = frame
        tableView.separatorStyle = .SingleLine
        tableView.registerClass(HomeContentCell.self, forCellReuseIdentifier: "Contact")
        tableView.registerClass(MaterialTableViewCell.self, forCellReuseIdentifier: "Header")
        tableView.registerClass(EmergencyInfoCell.self, forCellReuseIdentifier: "Info")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        
    }
    
    //sets up the first headerView on the tableview that displays the name of the neighborhood and its description
    func setupFirstHeaderView(headerViewCell: MaterialTableViewCell) {
        
        let frameForHeader = CGRectMake(0,5, 375, 71)
        let headerView = CardView(frame: frameForHeader)
        headerView.backgroundColor = MaterialColor.white
        headerView.shadowOpacity = 0.2
        headerView.divider = false
        
        let frameForNameLabel = CGRectMake(5, 5, 365, 25)
        let nameOfNeighborhood = UILabel(frame: frameForNameLabel)
        nameOfNeighborhood.text = currentNeighborhood.title
        nameOfNeighborhood.font = UIFont.systemFontOfSize(20.0, weight: UIFontWeightMedium)
        nameOfNeighborhood.textColor = UIColor.asphalt()
        
        let frameForDescriptionLabel = CGRectMake(5, 26, 365, 40)
        let descriptionLabel = UILabel(frame: frameForDescriptionLabel)
        if let description = currentNeighborhood.bio{
            descriptionLabel.text = description
            descriptionLabel.font = UIFont.systemFontOfSize(14.0)
            descriptionLabel.textColor = UIColor.charcoal()
        }
        //adds gestureRecognizers that drops down or hides mapView when this headerView is selected
        let gestureRec = UITapGestureRecognizer(target: self, action: #selector(headerSelected))
        gestureRec.numberOfTapsRequired = 1
        headerView.addGestureRecognizer(gestureRec)
        headerView.addSubview(nameOfNeighborhood)
        headerView.addSubview(descriptionLabel)
        headerViewCell.contentView.addSubview(headerView)
  
    }
    
    //sets up section headerViews for all but the first section
    func setupHeaderView(headerViewCell: MaterialTableViewCell, label: String) {
        
        let frameForHeader = CGRectMake(0, 0, 375, 60)
        let headerView = CardView(frame: frameForHeader)
        headerView.backgroundColor = MaterialColor.white
        headerView.shadowOffset = CGSize(width: 0, height: 0)
        headerView.cornerRadiusPreset = .None
        headerView.divider = false
        
        let frameForNameLabel = CGRectMake(5, 20, 200, 18)
        let numberOfNeighborsLabel = UILabel(frame: frameForNameLabel)
        numberOfNeighborsLabel.text = label
        numberOfNeighborsLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
        numberOfNeighborsLabel.textColor = UIColor.asphalt()
        
        let frameForSeeAllLabel = CGRectMake(300, 19, 100, 18)
        let seeAllLabel = UILabel(frame: frameForSeeAllLabel)
        seeAllLabel.font = UIFont.systemFontOfSize(13.0)
        seeAllLabel.textColor = UIColor.charcoal()
        seeAllLabel.text = "SEE ALL"
        
        let frameForNextButton = CGRectMake(346, 13, 30, 30)
        let nextButton = UIButton(frame: frameForNextButton)
        let image = UIImage(named: "next")
        nextButton.setImage(image, forState: UIControlState.Normal)
        
        if label == "Medics"{
            nextButton.addTarget(self, action: #selector(showListOfMedics), forControlEvents: UIControlEvents.TouchUpInside)
            let gestureRec = UITapGestureRecognizer(target: self, action: #selector(showListOfMedics))
            gestureRec.numberOfTapsRequired = 1
            headerView.addGestureRecognizer(gestureRec)
        } else if label != "Emergency Info" {
            nextButton.addTarget(self, action: #selector(showAllNeighbors), forControlEvents: UIControlEvents.TouchUpInside)
            let gestureRec = UITapGestureRecognizer(target: self, action: #selector(showAllNeighbors))
            gestureRec.numberOfTapsRequired = 1
            headerView.addGestureRecognizer(gestureRec)
        }else if label == "Emergency Info"{
            headerView.pulseAnimation = .None
        }
        
        if label != "Emergency Info"{
            
            headerView.addSubview(nextButton)
            headerView.addSubview(seeAllLabel)
        }
        
        headerView.addSubview(numberOfNeighborsLabel)

        headerViewCell.contentView.addSubview(headerView)
    }
    
    //actions for next button in the various section headers
    func showListOfMedics(){
        let navControl = self.navigationController
        let destination = MedicsViewController()
        destination.medics = medics
        navControl!.pushViewController(destination, animated: true)
    }
    
    func showAllNeighbors(){
        let navControl = self.navigationController
        let destination = NeighborsViewController()
        destination.neighbors = allNeighbors
        let searchController = SearchNeighborsViewController(rootViewController: destination)
        searchController.allNeighbors = allNeighbors
        navControl!.pushViewController(searchController, animated: true)
    }
    
    //prepares MenuButton for navigationDrawer Controller
    func prepareMenuButton(){
        let image = MaterialIcon.cm.menu
        menuButton = IconButton()
        menuButton.pulseColor = MaterialColor.black
        menuButton.setImage(image, forState: .Normal)
        menuButton.setImage(image, forState: .Highlighted)
        menuButton.tintColor = UIColor.clouds()
        menuButton.addTarget(self, action: #selector(handleMenuButton), forControlEvents: .TouchUpInside)
        
    }

    //closes menuView when menu button is pressed
    func handleMenuButton(){
        navigationDrawerController?.openLeftView()
        
    }
    
    //functions that prepare the Home navigation Controller.
    func prepareNavigationItem(){
        navigationItem.title = "Home"
        navigationItem.titleLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
        navigationItem.titleLabel.textAlignment = .Left
        navigationItem.detailLabel.textAlignment = .Left
        navigationItem.titleLabel.textColor = UIColor.clouds()
        navigationItem.leftControls = [menuButton]

    }
    
    func prepareNavigationBar(){
        navigationController?.navigationBar.backgroundColor = UIColor.asphalt()
        navigationController?.navigationBar.tintColor = UIColor.silver()
        navigationController?.navigationBar.statusBarStyle = .Default
    }
    
    //functions for dropdown mapView
    func hideMapView() {
        var frame = self.mapView.frame
        frame.origin.y = -frame.size.height
        tableView.scrollEnabled = true
        self.animateDropDownToFrame(frame) {
            self.mapViewIsDisplayed = false
        }
    }
    
    func showMapView() {
        //zoomBackToHouse()
        var frame = self.mapView.frame
        frame.origin.y = dropDownMenu.bounds.height + 90
        tableView.scrollEnabled = false
        self.animateDropDownToFrame(frame) {
            self.mapViewIsDisplayed = true
        }
    }
    
    //function for dropDown mapView effect
    func animateDropDownToFrame(frame: CGRect, completion:() -> Void) {
        if (!self.isAnimating) {
            self.isAnimating = true
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { 
                self.mapView.frame = frame
                }, completion: { (completed: Bool) in
                    self.isAnimating = false
                    if (completed) {
                        completion()
                    }
            })
        }
    }
    
    //action for when the nameOfNeighborhood headerView is selected.
    func headerSelected() {
        if (mapViewIsDisplayed) {
            hideMapView()
        } else {
            showMapView()
        }
    }
    
    //sets neighborhood regions on map
    func showExistingNeighborhoods(){
        for polygon in existingNeighborhoods{
            polygon.fillColor = UIColor.randomColor()
            polygon.map = mapView
        }
    }
    
    //loads all Neighborhoods From Parse and displays them on mapView
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

    func sendTextNotification(message: String) {
        let twilioSID = "AC9766ba47739f9da36b5246e7efca6399"
        let twilioSecret = "ffa991fd86c3fbe55c064c063a766248"
        
        for toNumber in currentNeighborsNumbers {
            // Build the request
            let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
            request.HTTPMethod = "POST"
            request.HTTPBody = "From=%2B12132796664&To=\(toNumber)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
            
            // Build the completion block and send the request
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    // Success
                    print("Response: \(responseDetails)")
                } else {
                    // Failure
                    print("Error: \(error)")
                }
            }).resume()
        }
    }
    
    //sets up blurview that covers tableView when dropDownMenu expands
    
    func setupBlurView(){
        blurEffect = UIBlurEffect(style: .Light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.userInteractionEnabled = true
        let gestureRec = UITapGestureRecognizer()
        gestureRec.addTarget(self, action: #selector(dismissDropDownMenu))
        blurView.addGestureRecognizer(gestureRec)
        
    }
    
    //dismisses dropDownMenu
    func dismissDropDownMenu(){
        dropDownMenu.expanding = false
    }
    
    //refreshes dropDownMenu to show new content
    func refreshDropDownMenu(){
        self.blurView.removeFromSuperview()
        tableView.scrollEnabled = true
        self.dropDownMenu.removeFromSuperview()
        self.setupDropDownMenu()
    }
    
    //sets up DropDown Menu
    func setupDropDownMenu(){
        setupBlurView()
        var safeStatus = ""
        let bool = User.currentUser()?.objectForKey("safe") as? Bool
        
        menuLabel = UILabel()
        menuLabel.textAlignment = .Center
        menuLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
        menuLabel.textColor = UIColor.clouds()
        menuLabel.numberOfLines = 0
        dropDownMenu = IGLDropDownMenu(menuButtonCustomView: menuLabel)
        dropDownMenu.frame = CGRectMake(0, 0, view.bounds.width, 60)
        dropDownMenu.delegate = self
        if let neighborhood = currentNeighborhood{
            let labelForMenu = (!neighborhood.isInAStateOfEmergency!) ? "Your neighborhood is safe" : "Your Neighborhood is currently in a state of emergency"
            menuLabel.text = labelForMenu
            
            let dropDownItems: NSMutableArray = NSMutableArray()
            
            //initializing various dropDownMenu items
            let optionForSafeNeighborhood = IGLDropDownItem()
            optionForSafeNeighborhood.text = "  Declare a state of emergency"
            let optionForUnsafeNeighborhood1 = IGLDropDownItem()
            optionForUnsafeNeighborhood1.text = "  Turn off state of emergency"
            
            let optionForUnsafeNeighorhood2 = IGLDropDownItem()
            optionForUnsafeNeighorhood2.text = "  See who's safe or not safe"
            let optionForUnsafeNeighborhood3 = IGLDropDownItem()
            if let state = bool{
                if state{
                    safeStatus = "Safe"
                }else{
                    safeStatus = "Not Safe"
                }
                optionForUnsafeNeighborhood3.text = "Change personal state of safety [\(safeStatus)]"
            }else{
                optionForUnsafeNeighborhood3.text = "Change personal state of safety"
            }
            
            if !neighborhood.isInAStateOfEmergency{
                dropDownItems.addObject(optionForSafeNeighborhood)
                menuLabel.backgroundColor = UIColor.emerald()
            } else {
                dropDownItems.addObject(optionForUnsafeNeighborhood1)
                dropDownItems.addObject(optionForUnsafeNeighorhood2)
                dropDownItems.addObject(optionForUnsafeNeighborhood3)
                menuLabel.backgroundColor = UIColor.alizarin()
            }
            dropDownMenu.dropDownItems = dropDownItems as [AnyObject]
        }
        
        dropDownMenu.direction = .Down
        dropDownMenu.type = .Stack
        dropDownMenu.gutterY = 15
        dropDownMenu.itemAnimationDelay = 0.1
        dropDownMenu.menuButtonStatic = true
        dropDownMenu.reloadView()
        
        view.addSubview(dropDownMenu)

    }
    
    //Sets up the view controllers for the safe/not safe view controller menu
    func setupSafeVC() {
        safeUnsafeVC = SafeNotSafeMenuViewController()
        let safe = SafeNotSafeViewController()
        let notSafe = SafeNotSafeViewController()
        let unaccounted = SafeNotSafeViewController()
        
        safe.title = "Safe"
        notSafe.title = "Not Safe"
        unaccounted.title = "Unaccounted For"
        
        
        self.safeUnsafeVC.controllerArray.append(safe)
        self.safeUnsafeVC.controllerArray.append(notSafe)
        self.safeUnsafeVC.controllerArray.append(unaccounted)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 0
        } else if section < 3 {
            return 1
        } else if currentNeighborhood.arrayOfContacts.isEmpty{
            return 1
        }else{
            return currentNeighborhood.arrayOfContacts.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section < 3{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Contact", forIndexPath: indexPath) as! HomeContentCell

            if indexPath.section == 1{
                cell.neighbors = allNeighbors
                
                cell.homeNavigationController = self.navigationController
                if allNeighbors.isEmpty{
                    cell.label.text = "  No Neighbors to display"
                    cell.label.hidden = false
                }else{
                    cell.label.hidden = true
                }
            }else{
                cell.neighbors = medics
                
                cell.homeNavigationController = self.navigationController
                if medics.isEmpty{
                    cell.label.text = "  No Medics to display"
                    cell.label.hidden = false
                }else{
                    cell.label.hidden = true
                }
            }
            return cell
        } else if currentNeighborhood.arrayOfContacts.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("Info", forIndexPath: indexPath) as! EmergencyInfoCell
            cell.showNoEmergencyInfoLabel()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Info") as! EmergencyInfoCell
            let info = currentNeighborhood.arrayOfContacts[indexPath.row]
            cell.infoType = info.name
            cell.infoPreview = info.phoneNumber
            return cell
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Header") as! MaterialTableViewCell
        
        if section == 0 {
            setupFirstHeaderView(cell)
            return cell.contentView
        } else if section == 1 {
            let label = (allNeighbors.count == 1 ) ? "Neighbor" : "Neighbors"
            setupHeaderView(cell, label: "\(allNeighbors.count) \(label)")
            return cell.contentView
        } else if section == 2 {
            setupHeaderView(cell, label: "Medics")
            return cell.contentView
        } else {
            setupHeaderView(cell, label: "Emergency Info")
            return cell.contentView
        }
    }
}

extension HomeViewController: UITableViewDelegate{
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 80
        } else {
            return 60
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 79
        }
        return 80
    }
    
}
extension HomeViewController: IGLDropDownMenuDelegate{
    
    //delegate function for dropDownMenu. Adds blurview to tableview when dropDownMenu expands and dismisses blurview when dropDownMenu contracts
    func dropDownMenu(dropDownMenu: IGLDropDownMenu!, expandingChanged isExpending: Bool) {
        if isExpending{
            blurView.frame = tableView.bounds
            blurView.clipsToBounds = true
            tableView.addSubview(blurView)
            tableView.scrollEnabled = false
        }else{
            blurView.removeFromSuperview()
            tableView.scrollEnabled = true
        }
    
    }
    
    //delegate function for dropDownMenu. Sets the various actions performed when a menu item is selected
    func dropDownMenu(dropDownMenu: IGLDropDownMenu!, selectedItemAtIndex index: Int) {
        if !currentNeighborhood.isInAStateOfEmergency {
            if index == 0 {
                showEmergencyView()
            }
        }else{
            if index == 1{
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.setupSafeVC()
                currentNeighborhood.updateNeighborhoodData({
                    self.safeUnsafeVC.allNeighbors = self.allNeighbors
                    self.safeUnsafeVC.currentNeighborhood = self.currentNeighborhood
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.presentViewController(self.safeUnsafeVC, animated: true, completion: nil)
                })
            }else if index == 0{
                turnOffEmergencyAlert()
            }else{
                safeNotSafeAlert()
            }
        }
    }
    
    func refreshHome(){
        AppDelegate.getAppDelegate().loadingVC.pullCurrentUserDataFromParse { 
        }
    }
}
extension HomeViewController: NavigationDrawerControllerDelegate{
    
    func navigationDrawerPanDidBegin(navigationDrawerController: NavigationDrawerController, point: CGPoint, position: SideNavigationPosition) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    func navigationDrawerWillOpen(navigationDrawerController: NavigationDrawerController, position: SideNavigationPosition) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    func navigationDrawerDidClose(navigationDrawerController: NavigationDrawerController, position: SideNavigationPosition) {
        self.tabBarController?.tabBar.hidden = false
    }
    
}


//
//  PostSignUpViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/6/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Eureka
import Parse
import ParseUI
import GoogleMaps

class PostSignUpViewController: FormViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let navigationVC = UINavigationController(rootViewController: AddressViewController())
    var houses: [PFObject]?
    var inNeighborhood: Bool!
    var neighborhood: GMSPolygon?
    let actionSheet = UIAlertController(title: "Image Source", message: nil, preferredStyle: .ActionSheet)
    let imagePicker = UIImagePickerController()
    let profileImg = PFImageView()
    var listSection: Form._Element?
    var lists: [[String: [String: String]]]? = User.currentUser()?.objectForKey("lists") as? [[String: [String: String]]] {
        didSet {
            if listSection != nil {
                getLists(listSection!, lists: lists)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up navigation
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(17.0, weight: UIFontWeightRegular)]
        self.title = "Edit Profile"
        self.navigationController?.navigationBar.tintColor = UIColor.asphalt()
        
        let logOut = UIBarButtonItem(title: "Log Out", style: .Done, target: self, action: #selector(logoutClicked))
        logOut.tintColor = UIColor.alizarin()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveEureka(_:)))
        self.navigationItem.leftBarButtonItem = logOut
        
        imagePicker.delegate = self
 
        //Set up the form
        form +++ Section(){ section in
            section.header = {
                var header = HeaderFooterView<UIView>(.Callback({
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    self.profileImg.contentMode = .ScaleAspectFill
                    if User.currentUser()?.objectForKey("profilePic") as? PFFile == nil {
                        self.profileImg.image = UIImage(named: "defaultProfPic")
                    } else {
                        self.profileImg.file = User.currentUser()?.objectForKey("profilePic") as? PFFile
                        self.profileImg.loadInBackground()
                    }
                    
                    self.profileImg.frame = CGRect(x: 145, y: 20, width: 80, height: 80)
                    self.profileImg.layer.cornerRadius = self.profileImg.frame.height/2
                    self.profileImg.layer.masksToBounds = true
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(PostSignUpViewController.selectProfile(_:)))
                    self.profileImg.addGestureRecognizer(tap)
                    self.profileImg.userInteractionEnabled = true
                    
                    
                    let label = UILabel(frame: CGRect(x: 145, y: 95, width: 80, height: 30))
                    label.textColor = UIColor.asphalt()
                    label.font = label.font.fontWithSize(13.0)
                    label.text = "Edit"
                    label.textAlignment = .Center
                    label.adjustsFontSizeToFitWidth = true
                    
                    view.addSubview(self.profileImg)
                    view.addSubview(label)
                    
                    return view
                }))
                header.height = { 100 }
                return header
            }()
            }
            +++ Section("Personal Info")
            <<< NameRow("fullName"){ row in
                row.title = "Full Name"
                row.placeholder = "Full Name"
            }
            <<< TextAreaRow("bio") {
                $0.placeholder = "Bio"
            }
            <<< SegmentedRow<String>("gender") {
                $0.title = "Gender"
                $0.options = ["Male", "Female", "Other"]
            }
            <<< PhoneRow("cellNum"){
                $0.title = "Mobile Phone"
                $0.placeholder = "Cell Phone Number"
            }
            <<< PhoneRow("workNum") {
                $0.title = "Work Phone"
                $0.placeholder = "Work Phone Number"
            }
            <<< MultipleSelectorRow<String>("med") {
                $0.title = "Medical Training"
                $0.options = ["Doctor", "Surgeon", "EMT", "Nurse", "Veterinarian", "Lifeguard", "CPR", "AED", "First Aid"]
                $0.cellUpdate({ (cell, row) in
                    saveEurekaInformation(self, object: User.currentUser()!, sender: nil, completion: nil)
                })
            }
            +++ Section("lists") { section in
                section.header = HeaderFooterView(title: "Emergency Contacts")
                listSection = section
                
                getLists(section, lists: lists)
            }
            
            +++ Section("homeInfo") { section in
                section.header = HeaderFooterView(title: "Home Info")
        }
        
        
        //Create the action sheet buttons for choosing the image options to change your profile
        let cameraRoll = UIAlertAction(title: "Photo Library", style: .Default, handler: {(UIAlertAction) -> Void in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let camera = UIAlertAction(title: "Camera", style: .Default, handler: {(UIAlertAction) -> Void in
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelOption = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
        actionSheet.addAction(cancelOption)
        actionSheet.addAction(camera)
        actionSheet.addAction(cameraRoll)
        
        let username = User.currentUser()?.username
        getHouses(username!)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func saveEureka(sender: UIBarButtonItem) {
        if User.currentUser()?.objectForKey("houses") == nil {
            noNeighborhoodsAlert()
            return
        }
        saveEurekaInformation(self, object: User.currentUser()!, sender: sender, completion: nil)
    }
    
    func noNeighborhoodsAlert() {
        let alertController = UIAlertController(
            title: "No Current Neighborhoods",
            message: "Please input your address below to join or create a neighborhood.",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let confirmAction = UIAlertAction(
        title: "Got it!", style: UIAlertActionStyle.Default) { (action) in
        }
        
        alertController.addAction(confirmAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Create the houses section
    func getHouses(currentUsername: String) {
        
        let userQuery = PFQuery(className: "User")
        userQuery.includeKey("neighborhoods")
        
        //Query all the PFObjects of houses that belong to the user and put them into the post array
        let query = PFQuery(className: "House")
        let houses = User.currentUser()?.objectForKey("houses") as? [String]
        
        if houses != nil && houses?.count != 0 {
            query.whereKey("objectId", containedIn: houses!)
            query.orderByDescending("createdAt")
            
            // fetch data asynchronously
            query.findObjectsInBackgroundWithBlock { (newHouse: [PFObject]?, error: NSError?) -> Void in
                self.form.sectionByTag("homeInfo")?.removeAll()
                self.form.sectionByTag("homeInfo")?.reload()
                self.form.last?.removeAll()
                self.form.last! <<< ButtonRow() {
                    $0.title = "Add Address"
                    $0.onCellSelection { cell, row in
                        //Needs to save information if it segues away from this page, so that the state can be faux saved
                        saveEurekaInformation(self, object: User.currentUser()!, sender: nil, completion: nil)
                        self.presentViewController(self.navigationVC, animated: true, completion: nil)
                    }
                }
                
                if let newHouse = newHouse {
                    for house in newHouse {
                        let address = house["address"] as? String
                        let neighborhoodLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 300, height: 20))
                        let deleteButton = DeleteButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                        
                        PFQuery(className: "Neighborhoods").getObjectInBackgroundWithId(house["neighborhood"] as! String, block: { (neighborhood: PFObject?, error: NSError?) in
                            if let neighborhood = neighborhood {
                                neighborhoodLabel.text = neighborhood["neighborhoodName"] as? String
                                deleteButton.neighborhoodId = neighborhood.objectId
                            }
                        })
                        
                        
                        neighborhoodLabel.font  = UIFont.boldSystemFontOfSize(15.0)
                        
                        let addressLabel = UILabel(frame: CGRect(x: 5, y: 25, width: 275, height: 80))
                        addressLabel.font = addressLabel.font.fontWithSize(15.0)
                        addressLabel.lineBreakMode = .ByWordWrapping
                        addressLabel.numberOfLines = 0
                        addressLabel.text = address
                        
                        // Set up the delete button and add fields to be passed to the deleteHouse function
                        deleteButton.setBackgroundImage(UIImage(named: "Delete-96"), forState: .Normal)
                        deleteButton.houseId = house.objectId
                        deleteButton.userId = User.currentUser()?.objectId
                        deleteButton.addTarget(self, action: #selector(self.deleteHouse(_:)), forControlEvents: .TouchUpInside)
                        
                        //Adds the different views into the label row and modifies the height
                        let label = LabelRow().cellSetup({ (cell, row) in
                            cell.height = { 105 }
                            cell.addSubview(neighborhoodLabel)
                            cell.addSubview(addressLabel)
                            cell.accessoryView = deleteButton
                        })
                        
                        self.form.last! <<< label
                        
                        self.tableView?.reloadData()
                    }
                    self.houses = newHouse
                    
                    
                } else {
                    // handle error
                    print(error?.localizedDescription)
                }
            }
        } else {
            print(User.currentUser()?.objectForKey("currentNeighborhood"))
            self.form.last! <<< ButtonRow() {
                $0.title = "Add Address"
                $0.onCellSelection { cell, row in
                    //Needs to save information if it segues away from this page, so that the state can be faux saved
                    saveEurekaInformation(self, object: User.currentUser()!, sender: nil, completion: nil)
                    self.presentViewController(self.navigationVC, animated: true, completion: nil)
                }
            }
        }
        
        self.getInfo()
        
        
        
        userQuery.findObjectsInBackgroundWithBlock { (users: [PFObject]?, error: NSError?) in
            if let users = users {
                print(users)
            }
        }
        
        
        
    }
    
    func deleteHouse(sender: DeleteButton) {
        let user = User.currentUser()
        print("Deleting neigborhood")
        //print(sender.houseId)
        print(sender.neighborhoodId)
        
        // Removes the user from the neighborhood's user array
        PFQuery(className: "Neighborhoods").getObjectInBackgroundWithId(sender.neighborhoodId!) { (hood: PFObject?, error: NSError?) in
            var usersArr = hood?.objectForKey("users") as! [String]
            var index: Int?
            for i in 0..<usersArr.count {
                if usersArr[i] == user?.objectId! {
                    index = i
                }
            }
            if index != nil {
                usersArr.removeAtIndex(index!)
                hood?.setObject(usersArr, forKey: "users")
                hood?.saveInBackground()
            }
        }
        
        // Removes the house from the User houses array
        var houses = user?.objectForKey("houses") as! [String]
        var houseIndex: Int?
        for i in 0..<houses.count {
            if houses[i] == sender.houseId! {
                houseIndex = i
            }
        }
        if houseIndex != nil {
            houses.removeAtIndex(houseIndex!)
            user?.setObject(houses, forKey: "houses")
            user?.saveInBackground()
        }

        
        // Removes the neighborhood from the User's neighborhoods array
        var neighborhoods = user?.objectForKey("neighborhoods") as! [String]
        print(neighborhoods)
        var neighborhoodIndex: Int?
        for i in 0..<neighborhoods.count {
            print(neighborhoods[i] + " " + sender.neighborhoodId!)
            if neighborhoods[i] == sender.neighborhoodId! {
                neighborhoodIndex = i
                print(neighborhoodIndex)
            }
        }
        if neighborhoodIndex != nil {
            neighborhoods.removeAtIndex(neighborhoodIndex!)
            print(neighborhoods)
            user?.setObject(neighborhoods, forKey: "neighborhoods")
            user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if success {
                    // Resets currentNeighborhood to the other neighborhood
                    if user?.objectForKey("currentNeighborhood") as! String == sender.neighborhoodId! {
                        if neighborhoods.count > 0 {
                            user?.setObject(neighborhoods[0], forKey: "currentNeighborhood")
                        } else {
                            user?.setObject("", forKey: "currentNeighborhood")
                            
                        }
                        
                        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if error == nil {
                                self.getHouses((user?.username)!)
                                self.listSection?.reload()
                            } else {
                                print(error?.localizedDescription)
                            }
                        })
                    }
                } else {
                    print()
                }
            })
        }

        
       

    }

    
    //Called in the completion block of the getHouses function
    func getInfo() {
        let user = User.currentUser()
        
        let medInfo = user?.objectForKey("med") as? NSArray
        var converted = Set<String>()
        
        if medInfo != nil {
            for item in medInfo! {
                converted.insert(item as! String)
            }
        }
        
        print(converted)
        
        form.setValues(["fullName": user?.objectForKey("fullName"), "bio": user?.objectForKey("bio"), "cellNum": user?.objectForKey("cellNum"), "workNum": user?.objectForKey("workNum"), "gender": user?.objectForKey("gender"), "med": converted])
        tableView?.reloadData()
        print("getting info")
    }
    
    
    // Gets the user's contact lists and then adds them to the list section
    // @param section: a form section
    // @param lists: the array of lists from Parse
    func getLists(section: Form._Element, lists: [[String: [String: String]]]?) {
        section.removeAll()
        section <<< ButtonRow("addList") {
            $0.title = "Add New List"
            $0.onCellSelection({ (cell, row) in
                self.navigationController?.pushViewController(EmergencyContactsViewController(), animated: true)
            })
        }
        // Creates the Eureka cells for each list and passes the needed info to let the user edit their list
        if lists != nil {
            for i in lists! {
                for (key, value) in i {
                    
                    let label = LabelRow()
                    label.cellSetup({ (cell, row) in
                        row.title = key
                        cell.accessoryType = .DisclosureIndicator
                    })
                    label.cellUpdate({ (cell, row) in
                        row.title = key
                        row.onCellSelection({ (cell, row) in
                            let vc = EmergencyContactsViewController()
                            vc.listName = key
                            print(vc.parseContacts)
                            print(vc.saveContacts)
                            vc.parseContacts = value
                            print(vc.parseContacts)
                            print(vc.saveContacts)
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                    })

                    
                    section.append(label)
                    
                }
            }
            
        }
    }
    
    //Open action sheet then views to change/pick a profile image
    func selectProfile(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        User.currentUser()?.setObject(getPFFileFromImage(originalImage)!, forKey: "profilePic")
        User.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                self.profileImg.file = User.currentUser()?.objectForKey("profilePic") as? PFFile
                self.profileImg.loadInBackground()
            }
        })
        dismissViewControllerAnimated(true, completion: nil)

        
    }
    
    // Sets a variable with the section object for lists
    func checkSection() {
        let section = form.sectionByTag("lists")
        if section != nil {
            self.listSection = section
        }
    }
    
  
    
    func logoutClicked() {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            print("User has logged out")
            let vc = WelcomeViewController()
            vc.modalPresentationStyle = .FullScreen
            vc.modalTransitionStyle = .CoverVertical
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
}


//
//  SafeNotSafeMenuViewController.swift
//  omni
//
//  Created by Ming Horn on 8/1/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import PageMenu
import Parse

class SafeNotSafeMenuViewController: UIViewController {
    
    var timer: NSTimer!
    var currentNeighborhood : Neighborhood!{
        didSet{
            safe = currentNeighborhood.listOfSafeNeighbors(allNeighbors)
            notSafe = currentNeighborhood.listOfUnsafeNeighbors(allNeighbors)
            unaccounted = currentNeighborhood.listOfUnaccountedNeighbors(allNeighbors)
        }
    }
    
    var cancelButton =  UIButton()
    var segmentedControl = UISegmentedControl()
    
    var descriptionLabel = UILabel()
    var nameLabel = UILabel()
    var topView = UIView()
    
    var pageMenu: CAPSPageMenu?
    var boolControllersSet = false
    
    // Array to keep track of controllers in page menu
    var controllerArray : [UIViewController] = [] {
        didSet {
            if controllerArray.count == 3 {
                boolControllersSet = true
            }
        }
    }
    
    var allNeighbors:[Neighbor] = []
    
    // fill these arrays with users based on safe / not safe / unaccounted
    var safe :[Neighbor] = [] {
        didSet {
            if boolControllersSet == true {
                (controllerArray[0] as! SafeNotSafeViewController).tableData = safe
            }
        }
    }
    var notSafe :[Neighbor] = [] {
        didSet {
            if boolControllersSet == true {
                (controllerArray[1] as! SafeNotSafeViewController).tableData = notSafe
                (controllerArray[1] as! SafeNotSafeViewController).notSafe = true
            }
        }
    }
    var unaccounted :[Neighbor] = [] {
        didSet {
            if boolControllersSet == true {
                (controllerArray[2] as! SafeNotSafeViewController).tableData = unaccounted
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        setupHeader()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        setupHeader()
        setupTimer()
    }

    
    func setupHeader() {
        //descriptionLabel.text = User.currentNeighborhood.objectForKey("emergencyDescription")
        descriptionLabel.frame = CGRect(x: 11, y: 50 , width: Int(view.bounds.width) - 11, height: 30)

        
        let currentNeighborhood = User.currentUser()?.objectForKey("currentNeighborhood") as? String
        PFQuery(className: "Neighborhoods").getObjectInBackgroundWithId(currentNeighborhood!) { (neighborhood: PFObject?, error: NSError?) in
            if let neighborhood = neighborhood {
                self.descriptionLabel.text = neighborhood.objectForKey("stateOfEmergencyDescription") as? String
                print(self.descriptionLabel.text)
                self.descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                self.descriptionLabel.textColor = UIColor.silver()
                self.descriptionLabel.font = UIFont.systemFontOfSize(14.0)
                self.descriptionLabel.numberOfLines = 0
                self.descriptionLabel.sizeToFit()
            }
        }
        
        
        
        nameLabel.frame = CGRect(x: 11, y: 26 , width: Int(view.bounds.width), height: 20)
        nameLabel.text = "State of emergency:"
        nameLabel.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightMedium)
        nameLabel.textColor = UIColor.alizarin()
        
        let endOfDescription = Int(descriptionLabel.frame.height + nameLabel.frame.height) + 26
        let endOfHeader = endOfDescription + Int(nameLabel.frame.height) + 8
        
        print(endOfDescription)
        print(endOfHeader)
        
        topView.frame = CGRectMake(0, 0, view.bounds.width, CGFloat(endOfHeader))
        topView.backgroundColor = UIColor.asphalt()
        
        cancelButton.frame = CGRectMake(view.bounds.width - 30, 22.0, 22, 22)
        cancelButton.setImage(UIImage(named: "cancelGray"), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(dismissViewController), forControlEvents: .TouchUpInside)
        
        view.addSubview(topView)
        topView.addSubview(cancelButton)
        topView.addSubview(descriptionLabel)
        topView.addSubview(nameLabel)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.asphalt()),
            .SelectionIndicatorColor (UIColor.clouds()),
            .SelectedMenuItemLabelColor(UIColor.clouds()),
            .UnselectedMenuItemLabelColor(UIColor.silver()),
            .MenuMargin(0.0),
            .MenuItemFont(UIFont.systemFontOfSize(13.0, weight: UIFontWeightRegular)),
            .CenterMenuItems(true),
            .MenuItemSeparatorPercentageHeight(0.1)
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, CGFloat(endOfHeader), self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
    }
    
    func dismissViewController(){
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
        timer = nil
    }
    
    func setupTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(refreshNeighborhood), userInfo: nil, repeats: true)
    }
    func refreshNeighborhood(){
        currentNeighborhood.updateNeighborhoodData {
            let update = self.currentNeighborhood
            self.currentNeighborhood = update
        }
    }
}

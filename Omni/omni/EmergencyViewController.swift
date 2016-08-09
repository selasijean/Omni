//
//  EmergencyViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/6/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Spring
import Material

class EmergencyViewController: UIViewController {

    var contactButton = SpringButton()
    var infoButton = UIButton()
    var policeButton = MaterialButton()

    var instructionLabel = UILabel()
    var currentNeighbors: [Neighbor]!
    var defaultNeighborsEmergencyContactListNumbers = [String: String]()
    var defaultNeighborsEmergencyContactList = [String: [String: String]]()
    var circleView: CircleLoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fillDefaultList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        circleView?.removeFromSuperview()
        addCircleView(UIColor.asphalt())

        contactButton.animation = "zoomIn"
        contactButton.curve = "easeIn"
        contactButton.duration = 2.0
        contactButton.animate()
        setUpView()
    }
    
    func setUpView() {
        
        view.backgroundColor = UIColor.clouds()
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(17.0, weight: UIFontWeightMedium)]
        self.navigationItem.title = "EMERGENCY OPTIONS"
        
        infoButton.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width - 45, y: 30, width: 30, height: 30)
        contactButton.frame = CGRect(x: 62, y: 161, width: 250, height: 250)
        instructionLabel.frame = CGRect(x: 0, y: 430, width: 375, height: 45)
        policeButton.frame = CGRect(x: 20, y: 543, width: 335, height: 53)
        
        infoButton.setImage(UIImage(named: "info"), forState: .Normal)
        infoButton.addTarget(self, action: #selector(EmergencyViewController.infoClicked), forControlEvents: .TouchUpInside)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(EmergencyViewController.callPolice(_:)))
        policeButton.addGestureRecognizer(longPress)
        policeButton.setTitle("CALL THE POLICE", forState: UIControlState.Normal)
        policeButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        policeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        policeButton.backgroundColor = UIColor.asphalt()
        policeButton.layer.cornerRadius = 10.0

        let longPress2 = UILongPressGestureRecognizer(target: self, action: #selector(EmergencyViewController.contactLists(_:)))
        contactButton.addGestureRecognizer(longPress2)
        contactButton.setTitle("HELP", forState: UIControlState.Normal)
        contactButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        contactButton.titleLabel!.numberOfLines = 0
        contactButton.setTitleColor(UIColor.clouds(), forState: UIControlState.Normal)
        contactButton.titleLabel?.font = UIFont.systemFontOfSize(36.0, weight: UIFontWeightMedium)
        contactButton.backgroundColor = UIColor.alizarin()
        contactButton.layer.cornerRadius = contactButton.frame.height/2
        contactButton.clipsToBounds = true

        instructionLabel.numberOfLines = 0
        instructionLabel.text = "Tap & Hold"
        instructionLabel.textColor = UIColor.asphalt()
        instructionLabel.textAlignment = NSTextAlignment.Center
        
        view.addSubview(infoButton)
        view.addSubview(policeButton)
        view.addSubview(instructionLabel)
        view.addSubview(contactButton)
    }
    
    func fillDefaultList() {
        for neighbor in currentNeighbors {
            if let name = neighbor.name {
                if neighbor.mobileNum != nil {
                    defaultNeighborsEmergencyContactListNumbers[name] = neighbor.mobileNum!
                } else if neighbor.workNum != nil {
                    defaultNeighborsEmergencyContactListNumbers[name] = neighbor.workNum!
                }
            }
        }
        
        defaultNeighborsEmergencyContactList["Current Neighborhood"] = defaultNeighborsEmergencyContactListNumbers
    }
    
    func addCircleView(stroke: UIColor) {
        let x = CGFloat(49.5)
        let circleWidth = CGFloat(275)
        let circleHeight = circleWidth
        
        // Create a new CircleView
        self.circleView = CircleLoadingView(frame: CGRectMake(x, 148.5, circleWidth, circleHeight))
        circleView!.circleLayer.strokeColor = stroke.CGColor
        
        view.addSubview(circleView!)
        
        // Animate the drawing of the circle over the course of 1 second
        circleView!.animateCircle(1.0)
    }
    
    func infoClicked() {
        moreInfoPopup(self.view)
    }
    
    func callPolice(sender: UIGestureRecognizer) {
        if sender.state == .Began {
            
        }
        if sender.state == .Ended {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://6507963633")!)
        }
    }
    
    func contactLists(sender: UIGestureRecognizer) {
        if sender.state == .Began {
            circleView?.removeFromSuperview()
            addCircleView(UIColor.emerald())
//            contactButton.animation = "fadeOut"
//            contactButton.curve = "easeOut"
            contactButton.duration = 1.2
            contactButton.animateToNext({
                if User.currentUser()?.objectForKey("lists") == nil {
                    if self.defaultNeighborsEmergencyContactList.count == 0 {
                        self.noEmergencyListAlert()
                        return
                    }
                }
                
                let vc = SelectListViewController()
                if self.defaultNeighborsEmergencyContactList.count != 0 {
                    vc.defaultNeighborsEmergencyContactList = self.defaultNeighborsEmergencyContactList
                }
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    func noEmergencyListAlert() {
        let alertController = UIAlertController(
            title: "No Emergency Contact Lists",
            message: "You currently do not have any neighbors or pre-set emergency contact lists. Invite your neighbors to OMNI or go to profile settings to set some emergency contact lists!",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let submitAction = UIAlertAction(
        title: "Got it!", style: UIAlertActionStyle.Default) { (action) in
        }
        
        alertController.addAction(submitAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

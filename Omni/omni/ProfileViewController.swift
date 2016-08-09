//
//  ProfileViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/6/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {

    var scrollView = UIScrollView()
    var containerView = UIView()
    
    var profilePic = PFImageView()
    var noProfilePic = UIImageView()
    var houseIcon = UIImageView()
    var nameLabel = UILabel()
    var bioLabel = UILabel()
    
    var settingsButton = UIButton()
    
    var publicInformationSeparator = UILabel()
    var medicalQualificationsLabel = UILabel()
    var medicalQualificationsCV: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    var infoPopupView = UIView()
    var instructionLabel = UILabel()
    var url = String()
    var upArrow = UIImageView()
    
    var privateInformationSeparator = UILabel()
    var privateInformationIcon = UIButton()
    var cellPhoneImage = UIImageView()
    var workPhoneImage = UIImageView()
    var emailImage = UIImageView()
    var cellPhoneNumber = UILabel()
    var workPhoneNumber = UILabel()
    var emailAddress = UILabel()
    
    var person: Neighbor!
    
    var qualifications: [String] = []
    var gender: String!
    
    var seePrivateInfo: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        loadData()
        medicalQualificationsCV?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        view.backgroundColor = UIColor.whiteColor()
        
        // other user profile
        if person.neighborPFObject.objectId != User.currentUser()?.objectId {
            settingsButton.hidden = true
            privateInformationIcon.hidden = true
            
        // personal user profile
        } else {
            person.neighborPFObject.objectId = User.currentUser()?.objectId
            privateInformationIcon.hidden = false
        }
        
        if person.medTraining != nil {
            qualifications.appendContentsOf(person.medTraining!)
            
            if !qualifications.contains("Lifeguard") {
                qualifications.append("notLifeguard")
            }
            
            if !qualifications.contains("CPR") {
                qualifications.append("notCPR")
            }
            
            if !qualifications.contains("AED") {
                qualifications.append("notAED")
            }
            
            if !qualifications.contains("First Aid") {
                qualifications.append("notFirstAid")
            }
        } else {
            qualifications.append("notLifeguard")
            qualifications.append("notCPR")
            qualifications.append("notAED")
            qualifications.append("notFirstAid")
        }
        
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        scrollView.contentSize = CGSize(width: 375, height: 1000)
        containerView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
        
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        profilePic.frame = CGRect(x: 0, y: 0, width: 375, height: 420)
        noProfilePic.frame = CGRect(x: 200, y: 220, width: 150, height: 180)
        houseIcon.frame = CGRect(x: 20, y: 385, width: 70, height: 70)
        nameLabel.frame = CGRect(x: 20, y: 460, width: 335, height: 50)
        bioLabel.frame = CGRect(x: 20, y: 514, width: 335, height: 30)
        settingsButton.frame = CGRect(x: 325, y: 35, width: 30, height: 30)
        
        noProfilePic.image = UIImage(named: "bear")
        noProfilePic.contentMode = .ScaleAspectFill
        
        houseIcon.image = UIImage(named: "house")
        houseIcon.layer.cornerRadius = houseIcon.frame.height/2
        houseIcon.clipsToBounds = true
        
        settingsButton.setImage(UIImage(named: "settings"), forState: .Normal)
        settingsButton.addTarget(self, action: #selector(settingsClicked), forControlEvents: UIControlEvents.TouchUpInside)
        
        containerView.addSubview(profilePic)
        containerView.addSubview(noProfilePic)
        containerView.addSubview(houseIcon)
        containerView.addSubview(nameLabel)
        containerView.addSubview(bioLabel)
        containerView.addSubview(settingsButton)
        
        publicInformationSeparator.backgroundColor = UIColor.clouds()
        
        medicalQualificationsLabel.text = "Medical Qualifications"
        medicalQualificationsLabel.textColor = UIColor.asphalt()
        medicalQualificationsLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        
        flowLayout.itemSize = CGSizeMake(70, 70)
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsetsMake(5,15,15,10)
        
        medicalQualificationsCV = UICollectionView(frame: CGRect(x: 0, y: 400, width: UIScreen.mainScreen().bounds.size.width, height: 70), collectionViewLayout: flowLayout)
        
        containerView.addSubview(publicInformationSeparator)
        containerView.addSubview(medicalQualificationsLabel)
        containerView.addSubview(medicalQualificationsCV!)
        
        privateInformationSeparator.backgroundColor = UIColor.clouds()
        privateInformationIcon.setImage(UIImage(named: "privateInfo"), forState: .Normal)
        privateInformationIcon.addTarget(self, action: #selector(ProfileViewController.privateInfoAlert), forControlEvents: .TouchUpInside)
        
        cellPhoneImage.image = UIImage(named: "mobile")
        workPhoneImage.image = UIImage(named: "work")
        emailImage.image = UIImage(named: "email")
        
        containerView.addSubview(privateInformationSeparator)
        containerView.addSubview(privateInformationIcon)
        containerView.addSubview(cellPhoneImage)
        containerView.addSubview(workPhoneImage)
        containerView.addSubview(emailImage)
        containerView.addSubview(cellPhoneNumber)
        containerView.addSubview(workPhoneNumber)
        containerView.addSubview(emailAddress)
        
        infoPopupView.backgroundColor = UIColor.asphalt()
        infoPopupView.layer.cornerRadius = 20.0
        infoPopupView.hidden = true
        upArrow.image = UIImage(named: "up")
        upArrow.hidden = true
        
        containerView.addSubview(infoPopupView)
        containerView.addSubview(upArrow)
    }
    
    func loadData() {
        profilePic.contentMode = .ScaleAspectFill
        if person.profilePic != nil {
            profilePic.file = person.profilePic
            noProfilePic.hidden = true
            houseIcon.layer.borderWidth = 0
        } else {
            profilePic.image = UIImage(named: "background")
            profilePic.contentMode = .ScaleAspectFill
            noProfilePic.hidden = false
            houseIcon.layer.borderWidth = 1.0
            houseIcon.layer.borderColor = UIColor.whiteColor().CGColor
        }
        profilePic.loadInBackground()
        profilePic.clipsToBounds = true
        
        nameLabel.text = person.name
        nameLabel.font = UIFont.systemFontOfSize(35.0, weight: UIFontWeightLight)
        nameLabel.textColor = UIColor.asphalt()
        
        bioLabel.text = person.bio
        bioLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightLight)
        bioLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        bioLabel.textColor = UIColor.charcoal()
        bioLabel.numberOfLines = 0
        bioLabel.sizeToFit()
        
        publicInformationSeparator.frame = CGRect(x: 0, y: 534 + bioLabel.frame.height, width: UIScreen.mainScreen().bounds.size.width, height: 1)
        medicalQualificationsLabel.frame = CGRect(x: 20, y: publicInformationSeparator.frame.origin.y + 10, width: 352, height: 32)
        medicalQualificationsCV!.frame = CGRect(x: 0, y: medicalQualificationsLabel.frame.origin.y + medicalQualificationsLabel.frame.height + 4, width: UIScreen.mainScreen().bounds.size.width, height: 70)
        
        medicalQualificationsCV!.dataSource = self
        medicalQualificationsCV!.delegate = self
        medicalQualificationsCV!.registerClass(MedicalBadgeCell.self, forCellWithReuseIdentifier: "Badge")
        medicalQualificationsCV?.backgroundColor = UIColor.whiteColor()
        
        var cellPhoneHeight = Int()
        if person.mobileNum != nil {
            cellPhoneNumber.text = person.mobileNum
            cellPhoneHeight = 30
        } else {
            cellPhoneHeight = 0
        }
        
        var workPhoneHeight = Int()
        if person.workNum != nil {
            workPhoneNumber.text = person.workNum
            workPhoneHeight = 30
        } else {
            workPhoneHeight = 0
        }
        
        var emailAddressHeight = Int()
        if person.email != nil {
            emailAddress.text = person.email
            emailAddressHeight = 30
        } else {
            emailAddressHeight = 0
        }
        
        let endofQualifications = Int(medicalQualificationsCV!.frame.origin.y + medicalQualificationsCV!.frame.height + 12)
        
        privateInformationSeparator.frame = CGRect(x: 0, y: endofQualifications, width: 375, height: 1)
        privateInformationIcon.frame = CGRect(x: 335, y: endofQualifications + 10, width: 25, height: 25)
        cellPhoneImage.frame = CGRect(x: 12, y: endofQualifications + 10, width: 30, height: cellPhoneHeight)
        cellPhoneNumber.frame = CGRect(x: 45, y: endofQualifications + 10, width: 319, height: cellPhoneHeight)
        workPhoneImage.frame = CGRect(x: 12, y: endofQualifications + cellPhoneHeight + 10, width: 30, height: workPhoneHeight)
        workPhoneNumber.frame = CGRect(x: 45, y: endofQualifications + cellPhoneHeight + 10, width: 319, height: workPhoneHeight)
        emailImage.frame = CGRect(x: 12, y: endofQualifications + cellPhoneHeight + workPhoneHeight + 10, width: 30, height: emailAddressHeight)
        emailAddress.frame = CGRect(x: 45, y: Int(endofQualifications + cellPhoneHeight + workPhoneHeight + 10), width: 319, height: emailAddressHeight)

        if person.neighborPFObject.objectId == User.currentUser()?.objectId {
            
            seePrivateInfo = Int(emailAddress.frame.origin.y) + emailAddressHeight
            
            self.scrollView.contentSize = CGSize(width: 375, height: seePrivateInfo! + 60)
            self.containerView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
            
        } else {
            self.scrollView.contentSize = CGSize(width: 375, height: endofQualifications + 70)
            self.containerView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)

            cellPhoneImage.hidden = true
            workPhoneImage.hidden = true
            emailImage.hidden = true
            cellPhoneNumber.hidden = true
            workPhoneNumber.hidden = true
            emailAddress.hidden = true
        }
    }
    
    func privateInfoAlert() {
        let alertController = UIAlertController(
            title: "Private Information",
            message: "The information in this section will never be public to your neighbors unless you mark yourself as 'Not Safe' during a state of emergency.",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let confirmAction = UIAlertAction(
        title: "Got it!", style: UIAlertActionStyle.Default) { (action) in
        }
        
        alertController.addAction(confirmAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setUpPopup() {
        instructionLabel.font = instructionLabel.font.fontWithSize(13.0)
        instructionLabel.textAlignment = NSTextAlignment.Center
        instructionLabel.textColor = UIColor.whiteColor()
        instructionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        instructionLabel.numberOfLines = 0
        instructionLabel.userInteractionEnabled = true
        instructionLabel.frame = CGRect(x: 8, y: 8, width: infoPopupView.frame.width - 16, height: infoPopupView.frame.height - 16)
        instructionLabel.userInteractionEnabled = true

        infoPopupView.addSubview(instructionLabel)
    }
    
    func openUrl(sender: UIGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func settingsClicked() {
        let vc = UINavigationController(rootViewController: PostSignUpViewController())
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return qualifications.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Badge", forIndexPath: indexPath) as! MedicalBadgeCell
        let qualification = qualifications[indexPath.row]
        print(qualification)
        cell.badge.image = UIImage(named: "\(qualification)")
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let attributes = medicalQualificationsCV?.layoutAttributesForItemAtIndexPath(indexPath)
        
        let cellRect = attributes!.frame
        let cellFrameInSuperview = medicalQualificationsCV?.convertRect(cellRect, toView: medicalQualificationsCV?.superview)
        
        let bottomEdge = Int(cellFrameInSuperview!.origin.y + cellFrameInSuperview!.height/2)
        // center is the midpoint of the cell frame
        let center = Int(cellFrameInSuperview!.origin.x + cellFrameInSuperview!.width/2)
        
        if infoPopupView.hidden {
            if qualifications[indexPath.row].containsString("not") {
                upArrow.frame = CGRect(x: center - 25, y: bottomEdge + 20, width: 50, height: 50)
                let topEdgeInfo = Int(upArrow.frame.origin.y + 25)
                
                // too close to the right edge
                if (375 - center) < (125 + 8) {
                    infoPopupView.frame = CGRect(x: 117, y: topEdgeInfo, width: 250, height: 80)
                    
                // too close to left edge
                } else if center < (125 + 8) {
                   infoPopupView.frame = CGRect(x: 8, y: topEdgeInfo, width: 250, height: 80)
                    
                // somewhere in the middle
                } else {
                    infoPopupView.frame = CGRect(x: center - 125, y: topEdgeInfo, width: 250, height: 80)
                }
                
                var urlEnding = String()
                if qualifications[indexPath.row].containsString("Lifeguard") {
                    urlEnding = "lifeguarding"
                } else if qualifications[indexPath.row].containsString("CPR") {
                    urlEnding = "cpr"
                } else if qualifications[indexPath.row].containsString("AED") {
                    urlEnding = "aed"
                } else if qualifications[indexPath.row].containsString("FirstAid") {
                    urlEnding = "first-aid"
                }
                
                url = "http://www.redcross.org/take-a-class/\(urlEnding)"
                
                instructionLabel.text = "Click this link to get certified today, and unlock this qualification! \n\(url)"
                
                setUpPopup()
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.openUrl(_:)))
                instructionLabel.addGestureRecognizer(tap)
                
                upArrow.hidden = false
                infoPopupView.hidden = false
            }
        } else {
            upArrow.hidden = true
            infoPopupView.hidden = true
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {
    func indexOf(string: String) -> String.Index? {
        return rangeOfString(string, options: .LiteralSearch, range: nil, locale: nil)?.startIndex
    }
}

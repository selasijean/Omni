//
//  SendTextsViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/11/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import SwiftRequest

class SendTextsViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    var successLabel = UILabel()
    var scrollView = UIScrollView()
    var containerView = UIView()
    
    var helpNeededLabel = UILabel()
    var police = UIButton()
    var fire = UIButton()
    var ambulance = UIButton()
    
    var medicalSituationLabel = UILabel()
    var bloodLoss = UIButton()
    var allergy = UIButton()
    var poisoning = UIButton()
    var heartAttack = UIButton()
    var choking = UIButton()
    var brokenBone = UIButton()
    var bloodLossLabel = UILabel()
    var allergyLabel = UILabel()
    var poisoningLabel = UILabel()
    var heartAttackLabel = UILabel()
    var chokingLabel = UILabel()
    var brokenBoneLabel = UILabel()
    
    var fireSituationLabel = UILabel()
    var me = UIButton()
    var others = UIButton()
    var pets = UIButton()
    var meLabel = UILabel()
    var othersLabel = UILabel()
    var petsLabel = UILabel()

    var policeEmergencies = [UIButton]()
    
    var policeSituationLabel = UILabel()
    var intruder = UIButton()
    var assault = UIButton()
    var theft = UIButton()
    var kidnapping = UIButton()
    var hostage = UIButton()
    var arson = UIButton()
    
    var policeArmedLabel = UILabel()
    var yes = UIButton()
    var no = UIButton()
    var maybe = UIButton()
    
    var customMessageView = UIView()
    var customMessageLabel = UILabel()
    var textView = UITextView()
    var characterCountLabel = UILabel()
    var sendButton = UIButton()
    
    var policeButton = UIButton()
    
    var numbersToContact: [String] = []
    
    let twilioSID = "AC9766ba47739f9da36b5246e7efca6399"
    let twilioSecret = "ffa991fd86c3fbe55c064c063a766248"
    let defaultMessage = "Tap to begin writing a custom message to send to your selected lists"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        setUpView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SendTextsViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SendTextsViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        view.backgroundColor = UIColor.clouds()
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(17.0, weight: UIFontWeightMedium)]
        self.title = "Send Texts"
        
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 119, width: 375, height: UIScreen.mainScreen().bounds.size.height - 119)
        scrollView.contentSize = CGSize(width: 375, height: 1250)
        containerView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
        
        view.addSubview(successLabel)
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        successLabel.frame = CGRect(x: 0, y: 64, width: 375, height: 55)
        successLabel.text = "Your location has been successfully shared"
        successLabel.textColor = UIColor.whiteColor()
        successLabel.textAlignment = NSTextAlignment.Center
        successLabel.backgroundColor = UIColor.emerald()
        
        policeButton.frame = CGRect(x: 20, y: 543, width: 335, height: 53)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(EmergencyViewController.callPolice(_:)))
        policeButton.addGestureRecognizer(longPress)
        policeButton.setTitle("CALL THE POLICE", forState: UIControlState.Normal)
        policeButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        policeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        policeButton.backgroundColor = UIColor.asphalt()
        policeButton.layer.borderWidth = 2.0
        policeButton.layer.borderColor = UIColor.clouds().CGColor
        policeButton.layer.cornerRadius = 10.0
        policeButton.addTarget(self, action: #selector(callPolice), forControlEvents: UIControlEvents.TouchUpInside)
        
        // type of help needed section
        
        helpNeededLabel.frame = CGRect(x: 10, y: 0, width: 355, height: 40)
        police.frame = CGRect(x: 20, y: 40, width: 100, height: 100)
        fire.frame = CGRect(x: 137, y: 40, width: 100, height: 100)
        ambulance.frame = CGRect(x: 255, y: 40, width: 100, height: 100)
        
        helpNeededLabel.text = "What kind of help do you need?"
        helpNeededLabel.textColor = UIColor.asphalt()
        helpNeededLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        helpNeededLabel.textAlignment = NSTextAlignment.Center
        
        police.backgroundColor = UIColor.asphalt()
        police.layer.cornerRadius = 10.0
        police.clipsToBounds = true
        police.setImage(UIImage(named: "police-text"), forState: .Normal)
        police.addTarget(self, action: #selector(SendTextsViewController.sendTextClicked(_:)), forControlEvents: .TouchUpInside)
        
        fire.backgroundColor = UIColor.silver()
        fire.layer.cornerRadius = 10.0
        fire.clipsToBounds = true
        fire.setImage(UIImage(named: "fire"), forState: .Normal)
        fire.addTarget(self, action: #selector(SendTextsViewController.sendTextClicked(_:)), forControlEvents: .TouchUpInside)
        
        ambulance.backgroundColor = UIColor.alizarin()
        ambulance.layer.cornerRadius = 10.0
        ambulance.clipsToBounds = true
        ambulance.setImage(UIImage(named: "ambulance"), forState: .Normal)
        ambulance.addTarget(self, action: #selector(SendTextsViewController.sendTextClicked(_:)), forControlEvents: .TouchUpInside)
        
        containerView.addSubview(helpNeededLabel)
        containerView.addSubview(police)
        containerView.addSubview(fire)
        containerView.addSubview(ambulance)
        
//      medical situation
        medicalSituationLabel.frame = CGRect(x: 10, y: 156, width: 355, height: 38)
        bloodLoss.frame = CGRect(x: 20, y: 195, width: 100, height: 100)
        allergy.frame = CGRect(x: 137, y: 195, width: 100, height: 100)
        poisoning.frame = CGRect(x: 255, y: 195, width: 100, height: 100)
        heartAttack.frame = CGRect(x: 20, y: 321, width: 100, height: 100)
        choking.frame = CGRect(x: 137, y: 321, width: 100, height: 100)
        brokenBone.frame = CGRect(x: 255, y: 321, width: 100, height: 100)
        
        bloodLossLabel.frame = CGRect(x: 20, y: 297, width: 100, height: 21)
        allergyLabel.frame = CGRect(x: 137, y: 297, width: 100, height: 21)
        poisoningLabel.frame = CGRect(x: 255, y: 297, width: 100, height: 21)
        heartAttackLabel.frame = CGRect(x: 20, y: 423, width: 100, height: 21)
        chokingLabel.frame = CGRect(x: 137, y: 423, width: 100, height: 21)
        brokenBoneLabel.frame = CGRect(x: 255, y: 423, width: 100, height: 21)
        
        medicalSituationLabel.text = "What kind of medical emergency?"
        medicalSituationLabel.textColor = UIColor.asphalt()
        medicalSituationLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        medicalSituationLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(medicalSituationLabel)
        
        let medicalEmergencies = [bloodLoss, allergy, poisoning, heartAttack, choking, brokenBone]
        
        bloodLoss.setImage(UIImage(named: "bloodLoss"), forState: .Normal)
        allergy.setImage(UIImage(named: "allergy"), forState: .Normal)
        poisoning.setImage(UIImage(named: "poisoning"), forState: .Normal)
        heartAttack.setImage(UIImage(named: "heartAttack"), forState: .Normal)
        choking.setImage(UIImage(named: "choking"), forState: .Normal)
        brokenBone.setImage(UIImage(named: "brokenBone"), forState: .Normal)
        
        for button in medicalEmergencies {
            button.layer.cornerRadius = 10.0
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(SendTextsViewController.sendTextClicked(_:)), forControlEvents: .TouchUpInside)
            containerView.addSubview(button)
        }
        
        let medicalEmergenciesLabels = [bloodLossLabel, allergyLabel, poisoningLabel, heartAttackLabel, chokingLabel, brokenBoneLabel]
        
        bloodLossLabel.text = "Blood Loss"
        allergyLabel.text = "Allergy"
        poisoningLabel.text = "Poisoning"
        heartAttackLabel.text = "Heart Attack"
        chokingLabel.text = "Choking"
        brokenBoneLabel.text = "Broken Bone"
        
        for label in medicalEmergenciesLabels {
            label.font = label.font.fontWithSize(13.0)
            label.textColor = UIColor.charcoal()
            label.textAlignment = NSTextAlignment.Center
            containerView.addSubview(label)
        }
        
//      fire situation
        fireSituationLabel.frame = CGRect(x: 10, y: 453, width: 355, height: 38)
        me.frame = CGRect(x: 20, y: 499, width: 100, height: 100)
        others.frame = CGRect(x: 137, y: 499, width: 100, height: 100)
        pets.frame = CGRect(x: 255, y: 499, width: 100, height: 100)
        
        meLabel.frame = CGRect(x: 20, y: 601, width: 100, height: 21)
        othersLabel.frame = CGRect(x: 137, y: 601, width: 100, height: 21)
        petsLabel.frame = CGRect(x: 255, y: 601, width: 100, height: 21)
        
        fireSituationLabel.text = "Who is trapped / in danger due to fire?"
        fireSituationLabel.textColor = UIColor.asphalt()
        fireSituationLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        fireSituationLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(fireSituationLabel)
        
        let fireEmergencies = [me, others, pets]
        
        me.setImage(UIImage(named: "me"), forState: .Normal)
        others.setImage(UIImage(named: "others"), forState: .Normal)
        pets.setImage(UIImage(named: "pets"), forState: .Normal)
        
        for button in fireEmergencies {
            button.layer.cornerRadius = 10.0
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(SendTextsViewController.sendTextClicked(_:)), forControlEvents: .TouchUpInside)
            containerView.addSubview(button)
        }
        
        let fireEmergenciesLabels = [meLabel, othersLabel, petsLabel]
        
        meLabel.text = "Me"
        othersLabel.text = "Others"
        petsLabel.text = "Pets"
        
        for label in fireEmergenciesLabels {
            label.font = label.font.fontWithSize(13.0)
            label.textColor = UIColor.charcoal()
            label.textAlignment = NSTextAlignment.Center
            containerView.addSubview(label)
        }
        
//      police situation
        policeSituationLabel.frame = CGRect(x: 10, y: 631, width: 355, height: 38)
        intruder.frame = CGRect(x: 20, y: 677, width: 100, height: 50)
        assault.frame = CGRect(x: 137, y: 677, width: 100, height: 50)
        theft.frame = CGRect(x: 255, y: 677, width: 100, height: 50)
        kidnapping.frame = CGRect(x: 20, y: 735, width: 100, height: 50)
        hostage.frame = CGRect(x: 137, y: 735, width: 100, height: 50)
        arson.frame = CGRect(x: 255, y: 735, width: 100, height: 50)
        
        policeSituationLabel.text = "What is the situation?"
        policeSituationLabel.textColor = UIColor.asphalt()
        policeSituationLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        policeSituationLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(policeSituationLabel)
        
        policeEmergencies = [intruder, assault, theft, kidnapping, hostage, arson]
        
        intruder.setTitle("Intruder", forState: .Normal)
        assault.setTitle("Assault", forState: .Normal)
        theft.setTitle("Theft", forState: .Normal)
        kidnapping.setTitle("Kidnapping", forState: .Normal)
        hostage.setTitle("Hostage", forState: .Normal)
        arson.setTitle("Arson", forState: .Normal)
        
        for button in policeEmergencies {
            button.setTitleColor(UIColor.charcoal(), forState: .Normal)
            button.titleLabel!.font = button.titleLabel!.font.fontWithSize(14.0)
            button.layer.cornerRadius = 10.0
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(SendTextsViewController.sendTextClicked(_:)), forControlEvents: .TouchUpInside)
            containerView.addSubview(button)
        }
        
//      armed situation
        policeArmedLabel.frame = CGRect(x: 10, y: 794, width: 355, height: 38)
        yes.frame = CGRect(x: 20, y: 840, width: 100, height: 100)
        no.frame = CGRect(x: 137, y: 840, width: 100, height: 100)
        maybe.frame = CGRect(x: 255, y: 840, width: 100, height: 100)
        
        policeArmedLabel.text = "Is the perpetrator armed?"
        policeArmedLabel.textColor = UIColor.asphalt()
        policeArmedLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        policeArmedLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(policeArmedLabel)
        
        let armedEmergencies = [yes, no, maybe]
        
        yes.setImage(UIImage(named: "armedYes"), forState: .Normal)
        no.setImage(UIImage(named: "armedNo"), forState: .Normal)
        maybe.setImage(UIImage(named: "armedMaybe"), forState: .Normal)
        
        for button in armedEmergencies {
            button.layer.cornerRadius = 10.0
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(SendTextsViewController.sendTextClicked(_:)), forControlEvents: .TouchUpInside)
            containerView.addSubview(button)
        }

//      custom message
        customMessageView.frame = CGRect(x: 20, y: 949, width: 335, height: 180)
        customMessageLabel.frame = CGRect(x: 0, y: 0, width: 335, height: 38)
        textView.frame = CGRect(x: 0, y: 40, width: 335, height: 100)
        characterCountLabel.frame = CGRect(x: 268, y: 145, width: 30, height: 30)
        sendButton.frame = CGRect(x: 305, y: 145, width: 30, height: 30)
        
        customMessageLabel.text = "Write a custom message"
        customMessageLabel.textColor = UIColor.asphalt()
        customMessageLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        customMessageLabel.textAlignment = NSTextAlignment.Center
        
        textView.delegate = self
        textView.text = defaultMessage
        textView.textColor = UIColor.charcoal()
        textView.font = textView.font?.fontWithSize(15.0)
        textView.backgroundColor = UIColor.clouds()
        textView.layer.borderWidth = 1.5
        textView.layer.borderColor = UIColor.silver().CGColor
        textView.layer.cornerRadius = 10.0
        
        characterCountLabel.text = "160"
        characterCountLabel.textColor = UIColor.silver()
        
        sendButton.setImage(UIImage(named: "send"), forState: .Normal)
        sendButton.addTarget(self, action: #selector(SendTextsViewController.sendCustomMessage(_:)), forControlEvents: .TouchUpInside)
        
        customMessageView.addSubview(customMessageLabel)
        customMessageView.addSubview(textView)
        customMessageView.addSubview(characterCountLabel)
        customMessageView.addSubview(sendButton)
        containerView.addSubview(customMessageView)
        
        view.addSubview(policeButton)
    }
    
    func textViewDidChange(textView: UITextView) {
        characterCountLabel.text = "\(160 - textView.text.characters.count)"
        if 160 - textView.text.characters.count < 0 {
            characterCountLabel.textColor = UIColor.alizarin()
        } else {
            characterCountLabel.textColor = UIColor.charcoal()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.charcoal() {
            textView.text = ""
            textView.textColor = UIColor.asphalt()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = defaultMessage
            textView.textColor = UIColor.charcoal()
        }
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 150
    }
    
    
    func sendTextClicked(sender: UIButton) {
        
        if sender.selected == true {
            self.successLabel.backgroundColor = UIColor.alizarin()
            self.successLabel.text = "You have already requested this"
            return
        }
        
        var message = ""
        if sender == police {
            message = "Please request a police car to my current location"
        } else if sender == fire {
            message = "Please request a fire truck to my current location"
        } else if sender == ambulance {
            message = "Please request an ambulance to my current location"
        } else if sender == bloodLoss {
            message = "Medical Emergency: Blood Loss"
        } else if sender == allergy {
            message = "Medical Emergency: Allergic Reaction"
        } else if sender == poisoning {
            message = "Medical Emergency: Poisoning"
        } else if sender == heartAttack {
            message = "Medical Emergency: Heart Attack"
        } else if sender == choking {
            message = "Medical Emergency: Choking, in need of CPR"
        } else if sender == brokenBone {
            message = "Medical Emergency: Broken Bone"
        } else if sender == me {
            let userFullName = User.currentUser()?.objectForKey("fullName")
            message = "Fire Emergency: \(userFullName!) is trapped and/or in danger"
        } else if sender == others {
            message = "Fire Emergency: Others are trapped and/or in danger"
        } else if sender == pets {
            message = "Fire Emergency: Pets are trapped and/or in danger"
        } else if sender == intruder {
            message = "Police Emergency: General intruder"
        } else if sender == assault {
            message = "Police Emergency: Assault"
        } else if sender == theft {
            message = "Police Emergency: Theft / Burglary"
        } else if sender == kidnapping {
            message = "Police Emergency: Kidnapping"
        } else if sender == hostage {
            message = "Police Emergency: Hostage Situation"
        } else if sender == arson {
            message = "Police Emergency: Arson"
        } else if sender == yes {
            message = "Police Emergency: Perpetrator is armed"
        } else if sender == no {
            message = "Police Emergency: Perpetrator is not armed"
        } else if sender == maybe {
            message = "Police Emergency: Unsure if perpetrator is armed"
        }
        
        for toNumber in numbersToContact {
            // Build the request
            let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
            request.HTTPMethod = "POST"
            request.HTTPBody = "From=%2B12132796664&To=\(toNumber)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
            
            // Build the completion block and send the request
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                print("Finished")
                if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    // Success
                    print("Response: \(responseDetails)")
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        sender.selected = true
                        
                        // move block outside of for loop
                        self.successLabel.backgroundColor = UIColor.emerald()
                        self.successLabel.text = "Your request has successfully sent"
                        
                        let checkmark = showCheckmark(sender)
                        if sender != self.police && sender != self.fire && sender != self.ambulance {
                            sender.backgroundColor = UIColor.whiteColor()
                        }
                        self.containerView.addSubview(checkmark)
                    }
                    
                } else {
                    // Failure
                    print("Error: \(error)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.successLabel.backgroundColor = UIColor.alizarin()
                        self.successLabel.text = "Your request has failed to send"
                        // break (uncomment in for loop)
                    }
                }
            }).resume()
        }
    }
    
    func sendCustomMessage(sender: UIButton) {
        
        let message = textView.text
        
        if message == defaultMessage {
            self.successLabel.backgroundColor = UIColor.alizarin()
            self.successLabel.text = "Please write a custom message first"
            return
        }
        
        if message.characters.count > 160 {
            self.successLabel.backgroundColor = UIColor.alizarin()
            self.successLabel.text = "Your message must be less than 160 characters"
            return
        }
        
        for toNumber in numbersToContact {
            // Build the request
            let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
            request.HTTPMethod = "POST"
            request.HTTPBody = "From=%2B12132796664&To=\(toNumber)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
            
            // Build the completion block and send the request
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                print("Finished")
                if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    // Success
                    print("Response: \(responseDetails)")
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        sender.selected = true
                        
                        // move block outside of for loop
                        self.successLabel.backgroundColor = UIColor.emerald()
                        self.successLabel.text = "Your request has successfully sent"
                        self.textView.text = self.defaultMessage
                        self.textView.textColor = UIColor.charcoal()
                        self.characterCountLabel.text = "160"
                    }
                    
                } else {
                    // Failure
                    print("Error: \(error)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.successLabel.backgroundColor = UIColor.alizarin()
                        self.successLabel.text = "Your request has failed to send"
                        // break (uncomment in for loop)
                    }
                }
            }).resume()
        }
    }
    
    func callPolice(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://6507963633")!)
        }
    }
}
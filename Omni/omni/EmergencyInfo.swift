//
//  EmergencyInfo.swift
//  omni
//
//  Created by Sarah Zhou on 7/20/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Spring

class EmergencyInfo: SpringView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var blur = UIVisualEffectView()
    var infoView = UIView()
    let cancelButton = UIButton()
    let infoLabel = UILabel()
    let actualInfo = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blur.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        infoView.frame = CGRect(x: 26, y: 100, width: 322, height: 438)
        cancelButton.frame = CGRect(x: 290, y: 18, width: 20, height: 20)
        infoLabel.frame = CGRect(x: 30, y: 18, width: 262, height: 20)
        actualInfo.frame = CGRect(x: 12, y: 45, width: 298, height: 350)
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)

        let blurEffect = UIBlurEffect(style: .Dark)
        blur = UIVisualEffectView(effect: blurEffect)
        
        infoView.backgroundColor = UIColor.whiteColor()
        infoView.layer.borderWidth = 2.0
        infoView.layer.borderColor = UIColor.alizarin().CGColor
        infoView.layer.cornerRadius = 20.0
        
        cancelButton.setImage(UIImage(named: "cancelGray"), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(EmergencyInfo.cancelInfoPopup(_:)), forControlEvents: .TouchUpInside)
        
        infoLabel.text = "Emergency Button Purpose"
        infoLabel.textAlignment = NSTextAlignment.Center
        infoLabel.textColor = UIColor.asphalt()
        infoLabel.font = UIFont.boldSystemFontOfSize(17.0)
        
        actualInfo.text = "Note: this feature is not mutually exclusive with calling the police. \n\nThe OMNI Emergency Button is a way to notify your personal emergency contact lists and/or your current neighborhood with pertinent, real-time information through SMS. \n\nThis feature provides pre-set situations that you can select and instantaneously send to your selected emergency contacts. \n\nDon't stress over what to say, just click."
        actualInfo.textAlignment = NSTextAlignment.Center
        actualInfo.sizeToFit()
        actualInfo.lineBreakMode = NSLineBreakMode.ByWordWrapping
        actualInfo.numberOfLines = 0
        actualInfo.textColor = UIColor.asphalt()
        actualInfo.font = actualInfo.font.fontWithSize(16.0)
        
        self.addSubview(blur)
        self.addSubview(infoView)
        infoView.addSubview(cancelButton)
        infoView.addSubview(infoLabel)
        infoView.addSubview(actualInfo)
    }
    
    func cancelInfoPopup(sender: UIButton) {
        let infoView = sender.superview! as UIView
        let originalView = infoView.superview! as! SpringView
        
        originalView.animation = "fadeOut"
        originalView.curve = "easeIn"
        originalView.duration = 2.0
        originalView.animate()
    }
}

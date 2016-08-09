//
//  EmergencyInfoCell.swift
//  omni
//
//  Created by Jean Adedze on 7/15/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Material

class EmergencyInfoCell: MaterialTableViewCell {
    
    var emergencyInfoTypeLabel: UILabel!
    var emergencyInfoPreviewLabel: UILabel!
    var noEmergencyInfoLabel: UILabel!
    let cardView = CardView(frame: CGRectMake(10, 10, 355, 68))
    
    let icons: [String: UIImage] = ["Local Police" : UIImage(named: "police")!, "Local Hospital" : UIImage(named: "hospital")!, "University Security" : UIImage(named: "university")!, "Neighborhood Private Security" : UIImage(named: "security")!]
    var icon: UIImage?
    
    var infoType: String!{
        didSet{
            updateInfoTypeLabel()
            hideNoEmergencyInfoLabel()
            
            self.icon = icons[infoType]
            let iconView = FabButton()
            let frameForInfoIcon = CGRectMake(8, 8, 45, 45)

            iconView.frame = frameForInfoIcon
            iconView.setImage(icon, forState: .Normal)
            iconView.backgroundColor = UIColor.whiteColor()
            iconView.shadowOpacity = 0.0
            iconView.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            cardView.addSubview(iconView)
        }
    }
    var infoPreview: String!{
        didSet{
            updateInforPreviewLabel()
            hideNoEmergencyInfoLabel()
        }
    }

    override func prepareView() {
        super.prepareView()
        
        cardView.divider = false
        cardView.shadowOpacity = 0.0
        
        let frameForInfoTypeLabel = CGRectMake(61, 8, 300, 34)
        let frameForInfoPreview = CGRectMake(61, 35, 300, 20)
        let frameForActionButton = CGRectMake(300, 8, 45, 45)
        
        
        emergencyInfoTypeLabel = UILabel(frame: frameForInfoTypeLabel)
        emergencyInfoTypeLabel.font = UIFont.systemFontOfSize(14.0)
        emergencyInfoTypeLabel.textColor = UIColor.asphalt()
        
        emergencyInfoPreviewLabel = UILabel(frame: frameForInfoPreview)
        emergencyInfoPreviewLabel.textColor = UIColor.charcoal()
        emergencyInfoPreviewLabel.font = UIFont.systemFontOfSize(13.0, weight: UIFontWeightLight)
        
        let contactButton = FabButton(frame: frameForActionButton)
        contactButton.backgroundColor = UIColor.clouds()
        
        let img = UIImage(named: "phoneSafe")
        contactButton.setImage(img, forState: UIControlState.Normal)
        contactButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        contactButton.setImage(img, forState: UIControlState.Highlighted)
        contactButton.shadowOpacity = 0.0
        
        noEmergencyInfoLabel = UILabel()
        noEmergencyInfoLabel.frame =  CGRect(x: 0, y: 0, width: 375, height: 80)
        noEmergencyInfoLabel.text = "  No Emergency Info inputted."
        noEmergencyInfoLabel.backgroundColor = UIColor.whiteColor()
        noEmergencyInfoLabel.textColor = UIColor.lightGrayColor()
        noEmergencyInfoLabel.hidden = true
        
        
        cardView.addSubview(contactButton)
        cardView.addSubview(emergencyInfoTypeLabel)
        cardView.addSubview(emergencyInfoPreviewLabel)
        
        contentView.addSubview(cardView)
        contentView.addSubview(noEmergencyInfoLabel)
        
    }
    
    func showNoEmergencyInfoLabel(){
        noEmergencyInfoLabel.hidden = false
    }
    func hideNoEmergencyInfoLabel(){
        noEmergencyInfoLabel.hidden = true
    }
    
    func updateInfoTypeLabel(){
        emergencyInfoTypeLabel.text = infoType
    }
    
    func updateInforPreviewLabel(){
        emergencyInfoPreviewLabel.text = infoPreview
    }

}

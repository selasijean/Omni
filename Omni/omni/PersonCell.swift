//
//  PeopleCell.swift
//  omni
//
//  Created by Sarah Zhou on 7/14/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PersonCell: UITableViewCell {
    
    var profPic = PFImageView()
    var phoneNum : String?
    var nameLabel = UILabel()
    var phoneButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profPic.frame = CGRect(x: 8, y: 11, width: 48, height: 48)
        profPic.contentMode = UIViewContentMode.ScaleAspectFill
        profPic.layer.cornerRadius = profPic.frame.height/2
        profPic.clipsToBounds = true
        contentView.addSubview(profPic)
        
        nameLabel.frame = CGRect(x: 61, y: 23, width: 252, height: 23)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.font = nameLabel.font.fontWithSize(17.0)
        nameLabel.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightMedium)
        contentView.addSubview(nameLabel)
        
        phoneButton.frame = CGRect(x: 326, y: 24, width: 32, height: 32)
        phoneButton.addTarget(self, action: #selector(callSelectedPerson), forControlEvents: .TouchUpInside)
        contentView.addSubview(phoneButton)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func callSelectedPerson() {
        if let num = phoneNum {
            let phoneNumberToCall = "tel://\(num)"
            UIApplication.sharedApplication().openURL(NSURL(string: phoneNumberToCall)!)
//            UIApplication.sharedApplication().openURL(NSURL(string: "tel://6507963633")!)
        }
    }
}

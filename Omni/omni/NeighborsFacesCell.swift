//
//  NeighborsFacesCell.swift
//  omni
//
//  Created by Jean Adedze on 7/15/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Material
import ParseUI

class NeighborsFacesCell: MaterialCollectionViewCell {
    
    var profileImageView: PFImageView!
    override func prepareView() {
        super.prepareView()
        
        
        profileImageView = PFImageView(frame: CGRectMake(0, 0, 60, 60))
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .ScaleAspectFill
        profileImageView.backgroundColor = UIColor.groupTableViewBackgroundColor()

        contentView.addSubview(profileImageView)
    }

}

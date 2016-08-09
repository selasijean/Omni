//
//  ProfileImage.swift
//  omni
//
//  Created by Ming Horn on 7/14/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import ParseUI


class ProfileImage: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Profile picture
        let profileImg = PFImageView()
        profileImg.image = UIImage(named: "user-female-44")
        profileImg.file = User.currentUser()?.objectForKey("profilePic") as? PFFile
        profileImg.loadInBackground()
        profileImg.frame = CGRect(x: 150, y: 100, width: 44, height: 44)
        addSubview(profileImg)
    }

}

//
//  PoliceButton.swift
//  omni
//
//  Created by Ming Horn on 8/1/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit

class PoliceButton: UIButton {

    let buttonText = "CALL THE POLICE"
    var overlayView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.asphalt()
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        overlayView.backgroundColor = UIColor.emerald()
        overlayView.alpha = 1
        self.addSubview(overlayView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

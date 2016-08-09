//
//  UIButton+CustomView.swift
//  omni
//
//  Created by Sarah Zhou on 7/18/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import Swift
import UIKit

extension UIButton {
    
    func showCheckmark() -> UIImageView {
        
        let checkmark = UIImageView(image: UIImage(named: "checkmark"))
        checkmark.frame = CGRect(x: 80, y: -20, width: 40, height: 40)

        return checkmark
    }
}

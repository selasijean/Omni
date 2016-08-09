//
//  MedicalBadgeCell.swift
//  omni
//
//  Created by Sarah Zhou on 7/25/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit

class MedicalBadgeCell: UICollectionViewCell {
    
    var badge = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        badge.frame = CGRect(x: 0, y: 4, width: 70, height: 70)
        badge.contentMode = UIViewContentMode.ScaleAspectFill
        badge.layer.cornerRadius = badge.frame.height/2
        badge.clipsToBounds = true
        contentView.addSubview(badge)
    }
}

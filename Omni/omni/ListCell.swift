//
//  ListCell.swift
//  omni
//
//  Created by Sarah Zhou on 7/12/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    
    var descriptionLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        descriptionLabel.frame = CGRect(x: 16, y: 14, width: 323, height: 21)
        descriptionLabel.textColor = UIColor.blackColor()
        contentView.addSubview(descriptionLabel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

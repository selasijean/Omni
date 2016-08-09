//
//  NetworkConnectionError.swift
//  omni
//
//  Created by Sarah Zhou on 7/20/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Spring

class NetworkConnectionError: SpringView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.alizarin()
        
        let tapToTryAgain = UITapGestureRecognizer(target: self, action: #selector(NetworkConnectionError.tryAgainClicked(_:)))
        self.addGestureRecognizer(tapToTryAgain)
        
        let cancelImageView = UIImageView(image: UIImage(named: "cancel"))
        cancelImageView.frame = CGRect(x: 8, y: 10, width: 40, height: 40)
        
        let networkErrorMessage = UILabel()
        networkErrorMessage.frame = CGRect(x: 56, y: 11, width: 310, height: 20)
        networkErrorMessage.text = "No Internet Connection"
        networkErrorMessage.textColor = UIColor.whiteColor()
        networkErrorMessage.font = UIFont.boldSystemFontOfSize(17.0)
        
        let tryAgainMessage = UILabel()
        tryAgainMessage.frame = CGRect(x: 56, y: 32, width: 310, height: 18)
        tryAgainMessage.text = "Tap to try again"
        tryAgainMessage.lineBreakMode = NSLineBreakMode.ByWordWrapping
        tryAgainMessage.numberOfLines = 0
        tryAgainMessage.textColor = UIColor.whiteColor()
        tryAgainMessage.font = tryAgainMessage.font.fontWithSize(15.0)
        
        self.addSubview(cancelImageView)
        self.addSubview(networkErrorMessage)
        self.addSubview(tryAgainMessage)
    }
    
    func tryAgainClicked(sender: UIGestureRecognizer) {
        let networkError = sender.view as! SpringView
        
        if Reachability.isConnectedToNetwork() {
            networkError.animation = "fadeOut"
            networkError.curve = "easeIn"
            networkError.duration = 1.0
            networkError.animate()
        }
    }
}

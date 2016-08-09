//
//  MedicsViewController.swift
//  omni
//
//  Created by Jean Adedze on 7/18/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import PageMenu

class MedicsViewController: UIViewController {

    var pageMenu : CAPSPageMenu?
    var medics :[Neighbor]!{
        didSet{
            controller.medics = medics
            controller2.medics = medics
        }
    }
    var controller = ListOfMedicsViewController()
    var controller2 = ListOfMedicsViewController()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        setupPageMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupPageMenu(){
        
        var controllerArray : [UIViewController] = []
        controller.title = "High Priority"
        controller2.title = "Low Priority"
        controllerArray.append(controller)
        controllerArray.append(controller2)
        
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .SelectionIndicatorColor (UIColor.redColor()),
            .SelectedMenuItemLabelColor(UIColor.asphalt()),
            .MenuItemSeparatorWidth(4.3),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorPercentageHeight(0.1)
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height - 49), pageMenuOptions: parameters)
        pageMenu?.delegate = self
        pageMenu?.scrollMenuBackgroundColor = UIColor.blackColor()
        self.view.addSubview(pageMenu!.view)
    }
    

}
extension MedicsViewController: CAPSPageMenuDelegate{
    
    func willMoveToPage(controller: UIViewController, index: Int){
        if index == 1{
            let toController = controller as! ListOfMedicsViewController
            toController.highPriority = false
        }
    }
}
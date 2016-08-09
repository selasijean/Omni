//
//  MenuViewController.swift
//  omni
//
//  Created by Jean Adedze on 7/13/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Material
import MBProgressHUD


class MenuViewController: UIViewController {
    
    var tableView: UITableView!
    var userNeighborhoods: [Neighborhood] = []
    var profileContainerView: MaterialView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupProfileView()
        prepareTableView()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
 
    }
    
    func setupView(){
        view.backgroundColor = MaterialColor.grey.darken4
        view.alpha = 0.9
        
    }
    
    func setupProfileView(){
        let frameForContainerView = CGRectMake(0, 0,view.bounds.width, 64)
        profileContainerView = MaterialView(frame: frameForContainerView)
        profileContainerView.backgroundColor = UIColor.asphalt()
        let frameForProfileView = CGRectMake(10, 12, 40, 40)
        let profileView = PFImageView(frame: frameForProfileView)
        profileView.contentMode = .ScaleAspectFill
        if let profileFile = User.currentUser()?.objectForKey("profilePic") as? PFFile{
            profileView.file = profileFile
            profileView.loadInBackground()
        }else{
            profileView.image = UIImage(named: "default")
        }
        profileView.layer.cornerRadius = profileView.frame.height / 2
        profileView.layer.masksToBounds = true
        profileView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        let frameForNameLabel = CGRectMake(58, 16, 150, 35)
        let nameLabel = UILabel(frame: frameForNameLabel)
        nameLabel.textColor = UIColor.clouds()
        nameLabel.text = User.currentUser()?.objectForKey("fullName") as? String
        nameLabel.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightBold)
        profileContainerView.addSubview(nameLabel)
        profileContainerView.addSubview(profileView)
        view.addSubview(profileContainerView)
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    func prepareTableView(){
        
        tableView = UITableView()
        tableView.registerClass(MaterialTableViewCell.self, forCellReuseIdentifier: "MenuTableViewCell")
        tableView.backgroundColor = MaterialColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        view.layout(tableView).edges(top: profileContainerView.bounds.height)
        
    }
    
    func passSelectedNeighborhoodListOfNeighborsToHomeVC(neighborhoodID: String){
        

        let housesArray = User.currentUser()?.objectForKey("houses") as! [String]
        let vc = self.navigationDrawerController?.rootViewController as! NavigationController
        let homeVC = vc.viewControllers.first as! HomeViewController
        let loadingVC = AppDelegate.getAppDelegate().loadingVC
        let emergencyVC = loadingVC.getEmergencyVC().viewControllers.first as! EmergencyViewController
        
        let queryForHouses = PFQuery(className: "House")
        queryForHouses.whereKey("objectId", containedIn: housesArray)
        queryForHouses.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) in
            if error == nil{
                var houses = [House]()
                for house in results!{
                    if (house["neighborhood"] as! String) == neighborhoodID{
                        houses.append(House(parseObject: house))
                    }
                }
                homeVC.userHouses = houses
                
            }else{
                print(error?.localizedDescription)
            }
        }
        
        let queryForNeighborsInRecentNeighborhood = PFQuery(className: "_User")
        queryForNeighborsInRecentNeighborhood.whereKey("neighborhoods", equalTo: neighborhoodID)
        queryForNeighborsInRecentNeighborhood.findObjectsInBackgroundWithBlock { (results:[PFObject]?,error:NSError?) in
            if error == nil{
                var neighbors = [Neighbor]()
                for neighbor in results!{
                    if neighbor.objectId != User.currentUser()?.objectId{
                        neighbors.append(Neighbor(neighbor: neighbor))
                    }
                }
                homeVC.allNeighbors = neighbors
                emergencyVC.currentNeighbors = neighbors
                homeVC.fillCurrentNeighborsNumbers()
                homeVC.tableView.reloadData()
                MBProgressHUD.hideHUDForView((self.navigationDrawerController?.rootViewController.view)!, animated: true)
            }else{
                print(error?.localizedDescription)
            }
        }
    }

}
extension MenuViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return userNeighborhoods.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuTableViewCell", forIndexPath: indexPath)
        
        if indexPath.row == userNeighborhoods.count{
            cell.textLabel?.text = "Settings"
            cell.textLabel?.textColor = MaterialColor.grey.lighten2
            cell.textLabel!.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
            cell.backgroundColor = MaterialColor.clear
            return cell
        }
        
        let neighborhood = userNeighborhoods[indexPath.row]
        cell.textLabel?.text = neighborhood.title
        cell.textLabel?.textColor = MaterialColor.grey.lighten2
        cell.textLabel!.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightMedium)
        cell.backgroundColor = MaterialColor.clear
        
        return cell
    }
}

extension MenuViewController: UITableViewDelegate{
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let navVC = self.navigationDrawerController?.rootViewController as! NavigationController
        let homeVC = navVC.viewControllers.first as! HomeViewController
        if indexPath.row != userNeighborhoods.count{
            MBProgressHUD.showHUDAddedTo((navigationDrawerController?.rootViewController.view)!, animated: true)
            
            
            let neighborhood = userNeighborhoods[indexPath.row]
            homeVC.currentNeighborhood = neighborhood
            
            homeVC.refreshDropDownMenu()
            navigationDrawerController?.closeLeftView()
            passSelectedNeighborhoodListOfNeighborsToHomeVC(neighborhood.neighborhoodID!)
            User.currentUser()?.setObject(neighborhood.neighborhoodID!, forKey: "currentNeighborhood")
            User.currentUser()?.saveInBackground()
        }else{
            let controller: NavigationController = (navigationDrawerController?.rootViewController as? NavigationController)!
            navigationDrawerController?.closeLeftView()
            let settingsVC = NeighborhoodSettingsViewController()
            settingsVC.neighborhood = homeVC.currentNeighborhood.neighborhoodParseObject
            settingsVC.fromHomeSettings = true
            controller.pushViewController(settingsVC, animated: true)
        }
        
    }
}

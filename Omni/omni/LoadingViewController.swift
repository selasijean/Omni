//
//  LoadingViewController.swift
//  omni
//
//  Created by Jean Adedze on 7/22/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Material
import Parse

class LoadingViewController: UIViewController {
    
    var tabBar = UITabBarController()
    var newUser: Bool = false
    private var homeVC: HomeViewController = HomeViewController()
    private var menuVC: MenuViewController = MenuViewController()
    private var emergencyNavigationVC = UINavigationController(rootViewController: EmergencyViewController())
    private var profile = ProfileViewController()
    
    private var userNeighborhoodsFromParse:[PFObject]!{
        didSet{
            var neighborhoods = [Neighborhood]()
            for object in userNeighborhoodsFromParse{
                if object.objectId! == (User.currentUser()?.objectForKey("currentNeighborhood"))! as! String{
                    recentNeighborhood = Neighborhood(parseObject: object)
                }
                neighborhoods.append(Neighborhood(parseObject: object))
            }
            userNeighborhoods = neighborhoods
        }
    }
    
    private var recentNeighborhoodNeighborsFromParse:[PFObject]!{
        didSet{
            var neighbors = [Neighbor]()
            for neighbor in recentNeighborhoodNeighborsFromParse{
                if neighbor.objectId != User.currentUser()?.objectId{
                    neighbors.append(Neighbor(neighbor: neighbor))
                }else{
                    profile.person = Neighbor(neighbor: neighbor)
                }
            }
            recentNeighborhoodNeighbors = neighbors
        }
    }
    
    private var housesFromParse:[PFObject]!{
        didSet{
            var houses = [House]()
            for house in housesFromParse{
                houses.append(House(parseObject: house))
            }
            userHouses = houses
        }
    }
    
    private var userHouses: [House]!{
        didSet{
            homeVC.userHouses = userHouses
        }
    }
    private var userNeighborhoods:[Neighborhood]!{
        didSet{
            menuVC.userNeighborhoods = userNeighborhoods
        }
    }
    
    private var recentNeighborhood:Neighborhood!{
        didSet{
            homeVC.currentNeighborhood = recentNeighborhood
        }
    }
    
    private var recentNeighborhoodNeighbors:[Neighbor]!{
        didSet{
            let emergencyVC = emergencyNavigationVC.viewControllers.first as! EmergencyViewController
            emergencyVC.currentNeighbors = recentNeighborhoodNeighbors
            homeVC.allNeighbors = recentNeighborhoodNeighbors
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        setupFauxTabBar()
        setupTabBar()
        pullCurrentUserDataFromParse {
            if self.newUser == true {
                self.homeVC.newUser = true
            }
            self.presentViewController(self.tabBar, animated: false, completion: nil)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupFauxTabBar(){
        let frame = CGRectMake(0, 0, 375, 64)
        let frameForTabBar = CGRectMake(0, view.bounds.height - 49, 375, 49)
        let navigationBar = UINavigationBar(frame: frame)
        let tabBarItem = UITabBar(frame: frameForTabBar)
        navigationBar.barTintColor = UIColor.asphalt()
        view.addSubview(navigationBar)
        view.addSubview(tabBarItem)
    }
    
    func setupTabBar(){
        
        tabBar = UITabBarController()
        let navigationController = NavigationController(rootViewController: homeVC)
        let navigationDrawerController = NavigationDrawerController(rootViewController: navigationController, leftViewController: menuVC, rightViewController: nil)
        navigationDrawerController.animationDuration = 0.5
        
        navigationDrawerController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "home"), tag: 0)
        emergencyNavigationVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "help"), tag: 1)
        profile.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile"), tag: 2)
        navigationDrawerController.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
        emergencyNavigationVC.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
        profile.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
        
        UITabBar.appearance().tintColor = UIColor.asphalt()
        let vcs = [navigationDrawerController, emergencyNavigationVC, profile]
        tabBar.viewControllers = vcs
//        tabBar.selectedIndex = 1

    }
    
    func pullCurrentUserDataFromParse(completion:() -> ()){
        
        let recentNeighborhood = User.currentUser()?.objectForKey("currentNeighborhood") as! String
        let housesArray = User.currentUser()?.objectForKey("houses") as! [String]
        let userId = PFUser.currentUser()?.objectId
        
        //query object for user's neighborhoods
        let query = PFQuery(className: "Neighborhoods")
        query.whereKey("users", equalTo: userId!)
        //query object for user's houses
        let queryForHouses = PFQuery(className: "House")
        queryForHouses.whereKey("objectId", containedIn: housesArray)
        //query object for neighbors in user's neighborhood
        let queryForNeighborsInRecentNeighborhood = PFQuery(className: "_User")
        queryForNeighborsInRecentNeighborhood.whereKey("neighborhoods", equalTo: recentNeighborhood)
        
        query.findObjectsInBackgroundWithBlock({ (neighborhoods:[PFObject]?, error: NSError?) in
            if error == nil{
                self.userNeighborhoodsFromParse = neighborhoods
                for neighborhood in neighborhoods!{
                    if neighborhood.objectId == recentNeighborhood{
                        self.recentNeighborhood = Neighborhood(parseObject: neighborhood)
                    }
                }
                queryForHouses.findObjectsInBackgroundWithBlock { (houses: [PFObject]?, error: NSError?) in
                    if error == nil{
                        self.housesFromParse = houses
                        queryForNeighborsInRecentNeighborhood.findObjectsInBackgroundWithBlock { (neighbors:[PFObject]?,error:NSError?) in
                            if error == nil{
                                self.recentNeighborhoodNeighborsFromParse = neighbors
                                completion()
                            }else{
                                print(error?.localizedDescription)
                            }
                        }
                    }else{
                        print(error?.localizedDescription)
                    }
                }
                
                
            }
        })
        
        
        
        
        
        
        
    }
    
    func getEmergencyVC() -> UINavigationController{
        return emergencyNavigationVC
    }
    
    func getMenuVC() -> MenuViewController{
        return menuVC
    }
    
    class func getLoadingViewController() -> LoadingViewController {
        return self.init()
    }

}

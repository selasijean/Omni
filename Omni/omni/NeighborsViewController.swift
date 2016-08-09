//
//  NeighborsViewController.swift
//  omni
//
//  Created by Jean Adedze on 7/18/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import ParseUI
import Material

class NeighborsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var neighbors:[Neighbor] = []    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setupTableView(){
        
        tableView = UITableView()
        let frame = CGRectMake(0, 0, 375, 552)
        tableView.frame = frame
        tableView.separatorStyle = .SingleLine
        tableView.registerClass(PersonCell.self, forCellReuseIdentifier: "Neighbors")
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return neighbors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {


        let cell = tableView.dequeueReusableCellWithIdentifier("Neighbors", forIndexPath: indexPath) as! PersonCell
        cell.selectionStyle = .None
        
        let neighbor = neighbors[indexPath.row]
        cell.nameLabel.text = neighbor.name
        cell.nameLabel.font = RobotoFont.regularWithSize(15)
        
        cell.profPic.frame = CGRectMake(10, 10, 40, 40)
        cell.profPic.layer.cornerRadius = 20
        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
        cell.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
        if let picture = neighbor.profilePic{
            cell.profPic.file = picture as PFFile
            cell.profPic.loadInBackground()
        }else{
            cell.profPic.image = UIImage(named: "default")
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let neighbor = neighbors[indexPath.row]
        let profileVC = ProfileViewController()
        profileVC.person = neighbor
        let navControl = self.navigationController
        navControl!.pushViewController(profileVC, animated: true)
    }
}

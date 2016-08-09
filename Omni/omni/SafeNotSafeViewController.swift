//
//  SafeNotSafeViewController.swift
//  omni
//
//  Created by Sarah Zhou on 7/14/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit

class SafeNotSafeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var cancelButton =  UIButton()
    var segmentedControl = UISegmentedControl()
    var peopleTableView = UITableView()
    var notSafe: Bool?
    
//    var fromProfile: Bool?
    
    let cellReuseIdentifier = "personName"
    
    
    // [User]
    var tableData: [Neighbor] = [] {
        didSet {
            self.peopleTableView.reloadData()
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpView() {
        view.backgroundColor = UIColor.whiteColor()

        peopleTableView.frame = CGRect(x: 0, y: 0, width: Int(view.bounds.width), height: Int(view.bounds.height) - 140)
        peopleTableView.dataSource = self
        peopleTableView.delegate = self
        peopleTableView.registerClass(PersonCell.self, forCellReuseIdentifier: "personName")
        peopleTableView.rowHeight = 70

        view.addSubview(peopleTableView)
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! PersonCell
        
        cell.selectionStyle = .None

        let neighbor = tableData[indexPath.row]
        cell.nameLabel.text = neighbor.name
        if let profileImage = neighbor.profilePic{
            cell.profPic.file = profileImage
            cell.profPic.loadInBackground()
        }else{
            cell.profPic.image = UIImage(named: "default")
            cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
        }

        if notSafe == true {
            cell.phoneButton.imageView!.hidden = false
            cell.phoneButton.setImage(UIImage(named: "phoneNotSafe"), forState: .Normal)
            if let mobileNum = neighbor.mobileNum {
                cell.phoneNum = mobileNum
            } else if let workNum = neighbor.workNum {
                cell.phoneNum = workNum
            }
        } else {
            cell.phoneButton.imageView!.hidden = true
        }
        
        cell.phoneNum = neighbor.mobileNum
        
        return cell
    }
}

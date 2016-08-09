//
//  ListOfMedicsViewController.swift
//  omni
//
//  Created by Jean Adedze on 7/19/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import ParseUI
import Material

class ListOfMedicsViewController: UIViewController{
    
    var tableView: UITableView!
    private var nameOfImage = "default"
    var highPriority: Bool = true
    
    var medics: [Neighbor]!{
        didSet{
            doctors = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isDoctor()
            })
            
            nurses = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isNurse()
            })
            surgeons = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isSurgeon()
            })
            emts = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isEMT()
            })
            vets = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isVeterinarian()
            })
            lifeGuards = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isLifeGuard()
            })
            CPRs = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isCPR()
            })
            AEDs = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isAED()
            })
            firstAids = medics.filter({ (neighbor: Neighbor) -> Bool in
                return neighbor.isFirstAid()
            })
            
        }
    }
    
    //various categories of medics
    var doctors:[Neighbor] = []
    var nurses:[Neighbor] = []
    var surgeons:[Neighbor] = []
    var emts:[Neighbor] = []
    var vets:[Neighbor] = []
    var lifeGuards: [Neighbor] = []
    var CPRs: [Neighbor] = []
    var AEDs: [Neighbor] = []
    var firstAids: [Neighbor] = []
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRectMake(0, 0, view.bounds.width , view.bounds.height - 49)
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //sets up tableView
    func setupTableView(){
        tableView = UITableView()
        let frame = CGRectMake(0, 0, 375, view.bounds.height - 100)
        tableView.frame = frame
        tableView.separatorStyle = .None
        tableView.registerClass(PersonCell.self, forCellReuseIdentifier: "Med")
        tableView.registerClass(MaterialTableViewCell.self, forCellReuseIdentifier: "Head")
        tableView.rowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
    }
    
    func showNoMedLabel(cell: PersonCell, message: String){
        let frameForLabel = CGRectMake(0, 0, cell.bounds.width, cell.bounds.height)
        let label = UILabel(frame: frameForLabel)
        label.text = "No \(message) available in your neighborhood"
        label.font = label.font.fontWithSize(12)
        label.textColor = UIColor.grayColor()
        cell.addSubview(label)
    }
    
    func setupHeaderView(headerViewCell: MaterialTableViewCell, label: String ){
        
        let frameForHeader = CGRectMake(0, 0, 375, 60)
        let headerView = CardView(frame: frameForHeader)
        headerView.backgroundColor = MaterialColor.white
        headerView.cornerRadiusPreset = .None
        headerView.divider = false
        
        let frameForNameLabel = CGRectMake(5, 20, 200, 18)
        let numberOfNeighborsLabel = UILabel(frame: frameForNameLabel)
        numberOfNeighborsLabel.text = label
        numberOfNeighborsLabel.font = RobotoFont.regularWithSize(15)
        
        headerView.addSubview(numberOfNeighborsLabel)
        headerViewCell.contentView.addSubview(headerView)
    }
}

extension ListOfMedicsViewController: UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if highPriority{
            return 4
        }else{
            return 5
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if highPriority{
            if section == 0{
                if doctors.isEmpty{
                    return 1
                }
                return doctors.count
            }else if section == 1{
                if surgeons.isEmpty{
                    return 1
                }
                return surgeons.count
            }else if section == 2{
                if nurses.isEmpty{
                    return 1
                }
                return nurses.count
            }else{
                if emts.isEmpty{
                    return 1
                }
                return emts.count
            }
        }else{
            if section == 0{
                if vets.isEmpty{
                    return 1
                }
                return vets.count
            }else if section == 1{
                if lifeGuards.isEmpty{
                    return 1
                }
                return lifeGuards.count
            }else if section == 2{
                if CPRs.isEmpty{
                    return 1
                }
                return CPRs.count
            }else if section == 3 {
                if AEDs.isEmpty{
                    return 1
                }
                return AEDs.count
            }else{
                if firstAids.isEmpty{
                    return 1
                }
                return firstAids.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Med", forIndexPath: indexPath) as! PersonCell
        cell.profPic.frame = CGRectMake(10, 10, 40, 40)
        cell.profPic.layer.cornerRadius = 20
        
        cell.phoneButton.setImage(UIImage(named: "phoneUnaccounted"), forState: .Normal)
        
        cell.nameLabel.frame = CGRectMake(65, 20, 375, 25)
        cell.selectionStyle = .None
        cell.backgroundColor = MaterialColor.grey.lighten5
        if highPriority{
            if indexPath.section == 0{
                if doctors.isEmpty{
                    showNoMedLabel(cell, message: "Doctors")
                }else{
                    let doctor = doctors[indexPath.row]
                    if let picture = doctor.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage)
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = doctor.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    if let mobileNum = doctor.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = doctor.workNum {
                        cell.phoneNum = workNum
                    }
                }
            }else if indexPath.section == 1{
                if surgeons.isEmpty{
                    showNoMedLabel(cell, message: "Surgeons")
                }else{
                    let surgeon = surgeons[indexPath.row]
                    if let picture = surgeon.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage )
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = surgeon.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    if let mobileNum = surgeon.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = surgeon.workNum {
                        cell.phoneNum = workNum
                    }
                }
                
            }else if indexPath.section == 2{
                if nurses.isEmpty{
                    showNoMedLabel(cell, message: "Nurses")
                }else{
                    let nurse = nurses[indexPath.row]
                    
                    if let picture = nurse.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage )
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = nurse.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    
                    if let mobileNum = nurse.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = nurse.workNum {
                        cell.phoneNum = workNum
                    }
                }
            }else{
                if emts.isEmpty{
                    showNoMedLabel(cell, message: "EMTs")
                }else{
                    let emt = emts[indexPath.row]
                    if let picture = emt.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage )
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = emt.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    if let mobileNum = emt.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = emt.workNum {
                        cell.phoneNum = workNum
                    }
                }
            }
        }else{
            if indexPath.section == 0{
                if vets.isEmpty{
                    showNoMedLabel(cell, message: "Veterinarians")
                }else{
                    let vet = vets[indexPath.row]
                    if let picture = vet.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage )
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = vet.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    if let mobileNum = vet.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = vet.workNum {
                        cell.phoneNum = workNum
                    }
                }
                
            }else if indexPath.section == 1{
                if lifeGuards.isEmpty{
                    showNoMedLabel(cell, message: "Life Guards")
                }else{
                    let lifeguard = lifeGuards[indexPath.row]
                    if let picture = lifeguard.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage )
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = lifeguard.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    if let mobileNum = lifeguard.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = lifeguard.workNum {
                        cell.phoneNum = workNum
                    }
                }
            }else if indexPath.section == 2{
                if CPRs.isEmpty{
                    showNoMedLabel(cell, message: "CPRs")
                }else{
                    let cpr = CPRs[indexPath.row]
                    if let picture = cpr.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage )
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = cpr.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    if let mobileNum = cpr.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = cpr.workNum {
                        cell.phoneNum = workNum
                    }
                }
                
            }else if indexPath.section == 3 {
                if AEDs.isEmpty{
                    showNoMedLabel(cell, message: "AEDs")
                }else{
                    let aed = AEDs[indexPath.row]
                    if let picture = aed.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage )
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = aed.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    if let mobileNum = aed.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = aed.workNum {
                        cell.phoneNum = workNum
                    }
                }
                
            }else{
                if firstAids.isEmpty{
                    showNoMedLabel(cell, message: "First Aids")
                }else{
                    let firstaid = firstAids[indexPath.row]
                    if let picture = firstaid.profilePic{
                        cell.profPic.file = picture as PFFile
                        cell.profPic.loadInBackground()
                    }else{
                        cell.profPic.image = UIImage(named: nameOfImage )
                        cell.profPic.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    }
                    cell.nameLabel.text = firstaid.name
                    cell.nameLabel.font = RobotoFont.regularWithSize(15)
                    if let mobileNum = firstaid.mobileNum {
                        cell.phoneNum = mobileNum
                    } else if let workNum = firstaid.workNum {
                        cell.phoneNum = workNum
                    }
                }
                
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Head") as! MaterialTableViewCell
        if highPriority{
            if section == 0{
                setupHeaderView(cell, label: "Doctors")
            }else if section == 1{
                setupHeaderView(cell, label: "Surgeons")
            }else if section == 2{
                setupHeaderView(cell, label: "Nurses")
            }else{
                setupHeaderView(cell, label: "EMTs")
            }
        }else{
            if section == 0{
                setupHeaderView(cell, label: "Veterinarians")
            }else if section == 1{
                setupHeaderView(cell, label: "Lifeguards")
            }else if section == 2{
                setupHeaderView(cell, label: "CPRs")
            }else if section == 3{
                setupHeaderView(cell, label: "AED")
            }else{
                setupHeaderView(cell, label: "First Aids")
            }
        }
        return cell.contentView
    }
    
}
extension ListOfMedicsViewController: UITableViewDelegate{
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
        
    }
}

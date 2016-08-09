//
//  HomeContentCell.swift
//  omni
//
//  Created by Jean Adedze on 7/15/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Material


class HomeContentCell: MaterialTableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var homeNavigationController: UINavigationController!
    var neighbors:[Neighbor] = []{
        didSet{
            collectionView.reloadData()
        }
    }
    var label: UILabel!
    
    var collectionView: UICollectionView!
    override func prepareView() {
        super.prepareView()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(60, 60)
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 50
        flowLayout.sectionInset = UIEdgeInsetsMake(5,15,15,10)
        collectionView = UICollectionView(frame: CGRectMake(0, 0,375, 90), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = MaterialColor.grey.lighten5
        collectionView.registerClass(NeighborsFacesCell.self, forCellWithReuseIdentifier: "Face")
        collectionView.delegate = self
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        prepareLabel()
        
    }
    
    func prepareLabel(){
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 375, height: 90))
        label.backgroundColor = UIColor.whiteColor()
        label.textColor = UIColor.lightGrayColor()
        label.hidden = true
        contentView.addSubview(label)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if neighbors.count <= 10{
            return neighbors.count
        }
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Face", forIndexPath: indexPath) as! NeighborsFacesCell
        cell.layer.cornerRadius = 15
        
        
        let neighbor = neighbors[indexPath.row]
        if let profileImage = neighbor.profilePic{
            cell.profileImageView.file = profileImage
            cell.profileImageView.loadInBackground()
        }else{
            cell.profileImageView.image = UIImage(named: "default")
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let neighbor = neighbors[indexPath.row]
        let profileVC = ProfileViewController()
        profileVC.person = neighbor
        homeNavigationController.pushViewController(profileVC, animated: true)

    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

//
//  SearchNeighborsViewController.swift
//  omni
//
//  Created by Jean Adedze on 7/29/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Material

class SearchNeighborsViewController: SearchBarController {
    
    var neighborsVC : NeighborsViewController!
    var tapGestureRec = UITapGestureRecognizer()
    var allNeighbors: [Neighbor]!
    var filteredNeighbors: [Neighbor] = []
    
    /// Prepares the view.
    override func prepareView() {
        super.prepareView()
        neighborsVC = rootViewController as! NeighborsViewController

        statusBarStyle = .Default
        prepareSearchBar()
        tapGestureRec.addTarget(self, action: #selector(dismissKeyboard))
        rootViewController.view.addGestureRecognizer(tapGestureRec)
        searchBar.textField.addTarget(self, action: #selector(textFieldDidChanged), forControlEvents: .EditingChanged)
        searchBar.clearButton.addTarget(self, action: #selector(clearButtonTapped), forControlEvents: .TouchUpInside)
        //searchBar.clearButton.addTarget(self, action: Selector, forControlEvents: .TouchUpInside)
    }
    
    func dismissKeyboard(){
        searchBar.textField.resignFirstResponder()
        tapGestureRec.enabled = false
    }
    
    func clearButtonTapped(){
        neighborsVC.neighbors = allNeighbors
        neighborsVC.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Prepares the searchBar.
    private func prepareSearchBar() {
        searchBar.textField.delegate = self
    }
    
    func textFieldDidChanged(){
        
        if let searchText = searchBar.textField.text {
            filteredNeighbors = searchText.isEmpty ? allNeighbors : allNeighbors.filter({(neighbor: Neighbor) -> Bool in
                let name = neighbor.name
                return name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })            
            neighborsVC.neighbors = filteredNeighbors
            neighborsVC.tableView.reloadData()
        }
    }

}
extension SearchNeighborsViewController: TextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        rootViewController.view.alpha = 0.5
        rootViewController.view.userInteractionEnabled = true
        tapGestureRec.enabled = true
    }
    
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        rootViewController.view.alpha = 1
        rootViewController.view.userInteractionEnabled = true
    
    }
}

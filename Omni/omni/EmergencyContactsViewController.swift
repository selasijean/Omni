//
//  EmergencyContactsViewController.swift
//  omni
//
//  Created by Ming Horn on 7/21/16.
//  Copyright © 2016 Sarah Zhou. All rights reserved.
//

import UIKit
import Eureka
import Parse
import Contacts
import ContactsUI

protocol AddContactViewControllerDelegate {
    func didFetchContacts(contacts: [CNContact])
}

class EmergencyContactsViewController: FormViewController, AddContactViewControllerDelegate, CNContactPickerDelegate {

    var delegate: AddContactViewControllerDelegate!
    
    var listName: String?
    var contactSection: Form._Element!
    
    // Converts the CNContact objects from the contacts picker to the name: phone format that we need
    var contacts = [CNContact]() {
        didSet {
            let person = contacts[contacts.count - 1]
            let numbers = person.phoneNumbers
            let name = "\(person.givenName) \(person.familyName)"
            let phone = numbers[0].value as! CNPhoneNumber
            parseContacts[name] = phone.stringValue
        }
    }
    
    // Dictionary to easily manipulate contacts in this view
    var parseContacts = [String: String]()
    
    // Dictionary to save to parse, creates a dictionary that is saved within the lists array
    var saveContacts = [String: [String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: #selector(saveInfo))
        
        loadForm()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        delegate.didFetchContacts([contact])
        addPerson(contactSection)
    }
    
    func showContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        
        presentViewController(contactPickerViewController, animated: true, completion: nil)
        
    }
    
    // Loads the Eureka skeleton of the form
    func loadForm() {
        form +++ Section("New List")
            <<< NameRow("listTitle") {
                $0.placeholder = "Name of List"
                if listName != nil {
                    $0.value = listName
                }
            }
            
            +++ Section("Contacts") { section in
                self.contactSection = section
                section <<< ButtonRow() {
                    $0.title = "Add Contact"
                    $0.onCellSelection({ (cell, row) in
                        self.showContacts(cell)
                    })
                }
                
                if parseContacts.count != 0 {
                    for (key, _) in parseContacts {
                        section.append(LabelRow() {
                            $0.title = key

                        })
                        
                    }
                }
            }
            +++ Section() { section in
                section.append(ButtonRow("deleteList") { row in
                    row.title = "Delete List"
                    row.cellSetup({ (cell, row) in
                        cell.tintColor = UIColor.alizarin()
                    })
                    row.onCellSelection({ (cell, row) in
                        self.saveInfo(true)
                    })
                })
            }
    }
    
    
    // Adds the rows of contacts to the list as they're added and adds them to contacts where they're added to parseContacts
    func addPerson(section: Form._Element) {
        if contacts.count != 0 {
            
            let label = LabelRow()
            label.cellSetup({ (cell, row) in
                let person = self.contacts[self.contacts.count - 1]
                row.title = "\(person.givenName) \(person.familyName)"
            })
            
            section.append(label)
        }
        
    }
    
    // Adds the saveContacts dictionary to the lists array on Parse or deletes a list from Parse
    func saveInfo(delete: Bool) {
        let user = User.currentUser()
        let name = form.rowByTag("listTitle")?.baseValue as! String
        saveContacts = [name : parseContacts]
        var list: [[String: [String: String]]]? = user?.objectForKey("lists") as? [[String: [String: String]]]
        if list != nil {
            var index = 0
            for i in list! {
                for (key, _) in i {
                    if key == name {
                        list!.removeAtIndex(index)
                        index -= 1
                    }
                }
                index += 1
            }
            if !delete {
                list!.append(saveContacts)
            }
            
        } else {
            if !delete {
                list = [saveContacts]
            } else {
                self.backToForm()
            }
            
        }
        
        user?.setObject(list!, forKey: "lists")
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if error == nil {
                let vcs = self.navigationController?.viewControllers
                let vc = vcs![vcs!.count - 2] as! PostSignUpViewController
                vc.lists = list
                self.backToForm()
            }
        })
    }
    
    func backToForm() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func didFetchContacts(contacts: [CNContact]) {
        for contact in contacts {
            self.contacts.append(contact)
        }
        
    }
    
    
    
//  Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let name = cell?.textLabel!.text!
            
            parseContacts.removeValueForKey(name!)
            self.contactSection.removeAtIndex(indexPath.row)
            
            saveInfo(false)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    


}



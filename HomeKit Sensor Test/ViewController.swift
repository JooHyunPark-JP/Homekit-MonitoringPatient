//
//  ViewController.swift
//  HomeKit Sensor Test
//
//  Created by Xcode User on 2018-05-28.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import UIKit
import HomeKit

class ViewController: UITableViewController, HMHomeManagerDelegate {
    
    
    //HomeSections Enum for Table View Sections
    enum HomeSections: Int {
        case Homes = 0
        static let count = 2
    }
    
    //Reuse Identifiers for Custom Prototype Table View Cells
    struct Identifiers {
        static let addHomeCell = "AddHomeCell"
        static let noHomesCell = "NoHomesCell"
        static let homeCell = "HomeCell"
    }
    
    var homeStore: HomeStore {
        return HomeStore.sharedInstance
    }
    
    // MARK: HMHomeManagerDelegate methods
    
    //Tells the delegate that the home manager updated its collection of homes.
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("homeManagerDidUpdateHomes")
        tableView.reloadData()
    }
    
    //Tells the delegate that the home manager added a home.
    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        print("didAddHome \(home.name)")
    }
    
    //Tells the delegate that the home manager updated its collection of homes.
    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        print("didRemoveHome \(home.name)")
    }
    
    // MARK: UITableView helpers
    
    //method simply returns whether or not the homes count equals zero,
    func isHomesListEmpty() -> Bool {
        return homeStore.homeManager.homes.count == 0
    }
    //method returns true if the specified row in the homes section is the last row
    func isIndexPathAddHome(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == HomeSections.Homes.rawValue
            && indexPath.row == homeStore.homeManager.homes.count
    }
    
    // verify if row is editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath : IndexPath) -> Bool {
        return !isIndexPathAddHome(indexPath: indexPath as NSIndexPath)
            && !isHomesListEmpty()
            && indexPath.section == HomeSections.Homes.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        homeStore.homeManager.delegate = self
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = homeStore.homeManager.homes.count
        
        switch (section) {
        case HomeSections.Homes.rawValue:
            return count + 1
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isIndexPathAddHome(indexPath: indexPath as NSIndexPath) {
            return tableView.dequeueReusableCell(withIdentifier: Identifiers.addHomeCell, for: indexPath)
        } else if isHomesListEmpty() {
            return tableView.dequeueReusableCell(withIdentifier: Identifiers.noHomesCell, for: indexPath)
        }
        
        var reuseIdentifier: String?
        
        switch (indexPath.section) {
        case HomeSections.Homes.rawValue:
            reuseIdentifier = Identifiers.homeCell
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier!, for: indexPath) as UITableViewCell
        
        let home = homeStore.homeManager.homes[indexPath.row] as HMHome
        cell.textLabel?.text = home.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == HomeSections.Homes.rawValue {
            return "List of Homes"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == HomeSections.Homes.rawValue
        {
            return "You can delete the home swipe the each cells from right to left"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isIndexPathAddHome(indexPath: indexPath as NSIndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            onAddHomeTouched()
        } else {

            let home = homeStore.homeManager.homes[indexPath.row] as HMHome
            homeStore.homeManager.updatePrimaryHome(home, completionHandler: { error in})

            print ("\(home)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRoomSegue"{
            let avc = segue.destination as! RoomViewController
            let indexPath = tableView.indexPathForSelectedRow
            //if let accessories = HomeStore.sharedInstance.homeManager.primaryHome?.rooms[indexPath!.row].accessories {
            //    avc.accessory = accessories as [HMAccessory]
            //    print(accessories)
            //}
            let selectedHome = indexPath!.row
            avc.home = selectedHome
        }
        
        if segue.identifier == "RoomOverViewSegue"
        {
            //Write code here when needs
        }
        
    }
    /*
     func confirmDelete(home : IndexPath)
     {
     let deleteAlert = UIAlertController(title: "Delete home", message: "Are you sure you want to delete?", preferredStyle: .alert)
     deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
     deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: nil))
     deleteAlert.popoverPresentationController?.sourceView = self.view
     deleteAlert.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
     
     present(deleteAlert, animated: true, completion:nil)
     }
     */
    
    /**/
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath : IndexPath) {

        if (editingStyle == .delete) {
            let deleteAlert = UIAlertController(title: "Delete home", message: "Are you sure you want to delete?", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            let home = homeStore.homeManager.homes[indexPath.row] as HMHome
            let primaryIndexPath = NSIndexPath(row: indexPath.row, section: HomeSections.Homes.rawValue)
                    deleteAlert.addAction(UIAlertAction(title: "Delete", style: .default) {action in
                        self.homeStore.homeManager.removeHome(home, completionHandler: { error in
                            if error != nil {
                                print("Error \(String(describing: error))")
                                return
                            } else {
                                tableView.beginUpdates()
                                print ("testing");
                                if self.homeStore.homeManager.homes.count == 0 {
                                    tableView.reloadRows(at: [primaryIndexPath as IndexPath], with: UITableViewRowAnimation.fade)
                                } else {
                                    tableView.deleteRows(at: [primaryIndexPath as IndexPath], with:.automatic)
                                }
                                tableView.deleteRows(at: [indexPath], with: .automatic)
                                tableView.endUpdates()
                            }})

                    })
                    //Use this for testing
                    //deleteAlert.popoverPresentationController?.sourceView = self.view
                    //deleteAlert.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
                    self.present(deleteAlert, animated: true, completion:nil)
                
            
        }
    }
    
    //On success, the table view is refreshed, and the new home appears in the list. If the home is the first home, it’s assigned as the primary home
    private func onAddHomeTouched() {
        
        let controller = UIAlertController(title: "Add Home", message: "Enter a name for the home", preferredStyle: .alert)
        
        controller.addTextField(configurationHandler: { textField in
            textField.placeholder = "My House"
        })
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        controller.addAction(UIAlertAction(title: "Add Home", style: .default) { action in
            
            let textFields = controller.textFields as [UITextField]?
            if let homeName = textFields![0].text {
                
                if homeName.isEmpty {
                    let alert = UIAlertController(title: "Error", message: "Please enter a name", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.homeStore.homeManager.addHome(withName: homeName, completionHandler: { home, error in
                        if error != nil {
                            print("failed to add new home. \(String(describing: error))")
                        } else {
                            print("added home \(home!.name)")
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
        present(controller, animated: true, completion: nil)
    }
    
    
}


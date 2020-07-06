//
//  RoomViewController.swift
//  HomeKit Sensor Test
//
//  Created by Xcode User on 2018-05-29.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import UIKit
import HomeKit

class RoomViewController: UITableViewController, HMHomeManagerDelegate {
    
    var home = 0;
    var selectedhome: HMHome {
        return (homeStore.homeManager.homes[home])
    }
    //HomeSections Enum for Table View Sections
    enum RoomSections: Int {
        case Rooms = 0
        static let count = 2
    }
    
    //Reuse Identifiers for Custom Prototype Table View Cells
    struct Identifiers {
        static let addRoomCell = "AddRoomCell"
        static let noRoomCell = "NoRoomCell"
        static let roomCell = "RoomCell"
    }
    
    var homeStore: HomeStore {
        return HomeStore.sharedInstance
    }
    
    // Passes Selected Accessory to AccessoryViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoomAccessorySegue"{
        let avc = segue.destination as! AccessoryViewController
        let indexPath = tableView.indexPathForSelectedRow
        //if let accessories = HomeStore.sharedInstance.homeManager.primaryHome?.rooms[indexPath!.row].accessories {
        //    avc.accessory = accessories as [HMAccessory]
        //    print(accessories)
        //}
        let selectedRoom = indexPath!.row
        avc.room = selectedRoom
        }
        
        if segue.identifier == "homeOverViewSegue"
        {
            //Write code here when needs
        }
        
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
    func isRoomsListEmpty() -> Bool {
        return homeStore.homeManager.primaryHome?.rooms.count == 0
    }
    //method returns true if the specified row in the homes section is the last row
    func isIndexPathAddRoom(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == RoomSections.Rooms.rawValue
            && indexPath.row == homeStore.homeManager.primaryHome?.rooms.count
    }
    
    // verify if row is editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath : IndexPath) -> Bool {
        return !isIndexPathAddRoom(indexPath: indexPath as NSIndexPath)
            && !isRoomsListEmpty()
            && indexPath.section == RoomSections.Rooms.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        homeStore.homeManager.delegate = self
        title = ("\(selectedhome.name)") + " Rooms"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return RoomSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = homeStore.homeManager.primaryHome?.rooms.count
        switch (section) {
        case RoomSections.Rooms.rawValue:
            return count! + 1
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isIndexPathAddRoom(indexPath: indexPath as NSIndexPath) {
            return tableView.dequeueReusableCell(withIdentifier: Identifiers.addRoomCell, for: indexPath)
        } else if isRoomsListEmpty() {
            return tableView.dequeueReusableCell(withIdentifier: Identifiers.noRoomCell, for: indexPath)
        }
        
        var reuseIdentifier: String?
        
        switch (indexPath.section) {
        case RoomSections.Rooms.rawValue:
            reuseIdentifier = Identifiers.roomCell
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier!, for: indexPath) as UITableViewCell
        
        let room = homeStore.homeManager.primaryHome!.rooms[indexPath.row]
        cell.textLabel?.text = room.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == RoomSections.Rooms.rawValue {
            return "List of Rooms"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == RoomSections.Rooms.rawValue
        {
            return "You can delete the home swipe the each cells from right to left"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isIndexPathAddRoom(indexPath: indexPath as NSIndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            onAddHomeTouched()
            
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
             let deleteAlert = UIAlertController(title: "Delete room", message: "Are you sure you want to delete?", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            let room = homeStore.homeManager.primaryHome?.rooms[indexPath.row] as! HMRoom
            let primaryIndexPath = NSIndexPath(row: indexPath.row, section: RoomSections.Rooms.rawValue)
                    deleteAlert.addAction(UIAlertAction(title: "Delete", style: .default) {action in
                        self.homeStore.homeManager.primaryHome?.removeRoom(room, completionHandler: { error in
                            if error != nil {
                                print("Error \(String(describing: error))")
                                return
                            }else{
                                tableView.beginUpdates()
                                
                                if self.homeStore.homeManager.primaryHome?.rooms.count == 0 {
                                    tableView.reloadRows(at: [primaryIndexPath as IndexPath], with: UITableViewRowAnimation.fade)
                                } else {
                                    tableView.deleteRows(at: [primaryIndexPath as IndexPath], with:.automatic)
                                }
                                tableView.deleteRows(at: [indexPath], with: .automatic)
                                tableView.endUpdates()
                            } })
                    })
                    //Use this for testing
                    //deleteAlert.popoverPresentationController?.sourceView = self.view
                    //deleteAlert.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
                    self.present(deleteAlert, animated: true, completion:nil)
            
            
        }
    }
    
    //On success, the table view is refreshed, and the new home appears in the list. If the home is the first home, it’s assigned as the primary home
    private func onAddHomeTouched() {
        
        let controller = UIAlertController(title: "Add Room", message: "Enter a name for the room", preferredStyle: .alert)
        
        controller.addTextField(configurationHandler: { textField in
            textField.placeholder = "Office"
        })
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        controller.addAction(UIAlertAction(title: "Add Room", style: .default) { action in
            
            let textFields = controller.textFields as [UITextField]?
            if let roomName = textFields![0].text {
                
                if roomName.isEmpty {
                    let alert = UIAlertController(title: "Error", message: "Please enter a name", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.homeStore.homeManager.primaryHome?.addRoom(withName: roomName, completionHandler: { room, error in
                        if error != nil {
                            print("failed to add new room. \(String(describing: error))")
                        } else {
                            print("added room \(room!.name)")
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
        present(controller, animated: true, completion: nil)
    }
    
    
}

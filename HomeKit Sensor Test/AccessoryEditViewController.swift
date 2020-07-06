//
//  AccessoryEditViewController.swift
//  HomeKit Sensor Test
//
//  Created by Xcode User on 2018-05-31.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import Foundation

import UIKit
import HomeKit

class AccessoryEditViewController: UITableViewController, HMHomeDelegate, HMAccessoryDelegate {
    
    var homeStore: HomeStore {
        return HomeStore.sharedInstance
    }
    var home: HMHome! {
        return homeStore.home
    }
    
    var room: HMRoom? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        home?.delegate = self
        
        NotificationCenter.default.addObserver(self,selector: #selector(updateAccessories),name: NSNotification.Name(HomeStore.Notification.AddAccessoryNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: HMHomeDelegate methods
    
    //he table view is updated when changes are made by other HomeKit apps
    func home(_ home: HMHome, didAdd accessory: HMAccessory) {
        print("didAddAccessory \(accessory.name)")
        tableView.reloadData()
    }
    
    func home(_ home: HMHome, didRemove accessory: HMAccessory) {
        print("didRemoveAccessory \(accessory.name)")
        tableView.reloadData()
    }
    
    @objc func updateAccessories() {
        print("updateAccessories selector called from NotificationCenter")
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if room?.accessories.count == 0 {
            setBackgroundMessage(message: "No Accessories Found")
        } else {
            setBackgroundMessage(message: nil)
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room!.accessories.count
    }
    
    //Setting up a Table Cell for an Accessory
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath : IndexPath) -> UITableViewCell {
        
        
        let accessory = room?.accessories[indexPath.row];
        let reuseIdentifier = "AccessoryCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = accessory?.name
        
        let accessoryName = accessory?.name
        let roomName = accessory?.room!.name
        let inIdentifier = NSLocalizedString("%@ in %@", comment: "Accessory in Room")
        cell.detailTextLabel?.text = String(format: inIdentifier, accessoryName!, roomName!)
        return cell
        
    }
    
    //Returning a Header for a Specified Section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return room?.accessories.count != 0 ? "List of Accessories" : ""
        }
        return nil
        
    }
    
    //Verify That the Given Row Is Editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath : IndexPath) -> Bool {
        //if indexPath.section == 1 {
        //    return true
        //}
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editAccessoryName(index: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath : IndexPath) {
        
        if (editingStyle == .delete) {
            
            let accessory = room?.accessories[indexPath.row]
            homeStore.homeManager.primaryHome!.removeAccessory(accessory!, completionHandler: { error in
                if error != nil {
                    print("Error \(String(describing: error))")
                    self.present(self, animated: error! as! Bool)
                } else {
                    tableView.beginUpdates()
                    let rowAnimation = self.room?.accessories.count == 0 ? UITableViewRowAnimation.fade : UITableViewRowAnimation.automatic
                    tableView.deleteRows(at: [indexPath], with: rowAnimation)
                    tableView.endUpdates()
                    tableView.reloadData()
                }
            })
        }
    }
    
    private func setBackgroundMessage(message: String?) {
        if let message = message {
            let label = UILabel()
            label.text = message
            label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            label.textColor = UIColor.lightGray
            label.textAlignment = .center
            label.sizeToFit()
            tableView.backgroundView = label
            tableView.separatorStyle = .none
        }
        else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
    
    private func editAccessoryName(index: Int) {
        
        let controller = UIAlertController(title: "Edit Name", message: "Enter a name for the Accessory", preferredStyle: .alert)
        
        controller.addTextField(configurationHandler: { textField in
            textField.placeholder = "\((self.room?.accessories[index].name)!)"
        })
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        controller.addAction(UIAlertAction(title: "Save", style: .default) { action in
            
            let textFields = controller.textFields as [UITextField]?
            if let accessoryName = textFields![0].text {
                
                if accessoryName.isEmpty {
                    let alert = UIAlertController(title: "Error", message: "Please enter a name", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.room?.accessories[index].updateName(accessoryName, completionHandler: { (error) in
                        if error != nil {
                            print("failed to edit Accessory Name. \(String(describing: error))")
                        } else {
                            print("Changed Name to \((self.room?.accessories[index].name)!)")
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
        present(controller, animated: true, completion: nil)
    }
    
}

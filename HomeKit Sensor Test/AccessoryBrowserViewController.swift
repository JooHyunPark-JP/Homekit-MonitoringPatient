//
//  AccessoryBrowserViewController.swift
//  HomeKit Sensor Test
//
//  Created by Xcode User on 2018-05-30.
//  Copyright © 2018 Xcode User. All rights reserved.
//
import Foundation
import HomeKit

class AccessoryBrowserViewController: UITableViewController, HMAccessoryBrowserDelegate, HMHomeManagerDelegate {
    
    @IBOutlet weak var addAccessoryLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    struct Notification {
        static let AddAccessoryNotification = "AddAccessoryNotification"
    }
    
    let homeManager = HMHomeManager()
    let browser = HMAccessoryBrowser()
    var accessories = [HMAccessory]()
    var room: HMRoom? = nil
    
    override func viewDidLoad() {
        // The delegate will inform us about accessory activity (discovered / lost)
        browser.delegate = self
        
        // Immediately start the discovery process
        browser.startSearchingForNewAccessories()
        tableView.reloadData()
        addAccessoryLabel.text = "Browsing for New Accessories..."
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Stops the discovery process
        browser.stopSearchingForNewAccessories()
    }
    
    // MARK: - Table
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accessories.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if accessories.count  == 0{
            setBackgroundMessage(message: "No Accessories Found")
            return ("")
        } else {
            setBackgroundMessage(message: nil)
            return ("Accessories Found")
        }
    }
    
    // Adds discovered accessories to tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath : IndexPath) -> UITableViewCell {
        let accessory = accessories[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccessoryBrowserCell", for: indexPath as IndexPath)
        cell.textLabel?.text = accessory.name
        cell.detailTextLabel?.text = accessory.category.localizedDescription
        return cell
    }
    // Selected accessory is added to primary home and first room
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let accessory = accessories[indexPath.row]
        //let room: HMRoom = (homeManager.primaryHome?.rooms.first)!
        
        addAccessoryLabel.text = "        Adding New Accessory..."
        activityIndicator.isHidden = false
        
        homeManager.primaryHome?.addAccessory(accessory, completionHandler: { error in
            if error != nil {
                self.addAccessoryLabel.text = "Browsing for New Accessories..."
                print("Something went wrong when attempting to add an accessory to our home. \(String(describing: error?.localizedDescription))")
            } else {
                print("Successfully added \(accessory.name) to \(String(describing: self.homeManager.primaryHome?.name)).")
                
                NotificationCenter.default.post(name: NSNotification.Name(Notification.AddAccessoryNotification), object: nil)
                
                self.homeManager.primaryHome?.assignAccessory(accessory, to: self.room!, completionHandler: { error in
                    if error != nil {
                        print("Something went wrong when attempting to add an accessory to our room. \(String(describing: error?.localizedDescription))")
                    } else {
                        print("Successfully added \(accessory.name) to \(self.room?.name).")
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        })
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
    
    // MARK: - Accessory Delegate
    
    // Informs us when we've located a new accessory in the home
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        accessories.append(accessory)
        tableView.reloadData()
    }
    
    // Inform us when a device has been removed
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        var index = 0
        for item in accessories {
            if item.name == accessory.name {
                accessories.remove(at: index)
                break;
            }
            index += 1
        }
        tableView.reloadData()
    }
}

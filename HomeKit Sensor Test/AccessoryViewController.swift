//
//  AccessoryViewController.swift
//  HomeKit Sensor Test
//
//  Created by Xcode User on 2018-05-29.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import UIKit
import HomeKit

class AccessoryViewController: UITableViewController, HMHomeDelegate, HMAccessoryDelegate {
    
    struct Identifiers {
        static let CharacteristicCell = "CharacteristicCell"
        static let ServiceCell = "ServiceCell"
        static let SliderCell = "SliderCell"
        static let SegmentedCell = "SegmentedCell"
    }
    // Data Formatter
    let formatter = DateFormatter()
    var currentDate: String = ""
    
    // String Array to Convert to JSON
    var array = [String]()
    
    var homeStore: HomeStore {
        return HomeStore.sharedInstance
    }
    var home: HMHome! {
        return homeStore.home
    }
    
    var room = 0
    
    var selectedRoom: HMRoom {
        return (homeStore.homeManager.primaryHome?.rooms[room])!
    }
    
    var selectedHome: HMHome {
        return (homeStore.homeManager.primaryHome)!
    }
    
    var accessories: [HMAccessory] {
        return (selectedHome.accessories)
    }
    
    var data = [HMService]()
    
    var database = AccessoryDatabase()
    
    var sensorCount = 0
    
    var accessory = [HMAccessory]() {
        didSet {
            for num in 0..<accessory.count {
                accessory[num].delegate = self
            }
        }
    }
    
    // Passes Selected Accessory to AccessoryBrowserViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAccessorySegue" {
            let abvc = segue.destination as! AccessoryBrowserViewController
            abvc.room = selectedRoom
        }
        if segue.identifier == "editAccessorySegue" {
            let aevc = segue.destination as! AccessoryEditViewController
            aevc.room = selectedRoom
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delete Database
        //database.deleteDatabase()
        // Create Table
        database.createTable()
        // Initialize sensorCount
        //sensorCount = database.retrieveCount(select: accessory.name, count: sensorCount)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        
        home?.delegate = self
        data = [HMService]()
        accessory = accessories
        for num in 0..<accessory.count {
            for service in accessory[num].services as [HMService] {
                if service.serviceType == HMServiceTypeAccessoryInformation{
                    data.insert(service, at: 0)
                } else {
                    data.append(service)
                }
            }
        }
        enableNotifications(enable: true)
        title = selectedRoom.name + " Accessories"
        //NotificationCenter.default.addObserver(self,selector: #selector(updateAccessories),name: NSNotification.Name(HomeStore.Notification.AddAccessoryNotification), object: nil)
        tableView.reloadData()
        //Retrieve all from database
        //array = database.retrieveAll()
        
        let printJSON = json(from:array as Any)!
        let printJSON2 = printJSON.replacingOccurrences(of: "\\", with: "")
        let printJSON3 = printJSON2.replacingOccurrences(of: "\"{", with: "{")
        let printJSON4 = printJSON3.replacingOccurrences(of: "}\"", with: "}")
        //print(printJSON4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Enable notification for each accessory service characteristics
    private func enableNotifications(enable: Bool) {
        for service in data {
            for characteristic in service.characteristics {
                if characteristic.properties.contains(HMCharacteristicPropertySupportsEventNotification) {
                    characteristic.enableNotification(enable, completionHandler: { error in
                        if let error = error {
                            print("Failed to enable notifications for \(characteristic): \(error.localizedDescription)")
                        }
                    })
                }
            }
        }
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
    // TableView number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedRoom.accessories.count == 0 {
            setBackgroundMessage(message: "No Accessories Found")
            return 0
        } else {
            setBackgroundMessage(message: nil)
            return data.count
        }
    }
    // TableView Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].characteristics.count
    }
    
    //Setting up a Table Cell for an Accessory
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath : IndexPath) -> UITableViewCell {
        
        var reuseIdentifier = Identifiers.CharacteristicCell
        
        let characteristic = data[indexPath.section].characteristics[indexPath.row]
        
        if characteristic.isReadOnly || characteristic.isWriteOnly {
            reuseIdentifier = Identifiers.CharacteristicCell
        }
            
        else if characteristic.isBoolean {
            reuseIdentifier = Identifiers.ServiceCell
        }
            
        else if characteristic.hasValueDescriptions {
            reuseIdentifier = Identifiers.SegmentedCell
        }
            
        else if characteristic.isNumeric {
            reuseIdentifier = Identifiers.SliderCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? CharacteristicCell {
            cell.characteristic = characteristic
        }
        
        return cell
    }
    
    //Returning a Header for a Specified Section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].name
    }
    
    //Verify That the Given Row Is Editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath : IndexPath) -> Bool {
        return false
    }
    // TableView for deleting
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath : IndexPath) {
        
        if (editingStyle == .delete) {
            
            let accessory = homeStore.homeManager.primaryHome!.accessories[indexPath.row]
            homeStore.homeManager.primaryHome!.removeAccessory(accessory, completionHandler: { error in
                if error != nil {
                    print("Error \(String(describing: error))")
                    self.present(self, animated: error! as! Bool)
                } else {
                    tableView.beginUpdates()
                    let rowAnimation = self.homeStore.homeManager.primaryHome!.accessories.count == 0 ? UITableViewRowAnimation.fade : UITableViewRowAnimation.automatic
                    tableView.deleteRows(at: [indexPath], with: rowAnimation)
                    tableView.endUpdates()
                    tableView.reloadData()
                }
            })
        }
    }
    // No Accessory Found Background Message
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
    // Accessory Delegate to update values
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        currentDate = formatter.string(from: Date())
        var value = characteristic.value as? Double
        if value == nil {
            value = 0.0
        }
        database.insertRow(name: accessory.name, home: selectedHome.name, room: (accessory.room?.name)!,sensorType: service.localizedDescription, sensorValue: Double(value!), date: "\(currentDate)")
        tableView.reloadData()
        uploadData()
    }
    // Convert String Array to JSON
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    // Uploads last row from database to server
    func uploadData(){
        array = database.retrieveLast()
        guard let uploadData = try? JSONEncoder().encode(array) else {
            return
        }
        //let url = URL(string: "http://smarthome.fast.sheridanc.on.ca/HomeKitTest/uploadAccessoryData.php/post")!
        let url = URL(string: "http://Fasts-MacBook-Pro-2.local:8888/uploadAccessoryData.php/post")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(response.statusCode)")
                print("response = \(response)")
            }
            
            if let mimeType = response?.mimeType,
                mimeType == "application/json",
                let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
        }
        task.resume()
    }
    
}

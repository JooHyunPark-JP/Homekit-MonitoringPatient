//
//  CharacteristicCell.swift
//  HomeKit Sensor Test
//
//  Created by Xcode User on 2018-05-31.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import Foundation

import HomeKit
import UIKit

class CharacteristicCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    var characteristic: HMCharacteristic! {
        didSet {
            var desc = characteristic.localizedDescription
            if characteristic.isReadOnly {
                desc = desc + ":"
            } else if characteristic.isWriteOnly {
                desc = desc + ":"
            }
            typeLabel?.text = desc
            valueLabel?.text = "No Value"
            
            setValue(newValue: characteristic.value as AnyObject, notify: false)
            
            selectionStyle = characteristic.characteristicType == HMCharacteristicTypeIdentify ? .default : .none
            
            if characteristic.isWriteOnly {
                return
            }
            
            if reachable {
                characteristic.readValue { error in
                    if let error = error {
                        print("Error reading value for \(self.characteristic): \(error)")
                    } else {
                        self.setValue(newValue: self.characteristic.value as AnyObject, notify: false)
                    }
                }
            }
        }
    }
    
    var value: AnyObject?
    
    var reachable: Bool {
        return (characteristic.service?.accessory?.isReachable ?? false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setValue(newValue: AnyObject?, notify: Bool) {
        self.value = newValue
        if let value = self.value {
            self.valueLabel?.text = self.characteristic.descriptionForValue(value: value)
        }
        
        if notify {
            self.characteristic.writeValue(self.value, completionHandler: { error in
                if let error = error {
                    print("Failed to write value for \(self.characteristic): \(error.localizedDescription)")
                }
            })
        }
    }
    
}

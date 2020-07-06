//
//  ServiceCell.swift
//  HomekitDemo
//
//  Created by Xcode User on 2018-04-04.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import Foundation
import HomeKit
import UIKit

class ServiceCell: CharacteristicCell {
    
    @IBOutlet weak var powerSwitch: UISwitch!
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        setValue(newValue: powerSwitch.isOn as AnyObject, notify: true)
    }
    
    override var characteristic: HMCharacteristic! {
        didSet {
            powerSwitch.isUserInteractionEnabled = reachable
        }
    }
    
    override func setValue(newValue: AnyObject?, notify: Bool) {
        super.setValue(newValue: newValue, notify: notify)
        if let newValue = newValue as? Bool, !notify {
            powerSwitch.setOn(newValue, animated: true)
        }
    }
}

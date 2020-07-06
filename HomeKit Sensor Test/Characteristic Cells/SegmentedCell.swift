//
//  SegmentedCell.swift
//  HomekitDemo
//
//  Created by Xcode User on 2018-04-04.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import Foundation
import HomeKit
import UIKit

class SegmentedCell: CharacteristicCell {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        let value = titleValues[segmentedControl.selectedSegmentIndex]
        setValue(newValue: value as AnyObject, notify: true)
    }
    
    var titleValues = [Int]() {
        didSet {
            segmentedControl.removeAllSegments()
            for index in 0..<titleValues.count {
                let value: AnyObject = titleValues[index] as AnyObject
                let title = self.characteristic.descriptionForValue(value: value)
                segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            }
        }
    }
    
    override var characteristic: HMCharacteristic! {
        didSet {
            segmentedControl.isUserInteractionEnabled = reachable
            
            if let values = self.characteristic.allValues as? [Int] {
                titleValues = values
            }
        }
    }
    
    override func setValue(newValue: AnyObject?, notify: Bool) {
        super.setValue(newValue: newValue, notify: notify)
        if !notify {
            if let intValue = value as? Int, let index = titleValues.index(of: intValue) {
                segmentedControl.selectedSegmentIndex = index
            }
        }
    }
    
}

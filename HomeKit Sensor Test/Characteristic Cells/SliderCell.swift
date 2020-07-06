//
//  SliderCell.swift
//  HomekitDemo
//
//  Created by Xcode User on 2018-04-04.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import Foundation
import HomeKit
import UIKit

class SliderCell: CharacteristicCell {
    
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = roundedValueForSliderValue(value: slider.value)
        setValue(newValue: value as AnyObject, notify: true)
    }
    
    override var characteristic: HMCharacteristic! {
        didSet {
            slider.isUserInteractionEnabled = reachable
        }
        
        willSet {
            slider.minimumValue = newValue.metadata?.minimumValue as? Float ?? 0.0
            slider.maximumValue = newValue.metadata?.maximumValue as? Float ?? 100.0
        }
    }
    
    override func setValue(newValue: AnyObject?, notify: Bool) {
        super.setValue(newValue: newValue, notify: notify)
        if let newValue = newValue as? NSNumber, !notify {
            slider.value = newValue.floatValue
        }
    }
    
    private func roundedValueForSliderValue(value: Float) -> Float {
        if let metadata = characteristic.metadata,
            let stepValue = metadata.stepValue as? Float, stepValue > 0 {
            let newValue = roundf(value / stepValue)
            let stepped = newValue * stepValue
            return stepped
        }
        return value
    }
}

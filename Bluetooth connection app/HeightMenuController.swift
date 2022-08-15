//
//  HeightMenu.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 07.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation
import AppKit

class HeightMenuController: NSViewController {
    
    private var popover = NSPopover()
    static private var vcIdentifier = "HeightMenu"
    private var button: NSButton?
    @IBOutlet weak var maxHeightTF: NSTextField!
    @IBOutlet weak var minHeightTF: NSTextField!
    @IBOutlet weak var applyButton: NSButton!
    
//    init(nextTo button: NSButton) {
//        self.popover = NSPopover()
//        self.button = button
//
//        let onlyIntegerInHeightsRangeFormatter = OnlyIntegerInHeightsRangeFormatter()
//        maxHeightTF.formatter = onlyIntegerInHeightsRangeFormatter
//        minHeightTF.formatter = onlyIntegerInHeightsRangeFormatter
//    }
    
    class func loadFromNib(nextTo button: NSButton) -> HeightMenuController {
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: Self.vcIdentifier) as! HeightMenuController
        vc.button = button
        vc.popover.contentViewController = vc
        return vc
    }
            
    override func viewDidLoad() {
        popover.behavior = .transient

        let onlyIntegerInHeightsRangeFormatter = OnlyIntegerInHeightsRangeFormatter()
        maxHeightTF.formatter = onlyIntegerInHeightsRangeFormatter
        minHeightTF.formatter = onlyIntegerInHeightsRangeFormatter
    }
    
    @objc func togglePopover() {
        if !popover.isShown {
            showPopover()
        } else {
            hidePopover()
        }
    }
    
    private func showPopover() {
        guard let button = button else {
            return
        }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)

    }
    
    private func hidePopover() {
        popover.close()
    }
    
    @IBAction func maxHeightTextFieldOutOfFocus(_ sender: Any) {
        keepInRange(textField: maxHeightTF)
    }
    
    @IBAction func minHeightTextFieldOutOfFocus(_ sender: Any) {
        keepInRange(textField: minHeightTF)
    }
    
    func keepInRange(textField: NSTextField) {
        
        let minHeight = HeightService.shared.minMaxHeight?.min ?? Constants.defaultHeightRange.min
        let maxHeight = HeightService.shared.minMaxHeight?.max ?? Constants.defaultHeightRange.max
        
        if textField.integerValue < minHeight {
            textField.integerValue = minHeight
        }
        
        if textField.integerValue > maxHeight {
            textField.integerValue = maxHeight
        }
    }
}

class OnlyIntegerInHeightsRangeFormatter: NumberFormatter {
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: partialString)) {
            return true
        }
        
        return false
    }
}


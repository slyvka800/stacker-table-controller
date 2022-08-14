//
//  HeightMenu.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 07.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation
import AppKit

class HeightMenuController {
    
    private var popover: NSPopover
    private var vcIdentifier = "HeightMenu"
    private var button: NSButton
    @IBOutlet weak var maxHeight: NSTextField!
    @IBOutlet weak var minHeight: NSTextField!
    @IBOutlet weak var applyButton: NSButton!
    
    init(nextTo button: NSButton) {
        self.popover = NSPopover()
        self.button = button
    }
    
    @objc func togglePopover() {
        if !popover.isShown {
            showPopover()
        } else {
            hidePopover()
        }
    }
    
    func showPopover() {
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: vcIdentifier) as! NSViewController
        popover.contentViewController = vc
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        popover.behavior = .transient
    }
    
    func hidePopover() {}
}

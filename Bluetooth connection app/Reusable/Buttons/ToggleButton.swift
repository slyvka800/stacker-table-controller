//
//  ToggleButton.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 06.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Cocoa

class ToggleButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        if self.state == .on {
            self.highlight(true)
        } else {
            self.highlight(false)
        }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
        
        super.draw(dirtyRect)
    }
    
    override func mouseEntered(with event: NSEvent) {
        if state == .on {
            self.alphaValue = 1
        } else {
            self.alphaValue = 0.8
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        self.alphaValue = 1
    }
    
}

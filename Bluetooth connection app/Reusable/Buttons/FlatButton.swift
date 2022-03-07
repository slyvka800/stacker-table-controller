//
//  FlatButton.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 06.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Cocoa

class FlatButton: NSButton {
    
    @IBInspectable var cornerRadius: CGFloat = 5
    @IBInspectable var bgColor: NSColor = .blue
    @IBInspectable var foreColor: NSColor = .white

    override func draw(_ dirtyRect: NSRect) {
        if self.isHighlighted {
            self.layer?.backgroundColor =  bgColor.blended(withFraction: 0.2, of: .black)?.cgColor
        } else {
            self.layer?.backgroundColor = bgColor.cgColor
        }
        self.layer?.cornerRadius = cornerRadius
        let attrString = NSAttributedString(string: "Height", attributes: [NSAttributedString.Key.foregroundColor: foreColor])
        self.attributedTitle = attrString

        super.draw(dirtyRect)
    }
    
}

//
//  CustomizablePopover.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 07.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Cocoa

@IBDesignable class CustomizablePopover: ReusableView {
    @IBInspectable var popoverBackgroundColor: NSColor?
    var backgroundView:PopoverBackgroundView?
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let frameView = self.window?.contentView?.superview {
            if backgroundView == nil {
                backgroundView = PopoverBackgroundView(frame: frameView.bounds)
                backgroundView?.bgColor = popoverBackgroundColor
                backgroundView!.autoresizingMask = NSView.AutoresizingMask([.width, .height]);
                frameView.addSubview(backgroundView!, positioned: NSWindow.OrderingMode.below, relativeTo: frameView)
            }
        }
    }
}

class PopoverBackgroundView: NSView {
    var bgColor: NSColor?
    
    override func draw(_ dirtyRect: NSRect) {
//        init(displayP3Red: 0.471, green: 0.486, blue: 0.659, alpha: 1)
        bgColor?.set()
        self.bounds.fill()
    }
}

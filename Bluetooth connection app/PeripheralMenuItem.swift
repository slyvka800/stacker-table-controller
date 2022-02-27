//
//  PeripheralMenuItem.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 08.12.2021.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa

class PeripheralMenuItem: NSCollectionViewItem {
    @IBOutlet var peripheralNameLabel: NSTextField!
    @IBOutlet var peripheralConnectionStatus: ReusableView!
    
    var menuController: MenuControllerDelegate?
    
    static let reuseIdentfier = NSUserInterfaceItemIdentifier("PeripheralMenuItem")
    
    override var isSelected: Bool {
        didSet {
            print(oldValue)
            print(isSelected)
            maanageSelectedState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
//        self.collectionView?.isSelectable = true
//        self.collectionView?.allowsEmptySelection = true
//        self.collectionView?.allowsMultipleSelection = false
    }
    
    private func maanageSelectedState() {
        print(isSelected)
        if !isSelected {
            guard let indexPath = self.collectionView?.indexPath(for: self) else { return }
            menuController?.selectedMenuItem(indexPath: indexPath)
        }
    }
    
}

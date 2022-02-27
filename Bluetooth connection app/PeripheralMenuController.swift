//
//  PeripheralMenuController.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 08.12.2021.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa
import CoreBluetooth

protocol MenuControllerDelegate{
    func selectedMenuItem(indexPath: IndexPath)
}

extension ViewController: NSCollectionViewDataSource, NSCollectionViewDelegate, MenuControllerDelegate {
    
    func setupCollectionView() {
        peripheralsMenuCollectionView.isSelectable = true
        peripheralsMenuCollectionView.allowsEmptySelection = true
        peripheralsMenuCollectionView.allowsMultipleSelection = false
        peripheralsMenuCollectionView.register(PeripheralMenuItem.self, forItemWithIdentifier: PeripheralMenuItem.reuseIdentfier)
        peripheralsMenuCollectionView.delegate = self
        peripheralsMenuCollectionView.dataSource = self
        
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return foundPeripherals.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let menuItem = collectionView.makeItem(withIdentifier: PeripheralMenuItem.reuseIdentfier, for: indexPath) as! PeripheralMenuItem
        let setIndex = foundPeripherals.index(foundPeripherals.startIndex, offsetBy: indexPath.item)
        
        if foundPeripherals.indices.contains(setIndex) {
            menuItem.peripheralNameLabel.stringValue = foundPeripherals[setIndex].name ?? "unknown"
            menuItem.menuController = self
            if foundPeripherals[setIndex] != peripheral {
                menuItem.peripheralConnectionStatus.isHidden = true
            }
        }
        return menuItem
    }
    
    func selectedMenuItem(indexPath: IndexPath) {
        print("kek")
        guard let selectedPeripheral = getFoundPeripheral(index: indexPath.item)
        else { return }
        print(selectedPeripheral.name)
        centralManager.connect(selectedPeripheral, options: nil)
    }
    
    func toggleConnectionIndicator(peripheral: CBPeripheral, isConnected: Bool) {
        let numOfSections = peripheralsMenuCollectionView.numberOfSections
        
        (0..<numOfSections).forEach { aSection in
            (0..<peripheralsMenuCollectionView.numberOfItems(inSection: aSection)).forEach { anItem in
                let indexPath = IndexPath(item: anItem, section: aSection)
                if let item = peripheralsMenuCollectionView.item(at: indexPath), let castedItem = item as? PeripheralMenuItem {
                    castedItem.peripheralConnectionStatus.isHidden = !isConnected
                }
            }
        }
        
    }
}

//extension NSTableView {
//    open override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
//        return true
//    }
//}

class KEK: NSTableView {
    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        return true
    }
}
